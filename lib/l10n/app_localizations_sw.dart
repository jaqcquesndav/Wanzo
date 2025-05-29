// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swahili (`sw`).
class AppLocalizationsSw extends AppLocalizations {
  AppLocalizationsSw([String locale = 'sw']) : super(locale);

  @override
  String get invoiceSettingsTitle => 'Mipangilio ya Ankara';

  @override
  String get currencySettings => 'Mipangilio ya Sarafu';

  @override
  String get activeCurrency => 'Sarafu Inayotumika';

  @override
  String exchangeRateSpecific(String currencyFrom, String currencyTo) {
    return 'Kiwango cha ubadilishaji ($currencyFrom hadi $currencyTo)';
  }

  @override
  String exchangeRateHint(String currencyFrom, String currencyTo) {
    return 'Weka kiwango cha 1 $currencyFrom hadi $currencyTo';
  }

  @override
  String get errorFieldRequired => 'Sehemu hii inahitajika.';

  @override
  String get errorInvalidRate => 'Tafadhali weka kiwango sahihi chanya.';

  @override
  String get invoiceFormatting => 'Muundo wa Ankara';

  @override
  String invoiceFormatHint(Object YEAR, Object MONTH, Object SEQ) {
    return 'Tumia $YEAR, $MONTH, $SEQ kwa thamani zinazobadilika.';
  }

  @override
  String get invoiceNumberFormat => 'Umbizo la Nambari ya Ankara';

  @override
  String get invoicePrefix => 'Kiambishi awali cha Ankara';

  @override
  String get taxesAndConditions => 'Kodi na Masharti';

  @override
  String get showTaxesOnInvoices => 'Onyesha kodi kwenye ankara';

  @override
  String get defaultTaxRatePercentage => 'Kiwango cha Kodi Chaguomsingi (%)';

  @override
  String get errorInvalidTaxRate => 'Kiwango cha kodi lazima kiwe kati ya 0 na 100.';

  @override
  String get defaultPaymentTerms => 'Masharti Chaguomsingi ya Malipo';

  @override
  String get defaultInvoiceNotes => 'Maelezo Chaguomsingi ya Ankara';

  @override
  String get settingsSavedSuccess => 'Mipangilio imehifadhiwa kikamilifu.';

  @override
  String get anErrorOccurred => 'Hitilafu imetokea.';

  @override
  String get errorUnknown => 'Hitilafu isiyojulikana';

  @override
  String currencySettingsError(String errorDetails) {
    return 'Haikuweza kuhifadhi mipangilio ya sarafu: $errorDetails';
  }

  @override
  String get currencySettingsSavedSuccess => 'Mipangilio ya sarafu imehifadhiwa kikamilifu.';

  @override
  String get currencyCDF => 'Faranga ya Kongo';

  @override
  String get currencyUSD => 'Dola ya Marekani';

  @override
  String get currencyFCFA => 'Faranga ya CFA';

  @override
  String get editProductTitle => 'Hariri Bidhaa';

  @override
  String get addProductTitle => 'Ongeza Bidhaa';

  @override
  String get productCategoryFood => 'Chakula';

  @override
  String get productCategoryDrink => 'Kinywaji';

  @override
  String get productCategoryOther => 'Nyingine';

  @override
  String get units => 'Vipimo';

  @override
  String get notes => 'Maelezo (Si lazima)';

  @override
  String get saveProduct => 'Hifadhi Bidhaa';

  @override
  String get inventoryValue => 'Thamani ya Mali';

  @override
  String get products => 'Bidhaa';

  @override
  String get stockMovements => 'Mienendo ya Hisa';

  @override
  String get noProducts => 'Hakuna bidhaa bado.';

  @override
  String get noStockMovements => 'Hakuna mienendo ya hisa bado.';

  @override
  String get searchProducts => 'Tafuta bidhaa...';

  @override
  String get totalStock => 'Jumla ya Hisa';

  @override
  String get valueInCdf => 'Thamani (CDF)';

  @override
  String valueIn(String currencyCode) {
    return 'Thamani ($currencyCode)';
  }

  @override
  String get lastModified => 'Imebadilishwa Mwisho';

  @override
  String get productDetails => 'Maelezo ya Bidhaa';

  @override
  String get deleteProduct => 'Futa Bidhaa';

  @override
  String get confirmDeleteProductTitle => 'Thibitisha Kufuta';

  @override
  String get confirmDeleteProductMessage => 'Una uhakika unataka kufuta bidhaa hii? Kitendo hiki hakiwezi kutenduliwa.';

  @override
  String get commonCancel => 'Ghairi';

  @override
  String get delete => 'Futa';

  @override
  String get stockIn => 'Uingizaji Hisa';

  @override
  String get stockOut => 'Utoaji Hisa';

  @override
  String get adjustment => 'Marekebisho';

  @override
  String get quantity => 'Kiasi';

  @override
  String get reason => 'Sababu (Si lazima)';

  @override
  String get addStockMovement => 'Ongeza Mwenendo wa Hisa';

  @override
  String get newStock => 'Hisa Mpya';

  @override
  String get value => 'Thamani';

  @override
  String get type => 'Aina';

  @override
  String get date => 'Tarehe';

  @override
  String get product => 'Bidhaa';

  @override
  String get selectProduct => 'Chagua Bidhaa';

  @override
  String get selectCategory => 'Chagua Kategoria';

  @override
  String get selectUnit => 'Chagua Kipimo';

  @override
  String imagePickingErrorMessage(String errorDetails) {
    return 'Hitilafu wakati wa kuchagua picha: $errorDetails';
  }

  @override
  String get galleryAction => 'Matunzio';

  @override
  String get cameraAction => 'Kamera';

  @override
  String get removeImageAction => 'Ondoa Picha';

  @override
  String get productImageSectionTitle => 'Picha ya Bidhaa';

  @override
  String get addImageLabel => 'Ongeza Picha';

  @override
  String get generalInformationSectionTitle => 'Taarifa za Jumla';

  @override
  String get productNameLabel => 'Jina la Bidhaa';

  @override
  String get productNameValidationError => 'Tafadhali ingiza jina la bidhaa.';

  @override
  String get productDescriptionLabel => 'Maelezo';

  @override
  String get productBarcodeLabel => 'Msimbo Pau (Si lazima)';

  @override
  String get featureComingSoonMessage => 'Kipengele kinakuja hivi karibuni!';

  @override
  String get productCategoryLabel => 'Kategoria';

