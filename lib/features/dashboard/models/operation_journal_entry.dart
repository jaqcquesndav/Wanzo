import 'package:flutter/material.dart'; // Added for IconData

enum OperationType {
  saleCash,
  saleCredit,
  saleInstallment,
  stockIn, // Entrée de stock (ex: nouvel arrivage, achat fournisseur)
  stockOut, // Sortie de stock suite à une vente ou ajustement
  cashIn, // Entrée d'espèce (ex: paiement client, apport)
  cashOut, // Sortie d'espèce (ex: dépense, retrait)
  customerPayment, // Paiement reçu d'un client pour une vente à crédit
  supplierPayment, // Paiement effectué à un fournisseur
  financingRequest, // Nouvelle demande de financement
  financingApproved, // Financement approuvé (entrée de fonds)
  financingRepayment, // Remboursement de financement (sortie de fonds)
  other;

  // Helper to convert string to OperationType, with a default value
  static OperationType fromString(String? typeString) {
    if (typeString == null) return OperationType.other;
    try {
      return OperationType.values.firstWhere((e) => e.toString().split('.').last.toLowerCase() == typeString.toLowerCase());
    } catch (e) {
      return OperationType.other;
    }
  }

  String toJson() => name;
  static OperationType fromJson(String json) => fromString(json);
}

extension OperationTypeExtension on OperationType {
  String get displayName {
    switch (this) {
      case OperationType.saleCash:
        return 'Vente (Espèce)';
      case OperationType.saleCredit:
        return 'Vente (Crédit)';
      case OperationType.saleInstallment:
        return 'Vente (Échelonnée)';
      case OperationType.stockIn:
        return 'Entrée Stock';
      case OperationType.stockOut:
        return 'Sortie Stock';
      case OperationType.cashIn:
        return 'Entrée Espèce';
      case OperationType.cashOut:
        return 'Sortie Espèce';
      case OperationType.customerPayment:
        return 'Paiement Client';
      case OperationType.supplierPayment:
        return 'Paiement Fournisseur';
      case OperationType.financingRequest:
        return 'Demande de Financement';
      case OperationType.financingApproved:
        return 'Financement Approuvé';
      case OperationType.financingRepayment:
        return 'Remboursement Financement';
      case OperationType.other:
        return 'Autre'; // Cas 'other' explicite
    }
  }

  IconData get icon {
    switch (this) {
      case OperationType.saleCash:
      case OperationType.saleCredit:
      case OperationType.saleInstallment:
        return Icons.shopping_cart_checkout;
      case OperationType.stockIn:
        return Icons.inventory_2_outlined; // More specific for stock in
      case OperationType.stockOut:
        return Icons.outbox_outlined; // More specific for stock out
      case OperationType.cashIn:
        return Icons.attach_money;
      case OperationType.cashOut:
        return Icons.money_off_csred_outlined;
      case OperationType.customerPayment:
        return Icons.person_pin_circle_outlined; 
      case OperationType.supplierPayment:
        return Icons.store_mall_directory_outlined;
      case OperationType.financingRequest:
        return Icons.post_add_outlined;
      case OperationType.financingApproved:
        return Icons.check_circle_outline;
      case OperationType.financingRepayment:
        return Icons.assignment_returned_outlined;
      case OperationType.other:
        return Icons.receipt_long_outlined;
    }
  }
}

@immutable
class OperationJournalEntry {
  final String id;
  final DateTime date;
  final String description;
  final OperationType type;
  final double amount; // Positif pour entrées/revenus, négatif pour sorties/dépenses
  final String? relatedDocumentId; // Ex: ID de la vente
  final double? quantity; // Quantité pour les mouvements de stock
  final String? productId; // ID du produit pour les mouvements de stock
  final String? productName; // Nom du produit pour les mouvements de stock
  final String? paymentMethod; // Méthode de paiement pour les transactions financières
  final String? currencyCode; // Code de la devise pour le montant
  final bool isDebit;
  final bool isCredit;
  final double balanceAfter;

  const OperationJournalEntry({
    required this.id,
    required this.date,
    required this.description,
    required this.type,
    required this.amount,
    this.relatedDocumentId,
    this.quantity,
    this.productId,
    this.productName,
    this.paymentMethod,
    this.currencyCode, // Added to constructor
    required this.isDebit,
    required this.isCredit,
    required this.balanceAfter,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'description': description,
      'type': type.toJson(), // Use the enum's toJson method
      'amount': amount,
      if (relatedDocumentId != null) 'relatedDocumentId': relatedDocumentId,
      if (quantity != null) 'quantity': quantity,
      if (productId != null) 'productId': productId,
      if (productName != null) 'productName': productName,
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
      if (currencyCode != null) 'currencyCode': currencyCode,
      'isDebit': isDebit,
      'isCredit': isCredit,
      'balanceAfter': balanceAfter,
    };
  }

  factory OperationJournalEntry.fromJson(Map<String, dynamic> json) {
    return OperationJournalEntry(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String,
      type: OperationType.fromJson(json['type'] as String), // Use the enum's fromJson method
      amount: (json['amount'] as num).toDouble(),
      relatedDocumentId: json['relatedDocumentId'] as String?,
      quantity: (json['quantity'] as num?)?.toDouble(),
      productId: json['productId'] as String?,
      productName: json['productName'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
      currencyCode: json['currencyCode'] as String?, // Added to fromJson
      isDebit: json['isDebit'] as bool? ?? false, // Provide default if null
      isCredit: json['isCredit'] as bool? ?? false, // Provide default if null
      balanceAfter: (json['balanceAfter'] as num?)?.toDouble() ?? 0.0, // Provide default if null
    );
  }

  OperationJournalEntry copyWith({
    String? id,
    DateTime? date,
    String? description,
    OperationType? type,
    double? amount,
    String? relatedDocumentId,
    double? quantity,
    String? productId,
    String? productName,
    String? paymentMethod,
    String? currencyCode,
    bool? isDebit,
    bool? isCredit,
    double? balanceAfter,
  }) {
    return OperationJournalEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      description: description ?? this.description,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      relatedDocumentId: relatedDocumentId ?? this.relatedDocumentId,
      quantity: quantity ?? this.quantity,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      currencyCode: currencyCode ?? this.currencyCode,
      isDebit: isDebit ?? this.isDebit,
      isCredit: isCredit ?? this.isCredit,
      balanceAfter: balanceAfter ?? this.balanceAfter,
    );
  }

  // Placeholder for AdhaBloc integration
  Map<String, dynamic> toContextMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'description': description,
      'type': type.toString().split('.').last, // Enum to string
      'amount': amount,
      if (relatedDocumentId != null) 'relatedDocumentId': relatedDocumentId,
      if (quantity != null) 'quantity': quantity,
      if (productId != null) 'productId': productId,
      if (productName != null) 'productName': productName,
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
      if (currencyCode != null) 'currencyCode': currencyCode, // Added to toContextMap
    };
  }
}
