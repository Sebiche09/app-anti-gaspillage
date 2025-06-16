import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:device_preview/device_preview.dart';
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
import 'ui/widgets/home/home_header.dart';
import 'ui/screens/loading_screen.dart';
import 'ui/screens/main_screen.dart';
import 'ui/screens/be_merchant_screen.dart';
import 'providers/merchant_provider.dart';
import 'services/merchant_service.dart';
import 'providers/restaurant_provider.dart';
import 'services/restaurant_service.dart';
import 'ui/screens/merchant/restaurant_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final apiService = ApiService(baseUrl: ApiConfig.baseUrl);
  final authService = AuthService(baseUrl: ApiConfig.baseUrl);
  final merchantService = MerchantService(apiService: apiService);

  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>(
            create: (_) => AuthProvider(authService),
          ),
          ChangeNotifierProvider<BasketsProvider>(
            create: (_) => BasketsProvider(
              BasketService(apiService: apiService),
            ),
          ),
          ChangeNotifierProvider<MerchantProvider>(
            create: (_) => MerchantProvider(merchantService: merchantService),
          ),
          // Ajoutez ce provider
          ChangeNotifierProvider<RestaurantProvider>(
            create: (_) => RestaurantProvider(
              restaurantService: RestaurantService(apiService: apiService),
            ),
          ),
        ],
        child: const LoadingApp(),
      ),
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = Provider.of<AuthProvider>(context, listen: false).initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return FutureBuilder(
          future: _initFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const MaterialApp(home: LoadingScreen());
            }

            if (authProvider.status == AuthStatus.authenticated) {
              Future.microtask(() {
                Provider.of<BasketsProvider>(context, listen: false).fetchBaskets();
              });
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
              home: authProvider.status == AuthStatus.authenticated
                  ? (authProvider.isMerchant
                      ? const BeMerchantScreen()  // Écran marchand
                      : const MainScreen())     // Écran classique
                  : const LoginScreen(),         // Écran de connexion
              routes: {
                '/login': (context) => const LoginScreen(),
                '/home': (context) => const MainScreen(),
                '/be_merchant': (context) => const BeMerchantScreen(),
                '/explore': (context) => const ExploreScreen(),
                '/add_restaurant': (context) => const RestaurantScreen(),
              },
            );
          },
        );
      },
    );
  }
}
