import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'financing_request.g.dart'; // Uncommented for generation

@HiveType(typeId: 16) // Changed typeId to 16
enum FinancingType {
  @HiveField(0)
  cashCredit, // Crédit de trésorerie

  @HiveField(1)
  investmentCredit, // Crédit d'investissement

  @HiveField(2)
  leasing, // Leasing
}

extension FinancingTypeExtension on FinancingType {
  String get displayName {
    switch (this) {
      case FinancingType.cashCredit:
        return 'Crédit de trésorerie';
      case FinancingType.investmentCredit:
        return 'Crédit d\'investissement';
      case FinancingType.leasing:
        return 'Leasing';
      // No default needed as all cases are covered
    }
  }
}

@HiveType(typeId: 9) // Changed typeId to 9
enum FinancialInstitution {
  @HiveField(0)
  bonneMoisson,

  @HiveField(1)
  tid,

  @HiveField(2)
  smico,

  @HiveField(3)
  tmb,

  @HiveField(4)
  equitybcdc,
}

extension FinancialInstitutionExtension on FinancialInstitution {
  String get displayName {
    switch (this) {
      case FinancialInstitution.bonneMoisson:
        return 'Bonne Moisson';
      case FinancialInstitution.tid:
        return 'TID';
      case FinancialInstitution.smico:
        return 'SMICO';
      case FinancialInstitution.tmb:
        return 'TMB';
      case FinancialInstitution.equitybcdc:
        return 'EquityBCDC';
      // No default needed as all cases are covered
    }
  }
}

@HiveType(typeId: 8) // Changed typeId to 8
class FinancingRequest extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final String currency;

  @HiveField(3)
  final String reason;

  @HiveField(4)
  final FinancingType type;

  @HiveField(5)
  final FinancialInstitution institution;

  @HiveField(6)
  final DateTime requestDate;

  @HiveField(7)
  final String status; // e.g., pending, approved, rejected

  const FinancingRequest({
    required this.id,
    required this.amount,
    required this.currency,
    required this.reason,
    required this.type,
    required this.institution,
    required this.requestDate,
    this.status = 'pending',
  });

  @override
  List<Object?> get props => [
        id,
        amount,
        currency,
        reason,
        type,
        institution,
        requestDate,
        status,
      ];

  FinancingRequest copyWith({
    String? id,
    double? amount,
    String? currency,
    String? reason,
    FinancingType? type,
    FinancialInstitution? institution,
    DateTime? requestDate,
    String? status,
  }) {
    return FinancingRequest(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      reason: reason ?? this.reason,
      type: type ?? this.type,
      institution: institution ?? this.institution,
      requestDate: requestDate ?? this.requestDate,
      status: status ?? this.status,
    );
  }
}
