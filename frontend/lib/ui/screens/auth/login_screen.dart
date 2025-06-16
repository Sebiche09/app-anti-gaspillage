import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_styles.dart';
import '../../../constants/app_text.dart';
import '../../widgets/auth/login_form.dart';
import '../../widgets/auth/register_link.dart';
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                const SizedBox(height: 12),
                Text(
                  AppText.loginTitle,
                  style: AppStyles.titleStyle,
                  textAlign: TextAlign.center,
                ),
                Text(
                  AppText.loginSubtitle,
                  style: AppStyles.subtitleStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                const LoginForm(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: RegisterLink(
        onPressed: () {
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => const RegisterScreen()),
          );
        },
      ),
    );
  }
}
