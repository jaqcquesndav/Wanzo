// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductAdapter extends TypeAdapter<Product> {
  @override
  final int typeId = 22;

  @override
  Product read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Product(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      barcode: fields[3] as String,
      category: fields[4] as ProductCategory,
      costPrice: fields[5] as double,
      sellingPrice: fields[6] as double,
      stockQuantity: fields[7] as double,
      unit: fields[8] as ProductUnit,
      alertThreshold: fields[9] as double,
      createdAt: fields[10] as DateTime,
      updatedAt: fields[11] as DateTime,
      imagePath: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.barcode)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.costPrice)
      ..writeByte(6)
      ..write(obj.sellingPrice)
      ..writeByte(7)
      ..write(obj.stockQuantity)
      ..writeByte(8)
      ..write(obj.unit)
      ..writeByte(9)
      ..write(obj.alertThreshold)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt)
      ..writeByte(12)
      ..write(obj.imagePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProductCategoryAdapter extends TypeAdapter<ProductCategory> {
  @override
  final int typeId = 20;

  @override
  ProductCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ProductCategory.food;
      case 1:
        return ProductCategory.drink;
      case 2:
        return ProductCategory.electronics;
      case 3:
        return ProductCategory.clothing;
      case 4:
        return ProductCategory.household;
      case 5:
        return ProductCategory.hygiene;
      case 6:
        return ProductCategory.office;
      case 7:
        return ProductCategory.other;
      default:
        return ProductCategory.food;
    }
  }

  @override
  void write(BinaryWriter writer, ProductCategory obj) {
    switch (obj) {
      case ProductCategory.food:
        writer.writeByte(0);
        break;
      case ProductCategory.drink:
        writer.writeByte(1);
        break;
      case ProductCategory.electronics:
        writer.writeByte(2);
        break;
      case ProductCategory.clothing:
        writer.writeByte(3);
        break;
      case ProductCategory.household:
        writer.writeByte(4);
        break;
      case ProductCategory.hygiene:
        writer.writeByte(5);
        break;
      case ProductCategory.office:
        writer.writeByte(6);
        break;
      case ProductCategory.other:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProductUnitAdapter extends TypeAdapter<ProductUnit> {
  @override
  final int typeId = 21;

  @override
  ProductUnit read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ProductUnit.piece;
      case 1:
        return ProductUnit.kg;
      case 2:
        return ProductUnit.g;
      case 3:
        return ProductUnit.l;
      case 4:
        return ProductUnit.ml;
      case 5:
        return ProductUnit.package;
      case 6:
        return ProductUnit.box;
      case 7:
        return ProductUnit.other;
      default:
        return ProductUnit.piece;
    }
  }

  @override
  void write(BinaryWriter writer, ProductUnit obj) {
    switch (obj) {
      case ProductUnit.piece:
        writer.writeByte(0);
        break;
      case ProductUnit.kg:
        writer.writeByte(1);
        break;
      case ProductUnit.g:
        writer.writeByte(2);
        break;
      case ProductUnit.l:
        writer.writeByte(3);
        break;
      case ProductUnit.ml:
        writer.writeByte(4);
        break;
      case ProductUnit.package:
        writer.writeByte(5);
        break;
      case ProductUnit.box:
        writer.writeByte(6);
        break;
      case ProductUnit.other:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductUnitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      barcode: json['barcode'] as String? ?? '',
      category: $enumDecode(_$ProductCategoryEnumMap, json['category']),
      costPrice: (json['costPrice'] as num).toDouble(),
      sellingPrice: (json['sellingPrice'] as num).toDouble(),
      stockQuantity: (json['stockQuantity'] as num).toDouble(),
      unit: $enumDecode(_$ProductUnitEnumMap, json['unit']),
      alertThreshold: (json['alertThreshold'] as num?)?.toDouble() ?? 5,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      imagePath: json['imagePath'] as String?,
    );

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'barcode': instance.barcode,
      'category': _$ProductCategoryEnumMap[instance.category]!,
      'costPrice': instance.costPrice,
      'sellingPrice': instance.sellingPrice,
      'stockQuantity': instance.stockQuantity,
      'unit': _$ProductUnitEnumMap[instance.unit]!,
      'alertThreshold': instance.alertThreshold,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      if (instance.imagePath case final value?) 'imagePath': value,
    };

const _$ProductCategoryEnumMap = {
  ProductCategory.food: 'food',
  ProductCategory.drink: 'drink',
  ProductCategory.electronics: 'electronics',
  ProductCategory.clothing: 'clothing',
  ProductCategory.household: 'household',
  ProductCategory.hygiene: 'hygiene',
  ProductCategory.office: 'office',
  ProductCategory.other: 'other',
};

const _$ProductUnitEnumMap = {
  ProductUnit.piece: 'piece',
  ProductUnit.kg: 'kg',
  ProductUnit.g: 'g',
  ProductUnit.l: 'l',
  ProductUnit.ml: 'ml',
  ProductUnit.package: 'package',
  ProductUnit.box: 'box',
  ProductUnit.other: 'other',
};
