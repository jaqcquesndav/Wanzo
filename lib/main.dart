import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:wanzo/features/auth/models/user.dart';
import 'package:go_router/go_router.dart';
import 'package:wanzo/features/settings/models/settings.dart';

// Core services and utilities
import 'core/navigation/app_router.dart';
import 'core/services/api_client.dart';
import 'core/utils/connectivity_service.dart';
import 'core/services/database_service.dart'; // Corrected import

// Import SyncService and its dependencies
import 'core/services/sync_service.dart';
import 'core/services/product_api_service.dart';
import 'core/services/customer_api_service.dart';
import 'core/services/sale_api_service.dart';

// Feature-specific services
import 'features/auth/services/auth0_service.dart';
import 'features/auth/services/offline_auth_service.dart';
import 'features/notifications/services/notification_service.dart';

// Repositories
import 'features/auth/repositories/auth_repository.dart';
import 'features/inventory/repositories/inventory_repository.dart';
import 'features/sales/repositories/sales_repository.dart';
import 'features/adha/repositories/adha_repository.dart';
import 'features/customer/repositories/customer_repository.dart';
import 'features/supplier/repositories/supplier_repository.dart';
import 'features/settings/repositories/settings_repository.dart';
import 'features/notifications/repositories/notification_repository.dart';
import 'features/dashboard/repositories/operation_journal_repository.dart';
import 'features/expenses/repositories/expense_repository.dart';
import 'features/financing/repositories/financing_repository.dart';
import 'features/subscription/repositories/subscription_repository.dart';

// BLoCs
import 'features/auth/bloc/auth_bloc.dart';
import 'features/inventory/bloc/inventory_bloc.dart';
import 'features/sales/bloc/sales_bloc.dart';
import 'features/adha/bloc/adha_bloc.dart';
import 'features/customer/bloc/customer_bloc.dart';
import 'features/supplier/bloc/supplier_bloc.dart';
import 'features/settings/bloc/settings_bloc.dart';
import 'features/notifications/bloc/notifications_bloc.dart';
import 'features/dashboard/bloc/operation_journal_bloc.dart';
import 'features/expenses/bloc/expense_bloc.dart';
import 'features/subscription/bloc/subscription_bloc.dart';
import 'features/financing/bloc/financing_bloc.dart';

// BLoC Events
import 'features/inventory/bloc/inventory_event.dart';
import 'features/customer/bloc/customer_event.dart';
import 'features/supplier/bloc/supplier_event.dart';
import 'features/settings/bloc/settings_event.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(UserAdapter());
  await Hive.openBox<Settings>('settingsBox');
  final syncStatusBox = await Hive.openBox<String>('syncStatusBox'); // Open syncStatusBox

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

  final subscriptionRepository = SubscriptionRepository(
    expenseRepository: expenseRepository,
    apiService: apiClient,
  );

  // Instantiate SyncService
  final syncService = SyncService(
    productApiService: productApiService,
    customerApiService: customerApiService,
    saleApiService: saleApiService,
    syncStatusBox: syncStatusBox,
  );
  await syncService.init(); // Initialize SyncService

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
  final settingsBloc = SettingsBloc(settingsRepository: settingsRepository);
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

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: salesRepository),
        RepositoryProvider.value(value: inventoryRepository),
        RepositoryProvider.value(value: adhaRepository),
        RepositoryProvider.value(value: customerRepository),
        RepositoryProvider.value(value: supplierRepository),
        RepositoryProvider.value(value: settingsRepository),
        RepositoryProvider.value(value: notificationRepository),
        RepositoryProvider.value(value: operationJournalRepository),
        RepositoryProvider.value(value: expenseRepository),
        RepositoryProvider.value(value: financingRepository),
        RepositoryProvider.value(value: subscriptionRepository),
        RepositoryProvider.value(value: apiClient),
        RepositoryProvider.value(value: notificationService),
        RepositoryProvider.value(value: connectivityService),
        RepositoryProvider.value(value: syncService), // Provide SyncService
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: authBloc..add(AuthCheckRequested())),
          BlocProvider.value(value: inventoryBloc..add(LoadProducts())),
          BlocProvider.value(value: salesBloc..add(LoadSales())),
          BlocProvider.value(value: adhaBloc),
          BlocProvider.value(value: customerBloc..add(LoadCustomers())),
          BlocProvider.value(value: supplierBloc..add(LoadSuppliers())),
          BlocProvider.value(value: settingsBloc..add(LoadSettings())),
          BlocProvider.value(value: notificationsBloc..add(LoadNotifications())),
          BlocProvider.value(
            value: operationJournalBloc
              ..add(LoadOperations(
                startDate: DateTime.now().subtract(const Duration(days: 7)),
                endDate: DateTime.now(),
              )),
          ),
          BlocProvider.value(value: expenseBloc..add(LoadExpenses())),
          BlocProvider.value(value: subscriptionBloc..add(LoadSubscriptionDetails())),
          BlocProvider.value(value: financingBloc),
        ],
        child: MyApp(appRouter: appRouter.router),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final GoRouter appRouter;

  const MyApp({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Wanzo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routerConfig: appRouter,
      builder: (context, child) {
        return child!;
      },
    );
  }
}
