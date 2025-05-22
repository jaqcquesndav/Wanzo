import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'settings.g.dart';

@HiveType(typeId: 28) // New unique typeId for CurrencyType
@JsonEnum()
enum CurrencyType {
  @HiveField(0)
  fc, // Franc Congolais
  @HiveField(1)
  cdf, // Congolese Franc (alternative representation)
  @HiveField(2)
  usd, // US Dollar
}

/// Modèle pour les paramètres de l'application
@HiveType(typeId: 26) // Existing typeId for Settings
@JsonSerializable(explicitToJson: true)
class Settings extends Equatable {
  /// Nom de l'entreprise
  @HiveField(0)
  final String companyName;

  /// Adresse de l'entreprise
  @HiveField(1)
  final String companyAddress;

  /// Numéro de téléphone de l'entreprise
  @HiveField(2)
  final String companyPhone;

  /// Email de l'entreprise
  @HiveField(3)
  final String companyEmail;

  /// Logo de l'entreprise (chemin du fichier)
  @HiveField(4)
  final String companyLogo;

  /// Devise utilisée par l'entreprise
  @HiveField(5)
  final CurrencyType currency; // Changed from String

  /// Format de date préféré
  @HiveField(6)
  final String dateFormat;

  /// Thème de l'application
  @HiveField(7)
  final AppThemeMode themeMode;

  /// Langue de l'application
  @HiveField(8)
  final String language;

  /// Afficher les taxes sur les factures
  @HiveField(9)
  final bool showTaxes;

  /// Taux de taxe par défaut (en pourcentage)
  @HiveField(10)
  final double defaultTaxRate;

  /// Format de numéro de facture
  @HiveField(11)
  final String invoiceNumberFormat;

  /// Préfixe pour les numéros de facture
  @HiveField(12)
  final String invoicePrefix;

  /// Conditions de paiement par défaut pour les factures
  @HiveField(13)
  final String defaultPaymentTerms;

  /// Notes par défaut à afficher sur les factures
  @HiveField(14)
  final String defaultInvoiceNotes;

  /// Numéro d'identification fiscale
  @HiveField(15)
  final String taxIdentificationNumber;

  /// Catégorie de stock par défaut pour les nouveaux produits
  @HiveField(16)
  final String defaultProductCategory;

  /// Nombre de jours pour les alertes de stock bas
  @HiveField(17)
  final int lowStockAlertDays;

  /// Options de sauvegarde activées
  @HiveField(18)
  final bool backupEnabled;

  /// Fréquence de sauvegarde automatique (en jours)
  @HiveField(19)
  final int backupFrequency;

  /// Email pour les rapports automatiques
  @HiveField(20)
  final String reportEmail;

  /// Numéro RCCM (Registre du Commerce et du Crédit Mobilier)
  @HiveField(21)
  final String rccmNumber;

  /// Numéro d'identification nationale
  @HiveField(22)
  final String idNatNumber;

  /// Notifications push activées
  @HiveField(23)
  final bool pushNotificationsEnabled;

  /// Notifications in-app activées
  @HiveField(24)
  final bool inAppNotificationsEnabled;

  /// Notifications par email activées
  @HiveField(25)
  final bool emailNotificationsEnabled;

  /// Notifications sonores activées
  @HiveField(26)
  final bool soundNotificationsEnabled;

  const Settings({
    this.companyName = '',
    this.companyAddress = '',
    this.companyPhone = '',
    this.companyEmail = '',
    this.companyLogo = '',
    this.currency = CurrencyType.fc, // Default to FC
    this.dateFormat = 'DD/MM/YYYY',
    this.themeMode = AppThemeMode.system,
    this.language = 'fr',
    this.showTaxes = true,
    this.defaultTaxRate = 16.0,
    this.invoiceNumberFormat = 'INV-{YEAR}-{SEQ}',
    this.invoicePrefix = 'INV',
    this.defaultPaymentTerms = 'Paiement sous 30 jours',
    this.defaultInvoiceNotes = 'Merci pour votre confiance !',
    this.taxIdentificationNumber = '',
    this.defaultProductCategory = 'Général',
    this.lowStockAlertDays = 7,
    this.backupEnabled = false,
    this.backupFrequency = 7,
    this.reportEmail = '',
    this.rccmNumber = '',
    this.idNatNumber = '',
    this.pushNotificationsEnabled = true,
    this.inAppNotificationsEnabled = true,
    this.emailNotificationsEnabled = false,
    this.soundNotificationsEnabled = true,
  });

