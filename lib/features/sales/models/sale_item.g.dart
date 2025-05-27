// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SaleItemAdapter extends TypeAdapter<SaleItem> {
  @override
  final int typeId = 41;

  @override
  SaleItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SaleItem(
      productId: fields[0] as String,
      productName: fields[1] as String,
      quantity: fields[2] as int,
      unitPrice: fields[3] as double,
      totalPrice: fields[4] as double,
      currencyCode: fields[5] as String,
      exchangeRate: fields[6] as double,
      unitPriceInCdf: fields[7] as double,
      totalPriceInCdf: fields[8] as double,
    );
  }

  @override
  void write(BinaryWriter writer, SaleItem obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.productId)
      ..writeByte(1)
      ..write(obj.productName)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.unitPrice)
      ..writeByte(4)
      ..write(obj.totalPrice)
      ..writeByte(5)
      ..write(obj.currencyCode)
      ..writeByte(6)
      ..write(obj.exchangeRate)
      ..writeByte(7)
      ..write(obj.unitPriceInCdf)
      ..writeByte(8)
      ..write(obj.totalPriceInCdf);
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

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SaleItem _$SaleItemFromJson(Map<String, dynamic> json) => SaleItem(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      currencyCode: json['currencyCode'] as String,
      exchangeRate: (json['exchangeRate'] as num).toDouble(),
      unitPriceInCdf: (json['unitPriceInCdf'] as num).toDouble(),
      totalPriceInCdf: (json['totalPriceInCdf'] as num).toDouble(),
    );

Map<String, dynamic> _$SaleItemToJson(SaleItem instance) => <String, dynamic>{
      'productId': instance.productId,
      'productName': instance.productName,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
      'totalPrice': instance.totalPrice,
      'currencyCode': instance.currencyCode,
      'exchangeRate': instance.exchangeRate,
      'unitPriceInCdf': instance.unitPriceInCdf,
      'totalPriceInCdf': instance.totalPriceInCdf,
    };
