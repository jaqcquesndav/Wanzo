import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @invoiceSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Invoice Settings'**
  String get invoiceSettingsTitle;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @currencySettings.
  ///
  /// In en, this message translates to:
  /// **'Currency Settings'**
  String get currencySettings;

  /// No description provided for @activeCurrency.
  ///
  /// In en, this message translates to:
  /// **'Active Currency'**
  String get activeCurrency;

  /// No description provided for @errorFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get errorFieldRequired;

  /// Label for exchange rate input field
  ///
  /// In en, this message translates to:
  /// **'Exchange Rate {fromCurrency} to {toCurrency}'**
  String exchangeRateSpecific(String fromCurrency, String toCurrency);

  /// No description provided for @errorInvalidRate.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid rate greater than 0'**
  String get errorInvalidRate;

  /// No description provided for @invoiceFormatting.
  ///
  /// In en, this message translates to:
  /// **'Invoice Formatting'**
  String get invoiceFormatting;

  /// No description provided for @invoiceFormatHint.
  ///
  /// In en, this message translates to:
  /// **'Use {YEAR}, {MONTH}, {SEQ} for year, month, sequence.'**
  String invoiceFormatHint(Object MONTH, Object SEQ, Object YEAR);

  /// No description provided for @invoiceNumberFormat.
  ///
  /// In en, this message translates to:
  /// **'Invoice Number Format'**
  String get invoiceNumberFormat;

  /// No description provided for @invoicePrefix.
  ///
  /// In en, this message translates to:
  /// **'Invoice Prefix'**
  String get invoicePrefix;

  /// No description provided for @taxesAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Taxes and Conditions'**
  String get taxesAndConditions;

  /// No description provided for @showTaxesOnInvoices.
  ///
  /// In en, this message translates to:
  /// **'Show taxes on invoices'**
  String get showTaxesOnInvoices;

  /// No description provided for @defaultTaxRatePercentage.
  ///
  /// In en, this message translates to:
  /// **'Default Tax Rate (%)'**
  String get defaultTaxRatePercentage;

  /// No description provided for @errorInvalidTaxRate.
  ///
  /// In en, this message translates to:
  /// **'Tax rate must be between 0 and 100'**
  String get errorInvalidTaxRate;

  /// No description provided for @defaultPaymentTerms.
  ///
  /// In en, this message translates to:
  /// **'Default Payment Terms'**
  String get defaultPaymentTerms;

  /// No description provided for @defaultInvoiceNotes.
  ///
  /// In en, this message translates to:
  /// **'Default Invoice Notes'**
  String get defaultInvoiceNotes;

  /// No description provided for @settingsSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Settings saved successfully.'**
  String get settingsSavedSuccess;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred.'**
  String get errorUnknown;

  /// No description provided for @currencySettingsError.
  ///
  /// In en, this message translates to:
  /// **'Currency Settings Error: {message}'**
  String currencySettingsError(String message);

  /// No description provided for @currencySettingsSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Currency settings saved successfully.'**
  String get currencySettingsSavedSuccess;

  /// No description provided for @anErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get anErrorOccurred;

  /// No description provided for @currencyCDF.
  ///
  /// In en, this message translates to:
  /// **'Congolese Franc'**
  String get currencyCDF;

  /// No description provided for @currencyUSD.
  ///
  /// In en, this message translates to:
  /// **'US Dollar'**
  String get currencyUSD;

  /// No description provided for @currencyFCFA.
  ///
  /// In en, this message translates to:
  /// **'CFA Franc'**
  String get currencyFCFA;

  /// No description provided for @editProductTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get editProductTitle;

  /// No description provided for @addProductTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProductTitle;

  /// No description provided for @productCategoryFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get productCategoryFood;

  /// No description provided for @productCategoryDrink.
  ///
  /// In en, this message translates to:
  /// **'Drink'**
  String get productCategoryDrink;

  /// No description provided for @productCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get productCategoryOther;

  /// No description provided for @units.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get units;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes (Optional)'**
  String get notes;

  /// No description provided for @saveProduct.
  ///
  /// In en, this message translates to:
  /// **'Save Product'**
  String get saveProduct;

  /// No description provided for @inventoryValue.
  ///
  /// In en, this message translates to:
  /// **'Inventory Value'**
  String get inventoryValue;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @stockMovements.
  ///
  /// In en, this message translates to:
  /// **'Stock Movements'**
  String get stockMovements;

  /// No description provided for @noProducts.
  ///
  /// In en, this message translates to:
  /// **'No products yet.'**
  String get noProducts;

  /// No description provided for @noStockMovements.
  ///
  /// In en, this message translates to:
  /// **'No stock movements yet.'**
  String get noStockMovements;

  /// No description provided for @searchProducts.
  ///
  /// In en, this message translates to:
  /// **'Search products...'**
  String get searchProducts;

  /// No description provided for @totalStock.
  ///
  /// In en, this message translates to:
  /// **'Total Stock'**
  String get totalStock;

  /// No description provided for @valueInCdf.
  ///
  /// In en, this message translates to:
  /// **'Value (CDF)'**
  String get valueInCdf;

  /// No description provided for @valueIn.
  ///
  /// In en, this message translates to:
  /// **'Value ({currencyCode})'**
  String valueIn(String currencyCode);

  /// No description provided for @lastModified.
  ///
  /// In en, this message translates to:
  /// **'Last Modified'**
  String get lastModified;

  /// No description provided for @productDetails.
  ///
  /// In en, this message translates to:
  /// **'Product Details'**
  String get productDetails;

  /// No description provided for @deleteProduct.
  ///
  /// In en, this message translates to:
  /// **'Delete Product'**
  String get deleteProduct;

  /// No description provided for @confirmDeleteProductTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get confirmDeleteProductTitle;

  /// No description provided for @confirmDeleteProductMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this product? This action cannot be undone.'**
  String get confirmDeleteProductMessage;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @stockIn.
  ///
  /// In en, this message translates to:
  /// **'Stock In'**
  String get stockIn;

  /// No description provided for @stockOut.
  ///
  /// In en, this message translates to:
  /// **'Stock Out'**
  String get stockOut;

  /// No description provided for @adjustment.
  ///
  /// In en, this message translates to:
  /// **'Adjustment'**
  String get adjustment;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason (Optional)'**
  String get reason;

  /// No description provided for @addStockMovement.
  ///
  /// In en, this message translates to:
  /// **'Add Stock Movement'**
  String get addStockMovement;

  /// No description provided for @newStock.
  ///
  /// In en, this message translates to:
  /// **'New Stock'**
  String get newStock;

  /// No description provided for @value.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get value;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @product.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get product;

  /// No description provided for @selectProduct.
  ///
  /// In en, this message translates to:
  /// **'Select Product'**
  String get selectProduct;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// No description provided for @selectUnit.
  ///
  /// In en, this message translates to:
  /// **'Select Unit'**
  String get selectUnit;

  /// No description provided for @imagePickingErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Error picking image: {errorDetails}'**
  String imagePickingErrorMessage(String errorDetails);

  /// No description provided for @galleryAction.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get galleryAction;

  /// No description provided for @cameraAction.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get cameraAction;

  /// No description provided for @removeImageAction.
  ///
  /// In en, this message translates to:
  /// **'Remove Image'**
  String get removeImageAction;

  /// No description provided for @productImageSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Product Image'**
  String get productImageSectionTitle;

  /// No description provided for @addImageLabel.
  ///
  /// In en, this message translates to:
  /// **'Add Image'**
  String get addImageLabel;

  /// No description provided for @generalInformationSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'General Information'**
  String get generalInformationSectionTitle;

  /// No description provided for @productNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get productNameLabel;

  /// No description provided for @productNameValidationError.
  ///
  /// In en, this message translates to:
  /// **'Please enter the product name.'**
  String get productNameValidationError;

  /// No description provided for @productDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get productDescriptionLabel;

  /// No description provided for @productBarcodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Barcode (Optional)'**
  String get productBarcodeLabel;

  /// No description provided for @featureComingSoonMessage.
  ///
  /// In en, this message translates to:
  /// **'Feature coming soon!'**
  String get featureComingSoonMessage;

  /// No description provided for @productCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get productCategoryLabel;

  /// No description provided for @productCategoryElectronics.
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get productCategoryElectronics;

  /// No description provided for @productCategoryClothing.
  ///
  /// In en, this message translates to:
  /// **'Clothing'**
  String get productCategoryClothing;

  /// No description provided for @productCategoryHousehold.
  ///
  /// In en, this message translates to:
  /// **'Household'**
  String get productCategoryHousehold;

  /// No description provided for @productCategoryHygiene.
  ///
  /// In en, this message translates to:
  /// **'Hygiene'**
  String get productCategoryHygiene;

  /// No description provided for @productCategoryOffice.
  ///
  /// In en, this message translates to:
  /// **'Office Supplies'**
  String get productCategoryOffice;

  /// No description provided for @pricingSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Pricing and Currency'**
  String get pricingSectionTitle;

  /// No description provided for @inputCurrencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Input Currency'**
  String get inputCurrencyLabel;

  /// No description provided for @inputCurrencyValidationError.
  ///
  /// In en, this message translates to:
  /// **'Please select an input currency.'**
  String get inputCurrencyValidationError;

  /// No description provided for @costPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Cost Price'**
  String get costPriceLabel;

  /// No description provided for @costPriceValidationError.
  ///
  /// In en, this message translates to:
  /// **'Please enter the cost price.'**
  String get costPriceValidationError;

  /// No description provided for @negativePriceValidationError.
  ///
  /// In en, this message translates to:
  /// **'Price cannot be negative.'**
  String get negativePriceValidationError;

  /// No description provided for @invalidNumberValidationError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number.'**
  String get invalidNumberValidationError;

  /// No description provided for @sellingPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Selling Price'**
  String get sellingPriceLabel;

  /// No description provided for @sellingPriceValidationError.
  ///
  /// In en, this message translates to:
  /// **'Please enter the selling price.'**
  String get sellingPriceValidationError;

  /// No description provided for @stockManagementSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Stock Management'**
  String get stockManagementSectionTitle;

  /// No description provided for @stockQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity in Stock'**
  String get stockQuantityLabel;

  /// No description provided for @stockQuantityValidationError.
  ///
  /// In en, this message translates to:
  /// **'Please enter the stock quantity.'**
  String get stockQuantityValidationError;

  /// No description provided for @negativeQuantityValidationError.
  ///
  /// In en, this message translates to:
  /// **'Quantity cannot be negative.'**
  String get negativeQuantityValidationError;

  /// No description provided for @productUnitLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get productUnitLabel;

  /// No description provided for @productUnitPiece.
  ///
  /// In en, this message translates to:
  /// **'Piece(s)'**
  String get productUnitPiece;

  /// No description provided for @productUnitKg.
  ///
  /// In en, this message translates to:
  /// **'Kilogram(s) (kg)'**
  String get productUnitKg;

  /// No description provided for @productUnitG.
  ///
  /// In en, this message translates to:
  /// **'Gram(s) (g)'**
  String get productUnitG;

  /// No description provided for @productUnitL.
  ///
  /// In en, this message translates to:
  /// **'Liter(s) (L)'**
  String get productUnitL;

  /// No description provided for @productUnitMl.
  ///
  /// In en, this message translates to:
  /// **'Milliliter(s) (ml)'**
  String get productUnitMl;

  /// No description provided for @productUnitPackage.
  ///
  /// In en, this message translates to:
  /// **'Package(s)'**
  String get productUnitPackage;

  /// No description provided for @productUnitBox.
  ///
  /// In en, this message translates to:
  /// **'Box(es)'**
  String get productUnitBox;

  /// No description provided for @productUnitOther.
  ///
  /// In en, this message translates to:
  /// **'Other Unit'**
  String get productUnitOther;

  /// No description provided for @lowStockThresholdLabel.
  ///
  /// In en, this message translates to:
  /// **'Low Stock Alert Threshold'**
  String get lowStockThresholdLabel;

  /// No description provided for @lowStockThresholdHelper.
  ///
  /// In en, this message translates to:
  /// **'Receive an alert when stock reaches this level.'**
  String get lowStockThresholdHelper;

  /// No description provided for @lowStockThresholdValidationError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid alert threshold.'**
  String get lowStockThresholdValidationError;

  /// No description provided for @negativeThresholdValidationError.
  ///
  /// In en, this message translates to:
  /// **'Threshold cannot be negative.'**
  String get negativeThresholdValidationError;

  /// No description provided for @saveChangesButton.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChangesButton;

  /// No description provided for @addProductButton.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProductButton;

  /// No description provided for @notesLabelOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (Optional)'**
  String get notesLabelOptional;

  /// No description provided for @addStockDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Stock to {productName}'**
  String addStockDialogTitle(String productName);

  /// No description provided for @currentStockLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Stock'**
  String get currentStockLabel;

  /// No description provided for @quantityToAddLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity to Add'**
  String get quantityToAddLabel;

  /// No description provided for @quantityValidationError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a quantity.'**
  String get quantityValidationError;

  /// No description provided for @positiveQuantityValidationError.
  ///
  /// In en, this message translates to:
  /// **'Quantity must be positive for a purchase.'**
  String get positiveQuantityValidationError;

  /// No description provided for @addButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addButtonLabel;

  /// No description provided for @stockAdjustmentDefaultNote.
  ///
  /// In en, this message translates to:
  /// **'Stock adjustment'**
  String get stockAdjustmentDefaultNote;

  /// Label for other stock transaction types
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get stockTransactionTypeOther;

  /// Fallback initial letter for product image if name is empty or image fails
  ///
  /// In en, this message translates to:
  /// **'P'**
  String get productInitialFallback;

  /// Title for the Inventory Screen
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get inventoryScreenTitle;

  /// Label for the All Products tab
  ///
  /// In en, this message translates to:
  /// **'All Products'**
  String get allProductsTabLabel;

  /// Label for the Low Stock tab
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get lowStockTabLabel;

  /// Label for the Transactions tab
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactionsTabLabel;

  /// Message displayed when there are no products
  ///
  /// In en, this message translates to:
  /// **'No products available.'**
  String get noProductsAvailableMessage;

  /// Message displayed when no products have low stock
  ///
  /// In en, this message translates to:
  /// **'No products with low stock.'**
  String get noLowStockProductsMessage;

  /// Message displayed when there are no transactions
  ///
  /// In en, this message translates to:
  /// **'No transactions available.'**
  String get noTransactionsAvailableMessage;

  /// Title for the search product dialog
  ///
  /// In en, this message translates to:
  /// **'Search Product'**
  String get searchProductDialogTitle;

  /// Hint text for the product search input field
  ///
  /// In en, this message translates to:
  /// **'Enter product name or barcode...'**
  String get searchProductHintText;

  /// Label for the cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButtonLabel;

  /// Label for the search button
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchButtonLabel;

  /// Title for the filter by category dialog
  ///
  /// In en, this message translates to:
  /// **'Filter by Category'**
  String get filterByCategoryDialogTitle;

  /// Message displayed when no categories are available for filtering
  ///
  /// In en, this message translates to:
  /// **'No categories available to filter.'**
  String get noCategoriesAvailableMessage;

  /// Label for the show all button in filters
  ///
  /// In en, this message translates to:
  /// **'Show All'**
  String get showAllButtonLabel;

  /// Message displayed on empty inventory screen
  ///
  /// In en, this message translates to:
  /// **'You haven\'\'t added any products to your inventory yet.'**
  String get noProductsInInventoryMessage;

  /// Label for product price
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get priceLabel;

  /// Label for product input price
  ///
  /// In en, this message translates to:
  /// **'Input'**
  String get inputPriceLabel;

  /// Label for product stock quantity
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get stockLabel;

  /// Label for a product that cannot be found
  ///
  /// In en, this message translates to:
  /// **'Unknown Product'**
  String get unknownProductLabel;

  /// Label for quantity
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantityLabel;

  /// Label for date
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// Label for value
  ///
  /// In en, this message translates to:
  /// **'Label for value'**
  String get valueLabel;

  /// Label for the retry button
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButtonLabel;

  /// Label for purchase stock transaction type
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get stockTransactionTypePurchase;

  /// Label for sale stock transaction type
  ///
  /// In en, this message translates to:
  /// **'Sale'**
  String get stockTransactionTypeSale;

  /// Label for adjustment stock transaction type
  ///
  /// In en, this message translates to:
  /// **'Adjustment'**
  String get stockTransactionTypeAdjustment;

  /// Title for the Sales Screen
  ///
  /// In en, this message translates to:
  /// **'Sales Management'**
  String get salesScreenTitle;

  /// Label for the All sales tab
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get salesTabAll;

  /// Label for the Pending sales tab
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get salesTabPending;

  /// Label for the Completed sales tab
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get salesTabCompleted;

  /// Title for the filter sales dialog
  ///
  /// In en, this message translates to:
  /// **'Filter Sales'**
  String get salesFilterDialogTitle;

  /// Label for the cancel button in filter sales dialog
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get salesFilterDialogCancel;

  /// Label for the apply button in filter sales dialog
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get salesFilterDialogApply;

  /// Label for total sales in summary
  ///
  /// In en, this message translates to:
  /// **'Total Sales'**
  String get salesSummaryTotal;

  /// Label for number of sales in summary
  ///
  /// In en, this message translates to:
  /// **'Number of Sales'**
  String get salesSummaryCount;

  /// Status text for pending sales
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get salesStatusPending;

  /// Status text for completed sales
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get salesStatusCompleted;

  /// Status text for partially paid sales
  ///
  /// In en, this message translates to:
  /// **'Partially Paid'**
  String get salesStatusPartiallyPaid;

  /// Status text for cancelled sales
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get salesStatusCancelled;

  /// Message when no sales are found
  ///
  /// In en, this message translates to:
  /// **'No sales found'**
  String get salesNoSalesFound;

  /// Label for the add sale button
  ///
  /// In en, this message translates to:
  /// **'Add Sale'**
  String get salesAddSaleButton;

  /// Prefix for error messages on sales screen
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get salesErrorPrefix;

  /// Label for the retry button on sales screen
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get salesRetryButton;

  /// Label for start date in filter sales dialog
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get salesFilterDialogStartDate;

  /// Label for end date in filter sales dialog
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get salesFilterDialogEndDate;

  /// Prefix for sale ID in sale list item
  ///
  /// In en, this message translates to:
  /// **'Sale #'**
  String get salesListItemSaleIdPrefix;

  /// Text for number of articles in a sale item
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{1 article} other{{count} articles}}'**
  String salesListItemArticles(int count);

  /// Label for total amount in sale list item
  ///
  /// In en, this message translates to:
  /// **'Total:'**
  String get salesListItemTotal;

  /// Label for remaining amount to pay in sale list item
  ///
  /// In en, this message translates to:
  /// **'Remaining to pay:'**
  String get salesListItemRemainingToPay;

  /// No description provided for @subscriptionScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Subscription Management'**
  String get subscriptionScreenTitle;

  /// No description provided for @subscriptionUnsupportedFileType.
  ///
  /// In en, this message translates to:
  /// **'Unsupported file type. Please choose a JPG or PNG file.'**
  String get subscriptionUnsupportedFileType;

  /// No description provided for @subscriptionFileTooLarge.
  ///
  /// In en, this message translates to:
  /// **'File too large. Maximum size is 5MB.'**
  String get subscriptionFileTooLarge;

  /// No description provided for @subscriptionNoImageSelected.
  ///
  /// In en, this message translates to:
  /// **'No image selected.'**
  String get subscriptionNoImageSelected;

  /// No description provided for @subscriptionUpdateSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Subscription updated successfully.'**
  String get subscriptionUpdateSuccessMessage;

  /// No description provided for @subscriptionUpdateFailureMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to update subscription: {error}'**
  String subscriptionUpdateFailureMessage(String error);

  /// No description provided for @subscriptionTokenTopUpSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Tokens topped up successfully.'**
  String get subscriptionTokenTopUpSuccessMessage;

  /// No description provided for @subscriptionTokenTopUpFailureMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to top up tokens: {error}'**
  String subscriptionTokenTopUpFailureMessage(String error);

  /// No description provided for @subscriptionPaymentProofUploadSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Payment proof uploaded successfully.'**
  String get subscriptionPaymentProofUploadSuccessMessage;

  /// No description provided for @subscriptionPaymentProofUploadFailureMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload payment proof: {error}'**
  String subscriptionPaymentProofUploadFailureMessage(String error);

  /// No description provided for @subscriptionRetryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get subscriptionRetryButton;

  /// No description provided for @subscriptionUnhandledState.
  ///
  /// In en, this message translates to:
  /// **'Unhandled state or initialization...'**
  String get subscriptionUnhandledState;

  /// No description provided for @subscriptionSectionOurOffers.
  ///
  /// In en, this message translates to:
  /// **'Our Subscription Offers'**
  String get subscriptionSectionOurOffers;

  /// No description provided for @subscriptionSectionCurrentSubscription.
  ///
  /// In en, this message translates to:
  /// **'Your Current Subscription'**
  String get subscriptionSectionCurrentSubscription;

  /// No description provided for @subscriptionSectionTokenUsage.
  ///
  /// In en, this message translates to:
  /// **'Adha Token Usage'**
  String get subscriptionSectionTokenUsage;

  /// No description provided for @subscriptionSectionInvoiceHistory.
  ///
  /// In en, this message translates to:
  /// **'Invoice History'**
  String get subscriptionSectionInvoiceHistory;

  /// No description provided for @subscriptionSectionPaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get subscriptionSectionPaymentMethods;

  /// No description provided for @subscriptionChangeSubscriptionButton.
  ///
  /// In en, this message translates to:
  /// **'Change Subscription'**
  String get subscriptionChangeSubscriptionButton;

  /// No description provided for @subscriptionTierFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get subscriptionTierFree;

  /// No description provided for @subscriptionTierUsers.
  ///
  /// In en, this message translates to:
  /// **'Users: {count}'**
  String subscriptionTierUsers(int count);

  /// No description provided for @subscriptionTierAdhaTokens.
  ///
  /// In en, this message translates to:
  /// **'Adha Tokens: {count}'**
  String subscriptionTierAdhaTokens(int count);

  /// No description provided for @subscriptionTierFeatures.
  ///
  /// In en, this message translates to:
  /// **'Features:'**
  String get subscriptionTierFeatures;

  /// No description provided for @subscriptionTierCurrentPlanChip.
  ///
  /// In en, this message translates to:
  /// **'Current Plan'**
  String get subscriptionTierCurrentPlanChip;

  /// No description provided for @subscriptionTierChoosePlanButton.
  ///
  /// In en, this message translates to:
  /// **'Choose this plan'**
  String get subscriptionTierChoosePlanButton;

  /// No description provided for @subscriptionCurrentPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Current Plan: {tierName}'**
  String subscriptionCurrentPlanTitle(String tierName);

  /// No description provided for @subscriptionCurrentPlanPrice.
  ///
  /// In en, this message translates to:
  /// **'Price: {price}'**
  String subscriptionCurrentPlanPrice(String price);

  /// No description provided for @subscriptionAvailableAdhaTokens.
  ///
  /// In en, this message translates to:
  /// **'Available Adha Tokens: {count}'**
  String subscriptionAvailableAdhaTokens(int count);

  /// No description provided for @subscriptionTopUpTokensButton.
  ///
  /// In en, this message translates to:
  /// **'Top-up Tokens'**
  String get subscriptionTopUpTokensButton;

  /// No description provided for @subscriptionNoInvoices.
  ///
  /// In en, this message translates to:
  /// **'No invoices available at the moment.'**
  String get subscriptionNoInvoices;

  /// No description provided for @subscriptionInvoiceListTitle.
  ///
  /// In en, this message translates to:
  /// **'Invoice {id} - {date}'**
  String subscriptionInvoiceListTitle(String id, String date);

  /// No description provided for @subscriptionInvoiceListSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Amount: {amount} - Status: {status}'**
  String subscriptionInvoiceListSubtitle(String amount, String status);

  /// No description provided for @subscriptionDownloadInvoiceTooltip.
  ///
  /// In en, this message translates to:
  /// **'Download invoice'**
  String get subscriptionDownloadInvoiceTooltip;

  /// No description provided for @subscriptionSimulateDownloadInvoice.
  ///
  /// In en, this message translates to:
  /// **'Simulation: Downloading {id} from {url}'**
  String subscriptionSimulateDownloadInvoice(String id, String url);

  /// No description provided for @subscriptionSimulateViewInvoiceDetails.
  ///
  /// In en, this message translates to:
  /// **'Simulation: View invoice details {id}'**
  String subscriptionSimulateViewInvoiceDetails(String id);

  /// No description provided for @subscriptionPaymentMethodsNextInvoice.
  ///
  /// In en, this message translates to:
  /// **'Payment methods for the next invoice:'**
  String get subscriptionPaymentMethodsNextInvoice;

  /// No description provided for @subscriptionPaymentMethodsRegistered.
  ///
  /// In en, this message translates to:
  /// **'Registered methods:'**
  String get subscriptionPaymentMethodsRegistered;

  /// No description provided for @subscriptionPaymentMethodsOtherOptions.
  ///
  /// In en, this message translates to:
  /// **'Other payment options:'**
  String get subscriptionPaymentMethodsOtherOptions;

  /// No description provided for @subscriptionPaymentMethodNewCard.
  ///
  /// In en, this message translates to:
  /// **'New Credit Card'**
  String get subscriptionPaymentMethodNewCard;

  /// No description provided for @subscriptionPaymentMethodNewMobileMoney.
  ///
  /// In en, this message translates to:
  /// **'New Mobile Money'**
  String get subscriptionPaymentMethodNewMobileMoney;

  /// No description provided for @subscriptionPaymentMethodManual.
  ///
  /// In en, this message translates to:
  /// **'Manual Payment (Transfer/Deposit)'**
  String get subscriptionPaymentMethodManual;

  /// No description provided for @subscriptionManualPaymentInstructions.
  ///
  /// In en, this message translates to:
  /// **'Please make the transfer/deposit to the provided details and upload a proof of payment.'**
  String get subscriptionManualPaymentInstructions;

  /// No description provided for @subscriptionProofUploadedLabel.
  ///
  /// In en, this message translates to:
  /// **'Proof Uploaded: {fileName}'**
  String subscriptionProofUploadedLabel(String fileName);

  /// No description provided for @subscriptionUploadProofButton.
  ///
  /// In en, this message translates to:
  /// **'Upload Proof'**
  String get subscriptionUploadProofButton;

  /// No description provided for @subscriptionReplaceProofButton.
  ///
  /// In en, this message translates to:
  /// **'Replace Proof'**
  String get subscriptionReplaceProofButton;

  /// No description provided for @subscriptionConfirmPaymentMethodButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm Payment Method'**
  String get subscriptionConfirmPaymentMethodButton;

  /// No description provided for @subscriptionSimulatePaymentMethodSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected payment method: {method} (Simulation)'**
  String subscriptionSimulatePaymentMethodSelected(String method);

  /// No description provided for @subscriptionChangeDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Subscription'**
  String get subscriptionChangeDialogTitle;

  /// No description provided for @subscriptionChangeDialogTierSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{price} - Tokens: {tokens}'**
  String subscriptionChangeDialogTierSubtitle(String price, String tokens);

  /// No description provided for @subscriptionTopUpDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Top-up Adha Tokens'**
  String get subscriptionTopUpDialogTitle;

  /// No description provided for @subscriptionTopUpDialogAmount.
  ///
  /// In en, this message translates to:
  /// **'{amount} {currencyCode}'**
  String subscriptionTopUpDialogAmount(String amount, String currencyCode);

  /// No description provided for @subscriptionNoActivePlan.
  ///
  /// In en, this message translates to:
  /// **'You do not have an active subscription plan.'**
  String get subscriptionNoActivePlan;

  /// No description provided for @contactsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get contactsScreenTitle;

  /// No description provided for @contactsScreenClientsTab.
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get contactsScreenClientsTab;

  /// No description provided for @contactsScreenSuppliersTab.
  ///
  /// In en, this message translates to:
  /// **'Suppliers'**
  String get contactsScreenSuppliersTab;

  /// No description provided for @contactsScreenAddClientTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add a client'**
  String get contactsScreenAddClientTooltip;

  /// No description provided for @contactsScreenAddSupplierTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add a supplier'**
  String get contactsScreenAddSupplierTooltip;

  /// No description provided for @searchCustomerHint.
  ///
  /// In en, this message translates to:
  /// **'Search for a customer...'**
  String get searchCustomerHint;

  /// No description provided for @customerError.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String customerError(String message);

  /// No description provided for @noCustomersToShow.
  ///
  /// In en, this message translates to:
  /// **'No customers to display'**
  String get noCustomersToShow;

  /// No description provided for @customersTitle.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customersTitle;

  /// No description provided for @filterCustomersTooltip.
  ///
  /// In en, this message translates to:
  /// **'Filter customers'**
  String get filterCustomersTooltip;

  /// No description provided for @addCustomerTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add a new customer'**
  String get addCustomerTooltip;

  /// No description provided for @noResultsForSearchTerm.
  ///
  /// In en, this message translates to:
  /// **'No results for {searchTerm}'**
  String noResultsForSearchTerm(String searchTerm);

  /// No description provided for @noCustomersAvailable.
  ///
  /// In en, this message translates to:
  /// **'No customers available'**
  String get noCustomersAvailable;

  /// No description provided for @topCustomersByPurchases.
  ///
  /// In en, this message translates to:
  /// **'Top customers by purchases'**
  String get topCustomersByPurchases;

  /// No description provided for @recentlyAddedCustomers.
  ///
  /// In en, this message translates to:
  /// **'Recently added customers'**
  String get recentlyAddedCustomers;

  /// No description provided for @resultsForSearchTerm.
  ///
  /// In en, this message translates to:
  /// **'Results for {searchTerm}'**
  String resultsForSearchTerm(String searchTerm);

  /// No description provided for @lastPurchaseDate.
  ///
  /// In en, this message translates to:
  /// **'Last purchase: {date}'**
  String lastPurchaseDate(String date);

  /// No description provided for @noRecentPurchase.
  ///
  /// In en, this message translates to:
  /// **'No recent purchase'**
  String get noRecentPurchase;

  /// No description provided for @totalPurchasesAmount.
  ///
  /// In en, this message translates to:
  /// **'Total purchases: {amount}'**
  String totalPurchasesAmount(String amount);

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get viewDetails;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @allCustomers.
  ///
  /// In en, this message translates to:
  /// **'All customers'**
  String get allCustomers;

  /// No description provided for @topCustomers.
  ///
  /// In en, this message translates to:
  /// **'Top customers'**
  String get topCustomers;

  /// No description provided for @recentCustomers.
  ///
  /// In en, this message translates to:
  /// **'Recent customers'**
  String get recentCustomers;

  /// No description provided for @byCategory.
  ///
  /// In en, this message translates to:
  /// **'By category'**
  String get byCategory;

  /// No description provided for @filterByCategory.
  ///
  /// In en, this message translates to:
  /// **'Filter by category'**
  String get filterByCategory;

  /// No description provided for @deleteCustomerTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete customer'**
  String get deleteCustomerTitle;

  /// No description provided for @deleteCustomerConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {customerName}? This action is irreversible.'**
  String deleteCustomerConfirmation(String customerName);

  /// No description provided for @customerCategoryVip.
  ///
  /// In en, this message translates to:
  /// **'VIP'**
  String get customerCategoryVip;

  /// No description provided for @customerCategoryRegular.
  ///
  /// In en, this message translates to:
  /// **'Regular'**
  String get customerCategoryRegular;

  /// No description provided for @customerCategoryNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get customerCategoryNew;

  /// No description provided for @customerCategoryOccasional.
  ///
  /// In en, this message translates to:
  /// **'Occasional'**
  String get customerCategoryOccasional;

  /// No description provided for @customerCategoryBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get customerCategoryBusiness;

  /// No description provided for @customerCategoryUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get customerCategoryUnknown;

  /// No description provided for @editCustomerTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Customer'**
  String get editCustomerTitle;

  /// No description provided for @addCustomerTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Customer'**
  String get addCustomerTitle;

  /// No description provided for @customerPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'+243 999 123 456'**
  String get customerPhoneHint;

  /// No description provided for @customerInformation.
  ///
  /// In en, this message translates to:
  /// **'Customer Information'**
  String get customerInformation;

  /// No description provided for @customerNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer Name'**
  String get customerNameLabel;

  /// No description provided for @customerNameValidationError.
  ///
  /// In en, this message translates to:
  /// **'Please enter the customer\'s name.'**
  String get customerNameValidationError;

  /// No description provided for @customerPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer Phone'**
  String get customerPhoneLabel;

  /// No description provided for @customerPhoneValidationError.
  ///
  /// In en, this message translates to:
  /// **'Please enter the customer\'s phone number.'**
  String get customerPhoneValidationError;

  /// No description provided for @customerEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer Email (Optional)'**
  String get customerEmailLabel;

  /// No description provided for @customerEmailLabelOptional.
  ///
  /// In en, this message translates to:
  /// **'Customer Email'**
  String get customerEmailLabelOptional;

  /// No description provided for @customerEmailValidationError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get customerEmailValidationError;

  /// No description provided for @customerAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer Address (Optional)'**
  String get customerAddressLabel;

  /// No description provided for @customerAddressLabelOptional.
  ///
  /// In en, this message translates to:
  /// **'Customer Address'**
  String get customerAddressLabelOptional;

  /// No description provided for @customerCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer Category'**
  String get customerCategoryLabel;

  /// No description provided for @customerNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes (Optional)'**
  String get customerNotesLabel;

  /// No description provided for @updateButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateButtonLabel;

  /// No description provided for @customerDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Customer Details'**
  String get customerDetailsTitle;

  /// No description provided for @editCustomerTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit customer'**
  String get editCustomerTooltip;

  /// No description provided for @customerNotFound.
  ///
  /// In en, this message translates to:
  /// **'Customer not found'**
  String get customerNotFound;

  /// No description provided for @contactInformationSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInformationSectionTitle;

  /// No description provided for @purchaseStatisticsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Purchase Statistics'**
  String get purchaseStatisticsSectionTitle;

  /// No description provided for @totalPurchasesLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Purchases'**
  String get totalPurchasesLabel;

  /// No description provided for @lastPurchaseLabel.
  ///
  /// In en, this message translates to:
  /// **'Last Purchase'**
  String get lastPurchaseLabel;

  /// No description provided for @noPurchaseRecorded.
  ///
  /// In en, this message translates to:
  /// **'No purchase recorded'**
  String get noPurchaseRecorded;

  /// No description provided for @customerSinceLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer Since'**
  String get customerSinceLabel;

  /// No description provided for @addSaleButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Add Sale'**
  String get addSaleButtonLabel;

  /// No description provided for @callButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get callButtonLabel;

  /// No description provided for @deleteButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButtonLabel;

  /// No description provided for @callingNumber.
  ///
  /// In en, this message translates to:
  /// **'Calling {phoneNumber}...'**
  String callingNumber(String phoneNumber);

  /// No description provided for @emailingTo.
  ///
  /// In en, this message translates to:
  /// **'Emailing to {email}...'**
  String emailingTo(String email);

  /// No description provided for @openingMapFor.
  ///
  /// In en, this message translates to:
  /// **'Opening map for {address}...'**
  String openingMapFor(String address);

  /// No description provided for @searchSupplierHint.
  ///
  /// In en, this message translates to:
  /// **'Search for a supplier...'**
  String get searchSupplierHint;

  /// No description provided for @clearSearchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearchTooltip;

  /// No description provided for @supplierError.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String supplierError(String message);

  /// No description provided for @noSuppliersToShow.
  ///
  /// In en, this message translates to:
  /// **'No suppliers to display'**
  String get noSuppliersToShow;

  /// No description provided for @suppliersTitle.
  ///
  /// In en, this message translates to:
  /// **'Suppliers'**
  String get suppliersTitle;

  /// No description provided for @filterSuppliersTooltip.
  ///
  /// In en, this message translates to:
  /// **'Filter suppliers'**
  String get filterSuppliersTooltip;

  /// No description provided for @addSupplierTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add a new supplier'**
  String get addSupplierTooltip;

  /// No description provided for @noSuppliersAvailable.
  ///
  /// In en, this message translates to:
  /// **'No suppliers available'**
  String get noSuppliersAvailable;

  /// No description provided for @topSuppliersByPurchases.
  ///
  /// In en, this message translates to:
  /// **'Top suppliers by purchases'**
  String get topSuppliersByPurchases;

  /// No description provided for @recentlyAddedSuppliers.
  ///
  /// In en, this message translates to:
  /// **'Recently added suppliers'**
  String get recentlyAddedSuppliers;

  /// No description provided for @contactPerson.
  ///
  /// In en, this message translates to:
  /// **'Contact: {name}'**
  String contactPerson(String name);

  /// No description provided for @moreOptionsTooltip.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get moreOptionsTooltip;

  /// No description provided for @allSuppliers.
  ///
  /// In en, this message translates to:
  /// **'All suppliers'**
  String get allSuppliers;

  /// No description provided for @topSuppliers.
  ///
  /// In en, this message translates to:
  /// **'Top suppliers'**
  String get topSuppliers;

  /// No description provided for @recentSuppliers.
  ///
  /// In en, this message translates to:
  /// **'Recent suppliers'**
  String get recentSuppliers;

  /// No description provided for @deleteSupplierTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete supplier'**
  String get deleteSupplierTitle;

  /// No description provided for @deleteSupplierConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {supplierName}? This action is irreversible.'**
  String deleteSupplierConfirmation(String supplierName);

  /// No description provided for @supplierCategoryStrategic.
  ///
  /// In en, this message translates to:
  /// **'Strategic'**
  String get supplierCategoryStrategic;

  /// No description provided for @supplierCategoryRegular.
  ///
  /// In en, this message translates to:
  /// **'Regular'**
  String get supplierCategoryRegular;

  /// No description provided for @supplierCategoryNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get supplierCategoryNew;

  /// No description provided for @supplierCategoryOccasional.
  ///
  /// In en, this message translates to:
  /// **'Occasional'**
  String get supplierCategoryOccasional;

  /// No description provided for @supplierCategoryInternational.
  ///
  /// In en, this message translates to:
  /// **'International'**
  String get supplierCategoryInternational;

  /// No description provided for @supplierCategoryUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get supplierCategoryUnknown;

  /// No description provided for @addSupplierTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Supplier'**
  String get addSupplierTitle;

  /// No description provided for @editSupplierTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Supplier'**
  String get editSupplierTitle;

  /// No description provided for @supplierInformation.
  ///
  /// In en, this message translates to:
  /// **'Supplier Information'**
  String get supplierInformation;

  /// No description provided for @supplierNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Supplier Name *'**
  String get supplierNameLabel;

  /// No description provided for @supplierNameValidationError.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get supplierNameValidationError;

  /// No description provided for @supplierPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number *'**
  String get supplierPhoneLabel;

  /// No description provided for @supplierPhoneValidationError.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get supplierPhoneValidationError;

  /// No description provided for @supplierPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'+243 999 123 456'**
  String get supplierPhoneHint;

  /// No description provided for @supplierEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get supplierEmailLabel;

  /// No description provided for @supplierEmailValidationError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get supplierEmailValidationError;

  /// No description provided for @supplierContactPersonLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact Person'**
  String get supplierContactPersonLabel;

  /// No description provided for @supplierAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get supplierAddressLabel;

  /// No description provided for @commercialInformation.
  ///
  /// In en, this message translates to:
  /// **'Commercial Information'**
  String get commercialInformation;

  /// No description provided for @deliveryTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivery Time'**
  String get deliveryTimeLabel;

  /// No description provided for @paymentTermsLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment Terms'**
  String get paymentTermsLabel;

  /// No description provided for @paymentTermsHint.
  ///
  /// In en, this message translates to:
  /// **'Ex: Net 30, 50% upfront, etc.'**
  String get paymentTermsHint;

  /// No description provided for @supplierCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Supplier Category'**
  String get supplierCategoryLabel;

  /// No description provided for @supplierNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get supplierNotesLabel;

  /// No description provided for @updateSupplierButton.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateSupplierButton;

  /// No description provided for @addSupplierButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addSupplierButton;

  /// No description provided for @supplierDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Supplier Details'**
  String get supplierDetailsTitle;

  /// No description provided for @supplierErrorLoading.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String supplierErrorLoading(String message);

  /// No description provided for @supplierNotFound.
  ///
  /// In en, this message translates to:
  /// **'Supplier not found'**
  String get supplierNotFound;

  /// No description provided for @contactLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contactLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressLabel;

  /// No description provided for @commercialInformationSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Commercial Information'**
  String get commercialInformationSectionTitle;

  /// No description provided for @deliveryTimeInDays.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =0{Not specified} =1{1 day} other{{count} days}}'**
  String deliveryTimeInDays(int count);

  /// No description provided for @supplierSinceLabel.
  ///
  /// In en, this message translates to:
  /// **'Supplier Since'**
  String get supplierSinceLabel;

  /// No description provided for @notesSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesSectionTitle;

  /// No description provided for @placeOrderButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Place Order'**
  String get placeOrderButtonLabel;

  /// No description provided for @featureToImplement.
  ///
  /// In en, this message translates to:
  /// **'Feature to implement'**
  String get featureToImplement;

  /// No description provided for @confirmDeleteSupplierTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Supplier'**
  String get confirmDeleteSupplierTitle;

  /// No description provided for @confirmDeleteSupplierMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {supplierName}? This action is irreversible.'**
  String confirmDeleteSupplierMessage(String supplierName);

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get commonError;

  /// No description provided for @commonToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get commonToday;

  /// No description provided for @commonThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get commonThisMonth;

  /// No description provided for @commonThisYear.
  ///
  /// In en, this message translates to:
  /// **'This Year'**
  String get commonThisYear;

  /// No description provided for @commonCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get commonCustom;

  /// No description provided for @commonAnonymousClient.
  ///
  /// In en, this message translates to:
  /// **'Anonymous Client'**
  String get commonAnonymousClient;

  /// No description provided for @commonAnonymousClientInitial.
  ///
  /// In en, this message translates to:
  /// **'A'**
  String get commonAnonymousClientInitial;

  /// No description provided for @commonErrorDataUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Data unavailable'**
  String get commonErrorDataUnavailable;

  /// No description provided for @commonNoData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get commonNoData;

  /// No description provided for @dashboardScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardScreenTitle;

  /// No description provided for @dashboardHeaderSalesToday.
  ///
  /// In en, this message translates to:
  /// **'Sales Today'**
  String get dashboardHeaderSalesToday;

  /// No description provided for @dashboardHeaderClientsServed.
  ///
  /// In en, this message translates to:
  /// **'Clients Served'**
  String get dashboardHeaderClientsServed;

  /// No description provided for @dashboardHeaderReceivables.
  ///
  /// In en, this message translates to:
  /// **'Receivables'**
  String get dashboardHeaderReceivables;

  /// No description provided for @dashboardHeaderTransactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get dashboardHeaderTransactions;

  /// No description provided for @dashboardCardViewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get dashboardCardViewDetails;

  /// No description provided for @dashboardSalesChartTitle.
  ///
  /// In en, this message translates to:
  /// **'Sales Overview'**
  String get dashboardSalesChartTitle;

  /// No description provided for @dashboardSalesChartNoData.
  ///
  /// In en, this message translates to:
  /// **'No sales data to display for the chart.'**
  String get dashboardSalesChartNoData;

  /// No description provided for @dashboardRecentSalesTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent Sales'**
  String get dashboardRecentSalesTitle;

  /// No description provided for @dashboardRecentSalesViewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get dashboardRecentSalesViewAll;

  /// No description provided for @dashboardRecentSalesNoData.
  ///
  /// In en, this message translates to:
  /// **'No recent sales.'**
  String get dashboardRecentSalesNoData;

  /// No description provided for @dashboardOperationsJournalTitle.
  ///
  /// In en, this message translates to:
  /// **'Operations Journal'**
  String get dashboardOperationsJournalTitle;

  /// No description provided for @dashboardOperationsJournalViewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get dashboardOperationsJournalViewAll;

  /// No description provided for @dashboardOperationsJournalNoData.
  ///
  /// In en, this message translates to:
  /// **'No recent operations.'**
  String get dashboardOperationsJournalNoData;

  /// No description provided for @dashboardOperationsJournalBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get dashboardOperationsJournalBalanceLabel;

  /// No description provided for @dashboardJournalExportSelectDateRangeTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Date Range'**
  String get dashboardJournalExportSelectDateRangeTitle;

  /// No description provided for @dashboardJournalExportExportButton.
  ///
  /// In en, this message translates to:
  /// **'Export to PDF'**
  String get dashboardJournalExportExportButton;

  /// No description provided for @dashboardJournalExportPrintButton.
  ///
  /// In en, this message translates to:
  /// **'Print Journal'**
  String get dashboardJournalExportPrintButton;

  /// No description provided for @dashboardJournalExportSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Journal exported successfully.'**
  String get dashboardJournalExportSuccessMessage;

  /// No description provided for @dashboardJournalExportFailureMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to export journal.'**
  String get dashboardJournalExportFailureMessage;

  /// No description provided for @dashboardJournalExportNoDataForPeriod.
  ///
  /// In en, this message translates to:
  /// **'No data available for the selected period to export.'**
  String get dashboardJournalExportNoDataForPeriod;

  /// No description provided for @dashboardJournalExportPrintingMessage.
  ///
  /// In en, this message translates to:
  /// **'Preparing journal for printing...'**
  String get dashboardJournalExportPrintingMessage;

  /// No description provided for @dashboardQuickActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get dashboardQuickActionsTitle;

  /// No description provided for @dashboardQuickActionsNewSale.
  ///
  /// In en, this message translates to:
  /// **'New Sale'**
  String get dashboardQuickActionsNewSale;

  /// No description provided for @dashboardQuickActionsNewExpense.
  ///
  /// In en, this message translates to:
  /// **'New Expense'**
  String get dashboardQuickActionsNewExpense;

  /// No description provided for @dashboardQuickActionsNewProduct.
  ///
  /// In en, this message translates to:
  /// **'New Product'**
  String get dashboardQuickActionsNewProduct;

  /// No description provided for @dashboardQuickActionsNewService.
  ///
  /// In en, this message translates to:
  /// **'New Service'**
  String get dashboardQuickActionsNewService;

  /// No description provided for @dashboardQuickActionsNewClient.
  ///
  /// In en, this message translates to:
  /// **'New Client'**
  String get dashboardQuickActionsNewClient;

  /// No description provided for @dashboardQuickActionsNewSupplier.
  ///
  /// In en, this message translates to:
  /// **'New Supplier'**
  String get dashboardQuickActionsNewSupplier;

  /// No description provided for @dashboardQuickActionsCashRegister.
  ///
  /// In en, this message translates to:
  /// **'Cash Register'**
  String get dashboardQuickActionsCashRegister;

  /// No description provided for @dashboardQuickActionsSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get dashboardQuickActionsSettings;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get commonLoading;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @journalPdf_title.
  ///
  /// In en, this message translates to:
  /// **'Operations Journal'**
  String get journalPdf_title;

  /// Footer for PDF, shows current and total pages
  ///
  /// In en, this message translates to:
  /// **'Page {currentPage} of {totalPages}'**
  String journalPdf_footer_pageInfo(int currentPage, int totalPages);

  /// Indicates the period covered by the journal
  ///
  /// In en, this message translates to:
  /// **'Period: {startDate} - {endDate}'**
  String journalPdf_period(String startDate, String endDate);

  /// No description provided for @journalPdf_tableHeader_date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get journalPdf_tableHeader_date;

  /// No description provided for @journalPdf_tableHeader_time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get journalPdf_tableHeader_time;

  /// No description provided for @journalPdf_tableHeader_description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get journalPdf_tableHeader_description;

  /// No description provided for @journalPdf_tableHeader_debit.
  ///
  /// In en, this message translates to:
  /// **'Debit'**
  String get journalPdf_tableHeader_debit;

  /// No description provided for @journalPdf_tableHeader_credit.
  ///
  /// In en, this message translates to:
  /// **'Credit'**
  String get journalPdf_tableHeader_credit;

  /// No description provided for @journalPdf_tableHeader_balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get journalPdf_tableHeader_balance;

  /// No description provided for @journalPdf_openingBalance.
  ///
  /// In en, this message translates to:
  /// **'Opening Balance'**
  String get journalPdf_openingBalance;

  /// No description provided for @journalPdf_closingBalance.
  ///
  /// In en, this message translates to:
  /// **'Closing Balance'**
  String get journalPdf_closingBalance;

  /// No description provided for @journalPdf_footer_generatedBy.
  ///
  /// In en, this message translates to:
  /// **'Generated by Wanzo'**
  String get journalPdf_footer_generatedBy;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
