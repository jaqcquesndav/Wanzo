import 'package:hive/hive.dart';
import '../../features/auth/models/user.dart';
import '../../features/notifications/models/notification_model.dart';
// Import Adha models
import '../../features/adha/models/adha_adapters.dart'; // Uncommented import
import '../../features/sales/models/sale.dart'; // Corrected: Import main model file
import '../../features/sales/models/sale_item.dart'; // Ensure SaleItemAdapter is available if defined separately or via sale_item.g.dart
import '../../features/financing/models/financing_request.dart'; // Corrected: Import main model file
import '../../features/customer/models/customer.dart'; // Added import for Customer model
import '../../features/supplier/models/supplier.dart'; // Added import for Supplier model
import '../../features/settings/models/settings.dart'; // Added import for Settings model
import '../../features/inventory/models/product.dart';
import '../../features/inventory/models/stock_transaction.dart';

/// Enregistre tous les adaptateurs Hive nécessaires
void registerHiveAdapters() {
  // User models
  if (!Hive.isAdapterRegistered(UserAdapter().typeId)) { // Use .typeId for consistency
    Hive.registerAdapter(UserAdapter());
  }
  if (!Hive.isAdapterRegistered(IdStatusAdapter().typeId)) { // Use .typeId
    Hive.registerAdapter(IdStatusAdapter());
  }

  // Sale models
  // Assuming SaleAdapter and SaleStatusAdapter are generated in sale.g.dart and accessible via sale.dart
  // The typeId for Sale is 7 as per sale.dart
  // The typeId for SaleStatus is 6 as per sale.dart
  if (!Hive.isAdapterRegistered(7)) { // typeId for Sale from sale.dart
    Hive.registerAdapter(SaleAdapter()); // This should now refer to the generated adapter
  }
  if (!Hive.isAdapterRegistered(2)) { // typeId for SaleItem (assuming it's 2 from sale_item.dart or its .g.dart file)
    Hive.registerAdapter(SaleItemAdapter());
  }
  
  // Customer models
  if (!Hive.isAdapterRegistered(CustomerAdapter().typeId)) { // Use .typeId
    Hive.registerAdapter(CustomerAdapter());
  }
  if (!Hive.isAdapterRegistered(CustomerCategoryAdapter().typeId)) { // Use .typeId
    Hive.registerAdapter(CustomerCategoryAdapter());
  }
  
  // SaleStatus is typeId 6 from sale.dart
  if (!Hive.isAdapterRegistered(6)) { // typeId for SaleStatus from sale.dart
    Hive.registerAdapter(SaleStatusAdapter()); // This should now refer to the generated adapter
  }

  // Financing models - Adjusted TypeIDs
  if (!Hive.isAdapterRegistered(FinancingRequestAdapter().typeId)) { // Use .typeId
    Hive.registerAdapter(FinancingRequestAdapter());
  }
  if (!Hive.isAdapterRegistered(FinancingTypeAdapter().typeId)) { // Use .typeId
    Hive.registerAdapter(FinancingTypeAdapter());
  }
  if (!Hive.isAdapterRegistered(FinancialInstitutionAdapter().typeId)) { // Use .typeId
    Hive.registerAdapter(FinancialInstitutionAdapter());
  }

  // Notification models - Adjusted TypeIDs
  if (!Hive.isAdapterRegistered(NotificationModelAdapter().typeId)) { // Use .typeId
    Hive.registerAdapter(NotificationModelAdapter());
  }
  
  if (!Hive.isAdapterRegistered(NotificationTypeAdapter().typeId)) { // Use .typeId
    Hive.registerAdapter(NotificationTypeAdapter());
  }

  // Adha models
  if (!Hive.isAdapterRegistered(AdhaMessageAdapter().typeId)) { // Use .typeId
    Hive.registerAdapter(AdhaMessageAdapter());
  }
  if (!Hive.isAdapterRegistered(AdhaMessageTypeAdapter().typeId)) { // Use .typeId
    Hive.registerAdapter(AdhaMessageTypeAdapter());
  }
  if (!Hive.isAdapterRegistered(AdhaConversationAdapter().typeId)) { // Use .typeId
    Hive.registerAdapter(AdhaConversationAdapter());
  }

  // Supplier models
  if (!Hive.isAdapterRegistered(SupplierAdapter().typeId)) { // Use .typeId
    Hive.registerAdapter(SupplierAdapter());
  }
  if (!Hive.isAdapterRegistered(SupplierCategoryAdapter().typeId)) { // Use .typeId
    Hive.registerAdapter(SupplierCategoryAdapter());
  }
  
  // Settings models
  if (!Hive.isAdapterRegistered(SettingsAdapter().typeId)) { // Use .typeId
    Hive.registerAdapter(SettingsAdapter());
  }
  if (!Hive.isAdapterRegistered(AppThemeModeAdapter().typeId)) { // Use .typeId
    Hive.registerAdapter(AppThemeModeAdapter());
  }

  // Inventory models
  if (!Hive.isAdapterRegistered(ProductCategoryAdapter().typeId)) { // Use .typeId
    Hive.registerAdapter(ProductCategoryAdapter());
  }
  if (!Hive.isAdapterRegistered(ProductUnitAdapter().typeId)) { // Use .typeId
    Hive.registerAdapter(ProductUnitAdapter());
  }
  if (!Hive.isAdapterRegistered(ProductAdapter().typeId)) { // Use .typeId
    Hive.registerAdapter(ProductAdapter());
  }
  if (!Hive.isAdapterRegistered(StockTransactionTypeAdapter().typeId)) { // Use .typeId
    Hive.registerAdapter(StockTransactionTypeAdapter());
  }
  if (!Hive.isAdapterRegistered(StockTransactionAdapter().typeId)) { // Use .typeId
    Hive.registerAdapter(StockTransactionAdapter());
  }
  
  // Add other adapters here
}
