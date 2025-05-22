import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart'; // Ajout de l'import
import '../../features/auth/screens/splash_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/inventory/models/product.dart';
import '../../features/inventory/screens/add_product_screen.dart';
import '../../features/inventory/screens/inventory_screen.dart';
import '../../features/inventory/screens/product_details_screen.dart';
import '../../features/sales/models/sale.dart';
import '../../features/sales/screens/add_sale_screen.dart';
import '../../features/sales/screens/sale_details_screen.dart';
import '../../features/sales/screens/sales_screen.dart';
import '../../features/adha/screens/adha_screen.dart'; // Updated import
import '../../features/customer/models/customer.dart';
import '../../features/customer/screens/customers_screen.dart';
import '../../features/customer/screens/add_customer_screen.dart';
import '../../features/customer/screens/customer_details_screen.dart';
import '../../features/supplier/models/supplier.dart';
import '../../features/supplier/screens/suppliers_screen.dart';
import '../../features/supplier/screens/add_supplier_screen.dart';
import '../../features/supplier/screens/supplier_details_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/notifications/screens/notification_settings_screen.dart';
import '../../features/contacts/screens/contacts_screen.dart'; // Import the new contacts screen
import '../../features/expenses/screens/add_expense_screen.dart'; // Added import
import '../../features/financing/screens/add_financing_request_screen.dart';
import '../../features/profile/screens/profile_screen.dart'; // Import ProfileScreen
import '../../features/subscription/screens/subscription_screen.dart'; // Import SubscriptionScreen

/// Configuration des routes de l'application
class AppRouter {
  final AuthBloc authBloc;

  AppRouter({required this.authBloc});

