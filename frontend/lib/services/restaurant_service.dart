simport 'dart:convert';
import '../models/restaurantCategory.dart';
import 'api_service.dart';
import '../constants/api_endpoints.dart';

class RestaurantService {
  final ApiService _apiService;
  
  RestaurantService({required ApiService apiService}) 
      : _apiService = apiService;
  
  Future<List<RestaurantCategory>> getCategories() async {
    try {
      final response = await _apiService.get('${ApiEndpoints.restaurantCategories}');
      print("Réponse brute de l'API: $response"); // Ajoutez ce log
      
      // La réponse est probablement un Map avec une clé 'data', pas directement une List
      if (response != null && response is Map<String, dynamic> && response.containsKey('data')) {
        final data = response['data'] as List;
        print("Données extraites: $data");
        return data.map((item) => RestaurantCategory.fromJson(item)).toList();
      } else if (response != null && response is List) {
        // Au cas où l'API renvoie directement une liste
        return response.map((item) => RestaurantCategory.fromJson(item)).toList();
      } else {
        print("Format invalide: $response");
        throw Exception('Format de données categories invalide');
      }
    } catch (e) {
      print("❌ Erreur complète lors de la récupération des catégories: $e");
      throw Exception('Erreur lors de la récupération des catégories: $e');
    }
  }
  
  Future<Map<String, dynamic>> createRestaurant({
    required String name,
    required String address,
    required String city,
    required String postalCode,
    required String phoneNumber,
    required int categoryId,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'name': name,
        'address': address,
        'city': city,
        'postal_code': postalCode,
        'phone_number': phoneNumber,
        'category_id': categoryId,
      };
      
      final response = await _apiService.post('${ApiEndpoints.restaurant}', data);
      if (response != null) {
        print("Données extraites lors de la création du restaurant: $response");
        return {
          'success': true,
          'data': response,
        };
      } else {
        return {
          'success': false,
          'message': 'Échec de la création du restaurant',
        };
      }
    } catch (e) {
      print("❌ Erreur lors de la création du restaurant: $e");
      return {
        'success': false,
        'message': 'Erreur lors de la création du restaurant: $e',
      };
    }
  }
}
