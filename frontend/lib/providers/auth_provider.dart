import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../constants/auth_status.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../constants/app_text.dart';
import 'error_notifier.dart';

/// Provider pour la gestion de l'authentification.
///
/// Permet de gérer la connexion, l'inscription, la déconnexion,
/// la vérification de code, et l'état d'authentification de l'utilisateur.
/// Utilise un [AuthService] pour communiquer avec l'API.
/// Les erreurs sont remontées via un [ErrorNotifier] global.
class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  final ErrorNotifier _errorNotifier;

  User? _user;
  AuthStatus _status = AuthStatus.uninitialized;
  bool _isMerchant = false;

  /// Initialise le provider avec un service d'authentification et un ErrorNotifier.
  AuthProvider(this._authService, this._errorNotifier);

  User? get user => _user;
  AuthStatus get status => _status;
  bool get isMerchant => _isMerchant;

  /// Retourne le message d'erreur actuel, ou null s'il n'y en a pas.
  String? get errorMessage => _errorNotifier.errorMessage;

  /// Met à jour l'état d'authentification et le message d'erreur.
  void _setStatus(AuthStatus status, {String errorMessage = '', bool notify = true}) {
    _status = status;
    if (errorMessage.isNotEmpty) {
      _errorNotifier.setError(errorMessage);
    } else {
      _errorNotifier.clearError();
    }
    if (notify) notifyListeners();
  }

  /// Met à jour l'utilisateur courant et le statut marchand à partir du token JWT.
  void _setUser(User? user, String? token) {
    _user = user;
    _isMerchant = _decodeMerchantStatus(token);
  }

  /// Décode le statut marchand à partir du token JWT.
  bool _decodeMerchantStatus(String? token) {
    if (token == null) return false;
    final decodedToken = JwtDecoder.decode(token);
    return decodedToken['isMerchant'] ?? false;
  }

  /// Initialise l'état d'authentification au démarrage de l'application.
  Future<void> initialize() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        final user = await _authService.getCurrentUser();
        final token = await _authService.getToken();
        _setUser(user, token);
        _setStatus(AuthStatus.authenticated);
      } else {
        _setUser(null, null);
        _setStatus(AuthStatus.unauthenticated);
      }
    } catch (e) {
      _setStatus(AuthStatus.error, errorMessage: e.toString());
    }
  }

  /// Effectue la connexion avec email et mot de passe.
  ///
  /// Retourne `null` si la connexion réussit, sinon un message d'erreur.
  /// En cas d'erreur spécifique, retourne un code texte pour gestion UI.
  Future<String?> login(String email, String password) async {
    _setStatus(AuthStatus.authenticating);
    try {
      final loginResponse = await _authService.login(email, password);
      if (loginResponse.success) {
        _setUser(loginResponse.user, loginResponse.token);
        _setStatus(AuthStatus.authenticated);
        return null;
      } else {
        final errorMsg = loginResponse.errorMessage ?? TextLogin.IncorrectCredentials;
        _setStatus(AuthStatus.error, errorMessage: errorMsg);
        if (errorMsg == "Please confirm your email before logging in.") {
          return TextLogin.confirmEmailCode;
        }
        return errorMsg;
      }
    } catch (e) {
      _setStatus(AuthStatus.error, errorMessage: e.toString());
      return e.toString();
    }
  }

  /// Effectue l'inscription avec email et mot de passe.
  ///
  /// Retourne `true` si l'inscription réussit, `false` sinon.
  Future<bool> register(String email, String password) async {
    _setStatus(AuthStatus.authenticating);
    try {
      final registerResponse = await _authService.register(email, password);
      _setUser(registerResponse.user, registerResponse.token);
      _setStatus(AuthStatus.authenticated);
      return true;
    } catch (e) {
      _setStatus(AuthStatus.error, errorMessage: e.toString());
      return false;
    }
  }

  /// Effectue la déconnexion.
  Future<void> logout() async {
    await _authService.logout();
    _setUser(null, null);
    _setStatus(AuthStatus.unauthenticated);
  }

  /// Vérifie le code envoyé par email.
  ///
  /// Retourne `true` si le code est correct, `false` sinon.
  Future<bool> verifyCode(String email, String code) async {
    _setStatus(AuthStatus.authenticating);
    try {
      final success = await _authService.verifyCode(email, code);
      if (success) {
        _setStatus(AuthStatus.unauthenticated);
        return true;
      } else {
        _setStatus(AuthStatus.error, errorMessage: 'Code de vérification incorrect');
        return false;
      }
    } catch (e) {
      _setStatus(AuthStatus.error, errorMessage: e.toString());
      return false;
    }
  }

  /// Renvoyer le code de vérification par email.
  ///
  /// Retourne `true` si l'envoi réussit, `false` sinon.
  Future<bool> resendCode(String email) async {
    try {
      await _authService.resendVerificationCode(email);
      return true;
    } catch (e) {
      _setStatus(_status, errorMessage: "Erreur lors de l'envoi du code : $e");
      return false;
    }
  }
}