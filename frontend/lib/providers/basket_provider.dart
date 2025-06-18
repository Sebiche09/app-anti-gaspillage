import 'package:flutter/foundation.dart';
import '../models/basket.dart';
import '../models/merchant_basket.dart';
import '../services/basket_service.dart';
import 'error_notifier.dart';

/// Provider pour la gestion des paniers.
///
/// Permet de récupérer, filtrer, rechercher, ajouter des paniers,
/// ainsi que de gérer les paniers spécifiques à un magasin.
/// Utilise un [BasketService] pour communiquer avec l'API.
/// Les erreurs sont remontées via un [ErrorNotifier] global.
class BasketsProvider with ChangeNotifier {
  BasketService _basketService;
  final ErrorNotifier _errorNotifier;

  List<Basket> _baskets = [];
  List<MerchantBasket> _merchantBaskets = [];
  List<Basket> _filteredBaskets = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _currentCategory = '';

  /// Initialise le provider avec un service de panier et un ErrorNotifier.
  BasketsProvider(this._basketService, this._errorNotifier);

  List<Basket> get baskets => _baskets;
  List<MerchantBasket> get merchantBaskets => _merchantBaskets;
  List<Basket> get filteredBaskets => _filteredBaskets;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get currentCategory => _currentCategory;

  /// Définit l'état de chargement et notifie les auditeurs.
  void _setLoading([bool value = true]) {
    _isLoading = value;
    notifyListeners();
  }

  /// Réinitialise l'état d'erreur dans le [ErrorNotifier].
  void _clearError() {
    _errorNotifier.clearError();
  }

  /// Met à jour le message d'erreur dans le [ErrorNotifier] et notifie.
  void _setError(String error) {
    _errorNotifier.setError(error);
    notifyListeners();
  }

  /// Met à jour le service de panier et recharge les paniers.
  void updateBasketService(BasketService basketService) {
    _basketService = basketService;
    fetchBaskets();
  }

  /// Met à jour la requête de recherche et applique les filtres.
  void searchBaskets(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  /// Récupère la liste complète des paniers depuis le service.
  ///
  /// En cas d'erreur, met à jour [ErrorNotifier].
  Future<void> fetchBaskets() async {
    _setLoading(true);
    _clearError();
    try {
      _baskets = await _basketService.getBaskets();
      _applyFilters();
    } catch (e) {
      _setError('Erreur de récupération des paniers: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Définit la requête de recherche et applique les filtres.
  set search(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  /// Définit la catégorie courante et applique les filtres.
  set category(String category) {
    _currentCategory = category;
    _applyFilters();
    notifyListeners();
  }

  /// Retourne la liste des paniers filtrés selon la catégorie et la recherche.
  List<Basket> getBasketsByCategory(String category) {
    if (category.isEmpty || category.toLowerCase() == 'tout' || category.toLowerCase() == 'all') {
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

  /// Applique les filtres de recherche et de catégorie sur la liste des paniers.
  void _applyFilters() {
    if (_searchQuery.isEmpty) {
      _filteredBaskets = _baskets;
    } else {
      _filteredBaskets = _baskets.where((basket) =>
        basket.name.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
  }

  /// Réinitialise les filtres de recherche et de catégorie.
  void resetFilters() {
    _searchQuery = '';
    _currentCategory = '';
    _applyFilters();
    notifyListeners();
  }

  /// Récupère les paniers d'un magasin spécifique.
  ///
  /// En cas d'erreur, met à jour [ErrorNotifier].
  Future<void> fetchBasketsForStore(int storeId) async {
    _setLoading(true);
    _clearError();
    try {
      _merchantBaskets = await _basketService.getBasketsByStore(storeId);
    } catch (e) {
      _setError('Erreur de récupération des paniers du magasin: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Ajoute un nouveau panier avec les informations fournies.
  ///
  /// En cas d'erreur, met à jour [ErrorNotifier] et relance l'exception.
  Future<void> addBasket({
    required String name,
    required double originalPrice,
    required double discountPercentage,
    required int storeId,
    required int quantity,
    required String description,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      await _basketService.createBasket(
        name: name,
        originalPrice: originalPrice,
        discountPercentage: discountPercentage,
        storeId: storeId,
        quantity: quantity,
        description: description,
      );
      await fetchBasketsForStore(storeId);
    } catch (e) {
      _setError('Erreur lors de l\'ajout du panier: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
}