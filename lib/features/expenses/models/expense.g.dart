// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExpenseAdapter extends TypeAdapter<Expense> {
  @override
  final int typeId = 11;

  @override
  Expense read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Expense(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      description: fields[2] as String,
      amount: fields[3] as double,
      category: fields[4] as ExpenseCategory,
      paymentMethod: fields[5] as String?,
      relatedDocumentId: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Expense obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.paymentMethod)
      ..writeByte(6)
      ..write(obj.relatedDocumentId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExpenseCategoryAdapter extends TypeAdapter<ExpenseCategory> {
  @override
  final int typeId = 10;

  @override
  ExpenseCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ExpenseCategory.rent;
      case 1:
        return ExpenseCategory.utilities;
      case 2:
        return ExpenseCategory.supplies;
      case 3:
        return ExpenseCategory.salaries;
      case 4:
        return ExpenseCategory.marketing;
      case 5:
        return ExpenseCategory.transport;
      case 6:
        return ExpenseCategory.maintenance;
      case 7:
        return ExpenseCategory.other;
      default:
        return ExpenseCategory.rent;
    }
  }

  @override
  void write(BinaryWriter writer, ExpenseCategory obj) {
    switch (obj) {
      case ExpenseCategory.rent:
        writer.writeByte(0);
        break;
      case ExpenseCategory.utilities:
        writer.writeByte(1);
        break;
      case ExpenseCategory.supplies:
        writer.writeByte(2);
        break;
      case ExpenseCategory.salaries:
        writer.writeByte(3);
        break;
      case ExpenseCategory.marketing:
        writer.writeByte(4);
        break;
      case ExpenseCategory.transport:
        writer.writeByte(5);
        break;
      case ExpenseCategory.maintenance:
        writer.writeByte(6);
        break;
      case ExpenseCategory.other:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
