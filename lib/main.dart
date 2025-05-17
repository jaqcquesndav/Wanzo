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
import 'features/notifications/bloc/notifications_bloc.dart';
import 'features/notifications/repositories/notification_repository.dart';
import 'features/notifications/services/notification_service.dart';
import 'features/connectivity/bloc/connectivity_bloc.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialisation de Firebase
  // try {
  //   await Firebase.initializeApp();
  // } catch (e) {
  //   debugPrint("Erreur d'initialisation Firebase: $e");
  //   // L'application peut continuer sans Firebase
  // }
    // Initialisation de Hive
  await Hive.initFlutter();
  registerHiveAdapters();
  
  // Initialisation des repositories
  final authRepository = AuthRepository();
  await authRepository.init();
  
  final salesRepository = SalesRepository();
  await salesRepository.init();
  
  final inventoryRepository = InventoryRepository();
  await inventoryRepository.init();
  
  final adhaRepository = AdhaRepository();
  await adhaRepository.init();
  
  final customerRepository = CustomerRepository();
  await customerRepository.init();
  
  final supplierRepository = SupplierRepository();
  await supplierRepository.init();
  
  final settingsRepository = SettingsRepository();
  await settingsRepository.init();  // Initialisation des services
  final connectivityService = ConnectivityService();
  await connectivityService.init();
  
  final databaseService = DatabaseService();
  
  final apiService = ApiService();
  await apiService.init();
  
  final syncService = SyncService();
  await syncService.init();
  
  // Initialisation du repository de notifications
  final notificationRepository = NotificationRepository();
  await notificationRepository.init();
  
  // Initialisation du service de notifications
  final notificationService = NotificationService();
  final settings = await settingsRepository.getSettings();
  await notificationService.init(settings);
    
  runApp(MyApp(
    authRepository: authRepository,
    salesRepository: salesRepository,
    inventoryRepository: inventoryRepository,
    adhaRepository: adhaRepository,
    customerRepository: customerRepository,
    supplierRepository: supplierRepository,
    settingsRepository: settingsRepository,
    notificationRepository: notificationRepository,
    notificationService: notificationService,
    connectivityService: connectivityService,
    databaseService: databaseService,
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
  final NotificationService notificationService;
  final ConnectivityService connectivityService;
  final DatabaseService databaseService;
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
    required this.notificationService,
    required this.connectivityService,
    required this.databaseService,
    required this.syncService,
  });
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            authRepository: authRepository,
          ),
        ),
        BlocProvider<SalesBloc>(
          create: (context) => SalesBloc(
            salesRepository: salesRepository,
          ),
        ),
        BlocProvider<InventoryBloc>(
          create: (context) => InventoryBloc(
            inventoryRepository: inventoryRepository,
          ),
        ),
        BlocProvider<AdhaBloc>(
          create: (context) => AdhaBloc(
            adhaRepository: adhaRepository,
          ),
        ),
        BlocProvider<CustomerBloc>(
          create: (context) => CustomerBloc(
            customerRepository: customerRepository,
          ),
        ),        BlocProvider<SupplierBloc>(
          create: (context) => SupplierBloc(
            supplierRepository: supplierRepository,
          ),
        ),        Provider<NotificationRepository>(
          create: (context) => notificationRepository,
        ),
        BlocProvider<NotificationsBloc>(
          create: (context) => NotificationsBloc(
            notificationService, // Corrected: Pass notificationService instance
          ),
        ),        BlocProvider<ConnectivityBloc>(
          create: (context) => ConnectivityBloc(connectivityService),
        ),
        BlocProvider<SettingsBloc>(
          create: (context) => SettingsBloc(
            settingsRepository: settingsRepository,
          ),
        ),
      ],
      child: Builder(
        builder: (context) {
          final authBloc = context.read<AuthBloc>();
          final appRouter = AppRouter(authBloc: authBloc);
          
          return MaterialApp.router(
            title: 'Wanzo',
            theme: WanzoTheme.lightTheme,
            darkTheme: WanzoTheme.darkTheme,
            themeMode: ThemeMode.light, // Changed from ThemeMode.system
            debugShowCheckedModeBanner: false,
            routerConfig: appRouter.router,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('fr'), // Français
              Locale('en'), // Anglais
            ],
          );
        },
      ),
    );
  }
}
