
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
  bool _isDisposed = false;
  
  AuthService({
    required this.baseUrl,
    FlutterSecureStorage? storage,
  }) : _storage = storage ?? const FlutterSecureStorage();

  // Méthode pour vérifier si le service est encore utilisable
  bool get isDisposed => _isDisposed;

  // Méthode pour marquer le service comme disposé
  void dispose() {
    _isDisposed = true;
    _cachedToken = null;
    _cachedUser = null;
    _cachedTokenExpiry = null;
  }

  // Vérification de sécurité avant chaque opération
  void _checkDisposed() {
    if (_isDisposed) {
      throw StateError('AuthService has been disposed');
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      _checkDisposed();
      final token = await getToken();
      return token != null;
    } catch (e) {
      debugPrint('Erreur lors de la vérification de la connexion: $e');
      return false;
    }
  }

  Future<LoginResponse> login(String email, String password) async {
    _checkDisposed();
    
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

      if (_isDisposed) {
        return LoginResponse(
          success: false,
          token: null,
          refreshToken: null,
          user: null,
          errorMessage: 'Service has been disposed',
        );
      }

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
    _checkDisposed();

    final Map<String, dynamic> responseData = json.decode(response.body);
    final String token = responseData['token'] as String;
    final String? refreshToken = responseData['refresh_token'] as String?;
    User? user;
    
    try {
      if (responseData.containsKey('user')) {
        final userData = responseData['user'] as Map<String, dynamic>;
        user = User.fromJson(userData);
        if (!_isDisposed) {
          _cachedUser = user;  
          await _storage.write(key: _userKey, value: jsonEncode(userData));
        }
      }
    } catch (e) {
      debugPrint('Erreur lors du traitement des données utilisateur: $e');
    }

    if (!_isDisposed) {
      final expiryTime = DateTime.now().add(_tokenValidity);
      _cachedTokenExpiry = expiryTime;  
      _cachedToken = token;  
      
      await Future.wait([
        _storage.write(key: _tokenKey, value: token),
        _storage.write(key: _expiryTimeKey, value: expiryTime.toIso8601String()),
        if (refreshToken != null) _storage.write(key: _refreshTokenKey, value: refreshToken),
      ]);
    }
    
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
    try {
      _checkDisposed();
      
      if (_cachedUser != null) {
        return _cachedUser;
      }
      
      final userData = await _storage.read(key: _userKey);
      if (userData != null && !_isDisposed) {
        try {
          _cachedUser = User.fromJson(jsonDecode(userData));
          return _cachedUser;
        } catch (e) {
          debugPrint('Erreur lors de la désérialisation des données utilisateur: $e');
          // Nettoyer les données corrompues
          if (!_isDisposed) {
            await _storage.delete(key: _userKey);
          }
        }
      }
      return null;
    } catch (e) {
      if (e is StateError) rethrow;
      debugPrint('Erreur lors de la récupération de l\'utilisateur: $e');
      return null;
    }
  }

  Future<String?> getToken() async {
    try {
      _checkDisposed();
      
      if (_cachedToken != null && _cachedTokenExpiry != null) {
        if (_cachedTokenExpiry!.isAfter(DateTime.now())) {
          return _cachedToken;
        }
      }
      
      final token = await _storage.read(key: _tokenKey);
      final expiryTimeString = await _storage.read(key: _expiryTimeKey);
      
      if (token == null || _isDisposed) {
        return null;
      }
      
      if (expiryTimeString == null || 
          DateTime.parse(expiryTimeString).isBefore(DateTime.now())) {
        final refreshed = await refreshToken();
        if (!refreshed || _isDisposed) {
          await logout();
          return null;
        }
        final newToken = await _storage.read(key: _tokenKey);
        if (!_isDisposed) {
          _cachedToken = newToken;
        }
        return newToken;
      }
      
      if (!_isDisposed) {
        _cachedToken = token;
        _cachedTokenExpiry = DateTime.parse(expiryTimeString);
      }
      
      return token;
    } catch (e) {
      if (e is StateError) rethrow;
      debugPrint('Erreur lors de la récupération du token: $e');
      return null;
    }
  }

  Future<bool> refreshToken() async {
    try {
      _checkDisposed();
      
      final refreshToken = await _storage.read(key: _refreshTokenKey);
      
      if (refreshToken == null || _isDisposed) {
        return false;
      }
      
      final url = '$baseUrl/api/auth/refresh-token';
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      ).timeout(_requestTimeout);
      
      if (_isDisposed) {
        return false;
      }
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newToken = data['token'] as String;
        final newRefreshToken = data['refresh_token'] as String?;
        
        if (!_isDisposed) {
          _cachedToken = newToken;
          final expiryTime = DateTime.now().add(_tokenValidity);
          _cachedTokenExpiry = expiryTime;
          
          await _storage.write(key: _tokenKey, value: newToken);
          await _storage.write(key: _expiryTimeKey, value: expiryTime.toIso8601String());
          
          if (newRefreshToken != null) {
            await _storage.write(key: _refreshTokenKey, value: newRefreshToken);
          }
        }
        
        debugPrint('Rafraîchissement réussi: $newToken');
        return true;
      } else {
        debugPrint('Échec du rafraîchissement: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      if (e is StateError) rethrow;
      debugPrint('Exception lors du rafraîchissement: $e');
      return false;
    }
  }

  Future<RegisterResponse> register(String email, String password) async {
    _checkDisposed();
    
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
      
      if (_isDisposed) {
        return RegisterResponse(
          success: false,
          token: null,
          refreshToken: null,
          user: null,
          errorMessage: 'Service has been disposed',
        );
      }
      
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
    try {
      // Ne pas vérifier _checkDisposed() ici car logout peut être appelé même après dispose
      _cachedToken = null;
      _cachedUser = null;
      _cachedTokenExpiry = null;

      await Future.wait([
        _storage.delete(key: _tokenKey),
        _storage.delete(key: _refreshTokenKey),
        _storage.delete(key: _expiryTimeKey),
        _storage.delete(key: _userKey),
      ]);
    } catch (e) {
      debugPrint('Erreur lors de la déconnexion: $e');
    }
  }

  Future<bool> verifyCode(String email, String code) async {
    try {
      _checkDisposed();
      
      final url = '$baseUrl/api/auth/validate-code';

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
      if (e is StateError) rethrow;
      debugPrint('Exception lors de la vérification: $e');
      return false;
    }
  }

  Future<void> resendVerificationCode(String email) async {
    _checkDisposed();
    
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
