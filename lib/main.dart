import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/navigation/app_router.dart';
import 'core/adapters/hive_adapters.dart';
import 'core/utils/connectivity_service.dart';
import 'core/services/api_service.dart';
import 'core/services/database_service.dart';
import 'core/services/sync_service.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/repositories/auth_repository.dart';
import 'features/inventory/bloc/inventory_bloc.dart';
import 'features/inventory/repositories/inventory_repository.dart';
import 'features/inventory/bloc/inventory_event.dart' as inventory_event;
import 'features/sales/bloc/sales_bloc.dart';
import 'features/sales/repositories/sales_repository.dart';
import 'features/adha/bloc/adha_bloc.dart';
import 'features/adha/repositories/adha_repository.dart';
import 'features/customer/bloc/customer_bloc.dart';
import 'features/customer/repositories/customer_repository.dart';
import 'features/supplier/bloc/supplier_bloc.dart';
import 'features/supplier/repositories/supplier_repository.dart';
import 'features/settings/bloc/settings_bloc.dart';
import 'features/settings/repositories/settings_repository.dart';
import 'features/settings/models/settings.dart';
import 'features/settings/bloc/settings_event.dart';
import 'features/notifications/bloc/notifications_bloc.dart';
import 'features/notifications/repositories/notification_repository.dart';
import 'features/notifications/services/notification_service.dart';
import 'features/connectivity/bloc/connectivity_bloc.dart';
import 'features/dashboard/repositories/operation_journal_repository.dart';
import 'features/dashboard/bloc/operation_journal_bloc.dart';
import 'features/expenses/bloc/expense_bloc.dart';
import 'features/expenses/repositories/expense_repository.dart';
import 'features/financing/bloc/financing_bloc.dart';
import 'features/financing/repositories/financing_repository.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  registerHiveAdapters();

  final authRepository = AuthRepository();
  await authRepository.init();

  final operationJournalRepository = OperationJournalRepository();
  await operationJournalRepository.init();

  final inventoryRepository = InventoryRepository();
  await inventoryRepository.init();

  final salesRepository = SalesRepository();
  await salesRepository.init();

  final expenseRepository = ExpenseRepository();
  await expenseRepository.init();

  final adhaRepository = AdhaRepository();
  await adhaRepository.init();

  final customerRepository = CustomerRepository();
  await customerRepository.init();

  final supplierRepository = SupplierRepository();
  await supplierRepository.init();

  final settingsRepository = SettingsRepository();
  await settingsRepository.init();

  final financingRepository = FinancingRepository();
  await financingRepository.init();

  final Settings settings = await settingsRepository.getSettings();

  final notificationService = NotificationService();
  await notificationService.init(settings);

  final connectivityService = ConnectivityService();
  await connectivityService.init();

  final databaseService = DatabaseService();

  final apiService = ApiService();
  await apiService.init();

  final syncService = SyncService();
  await syncService.init();

  final notificationRepository = NotificationRepository();
  await notificationRepository.init();

  runApp(MyApp(
    authRepository: authRepository,
    salesRepository: salesRepository,
    inventoryRepository: inventoryRepository,
    adhaRepository: adhaRepository,
    customerRepository: customerRepository,
    supplierRepository: supplierRepository,
    settingsRepository: settingsRepository,
    notificationRepository: notificationRepository,
    operationJournalRepository: operationJournalRepository,
    expenseRepository: expenseRepository,
    financingRepository: financingRepository,
    notificationService: notificationService,
    connectivityService: connectivityService,
    databaseService: databaseService,
    apiService: apiService,
    syncService: syncService,
  ));
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final SalesRepository salesRepository;
  final InventoryRepository inventoryRepository;
  final AdhaRepository adhaRepository;
  final CustomerRepository customerRepository;
  final SupplierRepository supplierRepository;
  final SettingsRepository settingsRepository;
  final NotificationRepository notificationRepository;
  final OperationJournalRepository operationJournalRepository;
  final ExpenseRepository expenseRepository;
  final FinancingRepository financingRepository;
  final NotificationService notificationService;
  final ConnectivityService connectivityService;
  final DatabaseService databaseService;
  final ApiService apiService;
  final SyncService syncService;

  const MyApp({
    super.key,
    required this.authRepository,
    required this.salesRepository,
    required this.inventoryRepository,
    required this.adhaRepository,
    required this.customerRepository,
    required this.supplierRepository,
    required this.settingsRepository,
    required this.notificationRepository,
    required this.operationJournalRepository,
    required this.expenseRepository,
    required this.financingRepository,
    required this.notificationService,
    required this.connectivityService,
    required this.databaseService,
    required this.apiService,
    required this.syncService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
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
      ],
      child: MultiProvider(
        providers: [
          Provider.value(value: notificationService),
          Provider.value(value: connectivityService),
          Provider.value(value: databaseService),
          Provider.value(value: apiService),
          Provider.value(value: syncService),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>(
              create: (context) => AuthBloc(
                authRepository: context.read<AuthRepository>(),
              ),
            ),
            BlocProvider<OperationJournalBloc>(
              create: (context) => OperationJournalBloc(
                repository: context.read<OperationJournalRepository>(),
              )..add(LoadOperations(
                  startDate: DateTime.now().subtract(const Duration(days: 30)),
                  endDate: DateTime.now())),
            ),
            BlocProvider<SalesBloc>(
              create: (context) => SalesBloc(
                salesRepository: context.read<SalesRepository>(),
                journalRepository: context.read<OperationJournalRepository>(),
                operationJournalBloc: context.read<OperationJournalBloc>(),
              ),
            ),
            BlocProvider<InventoryBloc>(
              create: (context) => InventoryBloc(
                inventoryRepository: context.read<InventoryRepository>(),
                journalRepository: context.read<OperationJournalRepository>(),
                notificationService: context.read<NotificationService>(),
                operationJournalBloc: context.read<OperationJournalBloc>(),
              )..add(const inventory_event.LoadProducts()),
            ),
            BlocProvider<AdhaBloc>(
              create: (context) => AdhaBloc(
                adhaRepository: context.read<AdhaRepository>(),
              ),
            ),
            BlocProvider<CustomerBloc>(
              create: (context) => CustomerBloc(
                customerRepository: context.read<CustomerRepository>(),
              ),
            ),
            BlocProvider<SupplierBloc>(
              create: (context) => SupplierBloc(
                supplierRepository: context.read<SupplierRepository>(),
              ),
            ),
            BlocProvider<NotificationsBloc>(
              create: (context) => NotificationsBloc(
                context.read<NotificationService>(),
              ),
            ),
            BlocProvider<ConnectivityBloc>(
              create: (context) => ConnectivityBloc(context.read<ConnectivityService>()),
            ),
            BlocProvider<SettingsBloc>(
              create: (context) => SettingsBloc(
                settingsRepository: context.read<SettingsRepository>(),
              )..add(LoadSettings()),
            ),
            BlocProvider<ExpenseBloc>(
              create: (context) => ExpenseBloc(
                expenseRepository: context.read<ExpenseRepository>(),
                journalRepository: context.read<OperationJournalRepository>(),
                operationJournalBloc: context.read<OperationJournalBloc>(),
              )..add(const LoadExpenses()),
            ),
            BlocProvider<FinancingBloc>(
              create: (context) => FinancingBloc(
                financingRepository: context.read<FinancingRepository>(),
                operationJournalBloc: context.read<OperationJournalBloc>(),
              ),
            ),
          ],
          child: Builder(
            builder: (context) {
              final authBloc = BlocProvider.of<AuthBloc>(context);
              final appRouter = AppRouter(authBloc: authBloc);

              return MaterialApp.router(
                title: 'Wanzo',
                theme: WanzoTheme.lightTheme,
                darkTheme: WanzoTheme.darkTheme,
                themeMode: ThemeMode.light,
                debugShowCheckedModeBanner: false,
                routerConfig: appRouter.router,
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('fr'),
                  Locale('en'),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
