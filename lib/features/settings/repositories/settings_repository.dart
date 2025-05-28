import 'package:hive/hive.dart';
import '../models/settings.dart';

/// Repository pour gérer les paramètres de l'application
class SettingsRepository {
  static const _settingsBoxName = 'settingsBox';
  static const _settingsKey = 'app_settings';
  
  late Box<Settings> _settingsBox;

  /// Initialise le repository
  Future<void> init() async {
    _settingsBox = await Hive.openBox<Settings>(_settingsBoxName);
    
    // Crée les paramètres par défaut s'ils n'existent pas
    if (!_settingsBox.containsKey(_settingsKey)) {
      await saveSettings(const Settings()); // Uses default constructor from Settings model
    }
  }

  /// Récupère les paramètres actuels
  Future<Settings> getSettings() async {
    return _settingsBox.get(_settingsKey) ?? const Settings(); // Uses default constructor
  }

  /// Sauvegarde les paramètres
  Future<void> saveSettings(Settings settings) async {
    await _settingsBox.put(_settingsKey, settings);
  }

  /// Met à jour une partie des paramètres
  Future<Settings> updateSettings(Settings updates) async {
    final currentSettings = await getSettings();
    final newSettings = currentSettings.copyWith(
      companyName: updates.companyName.isNotEmpty ? updates.companyName : currentSettings.companyName,
      companyAddress: updates.companyAddress.isNotEmpty ? updates.companyAddress : currentSettings.companyAddress,
      companyPhone: updates.companyPhone.isNotEmpty ? updates.companyPhone : currentSettings.companyPhone,
      companyEmail: updates.companyEmail.isNotEmpty ? updates.companyEmail : currentSettings.companyEmail,
      companyLogo: updates.companyLogo.isNotEmpty ? updates.companyLogo : currentSettings.companyLogo,
      activeCurrency: updates.activeCurrency != currentSettings.activeCurrency ? updates.activeCurrency : currentSettings.activeCurrency,
      dateFormat: updates.dateFormat.isNotEmpty ? updates.dateFormat : currentSettings.dateFormat,
      themeMode: updates.themeMode != currentSettings.themeMode ? updates.themeMode : currentSettings.themeMode,
      language: updates.language.isNotEmpty ? updates.language : currentSettings.language,
      showTaxes: updates.showTaxes != currentSettings.showTaxes ? updates.showTaxes : currentSettings.showTaxes,
      defaultTaxRate: updates.defaultTaxRate != currentSettings.defaultTaxRate ? updates.defaultTaxRate : currentSettings.defaultTaxRate,
      invoiceNumberFormat: updates.invoiceNumberFormat.isNotEmpty ? updates.invoiceNumberFormat : currentSettings.invoiceNumberFormat,
      invoicePrefix: updates.invoicePrefix.isNotEmpty ? updates.invoicePrefix : currentSettings.invoicePrefix,
      defaultPaymentTerms: updates.defaultPaymentTerms.isNotEmpty ? updates.defaultPaymentTerms : currentSettings.defaultPaymentTerms,
      defaultInvoiceNotes: updates.defaultInvoiceNotes.isNotEmpty ? updates.defaultInvoiceNotes : currentSettings.defaultInvoiceNotes,
      taxIdentificationNumber: updates.taxIdentificationNumber.isNotEmpty ? updates.taxIdentificationNumber : currentSettings.taxIdentificationNumber,
      defaultProductCategory: updates.defaultProductCategory.isNotEmpty ? updates.defaultProductCategory : currentSettings.defaultProductCategory,
      lowStockAlertDays: updates.lowStockAlertDays != currentSettings.lowStockAlertDays ? updates.lowStockAlertDays : currentSettings.lowStockAlertDays,
      backupEnabled: updates.backupEnabled != currentSettings.backupEnabled ? updates.backupEnabled : currentSettings.backupEnabled,
      backupFrequency: updates.backupFrequency != currentSettings.backupFrequency ? updates.backupFrequency : currentSettings.backupFrequency,
      reportEmail: updates.reportEmail.isNotEmpty ? updates.reportEmail : currentSettings.reportEmail,
      rccmNumber: updates.rccmNumber.isNotEmpty ? updates.rccmNumber : currentSettings.rccmNumber,
      idNatNumber: updates.idNatNumber.isNotEmpty ? updates.idNatNumber : currentSettings.idNatNumber,
      pushNotificationsEnabled: updates.pushNotificationsEnabled != currentSettings.pushNotificationsEnabled ? updates.pushNotificationsEnabled : currentSettings.pushNotificationsEnabled,
      inAppNotificationsEnabled: updates.inAppNotificationsEnabled != currentSettings.inAppNotificationsEnabled ? updates.inAppNotificationsEnabled : currentSettings.inAppNotificationsEnabled,
      emailNotificationsEnabled: updates.emailNotificationsEnabled != currentSettings.emailNotificationsEnabled ? updates.emailNotificationsEnabled : currentSettings.emailNotificationsEnabled,
      soundNotificationsEnabled: updates.soundNotificationsEnabled != currentSettings.soundNotificationsEnabled ? updates.soundNotificationsEnabled : currentSettings.soundNotificationsEnabled,
    );
    
    await saveSettings(newSettings);
    return newSettings;
  }

  /// Réinitialise les paramètres à leurs valeurs par défaut
  Future<Settings> resetSettings() async {
    const defaultSettings = Settings(); // Uses default constructor
    await saveSettings(defaultSettings);
    return defaultSettings;
  }
}
