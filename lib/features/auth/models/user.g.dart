// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 0;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      id: fields[0] as String,
      name: fields[1] as String,
      email: fields[2] as String,
      phone: fields[3] as String,
      role: fields[4] as String,
      token: fields[5] as String?,
      picture: fields[6] as String?,
      jobTitle: fields[7] as String?,
      physicalAddress: fields[8] as String?,
      idCard: fields[9] as String?,
      idCardStatus: fields[10] as IdStatus?,
      idCardStatusReason: fields[11] as String?,
      companyId: fields[12] as String?,
      companyName: fields[13] as String?,
      rccmNumber: fields[14] as String?,
      companyLocation: fields[15] as String?,
      businessSector: fields[16] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.phone)
      ..writeByte(4)
      ..write(obj.role)
      ..writeByte(5)
      ..write(obj.token)
      ..writeByte(6)
      ..write(obj.picture)
      ..writeByte(7)
      ..write(obj.jobTitle)
      ..writeByte(8)
      ..write(obj.physicalAddress)
      ..writeByte(9)
      ..write(obj.idCard)
      ..writeByte(10)
      ..write(obj.idCardStatus)
      ..writeByte(11)
      ..write(obj.idCardStatusReason)
      ..writeByte(12)
      ..write(obj.companyId)
      ..writeByte(13)
      ..write(obj.companyName)
      ..writeByte(14)
      ..write(obj.rccmNumber)
      ..writeByte(15)
      ..write(obj.companyLocation)
      ..writeByte(16)
      ..write(obj.businessSector);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class IdStatusAdapter extends TypeAdapter<IdStatus> {
  @override
  final int typeId = 1;

  @override
  IdStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return IdStatus.PENDING;
      case 1:
        return IdStatus.VERIFIED;
      case 2:
        return IdStatus.REJECTED;
      case 3:
        return IdStatus.UNKNOWN;
      default:
        return IdStatus.PENDING;
    }
  }

  @override
  void write(BinaryWriter writer, IdStatus obj) {
    switch (obj) {
      case IdStatus.PENDING:
        writer.writeByte(0);
        break;
      case IdStatus.VERIFIED:
        writer.writeByte(1);
        break;
      case IdStatus.REJECTED:
        writer.writeByte(2);
        break;
      case IdStatus.UNKNOWN:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IdStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      role: json['role'] as String,
      token: json['token'] as String?,
      picture: json['picture'] as String?,
      jobTitle: json['job_title'] as String?,
      physicalAddress: json['physical_address'] as String?,
      idCard: json['id_card'] as String?,
      idCardStatus: _idStatusFromJson(json['id_card_status'] as String?),
      idCardStatusReason: json['id_card_status_reason'] as String?,
      companyId: json['company_id'] as String?,
      companyName: json['company_name'] as String?,
      rccmNumber: json['rccm_number'] as String?,
      companyLocation: json['company_location'] as String?,
      businessSector: json['business_sector'] as String?,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'role': instance.role,
      if (instance.token case final value?) 'token': value,
      if (instance.picture case final value?) 'picture': value,
      if (instance.jobTitle case final value?) 'job_title': value,
      if (instance.physicalAddress case final value?) 'physical_address': value,
      if (instance.idCard case final value?) 'id_card': value,
      if (_idStatusToString(instance.idCardStatus) case final value?)
        'id_card_status': value,
      if (instance.idCardStatusReason case final value?)
        'id_card_status_reason': value,
      if (instance.companyId case final value?) 'company_id': value,
      if (instance.companyName case final value?) 'company_name': value,
      if (instance.rccmNumber case final value?) 'rccm_number': value,
      if (instance.companyLocation case final value?) 'company_location': value,
      if (instance.businessSector case final value?) 'business_sector': value,
    };