  factory Settings.fromJson(Map<String, dynamic> json) => _$SettingsFromJson(json);
  Map<String, dynamic> toJson() => _$SettingsToJson(this);

  Settings copyWith({
    String? companyName,
    String? companyAddress,
    String? companyPhone,
    String? companyEmail,
    String? companyLogo,
    CurrencyType? currency, // Changed
    String? dateFormat,
    AppThemeMode? themeMode,
    String? language,
    bool? showTaxes,
    double? defaultTaxRate,
    String? invoiceNumberFormat,
    String? invoicePrefix,
    String? defaultPaymentTerms,
    String? defaultInvoiceNotes,
    String? taxIdentificationNumber,
    String? defaultProductCategory,
    int? lowStockAlertDays,
    bool? backupEnabled,
    int? backupFrequency,
    String? reportEmail,
    String? rccmNumber,
    String? idNatNumber,
    bool? pushNotificationsEnabled,
    bool? inAppNotificationsEnabled,
    bool? emailNotificationsEnabled,
    bool? soundNotificationsEnabled,
  }) {
    return Settings(
      companyName: companyName ?? this.companyName,
      companyAddress: companyAddress ?? this.companyAddress,
      companyPhone: companyPhone ?? this.companyPhone,
      companyEmail: companyEmail ?? this.companyEmail,
      companyLogo: companyLogo ?? this.companyLogo,
      currency: currency ?? this.currency, // Changed
      dateFormat: dateFormat ?? this.dateFormat,
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      showTaxes: showTaxes ?? this.showTaxes,
      defaultTaxRate: defaultTaxRate ?? this.defaultTaxRate,
      invoiceNumberFormat: invoiceNumberFormat ?? this.invoiceNumberFormat,
      invoicePrefix: invoicePrefix ?? this.invoicePrefix,
      defaultPaymentTerms: defaultPaymentTerms ?? this.defaultPaymentTerms,
      defaultInvoiceNotes: defaultInvoiceNotes ?? this.defaultInvoiceNotes,
      taxIdentificationNumber: taxIdentificationNumber ?? this.taxIdentificationNumber,
      defaultProductCategory: defaultProductCategory ?? this.defaultProductCategory,
      lowStockAlertDays: lowStockAlertDays ?? this.lowStockAlertDays,
      backupEnabled: backupEnabled ?? this.backupEnabled,
      backupFrequency: backupFrequency ?? this.backupFrequency,
      reportEmail: reportEmail ?? this.reportEmail,
      rccmNumber: rccmNumber ?? this.rccmNumber,
      idNatNumber: idNatNumber ?? this.idNatNumber,
      pushNotificationsEnabled: pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      inAppNotificationsEnabled: inAppNotificationsEnabled ?? this.inAppNotificationsEnabled,
      emailNotificationsEnabled: emailNotificationsEnabled ?? this.emailNotificationsEnabled,
      soundNotificationsEnabled: soundNotificationsEnabled ?? this.soundNotificationsEnabled,
    );
  }

  @override
  List<Object?> get props => [
        companyName,
        companyAddress,
        companyPhone,
        companyEmail,
        companyLogo,
        currency, // Changed
        dateFormat,
        themeMode,
        language,
        showTaxes,
        defaultTaxRate,
        invoiceNumberFormat,
        invoicePrefix,
        defaultPaymentTerms,
        defaultInvoiceNotes,
        taxIdentificationNumber,
        defaultProductCategory,
        lowStockAlertDays,
        backupEnabled,
        backupFrequency,
        reportEmail,
        rccmNumber,
        idNatNumber,
        pushNotificationsEnabled,
        inAppNotificationsEnabled,
        emailNotificationsEnabled,
        soundNotificationsEnabled,
      ];
}

/// Modes de thème pour l'application
@HiveType(typeId: 27) // Existing typeId for AppThemeMode
@JsonEnum()
enum AppThemeMode {
  @HiveField(0)
  light,
  @HiveField(1)
  dark,
  @HiveField(2)
  system,
}
