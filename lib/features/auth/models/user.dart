import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'user.g.dart';

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

  /// Constructeur
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.token,
    this.picture,
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
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      token: token ?? this.token,
    );
  }

  @override
  List<Object?> get props => [id, name, email, phone, role, token];
}
