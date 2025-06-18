
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
import 'providers/error_notifier.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider<ErrorNotifier>(
            create: (_) => ErrorNotifier(),
          ),
          ChangeNotifierProxyProvider<ErrorNotifier, AuthProvider>(
            create: (context) {
              final authService = AuthService(baseUrl: ApiConfig.baseUrl);
              return AuthProvider(authService, Provider.of<ErrorNotifier>(context, listen: false));
            },
            update: (context, errorNotifier, previous) {
              if (previous != null) {
                return previous;
              }
              final authService = AuthService(baseUrl: ApiConfig.baseUrl);
              return AuthProvider(authService, errorNotifier);
            },
          ),
          ChangeNotifierProxyProvider2<ErrorNotifier, AuthProvider, BasketsProvider>(
            create: (context) {
              final errorNotifier = Provider.of<ErrorNotifier>(context, listen: false);
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final apiService = ApiService(
                baseUrl: ApiConfig.baseUrl,
                onSessionExpired: () => _handleSessionExpired(context, authProvider),
              );
              final basketService = BasketService(apiService: apiService);
              return BasketsProvider(basketService, errorNotifier);
            },
            update: (context, errorNotifier, authProvider, previous) {
              if (previous != null) {
                return previous;
              }
              final apiService = ApiService(
                baseUrl: ApiConfig.baseUrl,
                onSessionExpired: () => _handleSessionExpired(context, authProvider),
              );
              final basketService = BasketService(apiService: apiService);
              return BasketsProvider(basketService, errorNotifier);
            },
          ),
          ChangeNotifierProxyProvider2<ErrorNotifier, AuthProvider, MerchantProvider>(
            create: (context) {
              final errorNotifier = Provider.of<ErrorNotifier>(context, listen: false);
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final apiService = ApiService(
                baseUrl: ApiConfig.baseUrl,
                onSessionExpired: () => _handleSessionExpired(context, authProvider),
              );
              final merchantService = MerchantService(apiService: apiService);
              return MerchantProvider(merchantService: merchantService, errorNotifier: errorNotifier);
            },
            update: (context, errorNotifier, authProvider, previous) {
              if (previous != null) {
                return previous;
              }
              final apiService = ApiService(
                baseUrl: ApiConfig.baseUrl,
                onSessionExpired: () => _handleSessionExpired(context, authProvider),
              );
              final merchantService = MerchantService(apiService: apiService);
              return MerchantProvider(merchantService: merchantService, errorNotifier: errorNotifier);
            },
          ),
          ChangeNotifierProxyProvider2<ErrorNotifier, AuthProvider, StoreProvider>(
            create: (context) {
              final errorNotifier = Provider.of<ErrorNotifier>(context, listen: false);
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final apiService = ApiService(
                baseUrl: ApiConfig.baseUrl,
                onSessionExpired: () => _handleSessionExpired(context, authProvider),
              );
              final storeService = StoreService(apiService: apiService);
              return StoreProvider(storeService: storeService, errorNotifier: errorNotifier);
            },
            update: (context, errorNotifier, authProvider, previous) {
              if (previous != null) {
                return previous;
              }
              final apiService = ApiService(
                baseUrl: ApiConfig.baseUrl,
                onSessionExpired: () => _handleSessionExpired(context, authProvider),
              );
              final storeService = StoreService(apiService: apiService);
              return StoreProvider(storeService: storeService, errorNotifier: errorNotifier);
            },
          ),
        ],
        child: const LoadingApp(),
      ),
    ),
  );
}

void _handleSessionExpired(BuildContext context, AuthProvider authProvider) {
  // Vérifier si le context est encore valide et monté
  if (!context.mounted) return;
  
  try {
    // Vérifier si l'AuthProvider n'est pas disposé
    if (authProvider.hasListeners) {
      authProvider.logout();
    }
  } catch (e) {
    // Si l'AuthProvider est disposé, naviguer directement vers l'écran de connexion
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    }
  }
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
    if (mounted) {
      setState(() {
        isLoaded = true;
      });
    }
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
    _initFuture = _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    if (mounted) {
      await Provider.of<AuthProvider>(context, listen: false).initialize();
    }
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

            if (authProvider.status == AuthStatus.authenticated && mounted) {
              Future.microtask(() {
                if (mounted) {
                  Provider.of<BasketsProvider>(context, listen: false).fetchBaskets();
                }
              });
            }

            return MaterialApp(
              navigatorKey: navigatorKey,
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
