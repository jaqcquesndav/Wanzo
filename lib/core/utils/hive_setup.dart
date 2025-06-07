import 'package:hive_flutter/hive_flutter.dart';

// Auth models
import '../../features/auth/models/user.dart';
import '../../features/auth/models/business_sector.dart' as auth_bs;

// Customer models
import '../../features/customer/models/customer.dart' as customer_model; // Standardized import

// Inventory models
import '../../features/inventory/models/product.dart' as inventory_product;
import '../../features/inventory/models/stock_transaction.dart' as stock_tx_model;

// Sales models
import '../../features/sales/models/sale.dart';
import '../../features/sales/models/sale_item.dart' as sale_item_model; // Alias for SaleItemAdapter
import '../../features/sales/models/payment_method.dart';

// Supplier models
import '../../features/supplier/models/supplier.dart';

// Settings models
import '../../features/settings/models/settings.dart';
import '../enums/currency_enum.dart'; // Import for CurrencyAdapter

// Notifications models
import '../../features/notifications/models/notification_model.dart';

// Financing models
import '../../features/financing/models/financing_request.dart' as financing_model;

// Documents models
import '../../features/documents/models/document.dart' as document_model;

// Adha models
import '../../features/adha/models/adha_adapters.dart' as adha_adapters;

// Expense models
import '../../features/expenses/models/expense.dart'; // Added for Expense and ExpenseCategory


void _registerAdapterIfNotExists<T>(TypeAdapter<T> adapter) {
  if (!Hive.isAdapterRegistered(adapter.typeId)) {
    Hive.registerAdapter(adapter);
  }
}

Future<void> initializeHiveAdapters() async {
  // Register Adapters using the helper to avoid re-registration errors
  _registerAdapterIfNotExists(UserAdapter());
  _registerAdapterIfNotExists(IdStatusAdapter());
  _registerAdapterIfNotExists(auth_bs.BusinessSectorAdapter());

  // Customers - Standardized to use customer_model from features/customer/models/
  _registerAdapterIfNotExists(customer_model.CustomerAdapter()); 
  _registerAdapterIfNotExists(customer_model.CustomerCategoryAdapter());
  // Inventory
  _registerAdapterIfNotExists(inventory_product.ProductAdapter());
  _registerAdapterIfNotExists(inventory_product.ProductCategoryAdapter());
  _registerAdapterIfNotExists(inventory_product.ProductUnitAdapter());
  _registerAdapterIfNotExists(stock_tx_model.StockTransactionAdapter()); 
  _registerAdapterIfNotExists(stock_tx_model.StockTransactionTypeAdapter());

  // Sales
  _registerAdapterIfNotExists(SaleAdapter());
  _registerAdapterIfNotExists(sale_item_model.SaleItemAdapter()); // Use aliased import
  _registerAdapterIfNotExists(sale_item_model.SaleItemTypeAdapter()); // Added
  _registerAdapterIfNotExists(SaleStatusAdapter());
  _registerAdapterIfNotExists(PaymentMethodAdapter());
  
  // Supplier
  _registerAdapterIfNotExists(SupplierAdapter());
  _registerAdapterIfNotExists(SupplierCategoryAdapter());

  // Settings
  _registerAdapterIfNotExists(SettingsAdapter());
  _registerAdapterIfNotExists(AppThemeModeAdapter());
  _registerAdapterIfNotExists(CurrencyAdapter()); // Changed from CurrencyTypeAdapter 

  // Notifications
  _registerAdapterIfNotExists(NotificationModelAdapter());
  _registerAdapterIfNotExists(NotificationTypeAdapter());

  // Financing
  _registerAdapterIfNotExists(financing_model.FinancingRequestAdapter());
  _registerAdapterIfNotExists(financing_model.FinancingTypeAdapter());

  // Documents
  _registerAdapterIfNotExists(document_model.DocumentAdapter());

  // Adha
  _registerAdapterIfNotExists(adha_adapters.AdhaMessageAdapter());
  _registerAdapterIfNotExists(adha_adapters.AdhaConversationAdapter());

  // Register Expense adapters
  _registerAdapterIfNotExists(ExpenseAdapter()); // Added
  _registerAdapterIfNotExists(ExpenseCategoryAdapter()); // Added
}

// Helper function to open all necessary boxes
Future<void> openHiveBoxes() async {
  await Hive.openBox<User>('userBox');
  await Hive.openBox<auth_bs.BusinessSector>('authBusinessSectorsBox'); 
  await Hive.openBox<customer_model.Customer>('customersBox'); // Use customer_model.Customer
  // Ensure the correct Product type is used for 'productsBox' or use separate boxes.
  // For now, assuming 'productsBox' is for inventory_product.Product based on previous context.
  await Hive.openBox<inventory_product.Product>('productsBox'); 
  await Hive.openBox<stock_tx_model.StockTransaction>('stock_transactions'); // Added for InventoryRepository
  await Hive.openBox<Sale>('salesBox');
  await Hive.openBox<Supplier>('suppliersBox');
  await Hive.openBox<Settings>('settingsBox');
  await Hive.openBox<NotificationModel>('notificationsBox');
  await Hive.openBox<String>('syncStatusBox'); 
  await Hive.openBox<Expense>('expenses'); // Added to open the expenses box
  // Add other boxes if they were in main.dart and are not covered:
  // e.g. await Hive.openBox<global_product.Product>('globalProductsBox'); if needed
  // await Hive.openBox<document_model.Document>('documentsBox'); // Example if needed
  // await Hive.openBox<financing_model.FinancingRequest>('financingRequestsBox'); // Example if needed
  // await Hive.openBox<adha_adapters.AdhaConversation>('adhaConversationsBox'); // Example if needed
}
