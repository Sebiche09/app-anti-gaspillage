import 'package:flutter/foundation.dart';
import '../services/merchant_service.dart';

enum MerchantApplicationStatus {
  notApplied,  // N'a pas postulé
  pending,     // En attente de validation
  approved,    // Approuvé
  rejected,    // Rejeté
}

class MerchantProvider with ChangeNotifier {
  final MerchantService _merchantService;
  
  MerchantApplicationStatus _status = MerchantApplicationStatus.notApplied;
  String? _errorMessage;
  bool _isLoading = false;
  Map<String, dynamic>? _merchantData;

  MerchantProvider({required MerchantService merchantService}) 
      : _merchantService = merchantService;

  // Getters
  MerchantApplicationStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get merchantData => _merchantData;
  bool get hasApplication => _status != MerchantApplicationStatus.notApplied;
  
  // Vérifie le statut actuel du marchand
  Future<bool> checkApplicationStatus() async {
    try {
      _setLoading(true);
      _clearError();
      
      final result = await _merchantService.checkMerchantStatus();
      print("Result from API: $result");
      
      // Si vous recevez directement la réponse sans wrapper
      _merchantData = result; // Stocker toutes les données reçues
      
      // Déterminer le statut
      if (result != null && result.containsKey('status') && result['status'] != null) {
        final apiStatus = result['status'] as String;
        
        switch (apiStatus.toLowerCase()) {
          case 'pending':
            _status = MerchantApplicationStatus.pending;
            break;
          case 'approved':
            _status = MerchantApplicationStatus.approved;
            break;
          case 'rejected':
            _status = MerchantApplicationStatus.rejected;
            break;
          default:
            _status = MerchantApplicationStatus.notApplied;
        }
      } else {
        _status = MerchantApplicationStatus.notApplied;
      }
      
      print("Status set to: $_status");
      notifyListeners();
      return true;
    } catch (e) {
      print("Error in checkApplicationStatus: $e");
      _setError(e.toString());
      _status = MerchantApplicationStatus.notApplied;
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }


  
  // Soumet une demande pour devenir marchand
  Future<bool> submitApplication({
    required String businessName,
    required String emailPro,
    required String siren,
    required String phoneNumber,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      // Validation du SIREN
      final isValidSiren = await _merchantService.validateSiren(siren);
      if (!isValidSiren) {
        _setError('Le numéro SIREN est invalide');
        return false;
      }
      
      final result = await _merchantService.submitMerchantApplication(
        businessName: businessName,
        emailPro: emailPro,
        siren: siren,
        phoneNumber: phoneNumber,
      );
      
      if (result['success']) {
        _status = MerchantApplicationStatus.pending;
        _merchantData = result['data'];
        notifyListeners();
        return true;
      } else {
        _setError(result['message']);
        return false;
      }
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
