import 'package:hive/hive.dart';
import 'product.dart';

/// Adaptateur Hive pour la classe ProductCategory
class ProductCategoryAdapter extends TypeAdapter<ProductCategory> {
  @override
  final int typeId = 4;

  @override
  ProductCategory read(BinaryReader reader) {
    return ProductCategory.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, ProductCategory obj) {
    writer.writeByte(obj.index);
  }
}

/// Adaptateur Hive pour la classe ProductUnit
class ProductUnitAdapter extends TypeAdapter<ProductUnit> {
  @override
  final int typeId = 5;

  @override
  ProductUnit read(BinaryReader reader) {
    return ProductUnit.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, ProductUnit obj) {
    writer.writeByte(obj.index);
  }
}

/// Adaptateur Hive pour la classe Product
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
    writer.writeByte(12);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.name);
    writer.writeByte(2);
    writer.write(obj.description);
    writer.writeByte(3);
    writer.write(obj.barcode);
    writer.writeByte(4);
    writer.write(obj.category);
    writer.writeByte(5);
    writer.write(obj.costPrice);
    writer.writeByte(6);
    writer.write(obj.sellingPrice);
    writer.writeByte(7);
    writer.write(obj.stockQuantity);
    writer.writeByte(8);
    writer.write(obj.unit);
    writer.writeByte(9);
    writer.write(obj.alertThreshold);
    writer.writeByte(10);
    writer.write(obj.createdAt);
    writer.writeByte(11);
    writer.write(obj.updatedAt);
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

/// Adaptateur Hive pour la classe StockTransactionType
class StockTransactionTypeAdapter extends TypeAdapter<StockTransactionType> {
  @override
  final int typeId = 7;

  @override
  StockTransactionType read(BinaryReader reader) {
    return StockTransactionType.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, StockTransactionType obj) {
    writer.writeByte(obj.index);
  }
}

/// Adaptateur Hive pour la classe StockTransaction
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
    writer.writeByte(7);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.productId);
    writer.writeByte(2);
    writer.write(obj.type);
    writer.writeByte(3);
    writer.write(obj.quantity);
    writer.writeByte(4);
    writer.write(obj.date);
    writer.writeByte(5);
    writer.write(obj.referenceId);
    writer.writeByte(6);
    writer.write(obj.notes);
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
