import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:wanzo/l10n/app_localizations.dart';

import 'package:wanzo/utils/theme.dart';

import 'package:wanzo/core/navigation/app_router.dart';
import 'package:wanzo/core/services/api_client.dart';
import 'package:wanzo/core/utils/connectivity_service.dart';
import 'package:wanzo/core/services/database_service.dart';
import 'package:wanzo/core/utils/hive_setup.dart';

import 'package:wanzo/core/services/sync_service.dart';
import 'package:wanzo/core/services/product_api_service.dart';
import 'package:wanzo/core/services/customer_api_service.dart';
import 'package:wanzo/core/services/sale_api_service.dart';

import 'package:wanzo/features/auth/services/auth0_service.dart';
import 'package:wanzo/features/auth/services/offline_auth_service.dart';
import 'package:wanzo/features/notifications/services/notification_service.dart';

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
import 'package:wanzo/features/subscription/repositories/subscription_repository.dart';
import 'package:wanzo/features/transactions/repositories/transaction_repository.dart';

import 'package:wanzo/core/services/currency_service.dart';
import 'package:wanzo/features/settings/presentation/cubit/currency_settings_cubit.dart';

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
import 'package:wanzo/features/dashboard/bloc/dashboard_bloc.dart';

import 'package:wanzo/features/settings/bloc/settings_event.dart';
import 'package:wanzo/features/settings/bloc/settings_state.dart' as settings_bloc_state;
import 'package:wanzo/features/settings/models/settings.dart' as settings_models;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  await initializeHiveAdapters();
  await openHiveBoxes();

  final syncStatusBox = Hive.box<String>('syncStatusBox');

  final connectivityService = ConnectivityService();
  await connectivityService.init();

  final databaseService = DatabaseService();
  final secureStorage = const FlutterSecureStorage();
  final apiClient = ApiClient();

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

  final authRepository = AuthRepository(auth0Service: auth0Service);
  await authRepository.init();

  final settingsRepository = SettingsRepository();
  await settingsRepository.init();

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

  final transactionRepository = TransactionRepository();
  await transactionRepository.init();

  final currencyService = CurrencyService();
  await currencyService.loadSettings();

  final subscriptionRepository = SubscriptionRepository(
    expenseRepository: expenseRepository,
    apiService: apiClient,
  );

  final syncService = SyncService(
    productApiService: productApiService,
    customerApiService: customerApiService,
    saleApiService: saleApiService,
    syncStatusBox: syncStatusBox,
  );
  await syncService.init();

  final authBloc = AuthBloc(authRepository: authRepository);
  final operationJournalBloc = OperationJournalBloc(repository: operationJournalRepository);
  final inventoryBloc = InventoryBloc(
    inventoryRepository: inventoryRepository,
    notificationService: notificationService,
    operationJournalBloc: operationJournalBloc,
  );
  final salesBloc = SalesBloc(
    salesRepository: salesRepository,
    operationJournalBloc: operationJournalBloc,
  );
  final adhaBloc = AdhaBloc(
    adhaRepository: adhaRepository,
    authRepository: authRepository,
    operationJournalRepository: operationJournalRepository,
  );
  final customerBloc = CustomerBloc(customerRepository: customerRepository);
  final supplierBloc = SupplierBloc(supplierRepository: supplierRepository);
  final settingsBloc = SettingsBloc(
    settingsRepository: settingsRepository,
  )..add(const LoadSettings());
  
  final expenseBloc = ExpenseBloc(
      expenseRepository: expenseRepository,
      operationJournalBloc: operationJournalBloc);
  
  final subscriptionBloc =
      SubscriptionBloc(subscriptionRepository: subscriptionRepository);
  
  final financingBloc = FinancingBloc(
      financingRepository: financingRepository,
      operationJournalBloc: operationJournalBloc);
  
  final dashboardBloc = DashboardBloc(
    salesRepository: salesRepository,
    customerRepository: customerRepository, 
    transactionRepository: transactionRepository, 
  );

  final notificationsBloc = NotificationsBloc(notificationService);

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
    operationJournalBloc: operationJournalBloc,
    expenseBloc: expenseBloc,
    subscriptionBloc: subscriptionBloc,
    financingBloc: financingBloc,
    dashboardBloc: dashboardBloc,
    notificationsBloc: notificationsBloc,
    currencyService: currencyService,
    // Pass repositories directly
    authRepository: authRepository,
    inventoryRepository: inventoryRepository,
    salesRepository: salesRepository,
    adhaRepository: adhaRepository,
    customerRepository: customerRepository,
    supplierRepository: supplierRepository,
    settingsRepository: settingsRepository,
    operationJournalRepository: operationJournalRepository,
    expenseRepository: expenseRepository,
    subscriptionRepository: subscriptionRepository,
    financingRepository: financingRepository,
    notificationRepository: notificationRepository, // Added
    transactionRepository: transactionRepository, // Added
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
  final OperationJournalBloc operationJournalBloc;
  final ExpenseBloc expenseBloc;
  final SubscriptionBloc subscriptionBloc;
  final FinancingBloc financingBloc;
  final DashboardBloc dashboardBloc;
  final NotificationsBloc notificationsBloc;
  final CurrencyService currencyService;

  // Add repository fields
  final AuthRepository authRepository;
  final InventoryRepository inventoryRepository;
  final SalesRepository salesRepository;
  final AdhaRepository adhaRepository;
  final CustomerRepository customerRepository;
  final SupplierRepository supplierRepository;
  final SettingsRepository settingsRepository;
  final OperationJournalRepository operationJournalRepository;
  final ExpenseRepository expenseRepository;
  final SubscriptionRepository subscriptionRepository;
  final FinancingRepository financingRepository;
  final NotificationRepository notificationRepository; // Added
  final TransactionRepository transactionRepository; // Added

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
    required this.operationJournalBloc,
    required this.expenseBloc,
    required this.subscriptionBloc,
    required this.financingBloc,
    required this.dashboardBloc,
    required this.notificationsBloc,
    required this.currencyService,
    // Add repositories to constructor
    required this.authRepository,
    required this.inventoryRepository,
    required this.salesRepository,
    required this.adhaRepository,
    required this.customerRepository,
    required this.supplierRepository,
    required this.settingsRepository,
    required this.operationJournalRepository,
    required this.expenseRepository,
    required this.subscriptionRepository,
    required this.financingRepository,
    required this.notificationRepository, // Added
    required this.transactionRepository, // Added
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SettingsRepository>.value(value: settingsRepository),
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<InventoryRepository>.value(value: inventoryRepository),
        RepositoryProvider<SalesRepository>.value(value: salesRepository),
        RepositoryProvider<AdhaRepository>.value(value: adhaRepository),
        RepositoryProvider<CustomerRepository>.value(value: customerRepository),
        RepositoryProvider<SupplierRepository>.value(value: supplierRepository),
        RepositoryProvider<OperationJournalRepository>.value(value: operationJournalRepository),
        RepositoryProvider<ExpenseRepository>.value(value: expenseRepository),
        RepositoryProvider<SubscriptionRepository>.value(value: subscriptionRepository),
        RepositoryProvider<FinancingRepository>.value(value: financingRepository),
        RepositoryProvider<NotificationRepository>.value(value: notificationRepository), // Added
        RepositoryProvider<TransactionRepository>.value(value: transactionRepository), // Added
        RepositoryProvider<CurrencyService>.value(value: currencyService), // Added
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
          BlocProvider.value(value: operationJournalBloc),
          BlocProvider.value(value: expenseBloc),
          BlocProvider.value(value: subscriptionBloc),
          BlocProvider.value(value: financingBloc),
          BlocProvider.value(value: dashboardBloc),
          BlocProvider.value(value: notificationsBloc),
          BlocProvider<CurrencySettingsCubit>(
            create: (context) => CurrencySettingsCubit(currencyService)..loadSettings(), 
          ),
        ],
        child: BlocBuilder<SettingsBloc, settings_bloc_state.SettingsState>(
          builder: (context, settingsState) {
            ThemeMode themeMode = ThemeMode.system;
            // Check if the state is SettingsLoaded or SettingsUpdated and has settings
            if (settingsState is settings_bloc_state.SettingsLoaded || settingsState is settings_bloc_state.SettingsUpdated) {
              final currentSettings = (settingsState is settings_bloc_state.SettingsLoaded)
                  ? settingsState.settings
                  : (settingsState as settings_bloc_state.SettingsUpdated).settings;
              switch (currentSettings.themeMode) {
                case settings_models.AppThemeMode.light:
                  themeMode = ThemeMode.light;
                  break;
                case settings_models.AppThemeMode.dark:
                  themeMode = ThemeMode.dark;
                  break;
                case settings_models.AppThemeMode.system:
                  themeMode = ThemeMode.system;
                  break;
              }
            }

            Locale currentLocale = const Locale('fr'); // Default to French
            if (settingsState is settings_bloc_state.SettingsLoaded || settingsState is settings_bloc_state.SettingsUpdated) {
              final currentSettings = (settingsState is settings_bloc_state.SettingsLoaded)
                  ? settingsState.settings
                  : (settingsState as settings_bloc_state.SettingsUpdated).settings;
              currentLocale = Locale(currentSettings.language); // Set locale from settings
            }

            return MaterialApp.router(
              routerConfig: appRouter.router,
              title: 'Wanzo',
              theme: WanzoTheme.lightTheme,
              darkTheme: WanzoTheme.darkTheme,
              themeMode: themeMode,
              locale: currentLocale, // Use the locale from settings
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
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
