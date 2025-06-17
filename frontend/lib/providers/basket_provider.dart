import 'package:flutter/material.dart';
import '../models/basket.dart';
import '../services/basket_service.dart';

class BasketsProvider with ChangeNotifier {
  BasketService _basketService;
  List<Basket> _baskets = [];
  List<Basket> _filteredBaskets = [];
  bool _isLoading = false;
  String _error = '';
  String _searchQuery = '';
  String _currentCategory = '';

  BasketsProvider(this._basketService);

  List<Basket> get baskets => _baskets;
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
    basket.category.toLowerCase() == category.toLowerCase()
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
      basket.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          basket.address.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
  }

  void debugState() {
    print('BasketsProvider - État actuel:');
    print('Nombre total de paniers: ${_baskets.length}');
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
}
