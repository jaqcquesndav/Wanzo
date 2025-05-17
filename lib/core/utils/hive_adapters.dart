import 'package:hive/hive.dart';
import '../../features/auth/models/user_adapter.dart';
import '../../features/inventory/models/product_adapter.dart';
import '../../features/sales/models/sale_adapter.dart';
import '../../features/adha/models/adha_adapters.dart';
import '../../features/customer/models/customer_adapter.dart';
import '../../features/supplier/models/supplier_adapter.dart';
import '../../features/settings/models/settings_adapter.dart';
import '../../features/notifications/models/notification_adapter.dart';

// Enregistrement des adaptateurs Hive
void registerAdapters() {
  // Auth
  Hive.registerAdapter(UserAdapter());
  
  // Sales
  Hive.registerAdapter(SaleAdapter());
  Hive.registerAdapter(SaleItemAdapter());
  Hive.registerAdapter(SaleStatusAdapter());
  
  // Inventory
  Hive.registerAdapter(ProductCategoryAdapter());
  Hive.registerAdapter(ProductUnitAdapter());
  Hive.registerAdapter(ProductAdapter());
  Hive.registerAdapter(StockTransactionTypeAdapter());
  Hive.registerAdapter(StockTransactionAdapter());
  
  // Adha
  Hive.registerAdapter(AdhaMessageAdapter());
  Hive.registerAdapter(AdhaMessageTypeAdapter());
  Hive.registerAdapter(AdhaConversationAdapter());
  
  // Notifications
  Hive.registerAdapter(NotificationModelAdapter());
  Hive.registerAdapter(NotificationTypeAdapter());
  
  // TODO: Uncomment these once adapter files are properly generated
  /*
  // Customer
  Hive.registerAdapter(CustomerAdapter());
  Hive.registerAdapter(CustomerCategoryAdapter());
  
  // Supplier
  Hive.registerAdapter(SupplierAdapter());
  Hive.registerAdapter(SupplierCategoryAdapter());
  
  // Settings
  Hive.registerAdapter(SettingsAdapter());
  Hive.registerAdapter(AppThemeModeAdapter());
  */
}
