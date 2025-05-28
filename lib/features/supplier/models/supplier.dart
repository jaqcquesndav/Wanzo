import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'supplier.g.dart';

/// Modèle de données pour un fournisseur
@HiveType(typeId: 38)
@JsonSerializable(explicitToJson: true)
class Supplier extends Equatable {
  /// Identifiant unique du fournisseur
  @HiveField(0)
  final String id;

  /// Nom du fournisseur
  @HiveField(1)
  final String name;

  /// Numéro de téléphone du fournisseur
  @HiveField(2)
  final String phoneNumber;

  /// Adresse email du fournisseur
  @HiveField(3)
  final String email;

  /// Adresse physique du fournisseur
  @HiveField(4)
  final String address;

  /// Personne à contacter chez le fournisseur
  @HiveField(5)
  final String contactPerson;

  /// Date de création du fournisseur dans le système
  @HiveField(6)
  final DateTime createdAt;

  /// Notes ou informations supplémentaires sur le fournisseur
  @HiveField(7)
  final String notes;

  /// Total des achats effectués auprès de ce fournisseur (en francs congolais - FC)
  @HiveField(8)
  final double totalPurchases;

  /// Date du dernier achat auprès de ce fournisseur
  @HiveField(9)
  final DateTime? lastPurchaseDate;

  /// Catégorie du fournisseur
  @HiveField(10)
  final SupplierCategory category;

  /// Délai de livraison moyen (en jours)
  @HiveField(11)
  final int deliveryTimeInDays;

  /// Termes de paiement avec ce fournisseur (ex: "Net 30")
  @HiveField(12)
  final String paymentTerms;

  const Supplier({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.email = '',
    this.address = '',
    this.contactPerson = '',
    required this.createdAt,
    this.notes = '',
    this.totalPurchases = 0.0,
    this.lastPurchaseDate,
    this.category = SupplierCategory.regular,
    this.deliveryTimeInDays = 0,
    this.paymentTerms = '',
  });

  factory Supplier.fromJson(Map<String, dynamic> json) => _$SupplierFromJson(json);
  Map<String, dynamic> toJson() => _$SupplierToJson(this);

  /// Crée une copie du fournisseur avec des valeurs modifiées
  Supplier copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? email,
    String? address,
    String? contactPerson,
    DateTime? createdAt,
    String? notes,
    double? totalPurchases,
    DateTime? lastPurchaseDate,
    SupplierCategory? category,
    int? deliveryTimeInDays,
    String? paymentTerms,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      address: address ?? this.address,
      contactPerson: contactPerson ?? this.contactPerson,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
      totalPurchases: totalPurchases ?? this.totalPurchases,
      lastPurchaseDate: lastPurchaseDate ?? this.lastPurchaseDate,
      category: category ?? this.category,
      deliveryTimeInDays: deliveryTimeInDays ?? this.deliveryTimeInDays,
      paymentTerms: paymentTerms ?? this.paymentTerms,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        phoneNumber,
        email,
        address,
        contactPerson,
        createdAt,
        notes,
        totalPurchases,
        lastPurchaseDate,
        category,
        deliveryTimeInDays,
        paymentTerms,
      ];
}

/// Catégories de fournisseurs
@HiveType(typeId: 39)
@JsonEnum()
enum SupplierCategory {
  /// Fournisseur principal ou stratégique
  @HiveField(0)
  strategic,

  /// Fournisseur régulier
  @HiveField(1)
  regular,
  /// Nouveau fournisseur
  @HiveField(2)
  newSupplier,

  /// Fournisseur occasionnel
  @HiveField(3)
  occasional,

  /// Fournisseur local
  @HiveField(4)
  local,

  /// Fournisseur international
  @HiveField(5)
  international,

  /// Fournisseur en ligne
  @HiveField(6)
  online
}
