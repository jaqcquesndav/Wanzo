import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Wanzo models & adapters are now handled in hive_setup.dart
// import 'package:wanzo/features/auth/models/user.dart' as auth_user_model;
// ... (all other model and adapter imports removed)

import 'package:wanzo/utils/theme.dart';

// Core services and utilities
import 'package:wanzo/core/navigation/app_router.dart';
import 'package:wanzo/core/services/api_client.dart';
import 'package:wanzo/core/utils/connectivity_service.dart';
import 'package:wanzo/core/services/database_service.dart';
import 'package:wanzo/core/utils/hive_setup.dart'; // Import hive_setup.dart

// Import SyncService and its dependencies
import 'package:wanzo/core/services/sync_service.dart';
import 'package:wanzo/core/services/product_api_service.dart';
import 'package:wanzo/core/services/customer_api_service.dart';
import 'package:wanzo/core/services/sale_api_service.dart';

// Feature-specific services
import 'package:wanzo/features/auth/services/auth0_service.dart';
import 'package:wanzo/features/auth/services/offline_auth_service.dart';
import 'package:wanzo/features/notifications/services/notification_service.dart';

// Repositories
import 'package:wanzo/features/auth/repositories/auth_repository.dart';
import 'package:wanzo/features/inventory/repositories/inventory_repository.dart';
import 'package:wanzo/features/sales/repositories/sales_repository.dart';
import 'package:wanzo/features/adha/repositories/adha_repository.dart';
import 'package:wanzo/features/customer/repositories/customer_repository.dart';
import 'package:wanzo/features/supplier/repositories/supplier_repository.dart';
import 'package:wanzo/features/settings/repositories/settings_repository.dart';
import 'package:wanzo/features/notifications/repositories/notification_repository.dart';
import 'package:wanzo/features/dashboard/repositories/operation_journal_repository.dart';
import 'package:wanzo/features/expenses/repositories/expense_repository.dart';
import 'package:wanzo/features/financing/repositories/financing_repository.dart';
import 'package:wanzo/features/subscription/repositories/subscription_repository.dart'; // Ensure this import is present

// BLoCs
import 'package:wanzo/features/auth/bloc/auth_bloc.dart';
import 'package:wanzo/features/inventory/bloc/inventory_bloc.dart';
import 'package:wanzo/features/sales/bloc/sales_bloc.dart';
import 'package:wanzo/features/adha/bloc/adha_bloc.dart';
import 'package:wanzo/features/customer/bloc/customer_bloc.dart';
import 'package:wanzo/features/supplier/bloc/supplier_bloc.dart';
import 'package:wanzo/features/settings/bloc/settings_bloc.dart';
import 'package:wanzo/features/notifications/bloc/notifications_bloc.dart';
import 'package:wanzo/features/dashboard/bloc/operation_journal_bloc.dart';
import 'package:wanzo/features/expenses/bloc/expense_bloc.dart';
import 'package:wanzo/features/subscription/bloc/subscription_bloc.dart';
import 'package:wanzo/features/financing/bloc/financing_bloc.dart';

