import 'dart:convert';
import '../models/storeCategory.dart';
import 'api_service.dart';

class StoreService {
  final ApiService _apiService;
  
  StoreService({required ApiService apiService}) 
      : _apiService = apiService;
  
  Future<List<StoreCategory>> getCategories() async {
    try {
      final response = await _apiService.get('/api/categories');
      print("Réponse brute de l'API: $response"); 
      
      // La réponse est probablement un Map avec une clé 'data', pas directement une List
      if (response != null && response is Map<String, dynamic> && response.containsKey('data')) {
        final data = response['data'] as List;
        print("Données extraites: $data");
        return data.map((item) => StoreCategory.fromJson(item)).toList();
      } else if (response != null && response is List) {
        // Au cas où l'API renvoie directement une liste
        return response.map((item) => StoreCategory.fromJson(item)).toList();
      } else {
        print("Format invalide: $response");
        throw Exception('Format de données categories invalide');
      }
    } catch (e) {
      print("❌ Erreur complète lors de la récupération des catégories: $e");
      throw Exception('Erreur lors de la récupération des catégories: $e');
    }
  }
  
  Future<Map<String, dynamic>> createStore({
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
      
      final response = await _apiService.post('/api/merchants/stores', data);
      
      if (response != null) {
        return {
          'success': true,
          'data': response,
        };
      } else {
        return {
          'success': false,
          'message': 'Échec de la création du magasin',
        };
      }
    } catch (e) {
      print("❌ Erreur lors de la création du magasin: $e");
      return {
        'success': false,
        'message': 'Erreur lors de la création du magasin: $e',
      };
    }
  }
}
