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

    // Build our app and trigger a frame.
    // MyApp now only takes appRouter.router
    await tester.pumpWidget(MyApp(appRouter: appRouter.router));

    // Verify that the app launches and shows MaterialApp
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
