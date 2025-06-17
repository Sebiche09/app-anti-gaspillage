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
import 'providers/store_provider.dart';
import 'services/store_service.dart';
import 'ui/screens/merchant/store_screen.dart';
import 'ui/screens/auth/register_screen.dart';
import 'ui/screens/auth/validation_screen.dart';
import 'ui/screens/merchant/merchant_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final apiService = ApiService(
    baseUrl: ApiConfig.baseUrl,
    onSessionExpired: () {
      // Utilise le context global
      final authProvider = Provider.of<AuthProvider>(navigatorKey.currentContext!, listen: false);
      authProvider.logout();
    },
  );
  final authService = AuthService(baseUrl: ApiConfig.baseUrl);
  final merchantService = MerchantService(apiService: apiService);
  final basketService = BasketService(apiService: apiService);
  final storeService = StoreService(apiService: apiService);
  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>(
            create: (_) => AuthProvider(authService),
          ),
          ChangeNotifierProvider<BasketsProvider>(
            create: (_) => BasketsProvider(basketService),
          ),
          ChangeNotifierProvider<MerchantProvider>(
            create: (_) => MerchantProvider(merchantService: merchantService),
          ),
          ChangeNotifierProvider<StoreProvider>(
            create: (_) => StoreProvider(storeService: storeService),
          ),
        ],
        child: const LoadingApp(),
      ),
    ),
  );
}

//Ce widget sert de point d'entrée pour l'application
class LoadingApp extends StatefulWidget {

  const LoadingApp({super.key});
  @override
  _LoadingAppState createState() => _LoadingAppState();
}

//Ce widget gère le chargement des ressources nécessaires avant de lancer l'application principale
class _LoadingAppState extends State<LoadingApp> {
  bool isLoaded = false;

  // Cette méthode est appelée lors de l'initialisation de l'état du widget
  @override
  void initState() {
    super.initState();
    _loadResources();
  }

  // Cette méthode charge les ressources nécessaires, comme la localisation
  Future<void> _loadResources() async {
    await HomeHeader.loadLocation();
    setState(() {
      isLoaded = true;
    });
  }

  // Cette méthode construit l'interface utilisateur du widget
  @override
  Widget build(BuildContext context) {
    if (!isLoaded) {
      return const MaterialApp(
        home: LoadingScreen(),
      );
    }
    return const SoveManje();
  }
}

// Ce widget est le point d'entrée principal de l'application
class SoveManje extends StatefulWidget {
  const SoveManje({super.key});

  @override
  State<SoveManje> createState() => _SoveManjeState();
}

class _SoveManjeState extends State<SoveManje> {
  late Future<void> _initFuture;

  // Cette méthode est appelée lors de l'initialisation de l'état du widget
  @override
  void initState() {
    super.initState();
    _initFuture = Provider.of<AuthProvider>(context, listen: false).initialize();
  }

  // Cette méthode est appelée pour construire l'interface utilisateur du widget
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
              navigatorKey: navigatorKey, // Ajoute le navigatorKey ici !
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
                      ? const BeMerchantScreen()  
                      : const MainScreen())     
                  : const LoginScreen(),       
              routes: {
                '/login': (context) => const LoginScreen(),
                '/register': (context) => const RegisterScreen(),
                '/merchant': (context) => MerchantScreen(),
                '/home': (context) => const MainScreen(),
                '/be_merchant': (context) => const BeMerchantScreen(),
                '/explore': (context) => const ExploreScreen(),
                '/add_store': (context) => const StoreScreen(),
                '/validation': (context) {
                  final email = ModalRoute.of(context)!.settings.arguments as String;
                  return ValidationScreen(email: email);
                },
              },
            );
          },
        );
      },
    );
  }
}