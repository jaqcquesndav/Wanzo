import 'package:equatable/equatable.dart';

/// Statut de la vente
enum SaleStatus {
  pending,   // En attente
  completed, // Terminée
  cancelled  // Annulée
}

/// Élément de vente
class SaleItem extends Equatable {
  final String id;
  final String productId;
  final String productName;
  final double quantity;
  final double unitPrice;
  final double discount;

  const SaleItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    this.discount = 0,
  });

  /// Montant total pour cet élément
  double get totalAmount => (unitPrice * quantity) - discount;

  @override
  List<Object?> get props => [id, productId, productName, quantity, unitPrice, discount];
}

/// Modèle de vente
class Sale extends Equatable {
  final String id;
  final DateTime date;
  final String customerName;
  final String? customerId;
  final List<SaleItem> items;
  final double amountPaid;
  final String notes;
  final SaleStatus status;

  const Sale({
    required this.id,
    required this.date,
    required this.customerName,
    this.customerId,
    required this.items,
    required this.amountPaid,
    this.notes = '',
    this.status = SaleStatus.pending,
  });

  /// Montant total de la vente
  double get totalAmount => items.fold<double>(
    0, 
    (total, item) => total + item.totalAmount
  );

  /// Indique si la vente est entièrement payée
  bool get isFullyPaid => amountPaid >= totalAmount;

  /// Montant restant à payer
  double get remainingAmount => totalAmount - amountPaid;

  @override
  List<Object?> get props => [
    id, 
    date, 
    customerName, 
    customerId, 
    items, 
    amountPaid, 
    notes, 
    status
  ];
}