import 'user.dart';

class LoginResponse {
  final bool success;
  final String? token;
  final String? refreshToken;
  final User? user;
  final String? errorMessage; 

  LoginResponse({
    required this.success,
    required this.token,
    this.refreshToken,
    this.user,
    this.errorMessage, 
  });
}