  late final GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: '/', // Keep initial location as splash
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (BuildContext context, GoRouterState state) {
      final authState = authBloc.state;
      final isAuthenticated = authState is AuthAuthenticated;
      final isAuthenticating = authState is AuthLoading; // Or any state indicating an auth process

      final onAuthScreens = state.matchedLocation == '/login' || 
                            state.matchedLocation == '/signup' || 
                            state.matchedLocation == '/onboarding';
      final onSplashScreen = state.matchedLocation == '/';

      if (isAuthenticating || (onSplashScreen && authState is AuthInitial)) {
        // If authenticating or on splash and still in AuthInitial, stay on splash or show loading
        // No redirection needed here as SplashScreen handles its own logic based on AuthBloc state
        return null; 
      }

      if (!isAuthenticated && !onAuthScreens && !onSplashScreen) {
        // If not authenticated and not on auth screens or splash, redirect to login
        return '/login';
      }

      if (isAuthenticated && (onAuthScreens || onSplashScreen)) {
        // If authenticated and on auth screens or splash, redirect to dashboard
        return '/dashboard';
      }
      
      // No redirection needed
      return null;
    },
    routes: [
      // Route initiale affichant le splash screen
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Route d'onboarding
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
        // Route de connexion
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      
      // Route d'inscription
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      
      // Route pour le mot de passe oublié
      GoRoute(
        path: ForgotPasswordScreen.routeName,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      
      // Route du tableau de bord (protégée)
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      
      // Route de gestion du financement
      GoRoute(
        path: '/financing/add',
        builder: (context, state) => const AddFinancingRequestScreen(),
      ),

      // Route de gestion des ventes
      GoRoute(
        path: '/sales',
        builder: (context, state) => const SalesScreen(),
        routes: [
          // Route d'ajout d'une vente
          GoRoute(
            path: 'add',
            builder: (context, state) => const AddSaleScreen(),
          ),
          // Route de détail d'une vente
          GoRoute(
            path: ':saleId',            builder: (context, state) {
              // Récupération de l'identifiant de la vente depuis l'URL
              // final saleId = state.pathParameters['saleId'] ?? '';
              final sale = state.extra as Sale?;
              if (sale != null) {
                return SaleDetailsScreen(sale: sale);
              }
              // Dans un cas réel, vous voudriez récupérer la vente depuis le repository
              // en utilisant saleId si elle n'est pas passée en extra
              return const SalesScreen();
            },
          ),
        ],
      ),
        // Route de gestion de l'inventaire
      GoRoute(
        path: '/inventory',
        builder: (context, state) => const InventoryScreen(),
        routes: [
          // Route d'ajout d'un produit
          GoRoute(
            path: 'add',
            builder: (context, state) => const AddProductScreen(),
          ),          // Route de modification d'un produit
          GoRoute(
            path: 'edit/:productId',
            builder: (context, state) {
              final product = state.extra as Product?;
              return AddProductScreen(product: product);
            },
          ),
          // Route de détail d'un produit
          GoRoute(
            path: ':productId',
            builder: (context, state) {
              final product = state.extra as Product?;
              final productId = state.pathParameters['productId'] ?? '';
              return ProductDetailsScreen(
                productId: productId,
                product: product,
              );
            },          ),
        ],
      ),
      
      // Route de gestion des contacts (clients et fournisseurs)
      GoRoute(
        path: '/contacts',
        builder: (context, state) => const ContactsScreen(),
        // Child routes for adding/editing customers/suppliers can still exist if needed,
        // but primary access is through the ContactsScreen tabs.
        // The FAB in ContactsScreen will navigate to these.
      ),
      
      // Route de l'assistant Adha - Directement vers l'écran de chat
      GoRoute(
        path: '/adha',
        builder: (context, state) => const AdhaScreen(),
      ),
      
      // Route de gestion des clients
      // Le builder principal est commenté pour que /customers ne charge pas CustomersScreen.
      // ContactsScreen est l'écran principal pour lister les clients.
      GoRoute(
        path: '/customers',
        builder: (context, state) => const SizedBox.shrink(), // Added to prevent pageBuilder=null error
        routes: [
          GoRoute(
            path: 'add',
            builder: (context, state) => const AddCustomerScreen(),
          ),
          GoRoute(
            path: 'edit/:customerId',
            builder: (context, state) {
              final customer = state.extra as Customer?;
              return AddCustomerScreen(customer: customer);
            },
          ),
          GoRoute(
            path: ':customerId',
            builder: (context, state) {
              final customer = state.extra as Customer?;
              final customerId = state.pathParameters['customerId'] ?? '';
              return CustomerDetailsScreen(
                customerId: customerId,
                customer: customer,
              );
            },
          ),
        ],
      ),
      
      // Route de gestion des fournisseurs
      // Le builder principal est commenté pour que /suppliers ne charge pas SuppliersScreen.
      // ContactsScreen est l'écran principal pour lister les fournisseurs.
      GoRoute(
        path: '/suppliers',
        builder: (context, state) => const SizedBox.shrink(), // Added to prevent pageBuilder=null error
        routes: [
          GoRoute(
            path: 'add',
            builder: (context, state) => const AddSupplierScreen(),
          ),
          GoRoute(
            path: 'edit/:supplierId',
            builder: (context, state) {
              final supplier = state.extra as Supplier?;
              return AddSupplierScreen(supplier: supplier);
            },
          ),
          GoRoute(
            path: ':supplierId',
            builder: (context, state) {
              final supplier = state.extra as Supplier?;
              final supplierId = state.pathParameters['supplierId'] ?? '';
              return SupplierDetailsScreen(
                supplierId: supplierId,
                supplier: supplier,
              );
            },
          ),
        ],
      ),
      
      // Route des paramètres
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
        routes: [
          // Route des paramètres de notification
          GoRoute(
            path: 'notifications',
            builder: (context, state) {
              final settings = state.extra as dynamic;
              return NotificationSettingsScreen(settings: settings);
            },
          ),
        ],
      ),
      
      // Route des notifications
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      
      // Route d'ajout d'une dépense
      GoRoute(
        path: '/expenses/add',
        builder: (context, state) => const AddExpenseScreen(),
      ),
      // Route du profil utilisateur
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      // Route de gestion des abonnements
      GoRoute(
        path: '/subscription',
        builder: (context, state) => const SubscriptionScreen(),
      ),
    ],
  );
}

/// Classe permettant d'écouter les changements d'état d'authentification
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;
  
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
