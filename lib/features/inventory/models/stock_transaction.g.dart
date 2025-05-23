// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StockTransactionAdapter extends TypeAdapter<StockTransaction> {
  @override
  final int typeId = 33;

  @override
  StockTransaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StockTransaction(
      id: fields[0] as String,
      productId: fields[1] as String,
      type: fields[2] as StockTransactionType,
      quantity: fields[3] as double,
      date: fields[4] as DateTime,
      referenceId: fields[5] as String?,
      notes: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, StockTransaction obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.productId)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.quantity)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.referenceId)
      ..writeByte(6)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockTransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StockTransactionTypeAdapter extends TypeAdapter<StockTransactionType> {
  @override
  final int typeId = 32;

  @override
  StockTransactionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return StockTransactionType.purchase;
      case 1:
        return StockTransactionType.sale;
      case 2:
        return StockTransactionType.adjustment;
      case 3:
        return StockTransactionType.transferIn;
      case 4:
        return StockTransactionType.transferOut;
      case 5:
        return StockTransactionType.returned;
      case 6:
        return StockTransactionType.damaged;
      case 7:
        return StockTransactionType.lost;
      case 8:
        return StockTransactionType.initialStock;
      default:
        return StockTransactionType.purchase;
    }
  }

  @override
  void write(BinaryWriter writer, StockTransactionType obj) {
    switch (obj) {
      case StockTransactionType.purchase:
        writer.writeByte(0);
        break;
      case StockTransactionType.sale:
        writer.writeByte(1);
        break;
      case StockTransactionType.adjustment:
        writer.writeByte(2);
        break;
      case StockTransactionType.transferIn:
        writer.writeByte(3);
        break;
      case StockTransactionType.transferOut:
        writer.writeByte(4);
        break;
      case StockTransactionType.returned:
        writer.writeByte(5);
        break;
      case StockTransactionType.damaged:
        writer.writeByte(6);
        break;
      case StockTransactionType.lost:
        writer.writeByte(7);
        break;
      case StockTransactionType.initialStock:
        writer.writeByte(8);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockTransactionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
