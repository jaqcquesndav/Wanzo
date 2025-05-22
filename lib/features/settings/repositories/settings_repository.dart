import 'package:hive/hive.dart';
import '../models/settings.dart';

/// Repository pour gérer les paramètres de l'application
class SettingsRepository {
  static const _settingsBoxName = 'settingsBox'; // Corrected box name to match main.dart
  static const _settingsKey = 'app_settings';
  
  late Box<Settings> _settingsBox;

  /// Initialise le repository
  Future<void> init() async {
    // Enregistrement des adaptateurs Hive
    if (!Hive.isAdapterRegistered(SettingsAdapter().typeId)) { // Use adapter typeId
      Hive.registerAdapter(SettingsAdapter());
    }
    
    if (!Hive.isAdapterRegistered(AppThemeModeAdapter().typeId)) { // Use adapter typeId
      Hive.registerAdapter(AppThemeModeAdapter());
    }
    
    if (!Hive.isAdapterRegistered(CurrencyTypeAdapter().typeId)) { // Register CurrencyTypeAdapter
      Hive.registerAdapter(CurrencyTypeAdapter());
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
      companyName: updates.companyName != '' ? updates.companyName : currentSettings.companyName,
      companyAddress: updates.companyAddress != '' ? updates.companyAddress : currentSettings.companyAddress,
      companyPhone: updates.companyPhone != '' ? updates.companyPhone : currentSettings.companyPhone,
      companyEmail: updates.companyEmail != '' ? updates.companyEmail : currentSettings.companyEmail,
      companyLogo: updates.companyLogo != '' ? updates.companyLogo : currentSettings.companyLogo,
      currency: updates.currency != currentSettings.currency ? updates.currency : currentSettings.currency, // Adjusted for enum
      dateFormat: updates.dateFormat != '' ? updates.dateFormat : currentSettings.dateFormat,
      themeMode: updates.themeMode != currentSettings.themeMode ? updates.themeMode : currentSettings.themeMode,
      language: updates.language != '' ? updates.language : currentSettings.language,
      showTaxes: updates.showTaxes != currentSettings.showTaxes ? updates.showTaxes : currentSettings.showTaxes,
      defaultTaxRate: updates.defaultTaxRate != currentSettings.defaultTaxRate ? updates.defaultTaxRate : currentSettings.defaultTaxRate,
      invoiceNumberFormat: updates.invoiceNumberFormat != '' ? updates.invoiceNumberFormat : currentSettings.invoiceNumberFormat,
      invoicePrefix: updates.invoicePrefix != '' ? updates.invoicePrefix : currentSettings.invoicePrefix,
      defaultPaymentTerms: updates.defaultPaymentTerms != '' ? updates.defaultPaymentTerms : currentSettings.defaultPaymentTerms,
      defaultInvoiceNotes: updates.defaultInvoiceNotes != '' ? updates.defaultInvoiceNotes : currentSettings.defaultInvoiceNotes,
      taxIdentificationNumber: updates.taxIdentificationNumber != '' ? updates.taxIdentificationNumber : currentSettings.taxIdentificationNumber,
      defaultProductCategory: updates.defaultProductCategory != '' ? updates.defaultProductCategory : currentSettings.defaultProductCategory,
      lowStockAlertDays: updates.lowStockAlertDays != currentSettings.lowStockAlertDays ? updates.lowStockAlertDays : currentSettings.lowStockAlertDays,
      backupEnabled: updates.backupEnabled != currentSettings.backupEnabled ? updates.backupEnabled : currentSettings.backupEnabled,
      backupFrequency: updates.backupFrequency != currentSettings.backupFrequency ? updates.backupFrequency : currentSettings.backupFrequency,
      reportEmail: updates.reportEmail != '' ? updates.reportEmail : currentSettings.reportEmail,
      rccmNumber: updates.rccmNumber != '' ? updates.rccmNumber : currentSettings.rccmNumber,
      idNatNumber: updates.idNatNumber != '' ? updates.idNatNumber : currentSettings.idNatNumber,
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
    const defaultSettings = Settings();
    await saveSettings(defaultSettings);
    return defaultSettings;
  }
}

/// Adaptateur Hive pour Settings
class SettingsAdapter extends TypeAdapter<Settings> {
  @override
  final int typeId = 26; // Match typeId in Settings model

