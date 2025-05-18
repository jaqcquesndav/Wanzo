import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'customer.g.dart';

/// Modèle de données pour un client
@HiveType(typeId: 3)
class Customer extends Equatable {
  /// Identifiant unique du client
  @HiveField(0)
  final String id;

  /// Nom du client
  @HiveField(1)
  final String name;

  /// Numéro de téléphone du client
  @HiveField(2)
  final String phoneNumber;

  /// Adresse email du client
  @HiveField(3)
  final String? email; // Changed to nullable

  /// Adresse physique du client
  @HiveField(4)
  final String? address; // Changed to nullable

  /// Date de création du client dans le système
  @HiveField(5)
  final DateTime createdAt;

  /// Notes ou informations supplémentaires sur le client
  @HiveField(6)
  final String? notes; // Changed to nullable

  /// Historique d'achat total du client (en francs congolais - FC)
  @HiveField(7)
  final double totalPurchases;

  /// Date de dernier achat
  @HiveField(8)
  final DateTime? lastPurchaseDate;

  /// Catégorie du client (VIP, Régulier, etc.)
  @HiveField(9)
  final CustomerCategory category;

  const Customer({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.email, // No longer required, allow null
    this.address, // No longer required, allow null
    required this.createdAt,
    this.notes, // Allow null
    this.totalPurchases = 0.0,
    this.lastPurchaseDate,
    this.category = CustomerCategory.regular,
  });

  /// Crée une copie du client avec des valeurs modifiées
  Customer copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? email,
    String? address,
    DateTime? createdAt,
    String? notes,
    double? totalPurchases,
    DateTime? lastPurchaseDate,
    CustomerCategory? category,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
      totalPurchases: totalPurchases ?? this.totalPurchases,
      lastPurchaseDate: lastPurchaseDate ?? this.lastPurchaseDate,
      category: category ?? this.category,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        phoneNumber,
        email,
        address,
        createdAt,
        notes,
        totalPurchases,
        lastPurchaseDate,
        category,
      ];
}

/// Catégories de clients
@HiveType(typeId: 4)
enum CustomerCategory {
  /// Client VIP ou premium
  @HiveField(0)
  vip,

  /// Client régulier
  @HiveField(1)
  regular,

  /// Nouveau client
  @HiveField(2)
  new_customer,

  /// Client occasionnel
  @HiveField(3)
  occasional,

  /// Client B2B (Business to Business)
  @HiveField(4)
  business,
}
