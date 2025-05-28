// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wanzo/core/navigation/app_router.dart';
import 'package:wanzo/features/auth/bloc/auth_bloc.dart';
import 'package:wanzo/features/auth/repositories/auth_repository.dart';
import 'package:wanzo/features/auth/services/auth0_service.dart';
import 'package:wanzo/features/auth/services/offline_auth_service.dart';
import 'package:wanzo/features/auth/models/user.dart'; // Import User model

// Import core services
import 'package:wanzo/core/utils/connectivity_service.dart';
import 'package:wanzo/core/services/database_service.dart';
import 'package:wanzo/core/services/api_client.dart';
import 'package:wanzo/features/notifications/services/notification_service.dart';
import 'package:wanzo/core/services/currency_service.dart'; // Added import

// Import Repositories
import 'package:wanzo/features/settings/repositories/settings_repository.dart';
import 'package:wanzo/features/inventory/repositories/inventory_repository.dart';
import 'package:wanzo/features/sales/repositories/sales_repository.dart';
import 'package:wanzo/features/adha/repositories/adha_repository.dart';
import 'package:wanzo/features/customer/repositories/customer_repository.dart';
import 'package:wanzo/features/supplier/repositories/supplier_repository.dart';
import 'package:wanzo/features/notifications/repositories/notification_repository.dart';
import 'package:wanzo/features/dashboard/repositories/operation_journal_repository.dart';
import 'package:wanzo/features/expenses/repositories/expense_repository.dart';
import 'package:wanzo/features/financing/repositories/financing_repository.dart';
import 'package:wanzo/features/subscription/repositories/subscription_repository.dart';
import 'package:wanzo/features/transactions/repositories/transaction_repository.dart';

// Import BLoCs
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


import 'package:hive_flutter/hive_flutter.dart'; // Corrected Hive import
import 'package:wanzo/main.dart'; // Import MyApp

void main() {
  setUpAll(() async {
    // Initialize Hive for testing
    await Hive.initFlutter(); // Ensure Hive is initialized for tests
    Hive.registerAdapter(UserAdapter()); // Register UserAdapter
    await Hive.openBox<User>('userBox');
  });

  tearDownAll(() async {
    await Hive.close();
  });

  testWidgets('App initializes correctly', (WidgetTester tester) async {
    // Minimal services for auth flow
    final connectivityService = ConnectivityService();
    await connectivityService.init(); // Assuming init method exists

    final databaseService = DatabaseService();
    const secureStorage = FlutterSecureStorage();

    final offlineAuthService = OfflineAuthService(
      secureStorage: secureStorage,
      databaseService: databaseService,
      connectivityService: connectivityService,
    );

    final auth0Service = Auth0Service(offlineAuthService: offlineAuthService);
    await auth0Service.init(); // Call init

    final authRepository = AuthRepository(auth0Service: auth0Service);
    await authRepository.init(); // Call init

    final authBloc = AuthBloc(authRepository: authRepository);
    final appRouter = AppRouter(authBloc: authBloc);
    final apiClient = ApiClient(); 
    final notificationService = NotificationService(); 

    // Instantiate Repositories
    final settingsRepository = SettingsRepository();
    await settingsRepository.init();
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
    final transactionRepository = TransactionRepository(); 
    await transactionRepository.init();

    // Instantiate BLoCs
    final operationJournalBloc = OperationJournalBloc(repository: operationJournalRepository);
    final inventoryBloc = InventoryBloc(
        inventoryRepository: inventoryRepository,
        notificationService: notificationService,
        operationJournalBloc: operationJournalBloc);
    final salesBloc = SalesBloc(
        salesRepository: salesRepository,
        operationJournalBloc: operationJournalBloc);
    final adhaBloc = AdhaBloc(
        adhaRepository: adhaRepository,
        authRepository: authRepository,
        operationJournalRepository: operationJournalRepository);
    final customerBloc = CustomerBloc(customerRepository: customerRepository);
    final supplierBloc = SupplierBloc(supplierRepository: supplierRepository);
    final settingsBloc = SettingsBloc(settingsRepository: settingsRepository);
    final notificationsBloc = NotificationsBloc(notificationService);
    final expenseBloc = ExpenseBloc(
        expenseRepository: expenseRepository,
        operationJournalBloc: operationJournalBloc);
    final subscriptionBloc = SubscriptionBloc(subscriptionRepository: subscriptionRepository);
    final financingBloc = FinancingBloc(
        financingRepository: financingRepository,
        operationJournalBloc: operationJournalBloc);

    final dashboardBloc = DashboardBloc( 
      salesRepository: salesRepository,
      customerRepository: customerRepository,
      transactionRepository: transactionRepository,
      // operationJournalRepository is not a direct param for DashboardBloc constructor
    );
    
    final currencyService = CurrencyService(); 
    await currencyService.loadSettings(); 

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(
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
      dashboardBloc: dashboardBloc, 
      // Pass repositories
      authRepository: authRepository,
      settingsRepository: settingsRepository,
      inventoryRepository: inventoryRepository,
      salesRepository: salesRepository,
      adhaRepository: adhaRepository,
      customerRepository: customerRepository,
      supplierRepository: supplierRepository,
      notificationRepository: notificationRepository,
      operationJournalRepository: operationJournalRepository, // Reinstated
      expenseRepository: expenseRepository,
      financingRepository: financingRepository,
      subscriptionRepository: subscriptionRepository,
      transactionRepository: transactionRepository, 
      currencyService: currencyService, 
    ));

    // Verify that the app launches and shows MaterialApp
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
