// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SupplierAdapter extends TypeAdapter<Supplier> {
  @override
  final int typeId = 38;

  @override
  Supplier read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Supplier(
      id: fields[0] as String,
      name: fields[1] as String,
      phoneNumber: fields[2] as String,
      email: fields[3] as String,
      address: fields[4] as String,
      contactPerson: fields[5] as String,
      createdAt: fields[6] as DateTime,
      notes: fields[7] as String,
      totalPurchases: fields[8] as double,
      lastPurchaseDate: fields[9] as DateTime?,
      category: fields[10] as SupplierCategory,
      deliveryTimeInDays: fields[11] as int,
      paymentTerms: fields[12] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Supplier obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.phoneNumber)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.address)
      ..writeByte(5)
      ..write(obj.contactPerson)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.notes)
      ..writeByte(8)
      ..write(obj.totalPurchases)
      ..writeByte(9)
      ..write(obj.lastPurchaseDate)
      ..writeByte(10)
      ..write(obj.category)
      ..writeByte(11)
      ..write(obj.deliveryTimeInDays)
      ..writeByte(12)
      ..write(obj.paymentTerms);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupplierAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SupplierCategoryAdapter extends TypeAdapter<SupplierCategory> {
  @override
  final int typeId = 39;

  @override
  SupplierCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SupplierCategory.strategic;
      case 1:
        return SupplierCategory.regular;
      case 2:
        return SupplierCategory.newSupplier;
      case 3:
        return SupplierCategory.occasional;
      case 4:
        return SupplierCategory.international;
      default:
        return SupplierCategory.strategic;
    }
  }

  @override
  void write(BinaryWriter writer, SupplierCategory obj) {
    switch (obj) {
      case SupplierCategory.strategic:
        writer.writeByte(0);
        break;
      case SupplierCategory.regular:
        writer.writeByte(1);
        break;
      case SupplierCategory.newSupplier:
        writer.writeByte(2);
        break;
      case SupplierCategory.occasional:
        writer.writeByte(3);
        break;
      case SupplierCategory.international:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupplierCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Supplier _$SupplierFromJson(Map<String, dynamic> json) => Supplier(
      id: json['id'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String? ?? '',
      address: json['address'] as String? ?? '',
      contactPerson: json['contactPerson'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      notes: json['notes'] as String? ?? '',
      totalPurchases: (json['totalPurchases'] as num?)?.toDouble() ?? 0.0,
      lastPurchaseDate: json['lastPurchaseDate'] == null
          ? null
          : DateTime.parse(json['lastPurchaseDate'] as String),
      category:
          $enumDecodeNullable(_$SupplierCategoryEnumMap, json['category']) ??
              SupplierCategory.regular,
      deliveryTimeInDays: (json['deliveryTimeInDays'] as num?)?.toInt() ?? 0,
      paymentTerms: json['paymentTerms'] as String? ?? '',
    );

Map<String, dynamic> _$SupplierToJson(Supplier instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phoneNumber': instance.phoneNumber,
      'email': instance.email,
      'address': instance.address,
      'contactPerson': instance.contactPerson,
      'createdAt': instance.createdAt.toIso8601String(),
      'notes': instance.notes,
      'totalPurchases': instance.totalPurchases,
      if (instance.lastPurchaseDate?.toIso8601String() case final value?)
        'lastPurchaseDate': value,
      'category': _$SupplierCategoryEnumMap[instance.category]!,
      'deliveryTimeInDays': instance.deliveryTimeInDays,
      'paymentTerms': instance.paymentTerms,
    };

const _$SupplierCategoryEnumMap = {
  SupplierCategory.strategic: 'strategic',
  SupplierCategory.regular: 'regular',
  SupplierCategory.newSupplier: 'newSupplier',
  SupplierCategory.occasional: 'occasional',
  SupplierCategory.international: 'international',
};
