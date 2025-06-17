import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../constants/auth_status.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../constants/app_text.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;

  User? _user;
  String _errorMessage = '';
  AuthStatus _status = AuthStatus.uninitialized;
  bool _isMerchant = false;

  AuthProvider(this._authService);

  User? get user => _user;
  String get errorMessage => _errorMessage;
  AuthStatus get status => _status;
  bool get isMerchant => _isMerchant;

  Future<void> initialize() async {
    final isLoggedIn = await _authService.isLoggedIn();

    if (isLoggedIn) {
      _user = await _authService.getCurrentUser();
      final token = await _authService.getToken();
      _isMerchant = _decodeMerchantStatus(token);
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
      _isMerchant = false;
    }
    notifyListeners();
    print("AuthProvider initialized: isLoggedIn=$isLoggedIn, user=$_user, isMerchant=$_isMerchant");
  }

  Future<String?> login(String email, String password) async {
    _status = AuthStatus.authenticating;
    _errorMessage = '';
    notifyListeners();

    try {
      final loginResponse = await _authService.login(email, password);
      if (loginResponse.success) {
        _user = loginResponse.user;
        final token = loginResponse.token;
        _isMerchant = _decodeMerchantStatus(token);

        _status = AuthStatus.authenticated;
        notifyListeners();
        return null; 
      } else {
        _status = AuthStatus.error;
        _errorMessage = loginResponse.errorMessage ?? TextLogin.IncorrectCredentials;
        notifyListeners();

        if (loginResponse.errorMessage == "Please confirm your email before logging in.") {
        return TextLogin.confirmEmailCode;
        }
      return loginResponse.errorMessage;
      }
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return e.toString();
    }
  }


  Future<bool> register(String email, String password) async {
    _status = AuthStatus.authenticating;
    _errorMessage = '';
    notifyListeners();

    try {
      final registerResponse = await _authService.register(email, password);
      _user = registerResponse.user;
      _isMerchant = _decodeMerchantStatus(registerResponse.token);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    _isMerchant = false;
    notifyListeners();
  }

  bool _decodeMerchantStatus(String? token) {
    if (token == null) return false;
    final decodedToken = JwtDecoder.decode(token);
    return decodedToken['isMerchant'] ?? false;
  }

  Future<bool> verifyCode(String email, String code) async {
    _status = AuthStatus.authenticating;
    _errorMessage = '';
    notifyListeners();

    final success = await _authService.verifyCode(email, code);

    if (success) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } else {
      _status = AuthStatus.error;
      _errorMessage = 'Code de vérification incorrect';
      notifyListeners();
      return false;
    }
  }
  Future<bool> resendCode(String email) async {
    try {
      await _authService.resendVerificationCode(email);
      return true;
    } catch (e) {
      _errorMessage = "Erreur lors de l'envoi du code : $e";
      notifyListeners();
      return false;
    }
  }
}