// BLoC Events & States
import 'package:wanzo/features/settings/bloc/settings_event.dart';
import 'package:wanzo/features/settings/bloc/settings_state.dart' as settings_bloc_state;
import 'package:wanzo/features/settings/models/settings.dart' as settings_models; // Keep for ThemeMode access

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter(); // Initialize Hive itself

  await initializeHiveAdapters(); // Call adapter registration from hive_setup.dart
  await openHiveBoxes(); // Call box opening from hive_setup.dart

  // The following Hive.registerAdapter calls are removed as they are now in hive_setup.dart
  // Hive.registerAdapter(auth_user_model.UserAdapter());
  // ... (all other Hive.registerAdapter calls removed)

  // The following Hive.openBox calls are removed as they are now in hive_setup.dart
  // await Hive.openBox<settings_models.Settings>('settingsBox');
  // final syncStatusBox = await Hive.openBox<String>('syncStatusBox'); // This specific one might need to be kept if syncStatusBox is used directly here, or passed from openHiveBoxes
  // For now, assuming syncStatusBox is managed within services that use it, or openHiveBoxes makes it available if needed by main.
  // If syncStatusBox is needed directly in main, openHiveBoxes should return it or it should be opened here after openHiveBoxes.
  // Let's assume for now it's handled by SyncService initialization.
  final syncStatusBox = Hive.box<String>('syncStatusBox'); // Get the already opened box


  final connectivityService = ConnectivityService();
  await connectivityService.init();

  final databaseService = DatabaseService();
  final secureStorage = const FlutterSecureStorage();
  final apiClient = ApiClient();

  // Instantiate specific API services
  final productApiService = ProductApiService(apiClient: apiClient);
  final customerApiService = CustomerApiService(apiClient: apiClient);
  final saleApiService = SaleApiService(apiClient: apiClient);

  final offlineAuthService = OfflineAuthService(
    secureStorage: secureStorage,
    databaseService: databaseService,
    connectivityService: connectivityService,
  );

  final auth0Service = Auth0Service(offlineAuthService: offlineAuthService);
  await auth0Service.init();

  final notificationService = NotificationService();

  // Instantiate Repositories
  final authRepository = AuthRepository(auth0Service: auth0Service);
  await authRepository.init();

  final settingsRepository = SettingsRepository();
  await settingsRepository.init();

  // Initialize notificationService after settingsRepository
  await notificationService.init(await settingsRepository.getSettings());


  final inventoryRepository = InventoryRepository();
  await inventoryRepository.init();

  final salesRepository = SalesRepository();
  await salesRepository.init();

  final adhaRepository = AdhaRepository();
  await adhaRepository.init();

  final customerRepository = CustomerRepository();
  await customerRepository.init();

  final supplierRepository = SupplierRepository();
  await supplierRepository.init();

  final notificationRepository = NotificationRepository();
  await notificationRepository.init();

  final operationJournalRepository = OperationJournalRepository();
  await operationJournalRepository.init();

  final expenseRepository = ExpenseRepository();
  await expenseRepository.init();

  final financingRepository = FinancingRepository();
  await financingRepository.init();

  final subscriptionRepository = SubscriptionRepository(
    expenseRepository: expenseRepository,
    apiService: apiClient,
  );
  // No need to call init on subscriptionRepository if it doesn't have one

  final syncService = SyncService(
    productApiService: productApiService,
    customerApiService: customerApiService,
    saleApiService: saleApiService,
    syncStatusBox: syncStatusBox,
  );
  await syncService.init();

  // Instantiate BLoCs
  final authBloc = AuthBloc(authRepository: authRepository);
  final operationJournalBloc = OperationJournalBloc(repository: operationJournalRepository);

  final inventoryBloc = InventoryBloc(
    inventoryRepository: inventoryRepository,
    journalRepository: operationJournalRepository,
    notificationService: notificationService,
    operationJournalBloc: operationJournalBloc,
  );

  final salesBloc = SalesBloc(
    salesRepository: salesRepository,
    journalRepository: operationJournalRepository,
    operationJournalBloc: operationJournalBloc,
  );
  
  final adhaBloc = AdhaBloc(adhaRepository: adhaRepository);
  
  final customerBloc = CustomerBloc(customerRepository: customerRepository);
  
  final supplierBloc = SupplierBloc(supplierRepository: supplierRepository);

  final settingsBloc = SettingsBloc(
    settingsRepository: settingsRepository,
  )..add(const LoadSettings());
  
  final notificationsBloc = NotificationsBloc(notificationService);

  final expenseBloc = ExpenseBloc(
    expenseRepository: expenseRepository,
    journalRepository: operationJournalRepository,
    operationJournalBloc: operationJournalBloc,
  );
  
  final subscriptionBloc = SubscriptionBloc(subscriptionRepository: subscriptionRepository);

  final financingBloc = FinancingBloc(
    financingRepository: financingRepository,
    operationJournalBloc: operationJournalBloc,
  );
  
  final appRouter = AppRouter(authBloc: authBloc);

  runApp(MyApp(
    appRouter: appRouter,
    authBloc: authBloc,
    inventoryBloc: inventoryBloc,
    salesBloc: salesBloc,
    adhaBloc: adhaBloc,
    customerBloc: customerBloc,
    supplierBloc: supplierBloc,
    settingsBloc: settingsBloc,
    notificationsBloc: notificationsBloc,
    operationJournalBloc: operationJournalBloc,
    expenseBloc: expenseBloc,
    subscriptionBloc: subscriptionBloc,
    financingBloc: financingBloc,
    // Pass repositories
    authRepository: authRepository,
    settingsRepository: settingsRepository,
    inventoryRepository: inventoryRepository,
    salesRepository: salesRepository,
    adhaRepository: adhaRepository,
    customerRepository: customerRepository,
    supplierRepository: supplierRepository,
    notificationRepository: notificationRepository,
    operationJournalRepository: operationJournalRepository,
    expenseRepository: expenseRepository,
    financingRepository: financingRepository,
    subscriptionRepository: subscriptionRepository,
    // Pass services that might be needed via RepositoryProvider (if any)
    // For now, focusing on repositories as per RepositoryProvider.of usage.
    // notificationService: notificationService, // Example if needed
  ));
}

