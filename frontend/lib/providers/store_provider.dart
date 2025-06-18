import 'package:flutter/foundation.dart';
import '../models/storeCategory.dart';
import '../services/store_service.dart';
import '../models/store.dart';
import 'error_notifier.dart';

/// Provider pour la gestion des magasins.
///
/// Permet de récupérer, créer, mettre à jour, supprimer et sélectionner des magasins,
/// ainsi que de gérer les catégories associées.
/// Utilise un [StoreService] pour communiquer avec l'API.
class StoreProvider with ChangeNotifier {
  final StoreService _storeService;
  final ErrorNotifier _errorNotifier;
  bool _isLoading = false;
  List<StoreCategory> _categories = [];
  List<Store> _stores = [];
  Store? _selectedStore;

  /// Initialise le provider avec un service de magasin.
  StoreProvider({required StoreService storeService, required ErrorNotifier errorNotifier})
      : _storeService = storeService,
        _errorNotifier = errorNotifier;

  bool get isLoading => _isLoading;
  List<StoreCategory> get categories => _categories;
  List<Store> get stores => _stores;
  Store? get selectedStore => _selectedStore;
  bool get hasSelectedStore => _selectedStore != null;
  int get storeCount => _stores.length;

  /// Réinitialise l'état interne du provider.
  ///
  /// [loading] : indique si une opération de chargement est en cours.
  void _resetState({bool loading = false}) {
    _isLoading = loading;
    _errorNotifier.clearError();
  }

  /// Récupère les catégories de magasins depuis le service.
  ///
  /// Retourne la liste des catégories récupérées.
  /// En cas d'erreur, retourne une liste vide et met à jour [errorNotifier].
  Future<List<StoreCategory>> getCategories() async {
    _resetState(loading: true);
    try {
      final categories = await _storeService.getCategories();
      _categories = categories;
      return categories;
    } catch (e, stack) {
      _errorNotifier.setError(e.toString());
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Crée un nouveau magasin avec les informations fournies.
  ///
  /// Paramètres requis :
  /// - [name] : nom du magasin.
  /// - [address] : adresse du magasin.
  /// - [city] : ville.
  /// - [postalCode] : code postal.
  /// - [phoneNumber] : numéro de téléphone.
  /// - [categoryId] : identifiant de la catégorie du magasin.
  ///
  /// Retourne `true` si la création a réussi, `false` sinon.
  /// En cas d'erreur, met à jour [errorNotifier].
  Future<bool> createStore({
    required String name,
    required String address,
    required String city,
    required String postalCode,
    required String phoneNumber,
    required int categoryId,
  }) async {
    _resetState(loading: true);
    try {
      final result = await _storeService.createStore(
        name: name,
        address: address,
        city: city,
        postalCode: postalCode,
        phoneNumber: phoneNumber,
        categoryId: categoryId,
      );
      return result['success'] ?? false;
    } catch (e, stack) {
      _errorNotifier.setError(e.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Récupère la liste des magasins depuis le service.
  ///
  /// Met à jour la liste interne [_stores] et sélectionne automatiquement
  /// le premier magasin si aucun n'est sélectionné.
  ///
  /// Retourne la liste des magasins récupérés.
  /// En cas d'erreur, retourne une liste vide et met à jour [errorNotifier].
  Future<List<Store>> fetchStores() async {
    _resetState(loading: true);
    try {
      final stores = await _storeService.getStores();
      _stores = stores;
      if (_stores.isNotEmpty) {
        _selectedStore ??= _stores.first;
      } else {
        _selectedStore = null;
      }
      return stores;
    } catch (e, stack) {
      _errorNotifier.setError(e.toString());
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sélectionne un magasin spécifique.
  ///
  /// [store] : le magasin à sélectionner, ou `null` pour désélectionner.
  void selectStore(Store? store) {
    _selectedStore = store;
    notifyListeners();
  }

  /// Désélectionne le magasin actuellement sélectionné.
  void clearSelectedStore() {
    _selectedStore = null;
    notifyListeners();
  }

  /// Met à jour un magasin existant avec de nouvelles informations.
  ///
  /// [updated] : l'objet `Store` contenant les nouvelles informations.
  ///
  /// Retourne `true` si la mise à jour a réussi, `false` sinon.
  /// En cas d'erreur, met à jour [errorNotifier].
  Future<bool> updateStore(Store updated) async {
    _resetState(loading: true);
    try {
      final result = await _storeService.updateStore(updated);
      if (result) {
        final idx = _stores.indexWhere((s) => s.id == updated.id);
        if (idx != -1) {
          _stores[idx] = updated;
          _selectedStore = updated;
        }
      }
      return result;
    } catch (e, stack) {
      _errorNotifier.setError(e.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Supprime un magasin par son identifiant.
  ///
  /// [id] : identifiant du magasin à supprimer.
  ///
  /// Retourne `true` si la suppression a réussi, `false` sinon.
  /// En cas d'erreur, met à jour [errorNotifier].
  Future<bool> deleteStore(int id) async {
    _resetState(loading: true);
    try {
      final result = await _storeService.deleteStore(id);
      if (result) {
        _stores.removeWhere((s) => s.id == id);
        if (_stores.isNotEmpty) {
          _selectedStore = _stores.first;
        } else {
          _selectedStore = null;
        }
      }
      return result;
    } catch (e, stack) {
      _errorNotifier.setError(e.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}