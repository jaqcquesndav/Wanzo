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
      approvalDate: fields[8] as DateTime?,
      disbursementDate: fields[9] as DateTime?,
      scheduledPayments: (fields[10] as List?)?.cast<DateTime>(),
      completedPayments: (fields[11] as List?)?.cast<DateTime>(),
      notes: fields[12] as String?,
      interestRate: fields[13] as double?,
      termMonths: fields[14] as int?,
      monthlyPayment: fields[15] as double?,
      attachmentPaths: (fields[16] as List?)?.cast<String>(),
      financialProduct: fields[17] as FinancialProduct?,
      leasingCode: fields[18] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FinancingRequest obj) {
    writer
      ..writeByte(19)
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
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.approvalDate)
      ..writeByte(9)
      ..write(obj.disbursementDate)
      ..writeByte(10)
      ..write(obj.scheduledPayments)
      ..writeByte(11)
      ..write(obj.completedPayments)
      ..writeByte(12)
      ..write(obj.notes)
      ..writeByte(13)
      ..write(obj.interestRate)
      ..writeByte(14)
      ..write(obj.termMonths)
      ..writeByte(15)
      ..write(obj.monthlyPayment)
      ..writeByte(16)
      ..write(obj.attachmentPaths)
      ..writeByte(17)
      ..write(obj.financialProduct)
      ..writeByte(18)
      ..write(obj.leasingCode);
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
      case 3:
        return FinancingType.productionInputs;
      case 4:
        return FinancingType.merchandise;
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
      case FinancingType.productionInputs:
        writer.writeByte(3);
        break;
      case FinancingType.merchandise:
        writer.writeByte(4);
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
      case 5:
        return FinancialInstitution.wanzoPass;
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
      case FinancialInstitution.wanzoPass:
        writer.writeByte(5);
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

class FinancialProductAdapter extends TypeAdapter<FinancialProduct> {
  @override
  final int typeId = 17;

  @override
  FinancialProduct read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FinancialProduct.cashFlow;
      case 1:
        return FinancialProduct.investment;
      case 2:
        return FinancialProduct.equipment;
      case 3:
        return FinancialProduct.agricultural;
      case 4:
        return FinancialProduct.commercialGoods;
      default:
        return FinancialProduct.cashFlow;
    }
  }

  @override
  void write(BinaryWriter writer, FinancialProduct obj) {
    switch (obj) {
      case FinancialProduct.cashFlow:
        writer.writeByte(0);
        break;
      case FinancialProduct.investment:
        writer.writeByte(1);
        break;
      case FinancialProduct.equipment:
        writer.writeByte(2);
        break;
      case FinancialProduct.agricultural:
        writer.writeByte(3);
        break;
      case FinancialProduct.commercialGoods:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FinancialProductAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
