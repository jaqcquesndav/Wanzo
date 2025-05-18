// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomerAdapter extends TypeAdapter<Customer> {
  @override
  final int typeId = 3;

  @override
  Customer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Customer(
      id: fields[0] as String,
      name: fields[1] as String,
      phoneNumber: fields[2] as String,
      email: fields[3] as String?,
      address: fields[4] as String?,
      createdAt: fields[5] as DateTime,
      notes: fields[6] as String?,
      totalPurchases: fields[7] as double,
      lastPurchaseDate: fields[8] as DateTime?,
      category: fields[9] as CustomerCategory,
    );
  }

  @override
  void write(BinaryWriter writer, Customer obj) {
    writer
      ..writeByte(10)
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
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.totalPurchases)
      ..writeByte(8)
      ..write(obj.lastPurchaseDate)
      ..writeByte(9)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CustomerCategoryAdapter extends TypeAdapter<CustomerCategory> {
  @override
  final int typeId = 4;

  @override
  CustomerCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CustomerCategory.vip;
      case 1:
        return CustomerCategory.regular;
      case 2:
        return CustomerCategory.new_customer;
      case 3:
        return CustomerCategory.occasional;
      case 4:
        return CustomerCategory.business;
      default:
        return CustomerCategory.vip;
    }
  }

  @override
  void write(BinaryWriter writer, CustomerCategory obj) {
    switch (obj) {
      case CustomerCategory.vip:
        writer.writeByte(0);
        break;
      case CustomerCategory.regular:
        writer.writeByte(1);
        break;
      case CustomerCategory.new_customer:
        writer.writeByte(2);
        break;
      case CustomerCategory.occasional:
        writer.writeByte(3);
        break;
      case CustomerCategory.business:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
