import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Image.asset('assets/mini_logo.png'),
      ),
    );
  }
}
