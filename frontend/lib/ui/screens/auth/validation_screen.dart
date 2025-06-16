import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_styles.dart';
import '../../../constants/app_text.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/auth/verification_form.dart';
import '../../widgets/auth/resend_code_link.dart';


class ValidationScreen extends StatelessWidget {
  final String email;
  
  const ValidationScreen({
    super.key,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/logo.png',
                  height: 120,
                ),
                const SizedBox(height: 32),
                Text(
                  'Vérification',
                  style: AppStyles.titleStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Entrez le code de vérification envoyé à',
                  style: AppStyles.subtitleStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: AppStyles.subtitleStyle.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                VerificationForm(email: email),
                const SizedBox(height: 24),
                Text(
                  'Vous n\'avez pas reçu le code ?',
                  style: AppStyles.subtitleStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                ResendCodeLink(
                  email: email,
                  onPressed: () {
                    _resendVerificationCode(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _resendVerificationCode(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.resendCode(email);

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
        content: Text(
            success
                ? 'Code de vérification renvoyé'
                : authProvider.errorMessage.isNotEmpty
                    ? authProvider.errorMessage
                    : 'Erreur lors de l\'envoi du code',
        ),
        duration: const Duration(seconds: 2),
        ),
    );
  }      
}