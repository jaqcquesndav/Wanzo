// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get invoiceSettingsTitle => 'Paramètres de facturation';

  @override
  String get saveChanges => 'Enregistrer les modifications';

  @override
  String get currencySettings => 'Paramètres de devise';

  @override
  String get activeCurrency => 'Devise active';

  @override
  String get errorFieldRequired => 'Ce champ est requis';

  @override
  String exchangeRateSpecific(String fromCurrency, String toCurrency) {
    return 'Taux de change $fromCurrency vers $toCurrency';
  }

  @override
  String get errorInvalidRate => 'Veuillez entrer un taux valide supérieur à 0';

  @override
  String get invoiceFormatting => 'Formatage des factures';

  @override
  String invoiceFormatHint(Object MONTH, Object SEQ, Object YEAR) {
    return 'Utilisez $YEAR, $MONTH, $SEQ pour année, mois, séquence.';
  }

  @override
  String get invoiceNumberFormat => 'Format du numéro de facture';

  @override
  String get invoicePrefix => 'Préfixe de facture';

  @override
  String get taxesAndConditions => 'Taxes et conditions';

  @override
  String get showTaxesOnInvoices => 'Afficher les taxes sur les factures';

  @override
  String get defaultTaxRatePercentage => 'Taux de taxe par défaut (%)';

  @override
  String get errorInvalidTaxRate => 'Le taux de taxe doit être compris entre 0 et 100';

  @override
  String get defaultPaymentTerms => 'Conditions de paiement par défaut';

  @override
  String get defaultInvoiceNotes => 'Notes de facture par défaut';

  @override
  String get settingsSavedSuccess => 'Paramètres enregistrés avec succès.';

  @override
  String get errorUnknown => 'Une erreur inconnue s\'est produite.';

  @override
  String currencySettingsError(String message) {
    return 'Erreur des paramètres de devise: $message';
  }

  @override
  String get currencySettingsSavedSuccess => 'Paramètres de devise enregistrés avec succès.';

  @override
  String get anErrorOccurred => 'Une erreur s\'est produite';

  @override
  String get currencyCDF => 'Franc Congolais';

  @override
  String get currencyUSD => 'Dollar Américain';

  @override
  String get currencyFCFA => 'Franc CFA';

  @override
  String get editProductTitle => 'Modifier le produit';

  @override
  String get addProductTitle => 'Ajouter un produit';

  @override
  String get productCategoryFood => 'Alimentation';

  @override
  String get productCategoryDrink => 'Boisson';

  @override
  String get productCategoryOther => 'Autre';

  @override
  String get units => 'Unités';

  @override
  String get notes => 'Notes (Facultatif)';

  @override
  String get saveProduct => 'Enregistrer le produit';

  @override
  String get inventoryValue => 'Valeur de l\'inventaire';

  @override
  String get products => 'Produits';

  @override
  String get stockMovements => 'Mouvements de stock';

  @override
  String get noProducts => 'Aucun produit pour le moment.';

  @override
  String get noStockMovements => 'Aucun mouvement de stock pour le moment.';

  @override
  String get searchProducts => 'Rechercher des produits...';

  @override
  String get totalStock => 'Stock total';

  @override
  String get valueInCdf => 'Valeur (CDF)';

  @override
  String valueIn(String currencyCode) {
    return 'Valeur ($currencyCode)';
  }

  @override
  String get lastModified => 'Dernière modification';

  @override
  String get productDetails => 'Détails du produit';

  @override
  String get deleteProduct => 'Supprimer le produit';

  @override
  String get confirmDeleteProductTitle => 'Confirmer la suppression';

  @override
  String get confirmDeleteProductMessage => 'Êtes-vous sûr de vouloir supprimer ce produit ? Cette action est irréversible.';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get stockIn => 'Entrée de stock';

  @override
  String get stockOut => 'Sortie de stock';

  @override
  String get adjustment => 'Ajustement';

  @override
  String get quantity => 'Quantité';

  @override
  String get reason => 'Raison (Facultatif)';

  @override
  String get addStockMovement => 'Ajouter un mouvement de stock';

  @override
  String get newStock => 'Nouveau stock';

  @override
  String get value => 'Valeur';

  @override
  String get type => 'Type';

  @override
  String get date => 'Date';

  @override
  String get product => 'Produit';

  @override
  String get selectProduct => 'Sélectionner un produit';

  @override
  String get selectCategory => 'Sélectionner une catégorie';

  @override
  String get selectUnit => 'Sélectionner une unité';

  @override
  String imagePickingErrorMessage(String errorDetails) {
    return 'Erreur lors de la sélection de l\'image : $errorDetails';
  }

  @override
  String get galleryAction => 'Galerie';

  @override
  String get cameraAction => 'Appareil photo';

  @override
  String get removeImageAction => 'Supprimer l\'image';

  @override
  String get productImageSectionTitle => 'Image du produit';

  @override
  String get addImageLabel => 'Ajouter une image';

  @override
  String get generalInformationSectionTitle => 'Informations générales';

  @override
  String get productNameLabel => 'Nom du produit';

  @override
  String get productNameValidationError => 'Veuillez saisir le nom du produit.';

  @override
  String get productDescriptionLabel => 'Description';

  @override
  String get productBarcodeLabel => 'Code-barres (Facultatif)';

  @override
  String get featureComingSoonMessage => 'Fonctionnalité bientôt disponible !';

  @override
  String get productCategoryLabel => 'Catégorie';

  @override
  String get productCategoryElectronics => 'Électronique';

  @override
  String get productCategoryClothing => 'Vêtements';

  @override
  String get productCategoryHousehold => 'Ménager';

  @override
  String get productCategoryHygiene => 'Hygiène';

  @override
  String get productCategoryOffice => 'Fournitures de bureau';

  @override
  String get pricingSectionTitle => 'Prix et Devise';

  @override
  String get inputCurrencyLabel => 'Devise de saisie';

  @override
  String get inputCurrencyValidationError => 'Veuillez sélectionner une devise de saisie.';

  @override
  String get costPriceLabel => 'Prix d\'achat';

  @override
  String get costPriceValidationError => 'Veuillez saisir le prix d\'achat.';

  @override
  String get negativePriceValidationError => 'Le prix ne peut pas être négatif.';

  @override
  String get invalidNumberValidationError => 'Veuillez saisir un nombre valide.';

  @override
  String get sellingPriceLabel => 'Prix de vente';

  @override
  String get sellingPriceValidationError => 'Veuillez saisir le prix de vente.';

  @override
  String get stockManagementSectionTitle => 'Gestion des stocks';

  @override
  String get stockQuantityLabel => 'Quantité en stock';

  @override
  String get stockQuantityValidationError => 'Veuillez saisir la quantité en stock.';

  @override
  String get negativeQuantityValidationError => 'La quantité ne peut pas être négative.';

  @override
  String get productUnitLabel => 'Unité';

  @override
  String get productUnitPiece => 'Pièce(s)';

  @override
  String get productUnitKg => 'Kilogramme(s) (kg)';

  @override
  String get productUnitG => 'Gramme(s) (g)';

  @override
  String get productUnitL => 'Litre(s) (L)';

  @override
  String get productUnitMl => 'Millilitre(s) (ml)';

  @override
  String get productUnitPackage => 'Paquet(s)';

  @override
  String get productUnitBox => 'Boîte(s)';

  @override
  String get productUnitOther => 'Autre unité';

  @override
  String get lowStockThresholdLabel => 'Seuil d\'alerte de stock bas';

  @override
  String get lowStockThresholdHelper => 'Recevoir une alerte lorsque le stock atteint ce niveau.';

  @override
  String get lowStockThresholdValidationError => 'Veuillez saisir un seuil d\'alerte valide.';

  @override
  String get negativeThresholdValidationError => 'Le seuil ne peut pas être négatif.';

  @override
  String get saveChangesButton => 'Enregistrer les modifications';

  @override
  String get addProductButton => 'Ajouter le produit';

  @override
  String get notesLabelOptional => 'Notes (Facultatif)';

  @override
  String addStockDialogTitle(String productName) {
    return 'Ajouter du stock à $productName';
  }

  @override
  String get currentStockLabel => 'Stock actuel';

  @override
  String get quantityToAddLabel => 'Quantité à ajouter';

  @override
  String get quantityValidationError => 'Veuillez saisir une quantité.';

  @override
  String get positiveQuantityValidationError => 'La quantité doit être positive pour un achat.';

  @override
  String get addButtonLabel => 'Ajouter';

  @override
  String get stockAdjustmentDefaultNote => 'Ajustement de stock';

  @override
  String get stockTransactionTypeOther => 'Autre';

  @override
  String get productInitialFallback => 'P';

  @override
  String get inventoryScreenTitle => 'Inventaire';

  @override
  String get allProductsTabLabel => 'Tous les produits';

  @override
  String get lowStockTabLabel => 'Stock faible';

  @override
  String get transactionsTabLabel => 'Transactions';

  @override
  String get noProductsAvailableMessage => 'Aucun produit disponible.';

  @override
  String get noLowStockProductsMessage => 'Aucun produit en stock faible.';

  @override
  String get noTransactionsAvailableMessage => 'Aucune transaction disponible.';

  @override
  String get searchProductDialogTitle => 'Rechercher un produit';

  @override
  String get searchProductHintText => 'Saisir le nom du produit ou le code-barres...';

  @override
  String get cancelButtonLabel => 'Annuler';

  @override
  String get searchButtonLabel => 'Rechercher';

  @override
  String get filterByCategoryDialogTitle => 'Filtrer par catégorie';

  @override
  String get noCategoriesAvailableMessage => 'Aucune catégorie disponible pour le filtrage.';

  @override
  String get showAllButtonLabel => 'Afficher tout';

  @override
  String get noProductsInInventoryMessage => 'Vous n\'avez encore ajouté aucun produit à votre inventaire.';

  @override
  String get priceLabel => 'Prix';

  @override
  String get inputPriceLabel => 'Saisie';

  @override
  String get stockLabel => 'Stock';

  @override
  String get unknownProductLabel => 'Produit inconnu';

  @override
  String get quantityLabel => 'Quantité';

  @override
  String get dateLabel => 'Date';

  @override
  String get valueLabel => 'Valeur';

  @override
  String get retryButtonLabel => 'Réessayer';

  @override
  String get stockTransactionTypePurchase => 'Achat';

  @override
  String get stockTransactionTypeSale => 'Vente';

  @override
  String get stockTransactionTypeAdjustment => 'Ajustement';

  @override
  String get salesScreenTitle => 'Gestion des ventes';

  @override
  String get salesTabAll => 'Toutes';

  @override
  String get salesTabPending => 'En attente';

  @override
  String get salesTabCompleted => 'Terminées';

  @override
  String get salesFilterDialogTitle => 'Filtrer les ventes';

  @override
  String get salesFilterDialogCancel => 'Annuler';

  @override
  String get salesFilterDialogApply => 'Appliquer';

  @override
  String get salesSummaryTotal => 'Total des ventes';

  @override
  String get salesSummaryCount => 'Nombre de ventes';

  @override
  String get salesStatusPending => 'En attente';

  @override
  String get salesStatusCompleted => 'Terminée';

  @override
  String get salesStatusPartiallyPaid => 'Partiellement payée';

  @override
  String get salesStatusCancelled => 'Annulée';

  @override
  String get salesNoSalesFound => 'Aucune vente trouvée';

  @override
  String get salesAddSaleButton => 'Ajouter une vente';

  @override
  String get salesErrorPrefix => 'Erreur';

  @override
  String get salesRetryButton => 'Réessayer';

  @override
  String get salesFilterDialogStartDate => 'Date de début';

  @override
  String get salesFilterDialogEndDate => 'Date de fin';

  @override
  String get salesListItemSaleIdPrefix => 'Vente #';

  @override
  String salesListItemArticles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articles',
      one: '1 article',
    );
    return '$_temp0';
  }

  @override
  String get salesListItemTotal => 'Total :';

  @override
  String get salesListItemRemainingToPay => 'Reste à payer :';

  @override
  String get subscriptionScreenTitle => 'Gestion des Abonnements';

  @override
  String get subscriptionUnsupportedFileType => 'Type de fichier non supporté. Veuillez choisir un fichier JPG ou PNG.';

  @override
  String get subscriptionFileTooLarge => 'Fichier trop volumineux. La taille maximale est de 5MB.';

  @override
  String get subscriptionNoImageSelected => 'Aucune image sélectionnée.';

  @override
  String get subscriptionUpdateSuccessMessage => 'Abonnement mis à jour avec succès.';

  @override
  String subscriptionUpdateFailureMessage(String error) {
    return 'Échec de la mise à jour de l\'abonnement : $error';
  }

  @override
  String get subscriptionTokenTopUpSuccessMessage => 'Recharge de tokens réussie.';

  @override
  String subscriptionTokenTopUpFailureMessage(String error) {
    return 'Échec de la recharge de tokens : $error';
  }

  @override
  String get subscriptionPaymentProofUploadSuccessMessage => 'Preuve de paiement téléchargée avec succès.';

  @override
  String subscriptionPaymentProofUploadFailureMessage(String error) {
    return 'Échec du téléchargement de la preuve de paiement : $error';
  }

  @override
  String get subscriptionRetryButton => 'Réessayer';

  @override
  String get subscriptionUnhandledState => 'État non géré ou initialisation...';

  @override
  String get subscriptionSectionOurOffers => 'Nos Offres d\'Abonnement';

  @override
  String get subscriptionSectionCurrentSubscription => 'Votre Abonnement Actuel';

  @override
  String get subscriptionSectionTokenUsage => 'Utilisation des Tokens Adha';

  @override
  String get subscriptionSectionInvoiceHistory => 'Historique des Factures';

  @override
  String get subscriptionSectionPaymentMethods => 'Méthodes de Paiement';

  @override
  String get subscriptionChangeSubscriptionButton => 'Changer d\'abonnement';

  @override
  String get subscriptionTierFree => 'Gratuit';

  @override
  String subscriptionTierUsers(int count) {
    return 'Utilisateurs : $count';
  }

  @override
  String subscriptionTierAdhaTokens(int count) {
    return 'Tokens Adha : $count';
  }

  @override
  String get subscriptionTierFeatures => 'Fonctionnalités :';

  @override
  String get subscriptionTierCurrentPlanChip => 'Plan Actuel';

  @override
  String get subscriptionTierChoosePlanButton => 'Choisir ce plan';

  @override
  String subscriptionCurrentPlanTitle(String tierName) {
    return 'Plan Actuel : $tierName';
  }

  @override
  String subscriptionCurrentPlanPrice(String price) {
    return 'Prix : $price';
  }

  @override
  String subscriptionAvailableAdhaTokens(int count) {
    return 'Tokens Adha disponibles : $count';
  }

  @override
  String get subscriptionTopUpTokensButton => 'Recharger des Tokens';

  @override
  String get subscriptionNoInvoices => 'Aucune facture disponible pour le moment.';

  @override
  String subscriptionInvoiceListTitle(String id, String date) {
    return 'Facture $id - $date';
  }

  @override
  String subscriptionInvoiceListSubtitle(String amount, String status) {
    return 'Montant : $amount - Statut : $status';
  }

  @override
  String get subscriptionDownloadInvoiceTooltip => 'Télécharger la facture';

  @override
  String subscriptionSimulateDownloadInvoice(String id, String url) {
    return 'Simulation : Téléchargement de $id depuis $url';
  }

  @override
  String subscriptionSimulateViewInvoiceDetails(String id) {
    return 'Simulation : Voir détails de la facture $id';
  }

  @override
  String get subscriptionPaymentMethodsNextInvoice => 'Méthodes de paiement pour la prochaine facture :';

  @override
  String get subscriptionPaymentMethodsRegistered => 'Méthodes enregistrées :';

  @override
  String get subscriptionPaymentMethodsOtherOptions => 'Autres options de paiement :';

  @override
  String get subscriptionPaymentMethodNewCard => 'Nouvelle Carte Bancaire';

  @override
  String get subscriptionPaymentMethodNewMobileMoney => 'Nouveau Mobile Money';

  @override
  String get subscriptionPaymentMethodManual => 'Paiement Manuel (Transfert/Dépôt)';

  @override
  String get subscriptionManualPaymentInstructions => 'Veuillez effectuer le transfert/dépôt aux coordonnées qui seront fournies et télécharger une preuve de paiement.';

  @override
  String subscriptionProofUploadedLabel(String fileName) {
    return 'Preuve Téléchargée : $fileName';
  }

  @override
  String get subscriptionUploadProofButton => 'Télécharger la preuve';

  @override
  String get subscriptionReplaceProofButton => 'Remplacer la preuve';

  @override
  String get subscriptionConfirmPaymentMethodButton => 'Confirmer la méthode de paiement';

  @override
  String subscriptionSimulatePaymentMethodSelected(String method) {
    return 'Méthode de paiement sélectionnée : $method (Simulation)';
  }

  @override
  String get subscriptionChangeDialogTitle => 'Changer d\'abonnement';

  @override
  String subscriptionChangeDialogTierSubtitle(String price, String tokens) {
    return '$price - Tokens : $tokens';
  }

  @override
  String get subscriptionTopUpDialogTitle => 'Recharger des Tokens Adha';

  @override
  String subscriptionTopUpDialogAmount(String amount, String currencyCode) {
    return '$amount $currencyCode';
  }

  @override
  String get subscriptionNoActivePlan => 'Vous n\'avez pas de plan d\'abonnement actif.';

  @override
  String get contactsScreenTitle => 'Contacts';

  @override
  String get contactsScreenClientsTab => 'Clients';

  @override
  String get contactsScreenSuppliersTab => 'Fournisseurs';

  @override
  String get contactsScreenAddClientTooltip => 'Ajouter un client';

  @override
  String get contactsScreenAddSupplierTooltip => 'Ajouter un fournisseur';

  @override
  String get searchCustomerHint => 'Rechercher un client...';

  @override
  String customerError(String message) {
    return 'Erreur : $message';
  }

  @override
  String get noCustomersToShow => 'Aucun client à afficher';

  @override
  String get customersTitle => 'Clients';

  @override
  String get filterCustomersTooltip => 'Filtrer les clients';

  @override
  String get addCustomerTooltip => 'Ajouter un nouveau client';

  @override
  String noResultsForSearchTerm(String searchTerm) {
    return 'Aucun résultat pour $searchTerm';
  }

  @override
  String get noCustomersAvailable => 'Aucun client disponible';

  @override
  String get topCustomersByPurchases => 'Meilleurs clients par achats';

  @override
  String get recentlyAddedCustomers => 'Clients récemment ajoutés';

  @override
  String resultsForSearchTerm(String searchTerm) {
    return 'Résultats pour $searchTerm';
  }

  @override
  String lastPurchaseDate(String date) {
    return 'Dernier achat : $date';
  }

  @override
  String get noRecentPurchase => 'Aucun achat récent';

  @override
  String totalPurchasesAmount(String amount) {
    return 'Total des achats : $amount';
  }

  @override
  String get viewDetails => 'Voir les détails';

  @override
  String get edit => 'Modifier';

  @override
  String get allCustomers => 'Tous les clients';

  @override
  String get topCustomers => 'Meilleurs clients';

  @override
  String get recentCustomers => 'Clients récents';

  @override
  String get byCategory => 'Par catégorie';

  @override
  String get filterByCategory => 'Filtrer par catégorie';

  @override
  String get deleteCustomerTitle => 'Supprimer le client';

  @override
  String deleteCustomerConfirmation(String customerName) {
    return 'Êtes-vous sûr de vouloir supprimer $customerName ? Cette action est irréversible.';
  }

  @override
  String get customerCategoryVip => 'VIP';

  @override
  String get customerCategoryRegular => 'Régulier';

  @override
  String get customerCategoryNew => 'Nouveau';

  @override
  String get customerCategoryOccasional => 'Occasionnel';

  @override
  String get customerCategoryBusiness => 'Affaires';

  @override
  String get customerCategoryUnknown => 'Inconnue';

  @override
  String get editCustomerTitle => 'Modifier le client';

  @override
  String get addCustomerTitle => 'Ajouter un client';

  @override
  String get customerPhoneHint => '+243 999 123 456';

  @override
  String get customerInformation => 'Informations du client';

  @override
  String get customerNameLabel => 'Nom du client';

  @override
  String get customerNameValidationError => 'Veuillez saisir le nom du client.';

  @override
  String get customerPhoneLabel => 'Téléphone du client';

  @override
  String get customerPhoneValidationError => 'Veuillez saisir le numéro de téléphone du client.';

  @override
  String get customerEmailLabel => 'Email du client (Facultatif)';

  @override
  String get customerEmailLabelOptional => 'Email du client';

  @override
  String get customerEmailValidationError => 'Veuillez saisir une adresse e-mail valide.';

  @override
  String get customerAddressLabel => 'Adresse du client (Facultatif)';

  @override
  String get customerAddressLabelOptional => 'Adresse du client';

  @override
  String get customerCategoryLabel => 'Catégorie de client';

  @override
  String get customerNotesLabel => 'Notes (Facultatif)';

  @override
  String get updateButtonLabel => 'Mettre à jour';

  @override
  String get customerDetailsTitle => 'Détails du client';

  @override
  String get editCustomerTooltip => 'Modifier le client';

  @override
  String get customerNotFound => 'Client non trouvé';

  @override
  String get contactInformationSectionTitle => 'Informations de contact';

  @override
  String get purchaseStatisticsSectionTitle => 'Statistiques d\'achat';

  @override
  String get totalPurchasesLabel => 'Total des achats';

  @override
  String get lastPurchaseLabel => 'Dernier achat';

  @override
  String get noPurchaseRecorded => 'Aucun achat enregistré';

  @override
  String get customerSinceLabel => 'Client depuis';

  @override
  String get addSaleButtonLabel => 'Ajouter une vente';

  @override
  String get callButtonLabel => 'Appeler';

  @override
  String get deleteButtonLabel => 'Supprimer';

  @override
  String callingNumber(String phoneNumber) {
    return 'Appel vers $phoneNumber...';
  }

  @override
  String emailingTo(String email) {
    return 'Envoi d\'email à $email...';
  }

  @override
  String openingMapFor(String address) {
    return 'Ouverture de la carte pour $address...';
  }

  @override
  String get searchSupplierHint => 'Rechercher un fournisseur...';

  @override
  String get clearSearchTooltip => 'Effacer la recherche';

  @override
  String supplierError(String message) {
    return 'Erreur : $message';
  }

  @override
  String get noSuppliersToShow => 'Aucun fournisseur à afficher';

  @override
  String get suppliersTitle => 'Fournisseurs';

  @override
  String get filterSuppliersTooltip => 'Filtrer les fournisseurs';

  @override
  String get addSupplierTooltip => 'Ajouter un nouveau fournisseur';

  @override
  String get noSuppliersAvailable => 'Aucun fournisseur disponible';

  @override
  String get topSuppliersByPurchases => 'Principaux fournisseurs par achats';

  @override
  String get recentlyAddedSuppliers => 'Fournisseurs récemment ajoutés';

  @override
  String contactPerson(String name) {
    return 'Contact : $name';
  }

  @override
  String get moreOptionsTooltip => 'Plus d\'options';

  @override
  String get allSuppliers => 'Tous les fournisseurs';

  @override
  String get topSuppliers => 'Principaux fournisseurs';

  @override
  String get recentSuppliers => 'Fournisseurs récents';

  @override
  String get deleteSupplierTitle => 'Supprimer le fournisseur';

  @override
  String deleteSupplierConfirmation(String supplierName) {
    return 'Êtes-vous sûr de vouloir supprimer $supplierName ? Cette action est irréversible.';
  }

  @override
  String get supplierCategoryStrategic => 'Stratégique';

  @override
  String get supplierCategoryRegular => 'Régulier';

  @override
  String get supplierCategoryNew => 'Nouveau';

  @override
  String get supplierCategoryOccasional => 'Occasionnel';

  @override
  String get supplierCategoryInternational => 'International';

  @override
  String get supplierCategoryUnknown => 'Inconnu';

  @override
  String get addSupplierTitle => 'Ajouter un fournisseur';

  @override
  String get editSupplierTitle => 'Modifier le fournisseur';

  @override
  String get supplierInformation => 'Informations du fournisseur';

  @override
  String get supplierNameLabel => 'Nom du fournisseur *';

  @override
  String get supplierNameValidationError => 'Le nom est obligatoire';

  @override
  String get supplierPhoneLabel => 'Numéro de téléphone *';

  @override
  String get supplierPhoneValidationError => 'Le numéro de téléphone est obligatoire';

  @override
  String get supplierPhoneHint => '+243 999 123 456';

  @override
  String get supplierEmailLabel => 'Email';

  @override
  String get supplierEmailValidationError => 'Veuillez entrer un email valide';

  @override
  String get supplierContactPersonLabel => 'Personne à contacter';

  @override
  String get supplierAddressLabel => 'Adresse';

  @override
  String get commercialInformation => 'Informations commerciales';

  @override
  String get deliveryTimeLabel => 'Délai de livraison';

  @override
  String get paymentTermsLabel => 'Conditions de paiement';

  @override
  String get paymentTermsHint => 'Ex: Net 30, 50% d\'avance, etc.';

  @override
  String get supplierCategoryLabel => 'Catégorie de fournisseur';

  @override
  String get supplierNotesLabel => 'Notes';

  @override
  String get updateSupplierButton => 'Mettre à jour';

  @override
  String get addSupplierButton => 'Ajouter';

  @override
  String get supplierDetailsTitle => 'Détails du fournisseur';

  @override
  String supplierErrorLoading(String message) {
    return 'Erreur : $message';
  }

  @override
  String get supplierNotFound => 'Fournisseur non trouvé';

  @override
  String get contactLabel => 'Contact';

  @override
  String get phoneLabel => 'Téléphone';

  @override
  String get emailLabel => 'Email';

  @override
  String get addressLabel => 'Adresse';

  @override
  String get commercialInformationSectionTitle => 'Informations commerciales';

  @override
  String deliveryTimeInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours',
      one: '1 jour',
      zero: 'Non spécifié',
    );
    return '$_temp0';
  }

  @override
  String get supplierSinceLabel => 'Fournisseur depuis';

  @override
  String get notesSectionTitle => 'Notes';

  @override
  String get placeOrderButtonLabel => 'Passer commande';

  @override
  String get featureToImplement => 'Fonctionnalité à implémenter';

  @override
  String get confirmDeleteSupplierTitle => 'Supprimer le fournisseur';

  @override
  String confirmDeleteSupplierMessage(String supplierName) {
    return 'Êtes-vous sûr de vouloir supprimer $supplierName ? Cette action est irréversible.';
  }

  @override
  String get commonConfirm => 'Confirmer';

  @override
  String get commonError => 'Erreur';

  @override
  String get commonToday => 'Aujourd\'hui';

  @override
  String get commonThisMonth => 'Ce Mois-ci';

  @override
  String get commonThisYear => 'Cette Année';

  @override
  String get commonCustom => 'Personnalisé';

  @override
  String get commonAnonymousClient => 'Client Anonyme';

  @override
  String get commonAnonymousClientInitial => 'A';

  @override
  String get commonErrorDataUnavailable => 'Données indisponibles';

  @override
  String get commonNoData => 'Aucune donnée disponible';

  @override
  String get dashboardScreenTitle => 'Tableau de Bord';

  @override
  String get dashboardHeaderSalesToday => 'Ventes Aujourd\'hui';

  @override
  String get dashboardHeaderClientsServed => 'Clients Servis';

  @override
  String get dashboardHeaderReceivables => 'Créances';

  @override
  String get dashboardHeaderTransactions => 'Transactions';

  @override
  String get dashboardCardViewDetails => 'Voir Détails';

  @override
  String get dashboardSalesChartTitle => 'Aperçu des Ventes';

  @override
  String get dashboardSalesChartNoData => 'Aucune donnée de vente à afficher.';

  @override
  String get dashboardRecentSalesTitle => 'Ventes Récentes';

  @override
  String get dashboardRecentSalesViewAll => 'Voir Tout';

  @override
  String get dashboardRecentSalesNoData => 'Aucune vente récente.';

  @override
  String get dashboardOperationsJournalTitle => 'Journal des Opérations';

  @override
  String get dashboardOperationsJournalViewAll => 'Voir Tout';

  @override
  String get dashboardOperationsJournalNoData => 'Aucune opération récente.';

  @override
  String get dashboardOperationsJournalBalanceLabel => 'Solde';

  @override
  String get dashboardJournalExportSelectDateRangeTitle => 'Sélectionner la plage de dates';

  @override
  String get dashboardJournalExportExportButton => 'Exporter en PDF';

  @override
  String get dashboardJournalExportPrintButton => 'Imprimer le Journal';

  @override
  String get dashboardJournalExportSuccessMessage => 'Journal exporté avec succès.';

  @override
  String get dashboardJournalExportFailureMessage => 'Échec de l\'exportation du journal.';

  @override
  String get dashboardJournalExportNoDataForPeriod => 'Aucune donnée disponible pour la période sélectionnée.';

  @override
  String get dashboardJournalExportPrintingMessage => 'Préparation du journal pour l\'impression...';

  @override
  String get dashboardQuickActionsTitle => 'Actions Rapides';

  @override
  String get dashboardQuickActionsNewSale => 'Nouvelle Vente';

  @override
  String get dashboardQuickActionsNewExpense => 'Nouvelle Dépense';

  @override
  String get dashboardQuickActionsNewProduct => 'Nouveau Produit';

  @override
  String get dashboardQuickActionsNewService => 'Nouveau Service';

  @override
  String get dashboardQuickActionsNewClient => 'Nouveau Client';

  @override
  String get dashboardQuickActionsNewSupplier => 'Nouveau Fournisseur';

  @override
  String get dashboardQuickActionsCashRegister => 'Caisse';

  @override
  String get dashboardQuickActionsSettings => 'Paramètres';

  @override
  String get commonLoading => 'Chargement...';

  @override
  String get cancel => 'Annuler';
}
