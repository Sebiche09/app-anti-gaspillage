import 'api_service.dart';

class BasketConfigurationService {
  final ApiService apiService;

  BasketConfigurationService({required this.apiService});

  Future<void> submitBasketConfiguration({
    required int restaurantId,
    required double price,
    required List<Map<String, dynamic>> dailyAvailabilities,
  }) async {
    final endpoint = '${ApiEndpoints.restaurantConfig}$restaurantId/basket-configuration';

    final payload = {
      'price': price,
      'daily_availabilities': dailyAvailabilities,
    };

    await apiService.post(endpoint, payload);
  }
}
