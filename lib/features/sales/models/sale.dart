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
  final List<SaleItem> items;
  
  /// Montant total de la vente en CDF
  @HiveField(5)
  final double totalAmountInCdf;
  
  /// Montant payé en CDF
  @HiveField(6)
  final double paidAmountInCdf;
  
  /// Mode de paiement
  @HiveField(7)
  final String paymentMethod;
  
  /// Statut de la vente
  @HiveField(8)
  final SaleStatus status;
  
  /// Note ou commentaire sur la vente
  @HiveField(9)
  final String notes;

  /// Code de la devise de la transaction (par exemple, "USD", "CDF")
  @HiveField(10)
  final String transactionCurrencyCode;

  /// Taux de change vers CDF au moment de la transaction
  /// (Si transactionCurrencyCode est "CDF", exchangeRate est 1.0)
  @HiveField(11)
  final double transactionExchangeRate;

  /// Montant total dans la devise de la transaction
  @HiveField(12)
  final double totalAmountInTransactionCurrency;

  /// Montant payé dans la devise de la transaction
  @HiveField(13)
  final double paidAmountInTransactionCurrency;

  /// Constructeur
  const Sale({
    required this.id,
    required this.date,
    required this.customerId,
    required this.customerName,
    required this.items,
    required this.totalAmountInCdf,
    required this.paidAmountInCdf,
    required this.paymentMethod,
    required this.status,
    this.notes = '',
    required this.transactionCurrencyCode,
    required this.transactionExchangeRate,
    required this.totalAmountInTransactionCurrency,
    required this.paidAmountInTransactionCurrency,
  });

  factory Sale.fromJson(Map<String, dynamic> json) => _$SaleFromJson(json);
  Map<String, dynamic> toJson() => _$SaleToJson(this);

  /// Vérifier si la vente est entièrement payée (basé sur les montants en CDF)
  bool get isFullyPaid => paidAmountInCdf >= totalAmountInCdf;
  
  /// Montant restant à payer (en CDF)
  double get remainingAmountInCdf => totalAmountInCdf - paidAmountInCdf;

  /// Crée une copie de cette vente avec les données fournies remplaçant les données existantes
  Sale copyWith({
    String? id,
    DateTime? date,
    String? customerId,
    String? customerName,
    List<SaleItem>? items,
    double? totalAmountInCdf,
    double? paidAmountInCdf,
    String? paymentMethod,
    SaleStatus? status,
    String? notes,
    String? transactionCurrencyCode,
    double? transactionExchangeRate,
    double? totalAmountInTransactionCurrency,
    double? paidAmountInTransactionCurrency,
  }) {
    return Sale(
      id: id ?? this.id,
      date: date ?? this.date,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      items: items ?? this.items,
      totalAmountInCdf: totalAmountInCdf ?? this.totalAmountInCdf,
      paidAmountInCdf: paidAmountInCdf ?? this.paidAmountInCdf,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      transactionCurrencyCode: transactionCurrencyCode ?? this.transactionCurrencyCode,
      transactionExchangeRate: transactionExchangeRate ?? this.transactionExchangeRate,
      totalAmountInTransactionCurrency: totalAmountInTransactionCurrency ?? this.totalAmountInTransactionCurrency,
      paidAmountInTransactionCurrency: paidAmountInTransactionCurrency ?? this.paidAmountInTransactionCurrency,
    );
  }

  @override
  List<Object?> get props => [
    id, 
    date, 
    customerId, 
    customerName, 
    items, 
    totalAmountInCdf, 
    paidAmountInCdf,
    paymentMethod,
    status,
    notes,
    transactionCurrencyCode,
    transactionExchangeRate,
    totalAmountInTransactionCurrency,
    paidAmountInTransactionCurrency,
  ];
}

// Removed the duplicate SaleItem class definition from here.
// The correct SaleItem model is in 'sale_item.dart' and has HiveType(typeId: 41).
