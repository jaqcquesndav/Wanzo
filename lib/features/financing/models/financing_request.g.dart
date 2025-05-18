// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'financing_request.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FinancingRequestAdapter extends TypeAdapter<FinancingRequest> {
  @override
  final int typeId = 8;

  @override
  FinancingRequest read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FinancingRequest(
      id: fields[0] as String,
      amount: fields[1] as double,
      currency: fields[2] as String,
      reason: fields[3] as String,
      type: fields[4] as FinancingType,
      institution: fields[5] as FinancialInstitution,
      requestDate: fields[6] as DateTime,
      status: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, FinancingRequest obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.currency)
      ..writeByte(3)
      ..write(obj.reason)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.institution)
      ..writeByte(6)
      ..write(obj.requestDate)
      ..writeByte(7)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FinancingRequestAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FinancingTypeAdapter extends TypeAdapter<FinancingType> {
  @override
  final int typeId = 16;

  @override
  FinancingType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FinancingType.cashCredit;
      case 1:
        return FinancingType.investmentCredit;
      case 2:
        return FinancingType.leasing;
      default:
        return FinancingType.cashCredit;
    }
  }

  @override
  void write(BinaryWriter writer, FinancingType obj) {
    switch (obj) {
      case FinancingType.cashCredit:
        writer.writeByte(0);
        break;
      case FinancingType.investmentCredit:
        writer.writeByte(1);
        break;
      case FinancingType.leasing:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FinancingTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FinancialInstitutionAdapter extends TypeAdapter<FinancialInstitution> {
  @override
  final int typeId = 9;

  @override
  FinancialInstitution read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FinancialInstitution.bonneMoisson;
      case 1:
        return FinancialInstitution.tid;
      case 2:
        return FinancialInstitution.smico;
      case 3:
        return FinancialInstitution.tmb;
      case 4:
        return FinancialInstitution.equitybcdc;
      default:
        return FinancialInstitution.bonneMoisson;
    }
  }

  @override
  void write(BinaryWriter writer, FinancialInstitution obj) {
    switch (obj) {
      case FinancialInstitution.bonneMoisson:
        writer.writeByte(0);
        break;
      case FinancialInstitution.tid:
        writer.writeByte(1);
        break;
      case FinancialInstitution.smico:
        writer.writeByte(2);
        break;
      case FinancialInstitution.tmb:
        writer.writeByte(3);
        break;
      case FinancialInstitution.equitybcdc:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FinancialInstitutionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
