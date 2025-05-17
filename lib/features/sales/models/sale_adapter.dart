// filepath: c:\Users\DevSpace\Flutter\wanzo\lib\features\sales\models\sale_adapter.dart
import 'package:hive/hive.dart';
import 'sale.dart';

/// Adaptateur Hive pour la classe SaleStatus
class SaleStatusAdapter extends TypeAdapter<SaleStatus> {
  @override
  final int typeId = 3;

  @override
  SaleStatus read(BinaryReader reader) {
    return SaleStatus.values[reader.readInt()];
  }

  @override
  void write(BinaryWriter writer, SaleStatus obj) {
    writer.writeInt(obj.index);
  }
}

/// Adaptateur Hive pour la classe SaleItem
class SaleItemAdapter extends TypeAdapter<SaleItem> {
  @override
  final int typeId = 2;

  @override
  SaleItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SaleItem(
      productId: fields[0] as String,
      productName: fields[1] as String,
      quantity: fields[2] as double,
      unitPrice: fields[3] as double,
      totalPrice: fields[4] as double,
    );
  }

  @override
  void write(BinaryWriter writer, SaleItem obj) {
    writer.writeByte(5);
    writer.writeByte(0);
    writer.write(obj.productId);
    writer.writeByte(1);
    writer.write(obj.productName);
    writer.writeByte(2);
    writer.write(obj.quantity);
    writer.writeByte(3);
    writer.write(obj.unitPrice);
    writer.writeByte(4);
    writer.write(obj.totalPrice);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaleItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

/// Adaptateur Hive pour la classe Sale
class SaleAdapter extends TypeAdapter<Sale> {
  @override
  final int typeId = 1;

  @override
  Sale read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Sale(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      customerId: fields[2] as String,
      customerName: fields[3] as String,
      items: (fields[4] as List).cast<SaleItem>(),
      totalAmount: fields[5] as double,
      paidAmount: fields[6] as double,
      paymentMethod: fields[7] as String,
      status: fields[8] as SaleStatus,
      notes: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Sale obj) {
    writer.writeByte(10);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.date);
    writer.writeByte(2);
    writer.write(obj.customerId);
    writer.writeByte(3);
    writer.write(obj.customerName);
    writer.writeByte(4);
    writer.write(obj.items);
    writer.writeByte(5);
    writer.write(obj.totalAmount);
    writer.writeByte(6);
    writer.write(obj.paidAmount);
    writer.writeByte(7);
    writer.write(obj.paymentMethod);
    writer.writeByte(8);
    writer.write(obj.status);
    writer.writeByte(9);
    writer.write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
