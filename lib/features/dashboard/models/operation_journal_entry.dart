import 'package:flutter/foundation.dart';

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
  other,
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
  });
}