  @override
  String get productCategoryElectronics => 'Elektroniki';

  @override
  String get productCategoryClothing => 'Nguo';

  @override
  String get productCategoryHousehold => 'Vifaa vya Nyumbani';

  @override
  String get productCategoryHygiene => 'Usafi';

  @override
  String get productCategoryOffice => 'Vifaa vya Ofisi';

  @override
  String get pricingSectionTitle => 'Bei na Sarafu';

  @override
  String get inputCurrencyLabel => 'Sarafu ya Kuingiza';

  @override
  String get inputCurrencyValidationError => 'Tafadhali chagua sarafu ya kuingiza.';

  @override
  String get costPriceLabel => 'Bei ya Gharama';

  @override
  String get costPriceValidationError => 'Tafadhali ingiza bei ya gharama.';

  @override
  String get negativePriceValidationError => 'Bei haiwezi kuwa hasi.';

  @override
  String get invalidNumberValidationError => 'Tafadhali ingiza nambari sahihi.';

  @override
  String get sellingPriceLabel => 'Bei ya Kuuza';

  @override
  String get sellingPriceValidationError => 'Tafadhali ingiza bei ya kuuza.';

  @override
  String get stockManagementSectionTitle => 'Usimamizi wa Hisa';

  @override
  String get stockQuantityLabel => 'Kiasi katika Hisa';

  @override
  String get stockQuantityValidationError => 'Tafadhali ingiza kiasi cha hisa.';

  @override
  String get negativeQuantityValidationError => 'Kiasi hakiwezi kuwa hasi.';

  @override
  String get productUnitLabel => 'Kipimo';

  @override
  String get productUnitPiece => 'Kipande(Vipande)';

  @override
  String get productUnitKg => 'Kilogramu (kg)';

  @override
  String get productUnitG => 'Gramu (g)';

  @override
  String get productUnitL => 'Lita (L)';

  @override
  String get productUnitMl => 'Mililita (ml)';

  @override
  String get productUnitPackage => 'Kifurushi(Vifurushi)';

  @override
  String get productUnitBox => 'Sanduku(Masanduku)';

  @override
  String get productUnitOther => 'Kipimo Kingine';

  @override
  String get lowStockThresholdLabel => 'Kiwango cha Tahadhari ya Hisa Chini';

  @override
  String get lowStockThresholdHelper => 'Pokea tahadhari hisa inapofikia kiwango hiki.';

  @override
  String get lowStockThresholdValidationError => 'Tafadhali ingiza kiwango sahihi cha tahadhari.';

  @override
  String get negativeThresholdValidationError => 'Kiwango hakiwezi kuwa hasi.';

  @override
  String get saveChangesButton => 'Hifadhi Mabadiliko';

  @override
  String get addProductButton => 'Ongeza Bidhaa';

  @override
  String get notesLabelOptional => 'Maelezo (Si lazima)';

  @override
  String addStockDialogTitle(String productName) {
    return 'Ongeza Hisa kwa $productName';
  }

  @override
  String get currentStockLabel => 'Hisa ya Sasa';

  @override
  String get quantityToAddLabel => 'Kiasi cha Kuongeza';

  @override
  String get quantityValidationError => 'Tafadhali ingiza kiasi.';

  @override
  String get positiveQuantityValidationError => 'Kiasi lazima kiwe chanya kwa ununuzi.';

  @override
  String get addButtonLabel => 'Ongeza';

  @override
  String get stockAdjustmentDefaultNote => 'Marekebisho ya hisa';

  @override
  String get stockTransactionTypeOther => 'Nyingine';

  @override
  String get productInitialFallback => 'B';

  @override
  String get inventoryScreenTitle => 'Mali';

  @override
  String get allProductsTabLabel => 'Bidhaa Zote';

  @override
  String get lowStockTabLabel => 'Hisa Chini';

  @override
  String get transactionsTabLabel => 'Miamala';

  @override
  String get noProductsAvailableMessage => 'Hakuna bidhaa zinazopatikana.';

  @override
  String get noLowStockProductsMessage => 'Hakuna bidhaa zenye hisa chini.';

  @override
  String get noTransactionsAvailableMessage => 'Hakuna miamala inayopatikana.';

  @override
  String get searchProductDialogTitle => 'Tafuta Bidhaa';

  @override
  String get searchProductHintText => 'Ingiza jina la bidhaa au msimbo pau...';

  @override
  String get cancelButtonLabel => 'Ghairi';

  @override
  String get searchButtonLabel => 'Tafuta';

  @override
  String get filterByCategoryDialogTitle => 'Chuja kwa Kategoria';

  @override
  String get noCategoriesAvailableMessage => 'Hakuna kategoria zinazopatikana za kuchuja.';

  @override
  String get showAllButtonLabel => 'Onyesha Zote';

  @override
  String get noProductsInInventoryMessage => 'Bado hujaongeza bidhaa zozote kwenye mali yako.';

  @override
  String get priceLabel => 'Bei';

  @override
  String get inputPriceLabel => 'Bei ya Kuingiza';

  @override
  String get stockLabel => 'Hisa';

  @override
  String get unknownProductLabel => 'Bidhaa Isiyojulikana';

  @override
  String get quantityLabel => 'Kiasi';

  @override
  String get dateLabel => 'Tarehe';

  @override
  String get valueLabel => 'Thamani';

  @override
  String get retryButtonLabel => 'Jaribu Tena';

  @override
  String get stockTransactionTypePurchase => 'Ununuzi';

  @override
  String get stockTransactionTypeSale => 'Uuzaji';

  @override
  String get stockTransactionTypeAdjustment => 'Marekebisho';

  @override
  String get salesScreenTitle => 'Usimamizi wa Mauzo';

  @override
  String get salesTabAll => 'Zote';

  @override
  String get salesTabPending => 'Inasubiri';

  @override
  String get salesTabCompleted => 'Imekamilika';

  @override
  String get salesFilterDialogTitle => 'Chuja Mauzo';

  @override
  String get salesFilterDialogCancel => 'Ghairi';

  @override
  String get salesFilterDialogApply => 'Tumia';

  @override
  String get salesSummaryTotal => 'Jumla ya Mauzo';

  @override
  String get salesSummaryCount => 'Idadi ya Mauzo';

  @override
  String get salesStatusPending => 'Inasubiri';

  @override
  String get salesStatusCompleted => 'Imekamilika';

  @override
  String get salesStatusPartiallyPaid => 'Imelipwa Kiasi';

