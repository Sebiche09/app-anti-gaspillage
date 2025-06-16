import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class LoginLink extends StatelessWidget {
  final VoidCallback onPressed;

  const LoginLink({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Dejà un compte ? ',
            style: TextStyle(color: Colors.grey),
          ),
          GestureDetector(
            onTap: onPressed,
            child: const Text(
              'CONNEXION',
              style: TextStyle(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
