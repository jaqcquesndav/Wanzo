import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@HiveType(typeId: 1) // Consistent typeId for IdStatus
enum IdStatus {
  @HiveField(0)
  PENDING,
  @HiveField(1)
  VERIFIED,
  @HiveField(2)
  REJECTED,
  @HiveField(3)
  UNKNOWN,
}

// Helper for IdStatus JSON conversion
IdStatus _idStatusFromJson(String? statusString) {
  if (statusString == null) return IdStatus.UNKNOWN;
  switch (statusString.toLowerCase()) {
    case 'pending':
      return IdStatus.PENDING;
    case 'verified':
      return IdStatus.VERIFIED;
    case 'rejected':
      return IdStatus.REJECTED;
    default:
      return IdStatus.UNKNOWN;
  }
}

String? _idStatusToString(IdStatus? status) {
  if (status == null) return null;
  return status.toString().split('.').last.toUpperCase(); // Consistent with common API enum representation
}

/// Modèle représentant un utilisateur
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
@HiveType(typeId: 0)
class User extends Equatable {
  @HiveField(0)
  final String id; // Assuming API sends 'id', not 'sub' primarily.

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String phone; // API key will be 'phone_number' due to fieldRename

  @HiveField(4)
  final String role;

  @HiveField(5)
  final String? token;

  @HiveField(6)
  final String? picture;

  @HiveField(7)
  final String? jobTitle;

  @HiveField(8)
  final String? physicalAddress;

  @HiveField(9)
  final String? idCard;

  @HiveField(10)
  @JsonKey(fromJson: _idStatusFromJson, toJson: _idStatusToString)
  final IdStatus? idCardStatus;

  @HiveField(11)
  final String? idCardStatusReason;

  @HiveField(12)
  final String? companyId;

  @HiveField(13)
  final String? companyName;

  @HiveField(14)
  final String? rccmNumber;

  @HiveField(15)
  final String? companyLocation;

  @HiveField(16)
  final String? businessSector;

  @HiveField(17) // Ensure this HiveField index is unique and sequential
  final String? businessSectorId;

  @HiveField(18) // Ensure this HiveField index is unique and sequential
  final String? businessAddress;

  @HiveField(19) // Ensure this HiveField index is unique and sequential
  final String? businessLogoUrl;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.token,
    this.picture,
    this.jobTitle,
    this.physicalAddress,
    this.idCard,
    this.idCardStatus,
    this.idCardStatusReason,
    this.companyId,
    this.companyName,
    this.rccmNumber,
    this.companyLocation,
    this.businessSector,
    this.businessSectorId, // Added field
    this.businessAddress, // Added field
    this.businessLogoUrl, // Added field
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? token,
    String? picture,
    String? jobTitle,
    String? physicalAddress,
    String? idCard,
    IdStatus? idCardStatus,
    String? idCardStatusReason,
    String? companyId,
    String? companyName,
    String? rccmNumber,
    String? companyLocation,
    String? businessSector,
    String? businessSectorId, // Added parameter
    String? businessAddress, // Added parameter
    String? businessLogoUrl, // Added parameter
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      token: token ?? this.token,
      picture: picture ?? this.picture,
      jobTitle: jobTitle ?? this.jobTitle,
      physicalAddress: physicalAddress ?? this.physicalAddress,
      idCard: idCard ?? this.idCard,
      idCardStatus: idCardStatus ?? this.idCardStatus,
      idCardStatusReason: idCardStatusReason ?? this.idCardStatusReason,
      companyId: companyId ?? this.companyId,
      companyName: companyName ?? this.companyName,
      rccmNumber: rccmNumber ?? this.rccmNumber,
      companyLocation: companyLocation ?? this.companyLocation,
      businessSector: businessSector ?? this.businessSector,
      businessSectorId: businessSectorId ?? this.businessSectorId, // Added assignment
      businessAddress: businessAddress ?? this.businessAddress, // Added assignment
      businessLogoUrl: businessLogoUrl ?? this.businessLogoUrl, // Added assignment
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        role,
        token,
        picture,
        jobTitle,
        physicalAddress,
        idCard,
        idCardStatus,
        idCardStatusReason,
        companyId,
        companyName,
        rccmNumber,
        companyLocation,
        businessSector,
        businessSectorId, // Added to props
        businessAddress, // Added to props
        businessLogoUrl, // Added to props
      ];

  // Helper method for Adha businessProfile context
  Map<String, dynamic> toBusinessProfileContext() {
    return {
      'businessName': companyName ?? name, // Fallback to user name if company name is not set
      'businessSector': businessSector, // This is a string name, consider using businessSectorId if an ID is preferred by backend
      'businessSectorId': businessSectorId,
      'businessAddress': businessAddress ?? companyLocation ?? physicalAddress, // Fallback strategy for address
      'rccmNumber': rccmNumber,
      'businessLogoUrl': businessLogoUrl,
      // Add any other fields from User model that are relevant to businessProfile as per API_DOCUMENTATION.md
    };
  }
}
