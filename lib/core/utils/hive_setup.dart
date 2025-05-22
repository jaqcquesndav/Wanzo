import 'package:hive_flutter/hive_flutter.dart';

// Auth models
import '../../features/auth/models/user.dart';
import '../../features/auth/models/business_sector.dart' as auth_bs; // Alias to avoid name clash

// Company models
import '../../features/company/models/business_sector.dart' as company_bs; // Alias

// Customer models
import '../../features/customers/models/customer.dart';

// Inventory models
import '../../features/inventory/models/product.dart';

// Sales models
import '../../features/sales/models/sale.dart';
import '../../features/sales/models/payment_method.dart';

// Supplier models
import '../../features/supplier/models/supplier.dart';

// Settings models
import '../../features/settings/models/settings.dart';

// Notifications models
import '../../features/notifications/models/notification_model.dart';

// TODO: Add any other models that need Hive adapters

void _registerAdapterIfNotExists<T>(TypeAdapter<T> adapter) {
  if (!Hive.isAdapterRegistered(adapter.typeId)) {
    Hive.registerAdapter(adapter);
  }
}

Future<void> initializeHive() async {
  // Hive.initFlutter() is now called in main.dart to ensure single initialization.

  // Register Adapters using the helper to avoid re-registration errors
  _registerAdapterIfNotExists(UserAdapter());
  _registerAdapterIfNotExists(IdStatusAdapter());
  _registerAdapterIfNotExists(auth_bs.BusinessSectorAdapter()); // Auth BusinessSector

  // Company
  _registerAdapterIfNotExists(company_bs.BusinessSectorAdapter()); // Company BusinessSector

  // Customers
  _registerAdapterIfNotExists(CustomerAdapter());

  // Inventory
  _registerAdapterIfNotExists(ProductAdapter());
  _registerAdapterIfNotExists(ProductCategoryAdapter());
  _registerAdapterIfNotExists(ProductUnitAdapter());

  // Sales
  _registerAdapterIfNotExists(SaleAdapter());
  _registerAdapterIfNotExists(SaleItemAdapter());
  _registerAdapterIfNotExists(SaleStatusAdapter());
  _registerAdapterIfNotExists(PaymentMethodAdapter());
  
  // Supplier
  _registerAdapterIfNotExists(SupplierAdapter());
  _registerAdapterIfNotExists(SupplierCategoryAdapter());

  // Settings
  _registerAdapterIfNotExists(SettingsAdapter());
  _registerAdapterIfNotExists(AppThemeModeAdapter());

  // Notifications
  _registerAdapterIfNotExists(NotificationModelAdapter());
  _registerAdapterIfNotExists(NotificationTypeAdapter());

  // Note: Opening boxes is handled by openHiveBoxes()
}

// Helper function to open all necessary boxes
Future<void> openHiveBoxes() async {
  await Hive.openBox<User>('userBox');
  await Hive.openBox<auth_bs.BusinessSector>('authBusinessSectorsBox');
  await Hive.openBox<company_bs.BusinessSector>('companyBusinessSectorsBox');
  await Hive.openBox<Customer>('customersBox');
  await Hive.openBox<Product>('productsBox');
  await Hive.openBox<Sale>('salesBox');
  await Hive.openBox<Supplier>('suppliersBox');
  await Hive.openBox<Settings>('settingsBox');
  await Hive.openBox<NotificationModel>('notificationsBox');
  await Hive.openBox<String>('syncStatusBox'); // Added for SyncService status tracking
  // Add other boxes here
}
