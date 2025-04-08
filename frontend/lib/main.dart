import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:device_preview/device_preview.dart';
import 'dart:ui_web' as ui; 

import 'constants/auth_status.dart';
import 'providers/auth_provider.dart';
import 'providers/basket_provider.dart'; 
import 'services/auth_service.dart';
import 'services/api_service.dart'; 
import 'services/basket_service.dart';
import '/ui/screens/auth/login_screen.dart';
import '/ui/screens/home_screen.dart';
import '/ui/screens/explore_screen.dart';
import 'utils/api_config.dart';
import 'dart:html' as html;
import 'ui/widgets/home/home_header.dart';
import 'ui/screens/loading_screen.dart';
import 'ui/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerViewFactory();

  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => const LoadingApp(),
    ),
  );
}

class LoadingApp extends StatefulWidget {
  const LoadingApp({super.key});

  @override
  _LoadingAppState createState() => _LoadingAppState();
}

class _LoadingAppState extends State<LoadingApp> {
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadResources();
  }

  Future<void> _loadResources() async {
    await HomeHeader.loadLocation();
    setState(() {
      isLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoaded) {
      return const MaterialApp(
        home: LoadingScreen(),
      );
    }
    return const MyApp();
  }
}


void registerViewFactory() {
  ui.platformViewRegistry.registerViewFactory('mapbox-container', (int viewId) {
    final html.DivElement mapContainer = html.DivElement()
      ..id = 'mapbox-container'
      ..style.width = '100%'
      ..style.height = '100%';
    return mapContainer;
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService(baseUrl: ApiConfig.baseUrl);
    final authService = AuthService(baseUrl: ApiConfig.baseUrl);
    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(authService),
        ),
        ChangeNotifierProvider<BasketsProvider>(
          create: (_) => BasketsProvider(
            BasketService(apiService: apiService),
          ),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          // Chargez les paniers après authentification
          if (authProvider.status == AuthStatus.authenticated) {
            Future.microtask(() => 
              Provider.of<BasketsProvider>(context, listen: false).fetchBaskets()
            );
          }
          
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
              scaffoldBackgroundColor: Colors.white,
              useMaterial3: true,
            ),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/home': (context) => const MainScreen(),
              '/explore': (context) => const ExploreScreen(),
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
