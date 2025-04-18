import 'package:flutter/foundation.dart';
import '../models/restaurantCategory.dart';
import '../services/restaurant_service.dart';

class RestaurantProvider with ChangeNotifier {
  final RestaurantService _restaurantService;
  bool _isLoading = false;
  String? _errorMessage;
  List<RestaurantCategory> _categories = [];
  
  RestaurantProvider({required RestaurantService restaurantService}) 
      : _restaurantService = restaurantService;
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<RestaurantCategory> get categories => _categories;
  
  Future<List<RestaurantCategory>> getCategories() async {
    try {
      _setLoading(true);
      _clearError();
      
      final categories = await _restaurantService.getCategories();
      print("Categories récupérées: $categories");
      _categories = categories;
      notifyListeners();
      return categories;
    } catch (e) {
      _setError(e.toString());
      return [];
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> createRestaurant({
    required String name,
    required String address,
    required String city,
    required String postalCode,
    required String phoneNumber,
    required int categoryId,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      final result = await _restaurantService.createRestaurant(
        name: name,
        address: address,
        city: city,
        postalCode: postalCode,
        phoneNumber: phoneNumber,
        categoryId: categoryId,
      );
      
      return result['success'] ?? false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }
  
  void _clearError() {
    _errorMessage = null;
  }
}