  @override
  String get salesStatusCancelled => 'Imeghairiwa';

  @override
  String get salesNoSalesFound => 'Hakuna mauzo yaliyopatikana';

  @override
  String get salesAddSaleButton => 'Ongeza Mauzo';

  @override
  String get salesErrorPrefix => 'Hitilafu';

  @override
  String get salesRetryButton => 'Jaribu Tena';

  @override
  String get salesFilterDialogStartDate => 'Tarehe ya Kuanza';

  @override
  String get salesFilterDialogEndDate => 'Tarehe ya Mwisho';

  @override
  String get salesListItemSaleIdPrefix => 'Mauzo #';

  @override
  String salesListItemArticles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bidhaa',
      one: 'bidhaa 1',
    );
    return '$_temp0';
  }

  @override
  String get salesListItemTotal => 'Jumla:';

  @override
  String get salesListItemRemainingToPay => 'Kiasi Kilichobaki Kulipa:';

  @override
  String get subscriptionScreenTitle => 'Usimamizi wa Usajili';

  @override
  String get subscriptionUnsupportedFileType => 'Aina ya faili haitumiki. Tafadhali chagua faili ya JPG au PNG.';

  @override
  String get subscriptionFileTooLarge => 'Faili ni kubwa mno. Ukubwa wa juu ni 5MB.';

  @override
  String get subscriptionNoImageSelected => 'Hakuna picha iliyochaguliwa.';

  @override
  String get subscriptionUpdateSuccessMessage => 'Usajili umesasishwa kikamilifu.';

  @override
  String subscriptionUpdateFailureMessage(String error) {
    return 'Imeshindwa kusasisha usajili: $error';
  }

  @override
  String get subscriptionTokenTopUpSuccessMessage => 'Tokeni zimeongezwa kikamilifu.';

  @override
  String subscriptionTokenTopUpFailureMessage(String error) {
    return 'Imeshindwa kuongeza tokeni: $error';
  }

  @override
  String get subscriptionPaymentProofUploadSuccessMessage => 'Uthibitisho wa malipo umepakiwa kikamilifu.';

  @override
  String subscriptionPaymentProofUploadFailureMessage(String error) {
    return 'Imeshindwa kupakia uthibitisho wa malipo: $error';
  }

  @override
  String get subscriptionRetryButton => 'Jaribu Tena';

  @override
  String get subscriptionUnhandledState => 'Hali isiyoshughulikiwa au uanzishaji...';

  @override
  String get subscriptionSectionOurOffers => 'Matoleo Yetu ya Usajili';

  @override
  String get subscriptionSectionCurrentSubscription => 'Usajili Wako wa Sasa';

  @override
  String get subscriptionSectionTokenUsage => 'Matumizi ya Tokeni za Adha';

  @override
  String get subscriptionSectionInvoiceHistory => 'Historia ya Ankara';

  @override
  String get subscriptionSectionPaymentMethods => 'Njia za Malipo';

  @override
  String get subscriptionChangeSubscriptionButton => 'Badilisha Usajili';

  @override
  String get subscriptionTierFree => 'Bure';

  @override
  String subscriptionTierUsers(int count) {
    return 'Watumiaji: $count';
  }

  @override
  String subscriptionTierAdhaTokens(int count) {
    return 'Tokeni za Adha: $count';
  }

  @override
  String get subscriptionTierFeatures => 'Vipengele:';

  @override
  String get subscriptionTierCurrentPlanChip => 'Mpango wa Sasa';

  @override
  String get subscriptionTierChoosePlanButton => 'Chagua mpango huu';

  @override
  String subscriptionCurrentPlanTitle(String tierName) {
    return 'Mpango wa Sasa: $tierName';
  }

  @override
  String subscriptionCurrentPlanPrice(String price) {
    return 'Bei: $price';
  }

  @override
  String subscriptionAvailableAdhaTokens(int count) {
    return 'Tokeni za Adha Zinazopatikana: $count';
  }

  @override
  String get subscriptionTopUpTokensButton => 'Ongeza Tokeni';

  @override
  String get subscriptionNoInvoices => 'Hakuna ankara zinazopatikana kwa sasa.';

  @override
  String subscriptionInvoiceListTitle(String id, String date) {
    return 'Ankara $id - $date';
  }

  @override
  String subscriptionInvoiceListSubtitle(String amount, String status) {
    return 'Kiasi: $amount - Hali: $status';
  }

  @override
  String get subscriptionDownloadInvoiceTooltip => 'Pakua ankara';

  @override
  String subscriptionSimulateDownloadInvoice(String id, String url) {
    return 'Uigaji: Inapakua $id kutoka $url';
  }

  @override
  String subscriptionSimulateViewInvoiceDetails(String id) {
    return 'Uigaji: Tazama maelezo ya ankara $id';
  }

  @override
  String get subscriptionPaymentMethodsNextInvoice => 'Njia za malipo kwa ankara inayofuata:';

  @override
  String get subscriptionPaymentMethodsRegistered => 'Njia zilizosajiliwa:';

  @override
  String get subscriptionPaymentMethodsOtherOptions => 'Chaguo zingine za malipo:';

  @override
  String get subscriptionPaymentMethodNewCard => 'Kadi Mpya ya Mkopo';

  @override
  String get subscriptionPaymentMethodNewMobileMoney => 'Pesa Mpya ya Simu';

  @override
  String get subscriptionPaymentMethodManual => 'Malipo ya Mwongozo (Uhamisho/Amana)';

  @override
  String get subscriptionManualPaymentInstructions => 'Tafadhali fanya uhamisho/amana kwa maelezo yaliyotolewa na upakie uthibitisho wa malipo.';

  @override
  String subscriptionProofUploadedLabel(String fileName) {
    return 'Uthibitisho Umepakiwa: $fileName';
  }

  @override
  String get subscriptionUploadProofButton => 'Pakia Uthibitisho';

  @override
  String get subscriptionReplaceProofButton => 'Badilisha Uthibitisho';

  @override
  String get subscriptionConfirmPaymentMethodButton => 'Thibitisha Njia ya Malipo';

  @override
  String subscriptionSimulatePaymentMethodSelected(String method) {
    return 'Njia ya malipo iliyochaguliwa: $method (Uigaji)';
  }

  @override
  String get subscriptionChangeDialogTitle => 'Badilisha Usajili';

  @override
  String subscriptionChangeDialogTierSubtitle(String price, String tokens) {
    return '$price - Tokeni: $tokens';
  }

  @override
  String get subscriptionTopUpDialogTitle => 'Ongeza Tokeni za Adha';

  @override
  String subscriptionTopUpDialogAmount(String amount, String currencyCode) {
    return '$amount $currencyCode';
  }

  @override
  String get subscriptionNoActivePlan => 'Huna mpango wa usajili unaotumika.';

  @override
  String get contactsScreenTitle => 'Anwani';

  @override
  String get contactsScreenClientsTab => 'Wateja';

  @override
  String get contactsScreenSuppliersTab => 'Wauzaji';

  @override
  String get contactsScreenAddClientTooltip => 'Ongeza mteja';

  @override
  String get contactsScreenAddSupplierTooltip => 'Ongeza muuzaji';

  @override
  String get searchCustomerHint => 'Tafuta mteja...';

  @override
  String customerError(String message) {
    return 'Hitilafu: $message';
  }

  @override
  String get noCustomersToShow => 'Hakuna wateja wa kuonyesha';

  @override
  String get customersTitle => 'Wateja';

  @override
  String get filterCustomersTooltip => 'Chuja wateja';

  @override
  String get addCustomerTooltip => 'Ongeza mteja mpya';

  @override
  String noResultsForSearchTerm(String searchTerm) {
    return 'Hakuna matokeo ya $searchTerm';
  }

  @override
  String get noCustomersAvailable => 'Hakuna wateja wanaopatikana';

  @override
  String get topCustomersByPurchases => 'Wateja wakuu kwa ununuzi';

  @override
  String get recentlyAddedCustomers => 'Wateja walioongezwa hivi karibuni';

  @override
  String resultsForSearchTerm(String searchTerm) {
    return 'Matokeo ya $searchTerm';
  }

  @override
  String lastPurchaseDate(String date) {
    return 'Ununuzi wa mwisho: $date';
  }

  @override
  String get noRecentPurchase => 'Hakuna ununuzi wa hivi karibuni';

  @override
  String totalPurchasesAmount(String amount) {
    return 'Jumla ya ununuzi: $amount';
  }

  @override
  String get viewDetails => 'Tazama maelezo';

  @override
  String get edit => 'Hariri';

  @override
  String get allCustomers => 'Wateja wote';

  @override
  String get topCustomers => 'Wateja wakuu';

  @override
  String get recentCustomers => 'Wateja wa hivi karibuni';

  @override
  String get byCategory => 'Kwa Kategoria';

  @override
  String get filterByCategory => 'Chuja kwa kategoria';

  @override
  String get deleteCustomerTitle => 'Futa mteja';

  @override
  String deleteCustomerConfirmation(String customerName) {
    return 'Una uhakika unataka kumfuta $customerName? Kitendo hiki hakiwezi kutenduliwa.';
  }

  @override
  String get customerCategoryVip => 'VIP';

  @override
  String get customerCategoryRegular => 'Kawaida';

  @override
  String get customerCategoryNew => 'Mpya';

  @override
  String get customerCategoryOccasional => 'Wa Mara kwa Mara';

  @override
  String get customerCategoryBusiness => 'Biashara';

  @override
  String get customerCategoryUnknown => 'Haijulikani';

  @override
  String get editCustomerTitle => 'Hariri Mteja';

  @override
  String get addCustomerTitle => 'Ongeza Mteja';

  @override
  String get customerPhoneHint => '+243 999 123 456';

  @override
  String get customerInformation => 'Taarifa za Mteja';

  @override
  String get customerNameLabel => 'Jina la Mteja';

  @override
  String get customerNameValidationError => 'Tafadhali ingiza jina la mteja.';

  @override
  String get customerPhoneLabel => 'Simu ya Mteja';

  @override
  String get customerPhoneValidationError => 'Tafadhali ingiza nambari ya simu ya mteja.';

  @override
  String get customerEmailLabel => 'Barua Pepe ya Mteja (Si lazima)';

  @override
  String get customerEmailLabelOptional => 'Barua Pepe ya Mteja';

  @override
  String get customerEmailValidationError => 'Tafadhali ingiza anwani sahihi ya barua pepe.';

  @override
  String get customerAddressLabel => 'Anwani ya Mteja (Si lazima)';

  @override
  String get customerAddressLabelOptional => 'Anwani ya Mteja';

  @override
  String get customerCategoryLabel => 'Kategoria ya Mteja';

  @override
  String get customerNotesLabel => 'Maelezo (Si lazima)';

  @override
  String get updateButtonLabel => 'Sasisha';

  @override
  String get customerDetailsTitle => 'Maelezo ya Mteja';

  @override
  String get editCustomerTooltip => 'Hariri mteja';

  @override
  String get customerNotFound => 'Mteja hajapatikana';

  @override
  String get contactInformationSectionTitle => 'Taarifa za Mawasiliano';

  @override
  String get purchaseStatisticsSectionTitle => 'Takwimu za Ununuzi';

  @override
  String get totalPurchasesLabel => 'Jumla ya Ununuzi';

  @override
  String get lastPurchaseLabel => 'Ununuzi wa Mwisho';

  @override
  String get noPurchaseRecorded => 'Hakuna ununuzi uliorekodiwa';

  @override
  String get customerSinceLabel => 'Mteja Tangu';

  @override
  String get addSaleButtonLabel => 'Ongeza Mauzo';

  @override
  String get callButtonLabel => 'Piga Simu';

  @override
  String get deleteButtonLabel => 'Futa';

  @override
  String callingNumber(String phoneNumber) {
    return 'Inapiga $phoneNumber...';
  }

  @override
  String emailingTo(String email) {
    return 'Inatuma barua pepe kwa $email...';
  }

  @override
  String openingMapFor(String address) {
    return 'Inafungua ramani ya $address...';
  }

  @override
  String get searchSupplierHint => 'Tafuta muuzaji...';

  @override
  String get clearSearchTooltip => 'Futa utafutaji';

  @override
  String supplierError(String message) {
    return 'Hitilafu: $message';
  }

  @override
  String get noSuppliersToShow => 'Hakuna wauzaji wa kuonyesha';

  @override
  String get suppliersTitle => 'Wauzaji';

  @override
  String get filterSuppliersTooltip => 'Chuja wauzaji';

  @override
  String get addSupplierTooltip => 'Ongeza muuzaji mpya';

  @override
  String get noSuppliersAvailable => 'Hakuna wauzaji wanaopatikana';

  @override
  String get topSuppliersByPurchases => 'Wauzaji wakuu kwa ununuzi';

  @override
  String get recentlyAddedSuppliers => 'Wauzaji walioongezwa hivi karibuni';

  @override
  String contactPerson(String name) {
    return 'Mawasiliano: $name';
  }

  @override
  String get moreOptionsTooltip => 'Chaguo zaidi';

  @override
  String get allSuppliers => 'Wauzaji wote';

  @override
  String get topSuppliers => 'Wauzaji wakuu';

  @override
  String get recentSuppliers => 'Wauzaji wa hivi karibuni';

  @override
  String get deleteSupplierTitle => 'Futa muuzaji';

  @override
  String deleteSupplierConfirmation(String supplierName) {
    return 'Una uhakika unataka kumfuta $supplierName? Kitendo hiki hakiwezi kutenduliwa.';
  }

  @override
  String get supplierCategoryStrategic => 'Kimkakati';

  @override
  String get supplierCategoryRegular => 'Kawaida';

  @override
  String get supplierCategoryNew => 'Mpya';

  @override
  String get supplierCategoryOccasional => 'Wa Mara kwa Mara';

  @override
  String get supplierCategoryInternational => 'Kimataifa';

  @override
  String get supplierCategoryUnknown => 'Haijulikani';

  @override
  String get supplierCategoryLocal => 'Wa Ndani';

  @override
  String get supplierCategoryOnline => 'Mtandaoni';

  @override
  String get addSupplierTitle => 'Ongeza Muuzaji';

  @override
  String get editSupplierTitle => 'Hariri Muuzaji';

  @override
  String get supplierInformation => 'Taarifa za Muuzaji';

  @override
  String get supplierNameLabel => 'Jina la Muuzaji *';

  @override
  String get supplierNameValidationError => 'Jina linahitajika';

  @override
  String get supplierPhoneLabel => 'Nambari ya Simu *';

  @override
  String get supplierPhoneValidationError => 'Nambari ya simu inahitajika';

  @override
  String get supplierPhoneHint => '+243 999 123 456';

  @override
  String get supplierEmailLabel => 'Barua Pepe';

  @override
  String get supplierEmailValidationError => 'Tafadhali ingiza barua pepe sahihi';

  @override
  String get supplierContactPersonLabel => 'Mtu wa Kuwasiliana Naye';

  @override
  String get supplierAddressLabel => 'Anwani';

  @override
  String get commercialInformation => 'Taarifa za Kibiashara';

  @override
  String get deliveryTimeLabel => 'Muda wa Uwasilishaji';

  @override
  String get paymentTermsLabel => 'Masharti ya Malipo';

  @override
  String get paymentTermsHint => 'Mfano: Siku 30, 50% mwanzo, n.k.';

  @override
  String get supplierCategoryLabel => 'Kategoria ya Muuzaji';

  @override
  String get supplierNotesLabel => 'Maelezo';

  @override
  String get updateSupplierButton => 'Sasisha';

  @override
  String get addSupplierButton => 'Ongeza';

  @override
  String get supplierDetailsTitle => 'Maelezo ya Muuzaji';

  @override
  String supplierErrorLoading(String message) {
    return 'Hitilafu: $message';
  }

  @override
  String get supplierNotFound => 'Muuzaji hajapatikana';

  @override
  String get contactLabel => 'Mawasiliano';

  @override
  String get phoneLabel => 'Simu';

  @override
  String get emailLabel => 'Barua Pepe';

  @override
  String get addressLabel => 'Anwani';

  @override
  String get commercialInformationSectionTitle => 'Taarifa za Kibiashara';

  @override
  String deliveryTimeInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count siku',
      one: 'siku 1',
      zero: 'Haijabainishwa',
    );
    return '$_temp0';
  }

  @override
  String get supplierSinceLabel => 'Muuzaji Tangu';

  @override
  String get notesSectionTitle => 'Maelezo';

  @override
  String get placeOrderButtonLabel => 'Weka Oda';

  @override
  String get featureToImplement => 'Kipengele cha kutekeleza';

  @override
  String get confirmDeleteSupplierTitle => 'Futa Muuzaji';

  @override
  String confirmDeleteSupplierMessage(String supplierName) {
    return 'Una uhakika unataka kumfuta $supplierName? Kitendo hiki hakiwezi kutenduliwa.';
  }

  @override
  String get commonConfirm => 'Thibitisha';

  @override
  String get commonError => 'Hitilafu';

  @override
  String get commonToday => 'Leo';

  @override
  String get commonThisMonth => 'Mwezi Huu';

  @override
  String get commonThisYear => 'Mwaka Huu';

  @override
  String get commonCustom => 'Maalum';

  @override
  String get commonAnonymousClient => 'Mteja Asiyejulikana';

  @override
  String get commonAnonymousClientInitial => 'A';

  @override
  String get commonErrorDataUnavailable => 'Data haipatikani';

  @override
  String get commonNoData => 'Hakuna data inayopatikana';

  @override
  String get dashboardScreenTitle => 'Dashibodi';

  @override
  String get dashboardHeaderSalesToday => 'Mauzo ya Leo';

  @override
  String get dashboardHeaderClientsServed => 'Wateja Waliohudumiwa';

  @override
  String get dashboardHeaderReceivables => 'Madeni Yanayodaiwa';

  @override
  String get dashboardHeaderTransactions => 'Miamala';

  @override
  String get dashboardCardViewDetails => 'Tazama Maelezo';

  @override
  String get dashboardSalesChartTitle => 'Muhtasari wa Mauzo';

  @override
  String get dashboardSalesChartNoData => 'Hakuna data ya mauzo ya kuonyesha kwenye chati.';

  @override
  String get dashboardRecentSalesTitle => 'Mauzo ya Hivi Karibuni';

  @override
  String get dashboardRecentSalesViewAll => 'Tazama Yote';

  @override
  String get dashboardRecentSalesNoData => 'Hakuna mauzo ya hivi karibuni.';

  @override
  String get dashboardOperationsJournalTitle => 'Jarida la Uendeshaji';

  @override
  String get dashboardOperationsJournalViewAll => 'Tazama Yote';

  @override
  String get dashboardOperationsJournalNoData => 'Hakuna shughuli za hivi karibuni.';

  @override
  String get dashboardOperationsJournalBalanceLabel => 'Salio';

  @override
  String get dashboardJournalExportSelectDateRangeTitle => 'Chagua Kipindi cha Tarehe';

  @override
  String get dashboardJournalExportExportButton => 'Hamisha kwa PDF';

  @override
  String get dashboardJournalExportPrintButton => 'Chapisha Jarida';

  @override
  String get dashboardJournalExportSuccessMessage => 'Jarida limehamishwa kikamilifu.';

  @override
  String get dashboardJournalExportFailureMessage => 'Imeshindwa kuhamisha jarida.';

  @override
  String get dashboardJournalExportNoDataForPeriod => 'Hakuna data inayopatikana kwa kipindi kilichochaguliwa ili kuhamisha.';

  @override
  String get dashboardJournalExportPrintingMessage => 'Inaandaa jarida kwa uchapishaji...';

  @override
  String get dashboardQuickActionsTitle => 'Vitendo vya Haraka';

  @override
  String get dashboardQuickActionsNewSale => 'Mauzo Mapya';

  @override
  String get dashboardQuickActionsNewExpense => 'Gharama Mpya';

  @override
  String get dashboardQuickActionsNewProduct => 'Bidhaa Mpya';

  @override
  String get dashboardQuickActionsNewService => 'Huduma Mpya';

  @override
  String get dashboardQuickActionsNewClient => 'Mteja Mpya';

  @override
  String get dashboardQuickActionsNewSupplier => 'Muuzaji Mpya';

  @override
  String get dashboardQuickActionsCashRegister => 'Rejista ya Pesa';

  @override
  String get dashboardQuickActionsSettings => 'Mipangilio';

  @override
  String get dashboardQuickActionsNewInvoice => 'Ankara';

  @override
  String get dashboardQuickActionsNewFinancing => 'Ufadhili';

  @override
  String get commonLoading => 'Inapakia...';

  @override
  String get cancel => 'Ghairi';

  @override
  String get journalPdf_title => 'Jarida la Uendeshaji';

  @override
  String journalPdf_footer_pageInfo(int currentPage, int totalPages) {
    return 'Ukurasa $currentPage kati ya $totalPages';
  }

  @override
  String journalPdf_period(String startDate, String endDate) {
    return 'Kipindi: $startDate - $endDate';
  }

  @override
  String get journalPdf_tableHeader_date => 'Tarehe';

  @override
  String get journalPdf_tableHeader_time => 'Wakati';

  @override
  String get journalPdf_tableHeader_description => 'Maelezo';

  @override
  String get journalPdf_tableHeader_debit => 'Debiti';

  @override
  String get journalPdf_tableHeader_credit => 'Krediti';

  @override
  String get journalPdf_tableHeader_balance => 'Salio';

  @override
  String get journalPdf_openingBalance => 'Salio la Kuanzia';

  @override
  String get journalPdf_closingBalance => 'Salio la Kufunga';

  @override
  String get journalPdf_footer_generatedBy => 'Imetolewa na Wanzo';

  @override
  String get adhaHomePageTitle => 'Adha - Msaidizi wa AI';

  @override
  String get adhaHomePageDescription => 'Adha, msaidizi wako mahiri wa biashara';

  @override
  String get adhaHomePageBody => 'Niulize maswali kuhusu biashara yako na nitakusaidia kufanya maamuzi bora kwa uchambuzi na ushauri wa kibinafsi.';

  @override
  String get startConversationButton => 'Anzisha mazungumzo';

  @override
  String get viewConversationsButton => 'Tazama mazungumzo yangu';

  @override
  String get salesAnalysisFeatureTitle => 'Uchambuzi wa Mauzo';

  @override
  String get salesAnalysisFeatureDescription => 'Pata maarifa kuhusu utendaji wako wa mauzo';

  @override
  String get inventoryManagementFeatureTitle => 'Usimamizi wa Mali';

  @override
  String get inventoryManagementFeatureDescription => 'Fuatilia na uboreshe mali yako';

  @override
  String get customerRelationsFeatureTitle => 'Mahusiano na Wateja';

  @override
  String get customerRelationsFeatureDescription => 'Ushauri wa kuwahifadhi wateja wako';

  @override
  String get financialCalculationsFeatureTitle => 'Mahesabu ya Kifedha';

  @override
  String get financialCalculationsFeatureDescription => 'Makadirio na uchambuzi wa kifedha';

  @override
  String get loginButton => 'Ingia';

  @override
  String get registerButton => 'Jisajili';

  @override
  String get emailHint => 'Ingiza barua pepe yako';

  @override
  String get emailValidationErrorRequired => 'Tafadhali ingiza barua pepe yako';

  @override
  String get emailValidationErrorInvalid => 'Tafadhali ingiza barua pepe sahihi';

  @override
  String get passwordLabel => 'Nenosiri';

  @override
  String get passwordHint => 'Ingiza nenosiri lako';

  @override
  String get passwordValidationErrorRequired => 'Tafadhali ingiza nenosiri lako';

  @override
  String authFailureMessage(Object message) {
    return 'Uthibitishaji umeshindwa: $message';
  }

  @override
  String get loginToYourAccount => 'Ingia kwenye akaunti yako';

  @override
  String get rememberMeLabel => 'Nikumbuke';

  @override
  String get forgotPasswordButton => 'Umesahau nenosiri?';

  @override
  String get noAccountPrompt => 'Huna akaunti?';

  @override
  String get createAccountButton => 'Fungua akaunti';

  @override
  String get demoModeButton => 'Hali ya Onyesho';

  @override
  String get settings => 'Mipangilio';

  @override
  String get settingsTitle => 'Mipangilio';

  @override
  String get settingsDescription => 'Dhibiti mipangilio ya programu yako.';

  @override
  String get wanzoFallbackText => 'Maandishi Mbadala ya Wanzo';

  @override
  String get appVersion => 'Toleo la Programu';

  @override
  String get loadingSettings => 'Inapakia mipangilio...';

  @override
  String get companyInformation => 'Taarifa za Kampuni';

  @override
  String get companyInformationSubtitle => 'Dhibiti maelezo ya kampuni yako';

  @override
  String get appearanceAndDisplay => 'Muonekano na Onyesho';

  @override
  String get appearanceAndDisplaySubtitle => 'Binafsisha mwonekano na hisia';

  @override
  String get theme => 'Mandhari';

  @override
  String get themeLight => 'Nuru';

  @override
  String get themeDark => 'Giza';

  @override
  String get themeSystem => 'Mfumo';

  @override
  String get language => 'Lugha';

  @override
  String get languageEnglish => 'Kiingereza';

  @override
  String get languageFrench => 'Kifaransa';

  @override
  String get languageSwahili => 'Kiswahili';

  @override
  String get dateFormat => 'Umbizo la Tarehe';

  @override
  String get dateFormatDDMMYYYY => 'DD/MM/YYYY';

  @override
  String get dateFormatMMDDYYYY => 'MM/DD/YYYY';

  @override
  String get dateFormatYYYYMMDD => 'YYYY/MM/DD';

  @override
  String get dateFormatDDMMMYYYY => 'DD MMM YYYY';

  @override
  String get monthJan => 'Januari';

  @override
  String get monthFeb => 'Februari';

  @override
  String get monthMar => 'Machi';

  @override
  String get monthApr => 'Aprili';

  @override
  String get monthMay => 'Mei';

  @override
  String get monthJun => 'Juni';

  @override
  String get monthJul => 'Julai';

  @override
  String get monthAug => 'August';

  @override
  String get monthSep => 'September';

  @override
  String get monthOct => 'October';

  @override
  String get monthNov => 'November';

  @override
  String get monthDec => 'December';

  @override
  String get changeLogo => 'Change Logo';

  @override
  String get companyName => 'Company Name';

  @override
  String get companyNameRequired => 'Company name is required';

  @override
  String get email => 'Email';

  @override
  String get invalidEmail => 'Invalid email address';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get address => 'Address';

  @override
  String get rccm => 'RCCM';

  @override
  String get rccmHelperText => 'Trade and Personal Property Credit Register';

  @override
  String get taxId => 'Tax ID';

  @override
  String get taxIdHelperText => 'National Tax Identification Number';

  @override
  String get website => 'Website';

  @override
  String get invoiceSettings => 'Invoice Settings';

  @override
  String get invoiceSettingsSubtitle => 'Manage your invoice preferences';

  @override
  String get defaultInvoiceFooter => 'Default Invoice Footer';

  @override
  String get defaultInvoiceFooterHint => 'e.g., Thank you for your business!';

  @override
  String get showTotalInWords => 'Show Total in Words';

  @override
  String get exchangeRate => 'Exchange Rate (USD to Local)';

  @override
  String get inventorySettings => 'Inventory Settings';

  @override
  String get inventorySettingsSubtitle => 'Manage your inventory preferences';

  @override
  String get generalSettings => 'General Settings';

  @override
  String get defaultCategory => 'Default Category';

  @override
  String get defaultCategoryRequired => 'Default category is required';

  @override
  String get lowStockAlert => 'Low Stock Alert';

  @override
  String get lowStockAlertHint => 'Quantity at which to trigger alert';

  @override
  String get trackInventory => 'Track Inventory';

  @override
  String get allowNegativeStock => 'Allow Negative Stock';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get settingsUpdatedSuccessfully => 'Settings updated successfully';

  @override
  String get errorUpdatingSettings => 'Error updating settings';

  @override
  String get changesSaved => 'Changes saved successfully!';

  @override
  String get errorSavingChanges => 'Error saving changes';

  @override
  String get selectTheme => 'Select Theme';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get selectDateFormat => 'Select Date Format';

  @override
  String get displaySettings => 'Display Settings';

  @override
  String get displaySettingsDescription => 'Manage display settings.';

  @override
  String get companySettings => 'Company Settings';

  @override
  String get companySettingsDescription => 'Manage company settings.';

  @override
  String get invoiceSettingsDescription => 'Manage invoice settings.';

  @override
  String get inventorySettingsDescription => 'Manage inventory settings.';

  @override
  String minValue(double minValue) {
    return 'Min value: $minValue';
  }

  @override
  String maxValue(double maxValue) {
    return 'Max value: $maxValue';
  }

  @override
  String get valueMustBeNumber => 'Value must be a number';

  @override
  String get valueMustBePositive => 'Value must be positive';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get settingsGeneral => 'General';

  @override
  String get settingsCompany => 'Company';

  @override
  String get settingsInvoice => 'Invoice';

  @override
  String get settingsInventory => 'Inventory';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get searchSettings => 'Search settings...';

  @override
  String get backupAndReports => 'Backup and Reports';

  @override
  String get backupAndReportsSubtitle => 'Manage data backup and generate reports';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsSubtitle => 'Manage app notifications';

  @override
  String get resetSettings => 'Reset Settings';

  @override
  String get confirmResetSettings => 'Are you sure you want to reset all settings to their default values? This action cannot be undone.';

  @override
  String get reset => 'Reset';

  @override
  String get taxIdentificationNumber => 'Tax Identification Number';

  @override
  String get rccmNumber => 'RCCM Number';

  @override
  String get idNatNumber => 'National ID Number';

  @override
  String get idNatHelperText => 'National Identification Number';

  @override
  String get selectImageSource => 'Select Image Source';

  @override
  String get gallery => 'Gallery';

  @override
  String get camera => 'Camera';

  @override
  String get deleteCurrentLogo => 'Delete Current Logo';

  @override
  String get logoDeleted => 'Logo deleted.';

  @override
  String get logoUpdatedSuccessfully => 'Logo updated successfully.';

  @override
  String errorSelectingLogo(String errorDetails) {
    return 'Error selecting logo: $errorDetails';
  }

  @override
  String get defaultProductCategory => 'Default Product Category';

  @override
  String get stockAlerts => 'Stock Alerts';

  @override
  String get lowStockAlertDays => 'Low Stock Alert Days';

  @override
  String get days => 'Days';

  @override
  String get enterValidNumber => 'Please enter a valid number.';

  @override
  String get lowStockAlertDescription => 'Receive alerts when product stock is low for a specified number of days.';

  @override
  String get productCategories => 'Product Categories';

  @override
  String get manageYourProductCategories => 'Manage your product categories.';

  @override
  String get addCategory => 'Add Category';

  @override
  String get editCategory => 'Edit Category';

  @override
  String get deleteCategory => 'Delete Category';

  @override
  String get categoryName => 'Category Name';

  @override
  String get categoryNameCannotBeEmpty => 'Category name cannot be empty.';

  @override
  String get categoryAdded => 'Category added';

  @override
  String get categoryUpdated => 'Category updated';

  @override
  String get categoryDeleted => 'Category deleted';

  @override
  String get confirmDeleteCategory => 'Are you sure you want to delete this category?';

  @override
  String get deleteCategoryMessage => 'This action cannot be undone.';

  @override
  String errorAddingCategory(Object error) {
    return 'Error adding category: $error';
  }

  @override
  String errorUpdatingCategory(Object error) {
    return 'Error updating category: $error';
  }

  @override
  String errorDeletingCategory(Object error) {
    return 'Error deleting category: $error';
  }

  @override
  String errorFetchingCategories(Object error) {
    return 'Error fetching categories: $error';
  }

  @override
  String get noCategoriesFound => 'No categories found. Add one to get started!';

  @override
  String get signupScreenTitle => 'Create Business Account';

  @override
  String get signupStepIdentity => 'Identity';

  @override
  String get signupStepCompany => 'Company';

  @override
  String get signupStepConfirmation => 'Confirmation';

  @override
  String get signupPersonalInfoTitle => 'Your Personal Information';

  @override
  String get signupOwnerNameLabel => 'Full Name of Owner';

  @override
  String get signupOwnerNameHint => 'Enter your full name';

  @override
  String get signupOwnerNameValidation => 'Please enter the owner\'s name';

  @override
  String get signupEmailLabel => 'Email Address';

  @override
  String get signupEmailHint => 'Enter your email address';

  @override
  String get signupEmailValidationRequired => 'Please enter your email';

  @override
  String get signupEmailValidationInvalid => 'Please enter a valid email';

  @override
  String get signupPhoneLabel => 'Phone Number';

  @override
  String get signupPhoneHint => 'Enter your phone number';

  @override
  String get signupPhoneValidation => 'Please enter your phone number';

  @override
  String get signupPasswordLabel => 'Password';

  @override
  String get signupPasswordHint => 'Enter your password (min. 8 characters)';

  @override
  String get signupPasswordValidationRequired => 'Please enter a password';

  @override
  String get signupPasswordValidationLength => 'Password must be at least 8 characters';

  @override
  String get signupConfirmPasswordLabel => 'Confirm Password';

  @override
  String get signupConfirmPasswordHint => 'Confirm your password';

  @override
  String get signupConfirmPasswordValidationRequired => 'Please confirm your password';

  @override
  String get signupConfirmPasswordValidationMatch => 'Passwords do not match';

  @override
  String get signupRequiredFields => '* Required fields';

  @override
  String get signupCompanyInfoTitle => 'Your Company Information';

  @override
  String get signupCompanyNameLabel => 'Company Name';

  @override
  String get signupCompanyNameHint => 'Enter your company name';

  @override
  String get signupCompanyNameValidation => 'Please enter the company name';

  @override
  String get signupRccmLabel => 'RCCM Number / Business Registration';

  @override
  String get signupRccmHint => 'Enter your RCCM number or equivalent';

  @override
  String get signupRccmValidation => 'Please enter the RCCM number';

  @override
  String get signupAddressLabel => 'Address / Location';

  @override
  String get signupAddressHint => 'Enter your company address';

  @override
  String get signupAddressValidation => 'Please enter your company address';

  @override
  String get signupActivitySectorLabel => 'Business Sector';

  @override
  String get signupTermsAndConditionsTitle => 'Summary and Terms';

  @override
  String get signupInfoSummaryPersonal => 'Personal Information:';

  @override
  String get signupInfoSummaryName => 'Name:';

  @override
  String get signupInfoSummaryEmail => 'Email:';

  @override
  String get signupInfoSummaryPhone => 'Phone:';

  @override
  String get signupInfoSummaryCompany => 'Company Information:';

  @override
  String get signupInfoSummaryCompanyName => 'Company Name:';

  @override
  String get signupInfoSummaryRccm => 'RCCM:';

  @override
  String get signupInfoSummaryAddress => 'Address:';

  @override
  String get signupInfoSummaryActivitySector => 'Activity Sector:';

  @override
  String get signupAgreeToTerms => 'I have read and agree to the';

  @override
  String get signupTermsOfUse => 'Terms of Use';

  @override
  String get andConnector => 'and';

  @override
  String get signupPrivacyPolicy => 'Privacy Policy';

  @override
  String get signupAgreeToTermsConfirmation => 'By checking this box, you confirm that you have read, understood, and accepted our terms of service and privacy policy.';

  @override
  String get signupButtonPrevious => 'Previous';

  @override
  String get signupButtonNext => 'Next';

  @override
  String get signupButtonRegister => 'Register';

  @override
  String get signupAlreadyHaveAccount => 'Already have an account? Log in';

  @override
  String get signupErrorFillFields => 'Please fill in all required fields correctly for the current step.';

  @override
  String get signupErrorAgreeToTerms => 'You must agree to the terms and conditions to register.';

  @override
  String get signupSuccessMessage => 'Registration successful! Logging you in...';

  @override
  String signupErrorRegistration(String error) {
    return 'Registration failed: $error';
  }

  @override
  String get sectorAgricultureName => 'Agriculture and Agri-food';

  @override
  String get sectorAgricultureDescription => 'Agricultural production, food processing, livestock';

  @override
  String get sectorCommerceName => 'Trade and Distribution';

  @override
  String get sectorCommerceDescription => 'Retail, distribution, import-export';

  @override
  String get sectorServicesName => 'Services';

  @override
  String get sectorServicesDescription => 'Business and personal services';

  @override
  String get sectorTechnologyName => 'Technology and Innovation';

  @override
  String get sectorTechnologyDescription => 'Software development, telecommunications, fintech';

  @override
  String get sectorManufacturingName => 'Manufacturing and Industry';

  @override
  String get sectorManufacturingDescription => 'Industrial production, crafts, textiles';

  @override
  String get sectorConstructionName => 'Construction and Real Estate';

  @override
  String get sectorConstructionDescription => 'Construction, real estate development, architecture';

  @override
  String get sectorTransportationName => 'Transport and Logistics';

  @override
  String get sectorTransportationDescription => 'Freight transport, logistics, warehousing';

  @override
  String get sectorEnergyName => 'Energy and Natural Resources';

  @override
  String get sectorEnergyDescription => 'Energy production, mining, water';

  @override
  String get sectorTourismName => 'Tourism and Hospitality';

  @override
  String get sectorTourismDescription => 'Hotels, restaurants, tourism';

  @override
  String get sectorEducationName => 'Education and Training';

  @override
  String get sectorEducationDescription => 'Teaching, vocational training';

  @override
  String get sectorHealthName => 'Health and Medical Services';

  @override
  String get sectorHealthDescription => 'Medical care, pharmacy, medical equipment';

  @override
  String get sectorFinanceName => 'Financial Services';

  @override
  String get sectorFinanceDescription => 'Banking, insurance, microfinance';

  @override
  String get sectorOtherName => 'Other';

  @override
  String get sectorOtherDescription => 'Other business sectors';
}
