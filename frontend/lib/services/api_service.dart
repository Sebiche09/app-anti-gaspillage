import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'auth_service.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  final String baseUrl;
  final AuthService authService;
  final VoidCallback? onSessionExpired; 

  ApiService({
    required this.baseUrl,
    this.onSessionExpired,
  }) : authService = AuthService(baseUrl: baseUrl);

  Future<Map<String, String>> getHeaders() async {
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
  }

  Future<bool> isAuthenticated() async {
    return await authService.isLoggedIn();
  }

  Future<bool> _isTokenExpired() async {
    final token = await authService.getToken();
    if (token == null) {
      print('Aucun token trouvé');
      return true;
    }

    try {
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
    if (await _isTokenExpired()) {
      print('Token expiré, tentative de refresh...');
      final refreshSuccess = await authService.refreshToken();
      if (refreshSuccess) {
        print('Token rafraîchi avec succès');
        return true;
      } else {
        print('Échec du refresh, déconnexion...');
        await authService.logout();
        onSessionExpired?.call(); // Appel du callback
        return false;
      }
    }
    return true;
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
      final isLoggedIn = await isAuthenticated();
      if (!isLoggedIn) {
        throw Exception('User not authenticated');
      }

      if (!isRetry) {
        final tokenValid = await _ensureValidToken();
        if (!tokenValid) {
          throw Exception('Session expirée, veuillez vous reconnecter');
        }
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

      return await _handleResponse(response, method, endpoint, data: data, isRetry: isRetry);
    } catch (e) {
      print("❌ Erreur: $e");
      throw Exception('Failed to connect to the server: $e');
    }
  }

  Future<dynamic> _handleResponse(http.Response response, String method, String endpoint, {Map<String, dynamic>? data, bool isRetry = false}) async {
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.body.isNotEmpty) {
        return json.decode(response.body);
      } else {
        return null;
      }
    } else if (response.statusCode == 401 && !isRetry) {
      print("401 reçu du backend, tentative de rafraîchissement du token...");
      final refreshSuccess = await authService.refreshToken();
      if (refreshSuccess) {
        print("Token rafraîchi avec succès, nouvelle tentative...");
        return _makeRequest(method, endpoint, data: data, isRetry: true);
      } else {
        print("Échec du rafraîchissement, déconnexion de l'utilisateur...");
        await authService.logout();
        onSessionExpired?.call(); // Appel du callback
        throw Exception('Session expirée, veuillez vous reconnecter');
      }
    } else if (response.statusCode == 401 && isRetry) {
      print("Token toujours invalide après refresh, déconnexion...");
      await authService.logout();
      onSessionExpired?.call(); // Appel du callback
      throw Exception('Session expirée, veuillez vous reconnecter');
    } else {
      print("Erreur HTTP ${response.statusCode}: ${response.body}");
      throw Exception('Request failed with status: ${response.statusCode}');
    }
  }
}