class MyApp extends StatelessWidget {
  final AppRouter appRouter;
  final AuthBloc authBloc;
  final InventoryBloc inventoryBloc;
  final SalesBloc salesBloc;
  final AdhaBloc adhaBloc;
  final CustomerBloc customerBloc;
  final SupplierBloc supplierBloc;
  final SettingsBloc settingsBloc;
  final NotificationsBloc notificationsBloc;
  final OperationJournalBloc operationJournalBloc;
  final ExpenseBloc expenseBloc;
  final SubscriptionBloc subscriptionBloc;
  final FinancingBloc financingBloc;

  // Repositories
  final AuthRepository authRepository;
  final SettingsRepository settingsRepository;
  final InventoryRepository inventoryRepository;
  final SalesRepository salesRepository;
  final AdhaRepository adhaRepository;
  final CustomerRepository customerRepository;
  final SupplierRepository supplierRepository;
  final NotificationRepository notificationRepository;
  final OperationJournalRepository operationJournalRepository;
  final ExpenseRepository expenseRepository;
  final FinancingRepository financingRepository;
  final SubscriptionRepository subscriptionRepository;
  // final NotificationService notificationService; // Example

  const MyApp({
    super.key,
    required this.appRouter,
    required this.authBloc,
    required this.inventoryBloc,
    required this.salesBloc,
    required this.adhaBloc,
    required this.customerBloc,
    required this.supplierBloc,
    required this.settingsBloc,
    required this.notificationsBloc,
    required this.operationJournalBloc,
    required this.expenseBloc,
    required this.subscriptionBloc,
    required this.financingBloc,
    // Repositories
    required this.authRepository,
    required this.settingsRepository,
    required this.inventoryRepository,
    required this.salesRepository,
    required this.adhaRepository,
    required this.customerRepository,
    required this.supplierRepository,
    required this.notificationRepository,
    required this.operationJournalRepository,
    required this.expenseRepository,
    required this.financingRepository,
    required this.subscriptionRepository,
    // required this.notificationService, // Example
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: settingsRepository),
        RepositoryProvider.value(value: inventoryRepository),
        RepositoryProvider.value(value: salesRepository),
        RepositoryProvider.value(value: adhaRepository),
        RepositoryProvider.value(value: customerRepository),
        RepositoryProvider.value(value: supplierRepository),
        RepositoryProvider.value(value: notificationRepository),
        RepositoryProvider.value(value: operationJournalRepository),
        RepositoryProvider.value(value: expenseRepository),
        RepositoryProvider.value(value: financingRepository),
        RepositoryProvider.value(value: subscriptionRepository),
        // If NotificationService needs to be available via RepositoryProvider.of<NotificationService>(context)
        // RepositoryProvider.value(value: notificationService), 
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: authBloc),
          BlocProvider.value(value: inventoryBloc),
          BlocProvider.value(value: salesBloc),
          BlocProvider.value(value: adhaBloc),
          BlocProvider.value(value: customerBloc),
          BlocProvider.value(value: supplierBloc),
          BlocProvider.value(value: settingsBloc),
          BlocProvider.value(value: notificationsBloc),
          BlocProvider.value(value: operationJournalBloc),
          BlocProvider.value(value: expenseBloc),
          BlocProvider.value(value: subscriptionBloc),
          BlocProvider.value(value: financingBloc),
        ],
        child: BlocBuilder<SettingsBloc, settings_bloc_state.SettingsState>(
          builder: (context, settingsState) {
            ThemeMode currentThemeMode = ThemeMode.light; // Default to light
            if (settingsState is settings_bloc_state.SettingsLoaded) {
              currentThemeMode = settingsState.settings.themeMode == settings_models.AppThemeMode.dark
                  ? ThemeMode.dark
                  : ThemeMode.light;
            } else if (settingsState is settings_bloc_state.SettingsUpdated) {
              currentThemeMode = settingsState.settings.themeMode == settings_models.AppThemeMode.dark
                  ? ThemeMode.dark
                  : ThemeMode.light;
            }

            return MaterialApp.router(
              title: 'Wanzo',
              theme: WanzoTheme.lightTheme,
              darkTheme: WanzoTheme.darkTheme,
              themeMode: currentThemeMode,
              routerConfig: appRouter.router,
              debugShowCheckedModeBanner: false,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en', ''), 
                Locale('fr', 'FR'),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Helper function to show a loading dialog (optional)
void showLoadingDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Text(message),
          ],
        ),
      );
    },
  );
}

// Helper function to hide the loading dialog (optional)
void hideLoadingDialog(BuildContext context) {
  Navigator.of(context, rootNavigator: true).pop();
}
