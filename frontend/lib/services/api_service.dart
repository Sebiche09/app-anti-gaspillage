import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiService {
  final String baseUrl;
  final AuthService authService;

  ApiService({required this.baseUrl})
      : authService = AuthService(baseUrl: baseUrl);

  Future<Map<String, String>> getHeaders() async {
    final token = await authService.getToken();
    print("Token récupéré : $token");
    if (token != null) {
      return {
        'Content-Type': 'application/json',
        'Authorization': token,
      };


    }
    return {
      'Content-Type': 'application/json',
    };
  }

  Future<bool> isAuthenticated() async {
    return await authService.isLoggedIn();
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final isLoggedIn = await isAuthenticated();

      if (!isLoggedIn) {
        throw Exception('User not authenticated');
      }

      final headers = await getHeaders();


      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );
      return _handleResponse(response);
    } catch (e) {
      print("❌ Erreur: $e");
      throw Exception('Failed to connect to the server: $e');
    }
  }
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final isLoggedIn = await isAuthenticated();
      if (!isLoggedIn) {
        throw Exception('User not authenticated');
      }

      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.body.isNotEmpty) {
        return json.decode(response.body);
      } else {
        return null;
      }
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Please log in again');
    } else {
      print("Erreur HTTP ${response.statusCode}: ${response.body}");
      throw Exception('Request failed with status: ${response.statusCode}');
    }
  }
}