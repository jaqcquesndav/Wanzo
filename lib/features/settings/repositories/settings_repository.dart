import 'package:hive/hive.dart';
import '../models/settings.dart';

/// Repository pour gérer les paramètres de l'application
class SettingsRepository {
  static const _settingsBoxName = 'settings';
  static const _settingsKey = 'app_settings';
  
  late Box<Settings> _settingsBox;

  /// Initialise le repository
  Future<void> init() async {
    // Enregistrement des adaptateurs Hive
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(SettingsAdapter());
    }
    
    if (!Hive.isAdapterRegistered(8)) {
      Hive.registerAdapter(AppThemeModeAdapter());
    }
    
    _settingsBox = await Hive.openBox<Settings>(_settingsBoxName);
    
    // Crée les paramètres par défaut s'ils n'existent pas
    if (!_settingsBox.containsKey(_settingsKey)) {
      await saveSettings(const Settings());
    }
  }

  /// Récupère les paramètres actuels
  Future<Settings> getSettings() async {
    return _settingsBox.get(_settingsKey) ?? const Settings();
  }

  /// Sauvegarde les paramètres
  Future<void> saveSettings(Settings settings) async {
    await _settingsBox.put(_settingsKey, settings);
  }

  /// Met à jour une partie des paramètres
  Future<Settings> updateSettings(Settings updates) async {
    final currentSettings = await getSettings();
    final newSettings = currentSettings.copyWith(
      companyName: updates.companyName != '' ? updates.companyName : null,
      companyAddress: updates.companyAddress != '' ? updates.companyAddress : null,
      companyPhone: updates.companyPhone != '' ? updates.companyPhone : null,
      companyEmail: updates.companyEmail != '' ? updates.companyEmail : null,
      companyLogo: updates.companyLogo != '' ? updates.companyLogo : null,
      currency: updates.currency != '' ? updates.currency : null,
      dateFormat: updates.dateFormat != '' ? updates.dateFormat : null,
      themeMode: updates.themeMode != currentSettings.themeMode ? updates.themeMode : null,
      language: updates.language != '' ? updates.language : null,
      showTaxes: updates.showTaxes != currentSettings.showTaxes ? updates.showTaxes : null,
      defaultTaxRate: updates.defaultTaxRate != currentSettings.defaultTaxRate ? updates.defaultTaxRate : null,
      invoiceNumberFormat: updates.invoiceNumberFormat != '' ? updates.invoiceNumberFormat : null,
      invoicePrefix: updates.invoicePrefix != '' ? updates.invoicePrefix : null,
      defaultPaymentTerms: updates.defaultPaymentTerms != '' ? updates.defaultPaymentTerms : null,
      defaultInvoiceNotes: updates.defaultInvoiceNotes != '' ? updates.defaultInvoiceNotes : null,
      taxIdentificationNumber: updates.taxIdentificationNumber != '' ? updates.taxIdentificationNumber : null,
      defaultProductCategory: updates.defaultProductCategory != '' ? updates.defaultProductCategory : null,
      lowStockAlertDays: updates.lowStockAlertDays != currentSettings.lowStockAlertDays ? updates.lowStockAlertDays : null,
      backupEnabled: updates.backupEnabled != currentSettings.backupEnabled ? updates.backupEnabled : null,
      backupFrequency: updates.backupFrequency != currentSettings.backupFrequency ? updates.backupFrequency : null,
      reportEmail: updates.reportEmail != '' ? updates.reportEmail : null,
    );
    
    await saveSettings(newSettings);
    return newSettings;
  }

  /// Réinitialise les paramètres à leurs valeurs par défaut
  Future<Settings> resetSettings() async {
    const defaultSettings = Settings();
    await saveSettings(defaultSettings);
    return defaultSettings;
  }
}

/// Adaptateur Hive pour Settings
class SettingsAdapter extends TypeAdapter<Settings> {
  @override
  final int typeId = 7;

  @override
  Settings read(BinaryReader reader) {
    final companyName = reader.readString();
    final companyAddress = reader.readString();
    final companyPhone = reader.readString();
    final companyEmail = reader.readString();
    final companyLogo = reader.readString();
    final currency = reader.readString();
    final dateFormat = reader.readString();
    final themeModeIndex = reader.readInt();
    final language = reader.readString();
    final showTaxes = reader.readBool();
    final defaultTaxRate = reader.readDouble();
    final invoiceNumberFormat = reader.readString();
    final invoicePrefix = reader.readString();
    final defaultPaymentTerms = reader.readString();
    final defaultInvoiceNotes = reader.readString();
    final taxIdentificationNumber = reader.readString();
    final defaultProductCategory = reader.readString();
    final lowStockAlertDays = reader.readInt();
    final backupEnabled = reader.readBool();
    final backupFrequency = reader.readInt();
    final reportEmail = reader.readString();
    
    return Settings(
      companyName: companyName,
      companyAddress: companyAddress,
      companyPhone: companyPhone,
      companyEmail: companyEmail,
      companyLogo: companyLogo,
      currency: currency,
      dateFormat: dateFormat,
      themeMode: AppThemeMode.values[themeModeIndex],
      language: language,
      showTaxes: showTaxes,
      defaultTaxRate: defaultTaxRate,
      invoiceNumberFormat: invoiceNumberFormat,
      invoicePrefix: invoicePrefix,
      defaultPaymentTerms: defaultPaymentTerms,
      defaultInvoiceNotes: defaultInvoiceNotes,
      taxIdentificationNumber: taxIdentificationNumber,
      defaultProductCategory: defaultProductCategory,
      lowStockAlertDays: lowStockAlertDays,
      backupEnabled: backupEnabled,
      backupFrequency: backupFrequency,
      reportEmail: reportEmail,
    );
  }

  @override
  void write(BinaryWriter writer, Settings obj) {
    writer.writeString(obj.companyName);
    writer.writeString(obj.companyAddress);
    writer.writeString(obj.companyPhone);
    writer.writeString(obj.companyEmail);
    writer.writeString(obj.companyLogo);
    writer.writeString(obj.currency);
    writer.writeString(obj.dateFormat);
    writer.writeInt(obj.themeMode.index);
    writer.writeString(obj.language);
    writer.writeBool(obj.showTaxes);
    writer.writeDouble(obj.defaultTaxRate);
    writer.writeString(obj.invoiceNumberFormat);
    writer.writeString(obj.invoicePrefix);
    writer.writeString(obj.defaultPaymentTerms);
    writer.writeString(obj.defaultInvoiceNotes);
    writer.writeString(obj.taxIdentificationNumber);
    writer.writeString(obj.defaultProductCategory);
    writer.writeInt(obj.lowStockAlertDays);
    writer.writeBool(obj.backupEnabled);
    writer.writeInt(obj.backupFrequency);
    writer.writeString(obj.reportEmail);
  }
}

/// Adaptateur Hive pour AppThemeMode
class AppThemeModeAdapter extends TypeAdapter<AppThemeMode> {
  @override
  final int typeId = 8;

  @override
  AppThemeMode read(BinaryReader reader) {
    return AppThemeMode.values[reader.readInt()];
  }

  @override
  void write(BinaryWriter writer, AppThemeMode obj) {
    writer.writeInt(obj.index);
  }
}
