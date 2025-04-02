import 'user.dart';

class RegisterResponse {
  final bool success;
  final String? token;
  final String? refreshToken;
  final User? user;
  final String? errorMessage; 

  RegisterResponse({
    required this.success,
    required this.token,
    this.refreshToken,
    this.user,
    this.errorMessage, 
  });
}