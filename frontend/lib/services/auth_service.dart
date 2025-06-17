import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../models/login_response.dart';
import '../models/register_response.dart';

class AuthService {
  final String baseUrl;
  final FlutterSecureStorage _storage;
  
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _expiryTimeKey = 'token_expiry';
  static const String _userKey = 'user_data';
  
  static const Duration _requestTimeout = Duration(seconds: 10);

  static const Duration _tokenValidity = Duration(hours: 1);
  
  String? _cachedToken;
  User? _cachedUser;
  DateTime? _cachedTokenExpiry;
  
  AuthService({
    required this.baseUrl,
    FlutterSecureStorage? storage,
  }) : _storage = storage ?? const FlutterSecureStorage();

  Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      return token != null;
    } catch (e) {
      debugPrint('Erreur lors de la vérification de la connexion: $e');
      return false;
    }
  }

  Future<LoginResponse> login(String email, String password) async {
    final fullUrl = '$baseUrl/api/auth/login';
    
    try {
      final response = await http.post(
        Uri.parse(fullUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim(), 
          'password': password,
        }),
      ).timeout(_requestTimeout);

      if (response.statusCode == 200) {
        return _handleSuccessfulLogin(response);
      } else {
        return _handleFailedLogin(response);
      }
    } catch (e) {
      debugPrint('Exception lors de la connexion: $e');
      return LoginResponse(
        success: false,
        token: null,
        refreshToken: null,
        user: null,
        errorMessage: e is http.ClientException 
            ? 'Problème de connexion réseau'
            : 'Erreur de connexion: ${e.toString()}',
      );
    }
  }

  Future<LoginResponse> _handleSuccessfulLogin(http.Response response) async {

    final Map<String, dynamic> responseData = json.decode(response.body);
    final String token = responseData['token'] as String;
    final String? refreshToken = responseData['refresh_token'] as String?;
    User? user;
    try {
      if (responseData.containsKey('user')) {
        final userData = responseData['user'] as Map<String, dynamic>;
        user = User.fromJson(userData);
        _cachedUser = user;  
        await _storage.write(key: _userKey, value: jsonEncode(userData));
      }
    } catch (e) {
      debugPrint('Erreur lors du traitement des données utilisateur: $e');
    }

    final expiryTime = DateTime.now().add(_tokenValidity);
    _cachedTokenExpiry = expiryTime;  
    _cachedToken = token;  
    
    await Future.wait([
      _storage.write(key: _tokenKey, value: token),
      _storage.write(key: _expiryTimeKey, value: expiryTime.toIso8601String()),
      if (refreshToken != null) _storage.write(key: _refreshTokenKey, value: refreshToken),
    ]);
    debugPrint('Connexion réussie: $token');
    debugPrint('refreshToken: $refreshToken');
    return LoginResponse(
      success: true,
      token: token,
      refreshToken: refreshToken,
      user: user,
    );
  }

  LoginResponse _handleFailedLogin(http.Response response) {
    String errorMessage;

    try {
      final errorData = json.decode(response.body);
      errorMessage = errorData['error'] ?? errorData['message'] ?? 'Échec de connexion';
    } catch (e) {
      errorMessage = 'Échec de connexion (${response.statusCode})';
    }

    return LoginResponse(
      success: false,
      token: null,
      refreshToken: null,
      user: null,
      errorMessage: errorMessage,
    );
  }

  Future<User?> getCurrentUser() async {
    if (_cachedUser != null) {
      return _cachedUser;
    }
    
    final userData = await _storage.read(key: _userKey);
    if (userData != null) {
      try {
        _cachedUser = User.fromJson(jsonDecode(userData));
        return _cachedUser;
      } catch (e) {
        debugPrint('Erreur lors de la désérialisation des données utilisateur: $e');
        // Nettoyer les données corrompues
        await _storage.delete(key: _userKey);
      }
    }
    return null;
  }

  Future<String?> getToken() async {
    if (_cachedToken != null && _cachedTokenExpiry != null) {
      if (_cachedTokenExpiry!.isAfter(DateTime.now())) {
        return _cachedToken;
      }
    }
    
    final token = await _storage.read(key: _tokenKey);
    final expiryTimeString = await _storage.read(key: _expiryTimeKey);
    
    if (token == null) {
      return null;
    }
    
    if (expiryTimeString == null || 
        DateTime.parse(expiryTimeString).isBefore(DateTime.now())) {
      final refreshed = await refreshToken();
      if (!refreshed) {
        await logout();
        return null;
      }
      final newToken = await _storage.read(key: _tokenKey);
      _cachedToken = newToken;
      return newToken;
    }
    
    _cachedToken = token;
    _cachedTokenExpiry = DateTime.parse(expiryTimeString);
    
    return token;
  }

  Future<bool> refreshToken() async {
    final refreshToken = await _storage.read(key: _refreshTokenKey);
    
    if (refreshToken == null) {
      return false;
    }
    
    try {
      final url = '$baseUrl/api/auth/refresh-token';
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      ).timeout(_requestTimeout);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newToken = data['token'] as String;
        final newRefreshToken = data['refresh_token'] as String?;
        
        _cachedToken = newToken;
        final expiryTime = DateTime.now().add(_tokenValidity);
        _cachedTokenExpiry = expiryTime;
        
        await _storage.write(key: _tokenKey, value: newToken);
        await _storage.write(key: _expiryTimeKey, value: expiryTime.toIso8601String());
        
        if (newRefreshToken != null) {
          await _storage.write(key: _refreshTokenKey, value: newRefreshToken);
        }
        debugPrint('Rafraîchissement réussi: $newToken');
        return true;
      } else {
        debugPrint('Échec du rafraîchissement: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Exception lors du rafraîchissement: $e');
      return false;
    }
  }

  Future<RegisterResponse> register(String email, String password) async {
    final url = '$baseUrl/api/auth/signup';
    print(email + ""  +password);
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
        }),
      ).timeout(_requestTimeout);
      print('Response status: ${response.statusCode}');
      if (response.statusCode == 201 || response.statusCode == 200) {
        final loginResponse = await _handleSuccessfulLogin(response);
        return RegisterResponse(
          success: true,
          token: loginResponse.token,
          refreshToken: loginResponse.refreshToken,
          user: loginResponse.user,
          errorMessage: null,
        );
      } else {
        final loginResponse = _handleFailedLogin(response);
        return RegisterResponse(
          success: false,
          token: null,
          refreshToken: null,
          user: null,
          errorMessage: loginResponse.errorMessage,
        );
      }
    } catch (e) {
      return RegisterResponse(
        success: false,
        token: null,
        refreshToken: null,
        user: null,
        errorMessage: 'Erreur lors de l\'inscription: ${e.toString()}',
      );
    }
  }


  Future<void> logout() async {
  _cachedToken = null;
  _cachedUser = null;
  _cachedTokenExpiry = null;

  await Future.wait([
    _storage.delete(key: _tokenKey),
    _storage.delete(key: _refreshTokenKey),
    _storage.delete(key: _expiryTimeKey),
    _storage.delete(key: _userKey),
  ]);
}
  Future<bool> verifyCode(String email, String code) async {
    final url = '$baseUrl/api/auth/validate-code';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim(),
          'code': code.trim(),
        }),
      ).timeout(_requestTimeout);

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Exception lors de la vérification: $e');
      return false;
    }
  }
  Future<void> resendVerificationCode(String email) async {
    final url = '$baseUrl/api/auth/resend-code'; 
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    if (response.statusCode != 200) {
      throw Exception('Erreur lors de l\'envoi du code');
    }
  }
}
