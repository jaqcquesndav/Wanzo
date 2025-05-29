import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'financial_transaction.g.dart';

// Enum for transaction type
enum TransactionType {
  income,
  expense,
  transfer,
  payment, // For sales, purchases
  refund,
  openingBalance,
  other,
}

// Enum for transaction status
enum TransactionStatus {
  pending,
  completed,
  failed,
  cancelled,
  onHold,
}

@JsonSerializable(explicitToJson: true)
class FinancialTransaction extends Equatable {
  final String id;
  final DateTime date;
  final double amount;
  final TransactionType type;
  final String description;
  final String? category; // e.g., 'Office Supplies', 'Revenue from Sales'
  final String? relatedParty; // e.g., Customer ID, Supplier ID, Employee ID
  final String? paymentMethod; // e.g., 'Cash', 'Credit Card', 'Bank Transfer'
  final String? referenceNumber; // e.g., Invoice number, Receipt number
  final TransactionStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  // Potentially link to other entities like Invoice, Expense, Sale
  final String? linkedDocumentId; 
  final String? linkedDocumentType; // e.g., 'Invoice', 'Expense'

  const FinancialTransaction({
    required this.id,
    required this.date,
    required this.amount,
    required this.type,
    required this.description,
    this.category,
    this.relatedParty,
    this.paymentMethod,
    this.referenceNumber,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.linkedDocumentId,
    this.linkedDocumentType,
  });

  factory FinancialTransaction.fromJson(Map<String, dynamic> json) =>
      _$FinancialTransactionFromJson(json);

  Map<String, dynamic> toJson() => _$FinancialTransactionToJson(this);

  FinancialTransaction copyWith({
    String? id,
    DateTime? date,
    double? amount,
    TransactionType? type,
    String? description,
    String? category,
    String? relatedParty,
    String? paymentMethod,
    String? referenceNumber,
    TransactionStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? linkedDocumentId,
    String? linkedDocumentType,
  }) {
    return FinancialTransaction(
      id: id ?? this.id,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      description: description ?? this.description,
      category: category ?? this.category,
      relatedParty: relatedParty ?? this.relatedParty,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      linkedDocumentId: linkedDocumentId ?? this.linkedDocumentId,
      linkedDocumentType: linkedDocumentType ?? this.linkedDocumentType,
    );
  }

  @override
  List<Object?> get props => [
        id,
        date,
        amount,
        type,
        description,
        category,
        relatedParty,
        paymentMethod,
        referenceNumber,
        status,
        notes,
        createdAt,
        updatedAt,
        linkedDocumentId,
        linkedDocumentType,
      ];
}
