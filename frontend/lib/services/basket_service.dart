import '../models/basket.dart';
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
}