import 'package:flutter/foundation.dart';
import '../services/merchant_service.dart';
import 'error_notifier.dart';
import '../models/merchant_application_status.dart';

/// Provider pour la gestion de l'application marchand.
///
/// Permet de vérifier le statut de la candidature, de soumettre une demande,
/// et de récupérer les données du marchand.
/// Utilise un [MerchantService] pour communiquer avec l'API.
/// Les erreurs sont remontées via un [ErrorNotifier] global.
class MerchantProvider with ChangeNotifier {
  final MerchantService _merchantService;
  final ErrorNotifier _errorNotifier;

  MerchantApplicationStatus _status = MerchantApplicationStatus.notApplied;
  bool _isLoading = false;
  Map<String, dynamic>? _merchantData;

  MerchantProvider({
    required MerchantService merchantService,
    required ErrorNotifier errorNotifier,
  })  : _merchantService = merchantService,
        _errorNotifier = errorNotifier;

  MerchantApplicationStatus get status => _status;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get merchantData => _merchantData;
  bool get hasApplication => _status != MerchantApplicationStatus.notApplied;

  String get statusLabel {
    switch (_status) {
      case MerchantApplicationStatus.pending:
        return "En attente";
      case MerchantApplicationStatus.approved:
        return "Approuvé";
      case MerchantApplicationStatus.rejected:
        return "Rejeté";
      default:
        return "Non postulé";
    }
  }

  /// Réinitialise l'état interne du provider.
  ///
  /// [loading] : indique si une opération de chargement est en cours.
  void _resetState({bool loading = false}) {
    _isLoading = loading;
    _errorNotifier.clearError();
  }

  /// Vérifie le statut actuel du marchand.
  ///
  /// Retourne `true` si la récupération a réussi, `false` sinon.
  /// En cas d'erreur, met à jour [ErrorNotifier].
  Future<bool> checkApplicationStatus() async {
    _resetState(loading: true);
    try {
      final result = await _merchantService.checkMerchantStatus();
      _merchantData = result;

      // Déterminer le statut
      final apiStatus = (result?['status'] as String?)?.toLowerCase();
      switch (apiStatus) {
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
      return true;
    } catch (e, stack) {
      _errorNotifier.setError(e.toString());
      _status = MerchantApplicationStatus.notApplied;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Soumet une demande pour devenir marchand.
  ///
  /// Paramètres requis :
  /// - [businessName] : nom de l'entreprise.
  /// - [emailPro] : email professionnel.
  /// - [siren] : numéro SIREN.
  /// - [phoneNumber] : numéro de téléphone.
  ///
  /// Retourne `true` si la soumission a réussi, `false` sinon.
  /// En cas d'erreur, met à jour [ErrorNotifier].
  Future<bool> submitApplication({
    required String businessName,
    required String emailPro,
    required String siren,
    required String phoneNumber,
  }) async {
    _resetState(loading: true);
    try {
      // Validation du SIREN
      final isValidSiren = await _merchantService.validateSiren(siren);
      if (!isValidSiren) {
        _errorNotifier.setError('Le numéro SIREN est invalide');
        return false;
      }

      final result = await _merchantService.submitMerchantApplication(
        businessName: businessName,
        emailPro: emailPro,
        siren: siren,
        phoneNumber: phoneNumber,
      );

      if (result['success'] == true) {
        _status = MerchantApplicationStatus.pending;
        _merchantData = result['data'];
        return true;
      } else {
        _errorNotifier.setError(result['message'] ?? "Erreur inconnue");
        return false;
      }
    } catch (e, stack) {
      _errorNotifier.setError(e.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}