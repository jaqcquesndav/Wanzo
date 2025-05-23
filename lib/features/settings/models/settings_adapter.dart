// filepath: c:\Users\DevSpace\Flutter\wanzo\lib\features\settings\models\settings_adapter.dart
import 'package:hive/hive.dart';
import 'settings.dart';

/// Adaptateur Hive pour la classe Settings
class SettingsAdapter extends TypeAdapter<Settings> {
  @override
  final int typeId = 24; // Make sure this typeId is unique and registered in main.dart

  @override
  Settings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    
    return Settings(
      companyName: fields[0] as String? ?? '',
      companyAddress: fields[1] as String? ?? '',
      companyPhone: fields[2] as String? ?? '',
      companyEmail: fields[3] as String? ?? '',
      companyLogo: fields[4] as String? ?? '',
      currency: fields[5] is String ? CurrencyType.values.firstWhere((e) => e.name == fields[5], orElse: () => CurrencyType.usd) : fields[5] as CurrencyType? ?? CurrencyType.usd,
      dateFormat: fields[6] as String? ?? 'dd/MM/yyyy',
      themeMode: fields[7] as AppThemeMode? ?? AppThemeMode.system,
      language: fields[8] as String? ?? 'fr',
      showTaxes: fields[9] as bool? ?? false,
      defaultTaxRate: fields[10] as double? ?? 0.0,
      invoiceNumberFormat: fields[11] as String? ?? 'INV-{YYYY}-{NNNN}',
      invoicePrefix: fields[12] as String? ?? 'INV',
      defaultPaymentTerms: fields[13] as String? ?? 'Net 30',
      defaultInvoiceNotes: fields[14] as String? ?? '',
      taxIdentificationNumber: fields[15] as String? ?? '',
      defaultProductCategory: fields[16] as String? ?? '',
      lowStockAlertDays: fields[17] as int? ?? 7,
      backupEnabled: fields[18] as bool? ?? false,
      backupFrequency: fields[19] as int? ?? 24, // Assuming hours
      reportEmail: fields[20] as String? ?? '',
      rccmNumber: fields[21] as String? ?? '',
      idNatNumber: fields[22] as String? ?? '',
      pushNotificationsEnabled: fields[23] as bool? ?? true,
      inAppNotificationsEnabled: fields[24] as bool? ?? true,
      emailNotificationsEnabled: fields[25] as bool? ?? true,
      soundNotificationsEnabled: fields[26] as bool? ?? true,
    );
  }

  @override
  void write(BinaryWriter writer, Settings obj) {
    writer.writeByte(27); // Total number of fields
    writer.writeByte(0);
    writer.writeString(obj.companyName);
    writer.writeByte(1);
    writer.writeString(obj.companyAddress);
    writer.writeByte(2);
    writer.writeString(obj.companyPhone);
    writer.writeByte(3);
    writer.writeString(obj.companyEmail);
    writer.writeByte(4);
    writer.writeString(obj.companyLogo);
    writer.writeByte(5);
    writer.writeString(obj.currency.name); // Store enum as string
    writer.writeByte(6);
    writer.writeString(obj.dateFormat);
    writer.writeByte(7);
    writer.write(obj.themeMode); // Assuming AppThemeMode is already a HiveObject or has an adapter
    writer.writeByte(8);
    writer.writeString(obj.language);
    writer.writeByte(9);
    writer.writeBool(obj.showTaxes);
    writer.writeByte(10);
    writer.writeDouble(obj.defaultTaxRate);
    writer.writeByte(11);
    writer.writeString(obj.invoiceNumberFormat);
    writer.writeByte(12);
    writer.writeString(obj.invoicePrefix);
    writer.writeByte(13);
    writer.writeString(obj.defaultPaymentTerms);
    writer.writeByte(14);
    writer.writeString(obj.defaultInvoiceNotes);
    writer.writeByte(15);
    writer.writeString(obj.taxIdentificationNumber);
    writer.writeByte(16);
    writer.writeString(obj.defaultProductCategory);
    writer.writeByte(17);
    writer.writeInt(obj.lowStockAlertDays);
    writer.writeByte(18);
    writer.writeBool(obj.backupEnabled);
    writer.writeByte(19);
    writer.writeInt(obj.backupFrequency);
    writer.writeByte(20);
    writer.writeString(obj.reportEmail);
    writer.writeByte(21);
    writer.writeString(obj.rccmNumber);
    writer.writeByte(22);
    writer.writeString(obj.idNatNumber);
    writer.writeByte(23);
    writer.writeBool(obj.pushNotificationsEnabled);
    writer.writeByte(24);
    writer.writeBool(obj.inAppNotificationsEnabled);
    writer.writeByte(25);
    writer.writeBool(obj.emailNotificationsEnabled);
    writer.writeByte(26);
    writer.writeBool(obj.soundNotificationsEnabled);
  }
}

/// Adaptateur Hive pour l'énumération AppThemeMode
class AppThemeModeAdapter extends TypeAdapter<AppThemeMode> {
  @override
  final int typeId = 25;

  @override
  AppThemeMode read(BinaryReader reader) {
    return AppThemeMode.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, AppThemeMode obj) {
    writer.writeByte(obj.index);
  }
}