  @override
  Settings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Settings(
      companyName: fields[0] as String,
      companyAddress: fields[1] as String,
      companyPhone: fields[2] as String,
      companyEmail: fields[3] as String,
      companyLogo: fields[4] as String,
      currency: fields[5] as CurrencyType, // Read as CurrencyType
      dateFormat: fields[6] as String,
      themeMode: fields[7] as AppThemeMode,
      language: fields[8] as String,
      showTaxes: fields[9] as bool,
      defaultTaxRate: fields[10] as double,
      invoiceNumberFormat: fields[11] as String,
      invoicePrefix: fields[12] as String,
      defaultPaymentTerms: fields[13] as String,
      defaultInvoiceNotes: fields[14] as String,
      taxIdentificationNumber: fields[15] as String,
      defaultProductCategory: fields[16] as String,
      lowStockAlertDays: fields[17] as int,
      backupEnabled: fields[18] as bool,
      backupFrequency: fields[19] as int,
      reportEmail: fields[20] as String,
      rccmNumber: fields[21] as String,
      idNatNumber: fields[22] as String,
      pushNotificationsEnabled: fields[23] as bool,
      inAppNotificationsEnabled: fields[24] as bool,
      emailNotificationsEnabled: fields[25] as bool,
      soundNotificationsEnabled: fields[26] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Settings obj) {
    writer
      ..writeByte(27) // Number of fields
      ..writeByte(0)
      ..write(obj.companyName)
      ..writeByte(1)
      ..write(obj.companyAddress)
      ..writeByte(2)
      ..write(obj.companyPhone)
      ..writeByte(3)
      ..write(obj.companyEmail)
      ..writeByte(4)
      ..write(obj.companyLogo)
      ..writeByte(5)
      ..write(obj.currency) // Write CurrencyType enum
      ..writeByte(6)
      ..write(obj.dateFormat)
      ..writeByte(7)
      ..write(obj.themeMode)
      ..writeByte(8)
      ..write(obj.language)
      ..writeByte(9)
      ..write(obj.showTaxes)
      ..writeByte(10)
      ..write(obj.defaultTaxRate)
      ..writeByte(11)
      ..write(obj.invoiceNumberFormat)
      ..writeByte(12)
      ..write(obj.invoicePrefix)
      ..writeByte(13)
      ..write(obj.defaultPaymentTerms)
      ..writeByte(14)
      ..write(obj.defaultInvoiceNotes)
      ..writeByte(15)
      ..write(obj.taxIdentificationNumber)
      ..writeByte(16)
      ..write(obj.defaultProductCategory)
      ..writeByte(17)
      ..write(obj.lowStockAlertDays)
      ..writeByte(18)
      ..write(obj.backupEnabled)
      ..writeByte(19)
      ..write(obj.backupFrequency)
      ..writeByte(20)
      ..write(obj.reportEmail)
      ..writeByte(21)
      ..write(obj.rccmNumber)
      ..writeByte(22)
      ..write(obj.idNatNumber)
      ..writeByte(23)
      ..write(obj.pushNotificationsEnabled)
      ..writeByte(24)
      ..write(obj.inAppNotificationsEnabled)
      ..writeByte(25)
      ..write(obj.emailNotificationsEnabled)
      ..writeByte(26)
      ..write(obj.soundNotificationsEnabled);
  }
}

/// Adaptateur Hive pour AppThemeMode
class AppThemeModeAdapter extends TypeAdapter<AppThemeMode> {
  @override
  final int typeId = 27; // Match typeId in AppThemeMode enum

  @override
  AppThemeMode read(BinaryReader reader) {
    return AppThemeMode.values[reader.readInt()];
  }

  @override
  void write(BinaryWriter writer, AppThemeMode obj) {
    writer.writeInt(obj.index);
  }
}

/// Adaptateur Hive pour CurrencyType
class CurrencyTypeAdapter extends TypeAdapter<CurrencyType> {
  @override
  final int typeId = 28; // Match typeId in CurrencyType enum

  @override
  CurrencyType read(BinaryReader reader) {
    return CurrencyType.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, CurrencyType obj) {
    writer.writeByte(obj.index);
  }
}
