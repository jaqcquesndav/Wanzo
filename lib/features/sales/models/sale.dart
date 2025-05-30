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
  /// Identifiant unique de la vente (généré par le serveur)
  @HiveField(0)
  final String id;

  /// Identifiant unique local (généré sur l'appareil)
  @JsonKey(includeIfNull: false) // Ne pas inclure dans le JSON vers le serveur si nul
  final String? localId;

  /// Date de la vente
  @HiveField(1)
  final DateTime date;

  /// Date d'échéance
  @JsonKey(includeIfNull: false)
  final DateTime? dueDate;

  /// Identifiant du client
  @HiveField(2)
  final String? customerId; // Rendu optionnel, car peut ne pas être là si client non sauvegardé

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

  /// Montant total de la vente en USD (si applicable)
  @JsonKey(includeIfNull: false)
  final double? totalAmountInUsd;

  /// Montant payé en USD (si applicable)
  @JsonKey(includeIfNull: false)
  final double? paidAmountInUsd;

  /// Mode de paiement
  @HiveField(7)
  final String? paymentMethod;

  /// Statut de la vente
  @HiveField(8)
  final SaleStatus status;

  /// Numéro de facture
  @JsonKey(includeIfNull: false)
  final String? invoiceNumber;

  /// Note ou commentaire sur la vente
  @HiveField(9)
  final String? notes; // Rendu nullable

  /// Code de la devise de la transaction (par exemple, "USD", "CDF")
  @HiveField(10)
  final String? transactionCurrencyCode; // Rendu nullable

  /// Taux de change vers CDF au moment de la transaction
  @HiveField(11)
  final double? transactionExchangeRate; // Rendu nullable

  /// Montant total dans la devise de la transaction
  @HiveField(12)
  final double? totalAmountInTransactionCurrency; // Rendu nullable

  /// Montant payé dans la devise de la transaction
  @HiveField(13)
  final double? paidAmountInTransactionCurrency; // Rendu nullable
  
  /// Identifiant de l'utilisateur
  @JsonKey(includeIfNull: false)
  final String? userId;

  /// Date de création
  @JsonKey(includeIfNull: false)
  final DateTime? createdAt;

  /// Date de mise à jour
  @JsonKey(includeIfNull: false)
  final DateTime? updatedAt;

  /// Statut de synchronisation
  @JsonKey(includeToJson: false, includeFromJson: false) // Géré localement, pas pour l'API
  final String? syncStatus;

  /// Dernière tentative de synchronisation
  @JsonKey(includeToJson: false, includeFromJson: false)
  final DateTime? lastSyncAttempt;
  
  /// Message d'erreur de synchronisation
  @JsonKey(includeToJson: false, includeFromJson: false)
  final String? errorMessage;


  /// Constructeur
  const Sale({
    required this.id,
    this.localId,
    required this.date,
    this.dueDate,
    this.customerId,
    required this.customerName,
    required this.items,
    required this.totalAmountInCdf,
    required this.paidAmountInCdf,
    this.totalAmountInUsd,
    this.paidAmountInUsd,
    this.paymentMethod,
    required this.status,
    this.invoiceNumber,
    this.notes = '',
    this.transactionCurrencyCode,
    this.transactionExchangeRate,
    this.totalAmountInTransactionCurrency,
    this.paidAmountInTransactionCurrency,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.syncStatus,
    this.lastSyncAttempt,
    this.errorMessage,
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
    String? localId,
    DateTime? date,
    DateTime? dueDate,
    String? customerId,
    String? customerName,
    List<SaleItem>? items,
    double? totalAmountInCdf,
    double? paidAmountInCdf,
    double? totalAmountInUsd,
    double? paidAmountInUsd,
    String? paymentMethod,
    SaleStatus? status,
    String? invoiceNumber,
    String? notes,
    String? transactionCurrencyCode,
    double? transactionExchangeRate,
    double? totalAmountInTransactionCurrency,
    double? paidAmountInTransactionCurrency,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
    DateTime? lastSyncAttempt,
    String? errorMessage,
  }) {
    return Sale(
      id: id ?? this.id,
      localId: localId ?? this.localId,
      date: date ?? this.date,
      dueDate: dueDate ?? this.dueDate,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      items: items ?? this.items,
      totalAmountInCdf: totalAmountInCdf ?? this.totalAmountInCdf,
      paidAmountInCdf: paidAmountInCdf ?? this.paidAmountInCdf,
      totalAmountInUsd: totalAmountInUsd ?? this.totalAmountInUsd,
      paidAmountInUsd: paidAmountInUsd ?? this.paidAmountInUsd,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      notes: notes ?? this.notes,
      transactionCurrencyCode: transactionCurrencyCode ?? this.transactionCurrencyCode,
      transactionExchangeRate: transactionExchangeRate ?? this.transactionExchangeRate,
      totalAmountInTransactionCurrency: totalAmountInTransactionCurrency ?? this.totalAmountInTransactionCurrency,
      paidAmountInTransactionCurrency: paidAmountInTransactionCurrency ?? this.paidAmountInTransactionCurrency,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncAttempt: lastSyncAttempt ?? this.lastSyncAttempt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    id,
    localId,
    date,
    dueDate,
    customerId,
    customerName,
    items,
    totalAmountInCdf,
    paidAmountInCdf,
    totalAmountInUsd,
    paidAmountInUsd,
    paymentMethod,
    status,
    invoiceNumber,
    notes,
    transactionCurrencyCode,
    transactionExchangeRate,
    totalAmountInTransactionCurrency,
    paidAmountInTransactionCurrency,
    userId,
    createdAt,
    updatedAt,
    syncStatus,
    lastSyncAttempt,
    errorMessage,
  ];
}

// Removed the duplicate SaleItem class definition from here.
// The correct SaleItem model is in 'sale_item.dart' and has HiveType(typeId: 41).
