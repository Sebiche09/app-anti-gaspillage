import 'package:flutter/foundation.dart';
import '../services/basket_configuration_service.dart';

class BasketConfigurationProvider with ChangeNotifier {
  final BasketConfigurationService _service;

  bool _isLoading = false;
  String? _error;

  BasketConfigurationProvider({required BasketConfigurationService service})
      : _service = service;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> submitConfiguration({
    required int restaurantId,
    required double price,
    required List<Map<String, dynamic>> dailyAvailabilities,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      await _service.submitBasketConfiguration(
        restaurantId: restaurantId,
        price: price,
        dailyAvailabilities: dailyAvailabilities,
      );
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }
}
