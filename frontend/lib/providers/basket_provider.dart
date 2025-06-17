import 'package:flutter/material.dart';
import '../models/basket.dart';
import '../models/merchant_basket.dart'; // Ajoute cette ligne
import '../services/basket_service.dart';

class BasketsProvider with ChangeNotifier {
  BasketService _basketService;
  List<Basket> _baskets = [];
  List<MerchantBasket> _merchantBaskets = []; // Ajoute cette ligne
  List<Basket> _filteredBaskets = [];
  bool _isLoading = false;
  String _error = '';
  String _searchQuery = '';
  String _currentCategory = '';

  BasketsProvider(this._basketService);

  List<Basket> get baskets => _baskets;
  List<MerchantBasket> get merchantBaskets => _merchantBaskets; // Ajoute cette ligne
  bool get isLoading => _isLoading;
  String get error => _error;

  void updateBasketService(BasketService basketService) {
    _basketService = basketService;
    fetchBaskets();
  }

  Future<void> fetchBaskets() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _baskets = await _basketService.getBaskets();
      _applyFilters(); 
      _isLoading = false;
      debugState();
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      print('Erreur de récupération des paniers: $_error'); 
      notifyListeners();
    }
  }

  void searchBaskets(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  List<Basket> getBasketsByCategory(String category) {
    _currentCategory = category;

    if (category.isEmpty || category == 'Tout' || category.toLowerCase() == 'all') {
      return _searchQuery.isEmpty ? _baskets : _filteredBaskets;
    }

    List<Basket> categoryFiltered = _baskets.where((basket) =>
    (basket.category ?? '').toLowerCase() == category.toLowerCase()
    ).toList();

    if (_searchQuery.isNotEmpty) {
      categoryFiltered = categoryFiltered.where((basket) =>
          basket.name.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    return categoryFiltered;
  }

  void _applyFilters() {
    if (_searchQuery.isEmpty) {
      _filteredBaskets = _baskets;
    } else {
      _filteredBaskets = _baskets.where((basket) =>
        basket.name.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
  }

  void debugState() {
    print('BasketsProvider - État actuel:');
    print('Nombre total de paniers: ${_baskets.length}');
    print('Nombre de paniers marchands: ${_merchantBaskets.length}'); // Ajoute cette ligne
    print('Paniers filtrés: ${_filteredBaskets.length}');
    print('Requête de recherche: "$_searchQuery"');
    print('Catégorie actuelle: "$_currentCategory"');
    print('En chargement: $_isLoading');
    print('Erreur: $_error');
  }

  void resetFilters() {
    _searchQuery = '';
    _currentCategory = '';
    _applyFilters();
    notifyListeners();
  }

  // Modifie cette méthode
  Future<void> fetchBasketsForStore(int storeId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _merchantBaskets = await _basketService.getBasketsByStore(storeId);
      _isLoading = false;
      debugState();
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> addBasket({
    required String name,
    required double originalPrice,
    required double discountPercentage,
    required int storeId,
    required int quantity,
    required String category,
    required String description,
    
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _basketService.createBasket(
        name: name,
        originalPrice: originalPrice,
        discountPercentage: discountPercentage,
        storeId: storeId,
        quantity: quantity,
        category: category,
        description: description,
      );

      await fetchBasketsForStore(storeId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}