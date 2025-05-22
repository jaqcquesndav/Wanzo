import 'package:hive/hive.dart';
import '../../features/auth/models/user.dart';
import '../../features/notifications/models/notification_model.dart';
// Import Adha models
import '../../features/adha/models/adha_adapters.dart'; // Import Adha adapters
import '../../features/sales/models/sale.dart'; // Corrected: Import main model file
import '../../features/financing/models/financing_request.dart'; // Corrected: Import main model file
import '../../features/customer/models/customer.dart'; // Added import for Customer model
import '../../features/supplier/models/supplier.dart'; // Added import for Supplier model
import '../../features/settings/models/settings.dart'; // Added import for Settings model
import '../../features/inventory/models/product.dart';
import '../../features/inventory/models/stock_transaction.dart';

/// Enregistre tous les adaptateurs Hive nécessaires
void registerHiveAdapters() {
  // User models
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(UserAdapter());
  }
  if (!Hive.isAdapterRegistered(103)) { // IdStatusAdapter - Ensure this matches the typeId in user.g.dart
    Hive.registerAdapter(IdStatusAdapter());
  }

  // Sale models
  if (!Hive.isAdapterRegistered(1)) { // typeId for Sale
    Hive.registerAdapter(SaleAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) { // typeId for SaleItem
    Hive.registerAdapter(SaleItemAdapter());
  }
  // Note: SaleStatus was typeId 3, Customer is now 3, CustomerCategory is 4.
  // FinancingRequest was 4, now 8
  // FinancingType was 5, now 16
  // FinancialInstitution was 6, now 9

  // Customer models
  if (!Hive.isAdapterRegistered(3)) { // typeId for Customer
    Hive.registerAdapter(CustomerAdapter());
  }
  if (!Hive.isAdapterRegistered(4)) { // typeId for CustomerCategory
    Hive.registerAdapter(CustomerCategoryAdapter());
  }
  
  // SaleStatus is now 5
  if (!Hive.isAdapterRegistered(5)) { // typeId for SaleStatus
    Hive.registerAdapter(SaleStatusAdapter());
  }

  // Financing models - Adjusted TypeIDs
  if (!Hive.isAdapterRegistered(8)) { // Corrected: typeId for FinancingRequest is 8
    Hive.registerAdapter(FinancingRequestAdapter());
  }
  if (!Hive.isAdapterRegistered(16)) { // typeId for FinancingType
    Hive.registerAdapter(FinancingTypeAdapter());
  }
  if (!Hive.isAdapterRegistered(9)) { // typeId for FinancialInstitution
    Hive.registerAdapter(FinancialInstitutionAdapter());
  }

  // Notification models - Adjusted TypeIDs
  if (!Hive.isAdapterRegistered(10)) { // typeId for NotificationModel
    Hive.registerAdapter(NotificationModelAdapter());
  }
  
  if (!Hive.isAdapterRegistered(11)) { // typeId for NotificationType
    Hive.registerAdapter(NotificationTypeAdapter());
  }

  // Adha models
  if (!Hive.isAdapterRegistered(100)) { // typeId for AdhaMessageAdapter
    Hive.registerAdapter(AdhaMessageAdapter());
  }
  if (!Hive.isAdapterRegistered(101)) { // typeId for AdhaMessageTypeAdapter
    Hive.registerAdapter(AdhaMessageTypeAdapter());
  }
  if (!Hive.isAdapterRegistered(102)) { // typeId for AdhaConversationAdapter
    Hive.registerAdapter(AdhaConversationAdapter());
  }

  // Supplier models
  if (!Hive.isAdapterRegistered(12)) { // typeId for Supplier
    Hive.registerAdapter(SupplierAdapter());
  }
  if (!Hive.isAdapterRegistered(13)) { // typeId for SupplierCategory
    Hive.registerAdapter(SupplierCategoryAdapter());
  }
  
  // Settings models
  if (!Hive.isAdapterRegistered(14)) { // typeId for Settings
    Hive.registerAdapter(SettingsAdapter());
  }
  if (!Hive.isAdapterRegistered(15)) { // typeId for AppThemeMode
    Hive.registerAdapter(AppThemeModeAdapter());
  }

  // Inventory models
  if (!Hive.isAdapterRegistered(20)) { // typeId for ProductCategory
    Hive.registerAdapter(ProductCategoryAdapter());
  }
  if (!Hive.isAdapterRegistered(21)) { // typeId for ProductUnit
    Hive.registerAdapter(ProductUnitAdapter());
  }
  if (!Hive.isAdapterRegistered(22)) { // typeId for Product
    Hive.registerAdapter(ProductAdapter());
  }
  if (!Hive.isAdapterRegistered(23)) { // typeId for StockTransactionType
    Hive.registerAdapter(StockTransactionTypeAdapter());
  }
  if (!Hive.isAdapterRegistered(24)) { // typeId for StockTransaction
    Hive.registerAdapter(StockTransactionAdapter());
  }
  
  // Add other adapters here
}
