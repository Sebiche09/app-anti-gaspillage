import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class RegisterLink extends StatelessWidget {
  final VoidCallback onPressed;

  const RegisterLink({
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
            'Pas encore de compte ? ',
            style: TextStyle(color: Colors.grey),
          ),
          GestureDetector(
            onTap: onPressed,
            child: const Text(
              'INSCRIPTION',
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
