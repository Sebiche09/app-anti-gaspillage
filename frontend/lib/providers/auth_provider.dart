// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import '../constants/auth_status.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  
  User? _user;
  String _errorMessage = '';
  AuthStatus _status = AuthStatus.uninitialized;
  
  AuthProvider(this._authService);

  User? get user => _user;
  String get errorMessage => _errorMessage;
  AuthStatus get status => _status;
  
  Future<bool> login(String email, String password) async {
  _status = AuthStatus.authenticating;
  _errorMessage = '';
  notifyListeners();

  try {
    final loginResponse = await _authService.login(email, password);
    
    if (loginResponse.success) {
      _user = loginResponse.user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } else {
      _status = AuthStatus.error;
      _errorMessage = loginResponse.errorMessage ?? 'Identifiants incorrects';
      notifyListeners();
      return false;
    }
  } catch (e) {
    _status = AuthStatus.error;
    _errorMessage = e.toString();
    notifyListeners();
    return false;
  }
}

  Future<bool> register(String email, String password) async {
    _status = AuthStatus.authenticating;
    _errorMessage = '';
    notifyListeners();

    try {
      final registerResponse = await _authService.register(email, password);
      _user = registerResponse.user;
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
    notifyListeners();
  }
}
