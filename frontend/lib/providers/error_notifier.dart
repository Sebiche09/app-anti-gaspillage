import 'package:flutter/foundation.dart';


//// Notifier pour gérer les erreurs globales dans l'application.
/// Permet de définir un message d'erreur, de le récupérer,
/// et de le supprimer. Utilisé pour informer les utilisateurs
/// des erreurs rencontrées lors des opérations de l'application.
class ErrorNotifier with ChangeNotifier {
  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  void setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}