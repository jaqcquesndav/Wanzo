// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductAdapter extends TypeAdapter<Product> {
  @override
  final int typeId = 6;

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
    );
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    writer
      ..writeByte(12)
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
      ..write(obj.updatedAt);
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

class StockTransactionAdapter extends TypeAdapter<StockTransaction> {
  @override
  final int typeId = 8;

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
      referenceId: fields[5] as String,
      notes: fields[6] as String,
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

class ProductCategoryAdapter extends TypeAdapter<ProductCategory> {
  @override
  final int typeId = 4;

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
  final int typeId = 5;

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

class StockTransactionTypeAdapter extends TypeAdapter<StockTransactionType> {
  @override
  final int typeId = 7;

  @override
  StockTransactionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return StockTransactionType.purchase;
      case 1:
        return StockTransactionType.sale;
      case 2:
        return StockTransactionType.return_in;
      case 3:
        return StockTransactionType.return_out;
      case 4:
        return StockTransactionType.adjustment;
      case 5:
        return StockTransactionType.transfer;
      case 6:
        return StockTransactionType.loss;
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
      case StockTransactionType.return_in:
        writer.writeByte(2);
        break;
      case StockTransactionType.return_out:
        writer.writeByte(3);
        break;
      case StockTransactionType.adjustment:
        writer.writeByte(4);
        break;
      case StockTransactionType.transfer:
        writer.writeByte(5);
        break;
      case StockTransactionType.loss:
        writer.writeByte(6);
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
