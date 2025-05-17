// filepath: c:\Users\DevSpace\Flutter\wanzo\lib\features\settings\models\settings_adapter.dart
import 'package:hive/hive.dart';
import 'settings.dart';

/// Adaptateur Hive pour la classe Settings
class SettingsAdapter extends TypeAdapter<Settings> {
  @override
  final int typeId = 24;

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
      currency: fields[5] as String,
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
    writer.writeByte(27); // Total number of fields
    writer.writeByte(0);
    writer.write(obj.companyName);
    writer.writeByte(1);
    writer.write(obj.companyAddress);
    writer.writeByte(2);
    writer.write(obj.companyPhone);
    writer.writeByte(3);
    writer.write(obj.companyEmail);
    writer.writeByte(4);
    writer.write(obj.companyLogo);
    writer.writeByte(5);
    writer.write(obj.currency);
    writer.writeByte(6);
    writer.write(obj.dateFormat);
    writer.writeByte(7);
    writer.write(obj.themeMode);
    writer.writeByte(8);
    writer.write(obj.language);
    writer.writeByte(9);
    writer.write(obj.showTaxes);
    writer.writeByte(10);
    writer.write(obj.defaultTaxRate);
    writer.writeByte(11);
    writer.write(obj.invoiceNumberFormat);
    writer.writeByte(12);
    writer.write(obj.invoicePrefix);
    writer.writeByte(13);
    writer.write(obj.defaultPaymentTerms);
    writer.writeByte(14);
    writer.write(obj.defaultInvoiceNotes);
    writer.writeByte(15);
    writer.write(obj.taxIdentificationNumber);
    writer.writeByte(16);
    writer.write(obj.defaultProductCategory);
    writer.writeByte(17);
    writer.write(obj.lowStockAlertDays);
    writer.writeByte(18);
    writer.write(obj.backupEnabled);
    writer.writeByte(19);
    writer.write(obj.backupFrequency);
    writer.writeByte(20);
    writer.write(obj.reportEmail);
    writer.writeByte(21);
    writer.write(obj.rccmNumber);
    writer.writeByte(22);
    writer.write(obj.idNatNumber);
    writer.writeByte(23);
    writer.write(obj.pushNotificationsEnabled);
    writer.writeByte(24);
    writer.write(obj.inAppNotificationsEnabled);
    writer.writeByte(25);
    writer.write(obj.emailNotificationsEnabled);
    writer.writeByte(26);
    writer.write(obj.soundNotificationsEnabled);
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
