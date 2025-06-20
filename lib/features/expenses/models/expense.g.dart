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
      motif: fields[2] as String,
      amount: fields[3] as double,
      category: fields[4] as ExpenseCategory,
      paymentMethod: fields[5] as String?,
      attachmentUrls: (fields[6] as List?)?.cast<String>(),
      supplierId: fields[7] as String?,
      currencyCode: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Expense obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.motif)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.paymentMethod)
      ..writeByte(6)
      ..write(obj.attachmentUrls)
      ..writeByte(7)
      ..write(obj.supplierId)
      ..writeByte(8)
      ..write(obj.currencyCode);
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

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Expense _$ExpenseFromJson(Map<String, dynamic> json) => Expense(
      id: json['id'] as String,
      localId: json['localId'] as String?,
      date: DateTime.parse(json['date'] as String),
      motif: json['motif'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: $enumDecode(_$ExpenseCategoryEnumMap, json['category']),
      paymentMethod: json['paymentMethod'] as String?,
      attachmentUrls: (json['attachmentUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      supplierId: json['supplierId'] as String?,
      beneficiary: json['beneficiary'] as String?,
      notes: json['notes'] as String?,
      currencyCode: json['currencyCode'] as String?,
      userId: json['userId'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ExpenseToJson(Expense instance) => <String, dynamic>{
      'id': instance.id,
      if (instance.localId case final value?) 'localId': value,
      'date': instance.date.toIso8601String(),
      'motif': instance.motif,
      'amount': instance.amount,
      'category': _$ExpenseCategoryEnumMap[instance.category]!,
      if (instance.paymentMethod case final value?) 'paymentMethod': value,
      if (instance.attachmentUrls case final value?) 'attachmentUrls': value,
      if (instance.supplierId case final value?) 'supplierId': value,
      if (instance.beneficiary case final value?) 'beneficiary': value,
      if (instance.notes case final value?) 'notes': value,
      if (instance.userId case final value?) 'userId': value,
      if (instance.createdAt?.toIso8601String() case final value?)
        'createdAt': value,
      if (instance.updatedAt?.toIso8601String() case final value?)
        'updatedAt': value,
      if (instance.currencyCode case final value?) 'currencyCode': value,
    };

const _$ExpenseCategoryEnumMap = {
  ExpenseCategory.rent: 'rent',
  ExpenseCategory.utilities: 'utilities',
  ExpenseCategory.supplies: 'supplies',
  ExpenseCategory.salaries: 'salaries',
  ExpenseCategory.marketing: 'marketing',
  ExpenseCategory.transport: 'transport',
  ExpenseCategory.maintenance: 'maintenance',
  ExpenseCategory.other: 'other',
};
