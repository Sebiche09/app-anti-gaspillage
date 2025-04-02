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
  
  // Constantes pour le stockage
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _expiryTimeKey = 'token_expiry';
  static const String _userKey = 'user_data';
  
  // Timeout pour les requêtes HTTP
  static const Duration _requestTimeout = Duration(seconds: 10);
  
  // Durée par défaut de validité du token
  static const Duration _tokenValidity = Duration(hours: 1);
  
  // Cache en mémoire pour optimiser les performances
  String? _cachedToken;
  User? _cachedUser;
  DateTime? _cachedTokenExpiry;
  
  // Constructeur avec injection de dépendance pour faciliter les tests
  AuthService({
    required this.baseUrl,
    FlutterSecureStorage? storage,
  }) : _storage = storage ?? const FlutterSecureStorage();

  // Vérifie si l'utilisateur est connecté et si le token est valide
  Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      return token != null;
    } catch (e) {
      debugPrint('Erreur lors de la vérification de connexion: $e');
      return false;
    }
  }

  // connexion utilisateur 
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

  // Traite une réponse de login réussie
  Future<LoginResponse> _handleSuccessfulLogin(http.Response response) async {
    final Map<String, dynamic> responseData = json.decode(response.body);
    final String token = responseData['token'] as String;
    final String? refreshToken = responseData['refreshToken'] as String?;
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

    return LoginResponse(
      success: true,
      token: token,
      refreshToken: refreshToken,
      user: user,
    );
  }

  // Traite une réponse de login échouée
  LoginResponse _handleFailedLogin(http.Response response) {
    String errorMessage;
    
    try {
      final errorData = json.decode(response.body);
      errorMessage = errorData['message'] ?? 'Échec de connexion';
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

  // Récupère l'utilisateur actuel (d'abord du cache, puis du stockage)
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

  // Récupère le token avec vérification d'expiration et refresh automatique
  Future<String?> getToken() async {
    // Vérifier d'abord le cache
    if (_cachedToken != null && _cachedTokenExpiry != null) {
      // Si le token en cache est toujours valide
      if (_cachedTokenExpiry!.isAfter(DateTime.now())) {
        return _cachedToken;
      }
    }
    
    final token = await _storage.read(key: _tokenKey);
    final expiryTimeString = await _storage.read(key: _expiryTimeKey);
    
    if (token == null) {
      return null;
    }
    
    // Si pas d'expiration définie ou token expiré
    if (expiryTimeString == null || 
        DateTime.parse(expiryTimeString).isBefore(DateTime.now())) {
      // Tenter le rafraîchissement
      final refreshed = await refreshToken();
      if (!refreshed) {
        // En cas d'échec, déconnecter l'utilisateur
        await logout();
        return null;
      }
      // Retourner le nouveau token
      final newToken = await _storage.read(key: _tokenKey);
      _cachedToken = newToken;
      return newToken;
    }
    
    // Mise en cache
    _cachedToken = token;
    _cachedTokenExpiry = DateTime.parse(expiryTimeString);
    
    return token;
  }

  // Rafraîchit le token
  Future<bool> refreshToken() async {
    final refreshToken = await _storage.read(key: _refreshTokenKey);
    
    if (refreshToken == null) {
      return false;
    }
    
    try {
      final url = '$baseUrl/api/auth/refresh';
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      ).timeout(_requestTimeout);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newToken = data['token'] as String;
        final newRefreshToken = data['refreshToken'] as String?;
        
        // Mettre à jour les tokens
        _cachedToken = newToken;
        final expiryTime = DateTime.now().add(_tokenValidity);
        _cachedTokenExpiry = expiryTime;
        
        // Mettre à jour le stockage
        await _storage.write(key: _tokenKey, value: newToken);
        await _storage.write(key: _expiryTimeKey, value: expiryTime.toIso8601String());
        
        if (newRefreshToken != null) {
          await _storage.write(key: _refreshTokenKey, value: newRefreshToken);
        }
        
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

  // Enregistre un nouvel utilisateur
  Future<RegisterResponse> register(String fullname, String email, String phone, String password) async {
  final url = '$baseUrl/api/auth/signup';

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'full_name': fullname.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'password': password,
      }),
    ).timeout(_requestTimeout);
    print('Response status: ${response.statusCode}');
    if (response.statusCode == 201 || response.statusCode == 200) {
      // Adapter `_handleSuccessfulLogin` pour un `RegisterResponse`
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


  // Déconnexion avec nettoyage complet
  Future<void> logout() async {
    // Nettoyer le cache
    _cachedToken = null;
    _cachedUser = null;
    _cachedTokenExpiry = null;
    
    // Nettoyer le stockage
    await Future.wait([
      _storage.delete(key: _tokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _expiryTimeKey),
      _storage.delete(key: _userKey),
    ]);
    
    // Optionnel: appeler une API de déconnexion côté serveur
    try {
      final token = await _storage.read(key: _tokenKey);
      if (token != null) {
        final url = '$baseUrl/api/auth/logout';
        await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 5));
      }
    } catch (e) {
      // Ignorer les erreurs de déconnexion côté serveur
      debugPrint('Erreur lors de la déconnexion côté serveur: $e');
    }
  }
}
