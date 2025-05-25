// filepath: c:\Users\DevSpace\Flutter\wanzo\lib\features\sales\models\sale.dart
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import './sale_item.dart'; // Import SaleItem from its own file

part 'sale.g.dart';

/// Statut possible d'une vente
@HiveType(typeId: 6) // Keep existing typeId for SaleStatus
@JsonEnum()
enum SaleStatus {
  @HiveField(0)
  pending,    // En attente
  @HiveField(1)
  completed,  // Terminée
  @HiveField(2)
  cancelled,  // Annulée
  @HiveField(3) // Added new enum member
  partiallyPaid, // Partiellement payée
}

/// Modèle représentant une vente
@HiveType(typeId: 7) // Keep existing typeId for Sale
@JsonSerializable(explicitToJson: true)
class Sale extends Equatable {
  /// Identifiant unique de la vente
  @HiveField(0)
  final String id;
  
  /// Date de la vente
  @HiveField(1)
  final DateTime date;
  
  /// Identifiant du client
  @HiveField(2)
  final String customerId;
  
  /// Nom du client
  @HiveField(3)
  final String customerName;
  
  /// Liste des produits vendus
  @HiveField(4)
  final List<SaleItem> items; // This will now refer to the SaleItem from sale_item.dart
  
  /// Montant total de la vente
  @HiveField(5)
  final double totalAmount;
  
  /// Montant payé
  @HiveField(6)
  final double paidAmount;
  
  /// Mode de paiement
  @HiveField(7)
  final String paymentMethod;
  
  /// Statut de la vente
  @HiveField(8)
  final SaleStatus status;
  
  /// Note ou commentaire sur la vente
  @HiveField(9)
  final String notes;

  /// Constructeur
  const Sale({
    required this.id,
    required this.date,
    required this.customerId,
    required this.customerName,
    required this.items,
    required this.totalAmount,
    required this.paidAmount,
    required this.paymentMethod,
    required this.status,
    this.notes = '',
  });

  factory Sale.fromJson(Map<String, dynamic> json) => _$SaleFromJson(json);
  Map<String, dynamic> toJson() => _$SaleToJson(this);

  /// Vérifier si la vente est entièrement payée
  bool get isFullyPaid => paidAmount >= totalAmount;
  
  /// Montant restant à payer
  double get remainingAmount => totalAmount - paidAmount;

  /// Crée une copie de cette vente avec les données fournies remplaçant les données existantes
  Sale copyWith({
    String? id,
    DateTime? date,
    String? customerId,
    String? customerName,
    List<SaleItem>? items,
    double? totalAmount,
    double? paidAmount,
    String? paymentMethod,
    SaleStatus? status,
    String? notes,
  }) {
    return Sale(
      id: id ?? this.id,
      date: date ?? this.date,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
    id, 
    date, 
    customerId, 
    customerName, 
    items, 
    totalAmount, 
    paidAmount,
    paymentMethod,
    status,
    notes,
  ];
}

// Removed the duplicate SaleItem class definition from here.
// The correct SaleItem model is in 'sale_item.dart' and has HiveType(typeId: 41).
