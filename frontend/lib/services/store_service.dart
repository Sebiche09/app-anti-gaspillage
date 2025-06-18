import 'dart:convert';
import '../models/storeCategory.dart';
import 'api_service.dart';
import '../models/store.dart';
class StoreService {
  final ApiService _apiService;
  
  StoreService({required ApiService apiService}) 
      : _apiService = apiService;
  
  Future<List<StoreCategory>> getCategories() async {
    try {
      final response = await _apiService.get('/api/categories');
      
      if (response != null && response is Map<String, dynamic> && response.containsKey('data')) {
        final data = response['data'] as List;
        print("Données extraites: $data");
        return data.map((item) => StoreCategory.fromJson(item)).toList();
      } else if (response != null && response is List) {
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
  Future<List<Store>> getStores() async {
    try {
      final response = await _apiService.get('/api/merchants/stores');
      
      if (response != null && response is Map<String, dynamic> && response.containsKey('data')) {
        final data = response['data'] as List;
        return data.map((item) => Store.fromJson(item)).toList();
      } else if (response != null && response is List) {
        return response.map((item) => Store.fromJson(item)).toList();
      } else {
        throw Exception('Format de données magasins invalide');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des magasins: $e');
    }
  }

  Future<bool> updateStore(Store store) async {
    try {
      final Map<String, dynamic> data = {
        'name': store.name,
        'address': store.address,
        'city': store.city,
        'postal_code': store.postalCode,
        'phone_number': store.phoneNumber,
        'category_id': store.categoryId,
      };
      
      final response = await _apiService.put('/api/merchants/stores/${store.id}', data);
      
      if (response != null) {
        print("✅ Magasin mis à jour avec succès");
        return true;
      } else {
        print("❌ Échec de la mise à jour du magasin");
        return false;
      }
    } catch (e) {
      print("❌ Erreur lors de la mise à jour du magasin: $e");
      throw Exception('Erreur lors de la mise à jour du magasin: $e');
    }
  }

  Future<bool> deleteStore(int id) async {
    try {
      final response = await _apiService.delete('/api/merchants/stores/$id');
      
      if (response != null) {
        print("✅ Magasin supprimé avec succès");
        return true;
      } else {
        print("❌ Échec de la suppression du magasin");
        return false;
      }
    } catch (e) {
      print("❌ Erreur lors de la suppression du magasin: $e");
      throw Exception('Erreur lors de la suppression du magasin: $e');
    }
  }
}
