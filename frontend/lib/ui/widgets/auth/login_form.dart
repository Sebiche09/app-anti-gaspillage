
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text.dart';
import '../../../providers/auth_provider.dart';
import '../../../constants/auth_status.dart';
import '../../../ui/screens/main_screen.dart';
import '../../screens/auth/validation_screen.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>(); 
  final _emailController = TextEditingController(); 
  final _passwordController = TextEditingController(); 
  bool _obscurePassword = true;
  bool _isLoggingIn = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_isLoggingIn) return;
    
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoggingIn = true;
      });

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        
        if (!authProvider.hasListeners) {
          if (mounted) {
            setState(() {
              _isLoggingIn = false;
            });
          }
          return;
        }

        final result = await authProvider.login(
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (!mounted) return;

        setState(() {
          _isLoggingIn = false;
        });

        if (result == null) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            authProvider.isMerchant ? TextLogin.merchantRoute : TextLogin.homeRoute,
            (route) => false, 
          );
        } else if (result == TextLogin.confirmEmailCode) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            TextLogin.validationRoute,
            (route) => false,
            arguments: _emailController.text.trim(),
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(TextLogin.emailNotConfirmedMessage),
                backgroundColor: AppColors.error,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result ?? TextLogin.loginFailedMessage),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoggingIn = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur de connexion: ${e.toString()}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final isLoading = _isLoggingIn || authProvider.status == AuthStatus.authenticating;

        return Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                enabled: !isLoading,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.formColor,
                  hintText: TextLogin.emailHint,
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return TextLogin.ValidatorMessageEmailEmpty;
                  }
                  if (!RegExp(TextLogin.RegexEmailPattern).hasMatch(value)) {
                    return TextLogin.ValidatorMessageEmailInvalid;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                enabled: !isLoading,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.formColor,
                  hintText: TextLogin.passwordHint,
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: isLoading ? null : () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return TextLogin.ValidatorMessagePasswordEmpty;
                  }
                  if (value.length < 6) {
                    return TextLogin.ValidatorMessagePasswordShort;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    TextLogin.loginButton,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextButton(
                onPressed: isLoading ? null : () {
                },
                child: const Text(
                  TextLogin.forgotPassword,
                  style: TextStyle(color: AppColors.secondary),
                ),
              ),

              const SizedBox(height: 24),

              if (authProvider.status == AuthStatus.error && authProvider.errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: Text(
                    authProvider.errorMessage!,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
