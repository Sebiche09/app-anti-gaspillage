import 'package:flutter/foundation.dart';
import '../models/storeCategory.dart';
import '../services/store_service.dart';

class StoreProvider with ChangeNotifier {
  final StoreService _storeService;
  bool _isLoading = false;
  String? _errorMessage;
  List<StoreCategory> _categories = [];
  
  StoreProvider({required StoreService storeService}) 
      : _storeService = storeService;
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<StoreCategory> get categories => _categories;
  
  Future<List<StoreCategory>> getCategories() async {
    try {
      _setLoading(true);
      _clearError();
      
      final categories = await _storeService.getCategories();
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
  
  Future<bool> createStore({
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
      
      final result = await _storeService.createStore(
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
