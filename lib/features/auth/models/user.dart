import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'user.g.dart';

// Enum for ID Status
@HiveType(typeId: 103) // Changed typeId from 100 to 103 to avoid conflict
enum IdStatus {
  @HiveField(0)
  PENDING,
  @HiveField(1)
  ACTIVE,
  @HiveField(2)
  BLOCKED,
  @HiveField(3)
  UNKNOWN
}

/// Modèle représentant un utilisateur de l'application
@HiveType(typeId: 0)
class User extends Equatable {
  /// Identifiant unique de l'utilisateur
  @HiveField(0)
  final String id;

  /// Nom de l'utilisateur
  @HiveField(1)
  final String name;

  /// Email de l'utilisateur
  @HiveField(2)
  final String email;

  /// Numéro de téléphone de l'utilisateur
  @HiveField(3)
  final String phone;

  /// Rôle de l'utilisateur dans l'entreprise
  @HiveField(4)
  final String role;

  /// Token d'authentification
  @HiveField(5)
  final String token;

  /// URL de l'image de profil
  @HiveField(6)
  final String? picture;

  /// Fonction dans l'entreprise
  @HiveField(7)
  final String? jobTitle;

  /// Adresse physique
  @HiveField(8)
  final String? physicalAddress;

  /// Informations de la carte d'identité
  @HiveField(9)
  final String? idCard;

  /// Statut de la carte d'identité
  @HiveField(10)
  final IdStatus idCardStatus; // Changed to non-nullable, defaulting to UNKNOWN

  /// Raison du statut de la carte d'identité (si applicable)
  @HiveField(11)
  final String? idCardStatusReason;

  /// Constructeur
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.token,
    this.picture,
    this.jobTitle,
    this.physicalAddress,
    this.idCard,
    this.idCardStatus = IdStatus.UNKNOWN, // Default value
    this.idCardStatusReason,
  });

  /// Constructeur vide pour représenter un utilisateur non connecté
  factory User.empty() {
    return const User(
      id: '',
      name: '',
      email: '',
      phone: '',
      role: '',
      token: '',
      jobTitle: '',
      physicalAddress: '',
      idCard: '',
      idCardStatus: IdStatus.UNKNOWN,
      idCardStatusReason: '',
    );
  }

  /// Transforme un JSON en objet User
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      role: json['role'] as String,
      token: json['token'] as String,
      picture: json['picture'] as String?,
      jobTitle: json['jobTitle'] as String?,
      physicalAddress: json['physicalAddress'] as String?,
      idCard: json['idCard'] as String?,
      idCardStatus: json['idCardStatus'] != null
          ? IdStatus.values.firstWhere(
              (e) => e.toString() == json['idCardStatus'],
              orElse: () => IdStatus.UNKNOWN)
          : IdStatus.UNKNOWN,
      idCardStatusReason: json['idCardStatusReason'] as String?,
    );
  }

  /// Transforme l'objet User en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'token': token,
      'picture': picture,
      'jobTitle': jobTitle,
      'physicalAddress': physicalAddress,
      'idCard': idCard,
      'idCardStatus': idCardStatus.toString(), // Store enum as string
      'idCardStatusReason': idCardStatusReason,
    };
  }

  /// Crée une copie de l'objet User avec des propriétés modifiées
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
        idCardStatusReason
      ];
}
