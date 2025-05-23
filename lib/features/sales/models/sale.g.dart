// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SaleAdapter extends TypeAdapter<Sale> {
  @override
  final int typeId = 7;

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
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.customerId)
      ..writeByte(3)
      ..write(obj.customerName)
      ..writeByte(4)
      ..write(obj.items)
      ..writeByte(5)
      ..write(obj.totalAmount)
      ..writeByte(6)
      ..write(obj.paidAmount)
      ..writeByte(7)
      ..write(obj.paymentMethod)
      ..writeByte(8)
      ..write(obj.status)
      ..writeByte(9)
      ..write(obj.notes);
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

class SaleStatusAdapter extends TypeAdapter<SaleStatus> {
  @override
  final int typeId = 6;

  @override
  SaleStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SaleStatus.pending;
      case 1:
        return SaleStatus.completed;
      case 2:
        return SaleStatus.cancelled;
      default:
        return SaleStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, SaleStatus obj) {
    switch (obj) {
      case SaleStatus.pending:
        writer.writeByte(0);
        break;
      case SaleStatus.completed:
        writer.writeByte(1);
        break;
      case SaleStatus.cancelled:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaleStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Sale _$SaleFromJson(Map<String, dynamic> json) => Sale(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => SaleItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      paidAmount: (json['paidAmount'] as num).toDouble(),
      paymentMethod: json['paymentMethod'] as String,
      status: $enumDecode(_$SaleStatusEnumMap, json['status']),
      notes: json['notes'] as String? ?? '',
    );

Map<String, dynamic> _$SaleToJson(Sale instance) => <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'customerId': instance.customerId,
      'customerName': instance.customerName,
      'items': instance.items.map((e) => e.toJson()).toList(),
      'totalAmount': instance.totalAmount,
      'paidAmount': instance.paidAmount,
      'paymentMethod': instance.paymentMethod,
      'status': _$SaleStatusEnumMap[instance.status]!,
      'notes': instance.notes,
    };

const _$SaleStatusEnumMap = {
  SaleStatus.pending: 'pending',
  SaleStatus.completed: 'completed',
  SaleStatus.cancelled: 'cancelled',
};
