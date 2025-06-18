import '../models/basket.dart';
import '../models/merchant_basket.dart'; // Ajoute cette ligne
import 'api_service.dart';

class BasketService {
  final ApiService _apiService;

  BasketService({required ApiService apiService})
      : _apiService = apiService;

  Future<List<Basket>> getBaskets() async {
    try {
      final data = await _apiService.get('/api/baskets/');
      if (data == null) return [];
      return (data as List<dynamic>).map((json) => Basket.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load baskets: $e');
    }
  }

  Future<Basket> getBasketById(String id) async {
    try {
      final data = await _apiService.get('/api/baskets/$id');
      return Basket.fromJson(data);
    } catch (e) {
      throw Exception('Failed to load basket: $e');
    }
  }

  Future<List<Basket>> searchBaskets(String query) async {
    try {
      final data = await _apiService.get('/api/baskets/search?q=$query');
      if (data == null) return [];
      return (data as List<dynamic>).map((json) => Basket.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search baskets: $e');
    }
  }

  Future<Basket> reserveBasket(String id) async {
    try {
      final data = await _apiService.post('/api/baskets/$id/reserve', {});
      return Basket.fromJson(data);
    } catch (e) {
      throw Exception('Failed to reserve basket: $e');
    }
  }

  // Modifie cette méthode pour retourner MerchantBasket
  Future<List<MerchantBasket>> getBasketsByStore(int storeId) async {
    try {
      final data = await _apiService.get('/api/stores/$storeId/baskets');
      if (data == null) return [];
      return (data as List<dynamic>).map((json) => MerchantBasket.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load baskets for store: $e');
    }
  }

  Future<void> createBasket({
    required String name,
    required double originalPrice,
    required double discountPercentage,
    required int storeId,
    required int quantity,
    required String description,
  }) async {
    try {
      await _apiService.post('/api/baskets/', {
        "name": name,
        "original_price": originalPrice,
        "discount_percentage": discountPercentage,
        "store_id": storeId,
        "quantity": quantity,
        "description": description,
      });
    } catch (e) {
      throw Exception('Failed to create basket: $e');
    }
  }
}