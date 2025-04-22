class ApiEndpoints {
  // Auth endpoints
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/signup';
  static const String refreshToken = '/api/auth/refresh-token';
  
  // Baskets endpoints
  static const String baskets = '/api/baskets';
  static const String basketById = '/api/baskets/'; // + id
  
  // Restaurant endpoints
  static const String restaurants = '/api/merchants/restaurants';
  static const String restaurantById = '/api/restaurants/'; // + id
  static const String restaurantConfig = '/api/merchants/restaurants/'; // + id + '/basket-configuration'
  static const String restaurantCategories = '/api/categories';
  
  // Merchant endpoints
  static const String merchantInfo = '/api/merchants';
  static const String merchantRestaurants = '/api/merchants/restaurants';
  static const String merchantRequestStatus = '/api/merchants/request-status';
}