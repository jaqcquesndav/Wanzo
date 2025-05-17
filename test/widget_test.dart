// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wanzo/features/auth/repositories/auth_repository.dart';
import 'package:wanzo/features/inventory/repositories/inventory_repository.dart';
import 'package:wanzo/features/sales/repositories/sales_repository.dart';
import 'package:wanzo/features/adha/repositories/adha_repository.dart';
import 'package:wanzo/features/customer/repositories/customer_repository.dart';
import 'package:wanzo/features/supplier/repositories/supplier_repository.dart';
import 'package:wanzo/features/settings/repositories/settings_repository.dart';
import 'package:wanzo/features/notifications/repositories/notification_repository.dart';
import 'package:wanzo/features/notifications/services/notification_service.dart';
import 'package:wanzo/core/utils/connectivity_service.dart';
import 'package:wanzo/core/services/database_service.dart';
import 'package:wanzo/core/services/sync_service.dart';
import 'package:wanzo/main.dart';

void main() {
  testWidgets('App initializes correctly', (WidgetTester tester) async {
    // Création des instances de repositories pour les tests
    final authRepository = AuthRepository();
    final salesRepository = SalesRepository();
    final inventoryRepository = InventoryRepository();
    final adhaRepository = AdhaRepository();
    final customerRepository = CustomerRepository();
    final supplierRepository = SupplierRepository();
    final settingsRepository = SettingsRepository();
    final notificationRepository = NotificationRepository();
    final notificationService = NotificationService();
    final connectivityService = ConnectivityService();
    final databaseService = DatabaseService();
    final syncService = SyncService();
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(
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

    // Vérifier que l'app se lance sans erreur
    expect(find.byType(MaterialApp), findsWidgets);
  });
}
