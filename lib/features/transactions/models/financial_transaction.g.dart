// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'financial_transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FinancialTransaction _$FinancialTransactionFromJson(
        Map<String, dynamic> json) =>
    FinancialTransaction(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      amount: (json['amount'] as num).toDouble(),
      type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
      description: json['description'] as String,
      category: json['category'] as String?,
      relatedParty: json['relatedParty'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
      referenceNumber: json['referenceNumber'] as String?,
      status: $enumDecode(_$TransactionStatusEnumMap, json['status']),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      linkedDocumentId: json['linkedDocumentId'] as String?,
      linkedDocumentType: json['linkedDocumentType'] as String?,
    );

Map<String, dynamic> _$FinancialTransactionToJson(
        FinancialTransaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'amount': instance.amount,
      'type': _$TransactionTypeEnumMap[instance.type]!,
      'description': instance.description,
      if (instance.category case final value?) 'category': value,
      if (instance.relatedParty case final value?) 'relatedParty': value,
      if (instance.paymentMethod case final value?) 'paymentMethod': value,
      if (instance.referenceNumber case final value?) 'referenceNumber': value,
      'status': _$TransactionStatusEnumMap[instance.status]!,
      if (instance.notes case final value?) 'notes': value,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      if (instance.linkedDocumentId case final value?)
        'linkedDocumentId': value,
      if (instance.linkedDocumentType case final value?)
        'linkedDocumentType': value,
    };

const _$TransactionTypeEnumMap = {
  TransactionType.income: 'income',
  TransactionType.expense: 'expense',
  TransactionType.transfer: 'transfer',
  TransactionType.payment: 'payment',
  TransactionType.refund: 'refund',
  TransactionType.openingBalance: 'openingBalance',
  TransactionType.other: 'other',
};

const _$TransactionStatusEnumMap = {
  TransactionStatus.pending: 'pending',
  TransactionStatus.completed: 'completed',
  TransactionStatus.failed: 'failed',
  TransactionStatus.cancelled: 'cancelled',
  TransactionStatus.onHold: 'onHold',
};
