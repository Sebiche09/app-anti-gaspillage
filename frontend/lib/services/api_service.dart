
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'auth_service.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  final String baseUrl;
  final AuthService authService;
  final VoidCallback? onSessionExpired; 
  bool _isDisposed = false;

  ApiService({
    required this.baseUrl,
    this.onSessionExpired,
  }) : authService = AuthService(baseUrl: baseUrl);

  // Méthode pour marquer le service comme disposé
  void dispose() {
    _isDisposed = true;
    authService.dispose();
  }

  // Vérification de sécurité avant chaque opération
  void _checkDisposed() {
    if (_isDisposed) {
      throw StateError('ApiService has been disposed');
    }
  }

  // Callback sécurisé pour l'expiration de session
  void _safeSessionExpiredCallback() {
    if (!_isDisposed && onSessionExpired != null) {
      try {
        onSessionExpired!();
      } catch (e) {
        debugPrint('Erreur lors du callback d\'expiration de session: $e');
      }
    }
  }

  Future<Map<String, String>> getHeaders() async {
    _checkDisposed();
    
    try {
      final token = await authService.getToken();
      if (token != null) {
        return {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        };
      }
      return {
        'Content-Type': 'application/json',
      };
    } catch (e) {
      debugPrint('Erreur lors de la récupération des headers: $e');
      return {
        'Content-Type': 'application/json',
      };
    }
  }

  Future<bool> isAuthenticated() async {
    try {
      _checkDisposed();
      return await authService.isLoggedIn();
    } catch (e) {
      debugPrint('Erreur lors de la vérification d\'authentification: $e');
      return false;
    }
  }

  Future<bool> _isTokenExpired() async {
    try {
      _checkDisposed();
      
      final token = await authService.getToken();
      if (token == null) {
        print('Aucun token trouvé');
        return true;
      }

      if (JwtDecoder.isExpired(token)) {
        print('Token expiré détecté côté frontend');
        return true;
      }
      return false;
    } catch (e) {
      print('Erreur lors de la vérification du token: $e');
      return true;
    }
  }

  Future<bool> _ensureValidToken() async {
    try {
      _checkDisposed();
      
      if (await _isTokenExpired()) {
        print('Token expiré, tentative de refresh...');
        final refreshSuccess = await authService.refreshToken();
        if (refreshSuccess && !_isDisposed) {
          print('Token rafraîchi avec succès');
          return true;
        } else {
          print('Échec du refresh, déconnexion...');
          if (!_isDisposed) {
            await authService.logout();
            _safeSessionExpiredCallback();
          }
          return false;
        }
      }
      return true;
    } catch (e) {
      debugPrint('Erreur lors de la validation du token: $e');
      return false;
    }
  }

  Future<dynamic> get(String endpoint) async {
    return _makeRequest('GET', endpoint);
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    return _makeRequest('POST', endpoint, data: data);
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    return _makeRequest('PUT', endpoint, data: data);
  }

  Future<dynamic> delete(String endpoint) async {
    return _makeRequest('DELETE', endpoint);
  }

  Future<dynamic> _makeRequest(String method, String endpoint, {Map<String, dynamic>? data, bool isRetry = false}) async {
    try {
      _checkDisposed();
      
      final isLoggedIn = await isAuthenticated();
      if (!isLoggedIn) {
        throw Exception('User not authenticated');
      }

      if (!isRetry && !_isDisposed) {
        final tokenValid = await _ensureValidToken();
        if (!tokenValid) {
          throw Exception('Session expirée, veuillez vous reconnecter');
        }
      }

      if (_isDisposed) {
        throw Exception('Service has been disposed');
      }

      final headers = await getHeaders();
      Uri uri = Uri.parse('$baseUrl$endpoint');
      http.Response response;

      switch (method) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(uri, headers: headers, body: json.encode(data));
          break;
        case 'PUT':
          response = await http.put(uri, headers: headers, body: json.encode(data));
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        default:
          throw Exception('Invalid HTTP method: $method');
      }

      if (_isDisposed) {
        throw Exception('Service has been disposed during request');
      }

      return await _handleResponse(response, method, endpoint, data: data, isRetry: isRetry);
    } catch (e) {
      if (e is StateError) rethrow;
      print("❌ Erreur: $e");
      throw Exception('Failed to connect to the server: $e');
    }
  }

  Future<dynamic> _handleResponse(http.Response response, String method, String endpoint, {Map<String, dynamic>? data, bool isRetry = false}) async {
    try {
      _checkDisposed();
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isNotEmpty) {
          return json.decode(response.body);
        } else {
          return null;
        }
      } else if (response.statusCode == 401 && !isRetry && !_isDisposed) {
        print("401 reçu du backend, tentative de rafraîchissement du token...");
        final refreshSuccess = await authService.refreshToken();
        if (refreshSuccess && !_isDisposed) {
          print("Token rafraîchi avec succès, nouvelle tentative...");
          return _makeRequest(method, endpoint, data: data, isRetry: true);
        } else {
          print("Échec du rafraîchissement, déconnexion de l'utilisateur...");
          if (!_isDisposed) {
            await authService.logout();
            _safeSessionExpiredCallback();
          }
          throw Exception('Session expirée, veuillez vous reconnecter');
        }
      } else if (response.statusCode == 401 && (isRetry || _isDisposed)) {
        print("Token toujours invalide après refresh, déconnexion...");
        if (!_isDisposed) {
          await authService.logout();
          _safeSessionExpiredCallback();
        }
        throw Exception('Session expirée, veuillez vous reconnecter');
      } else {
        print("Erreur HTTP ${response.statusCode}: ${response.body}");
        throw Exception('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      if (e is StateError) rethrow;
      debugPrint('Erreur lors du traitement de la réponse: $e');
      rethrow;
    }
  }
}
