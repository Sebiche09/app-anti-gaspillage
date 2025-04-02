// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:device_preview/device_preview.dart';
import 'constants/auth_status.dart';
import 'providers/auth_provider.dart';
import 'services/auth_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'utils/api_config.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthProvider>(
      create: (context) => AuthProvider(
        AuthService(baseUrl: ApiConfig.baseUrl),
      ),
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            useInheritedMediaQuery: true,
            locale: DevicePreview.locale(context),
            builder: DevicePreview.appBuilder,
            title: 'Sové Manjé',
            theme: ThemeData(
              primaryColor: const Color(0xFF3B4929),
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF3B4929),
                primary: const Color(0xFF3B4929),
              ),
              scaffoldBackgroundColor: const Color(0xFF3B4929),
              useMaterial3: true,
            ),
            // Définissez vos routes ici
            routes: {
              '/login': (context) => const LoginScreen(),
              '/home': (context) => const HomeScreen(),
            },
            initialRoute: authProvider.status == AuthStatus.authenticated
                ? '/home'
                : '/login',
          );
        },
      ),
    );
  }
}
