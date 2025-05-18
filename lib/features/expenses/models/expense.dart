import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'expense.g.dart';

@HiveType(typeId: 10) // Ensure typeId is unique
enum ExpenseCategory {
  @HiveField(0)
  rent,
  @HiveField(1)
  utilities,
  @HiveField(2)
  supplies,
  @HiveField(3)
  salaries,
  @HiveField(4)
  marketing,
  @HiveField(5)
  transport,
  @HiveField(6)
  maintenance,
  @HiveField(7)
  other,
}

extension ExpenseCategoryExtension on ExpenseCategory {
  String get displayName {
    switch (this) {
      case ExpenseCategory.rent:
        return 'Loyer';
      case ExpenseCategory.utilities:
        return 'Services Publics';
      case ExpenseCategory.supplies:
        return 'Fournitures';
      case ExpenseCategory.salaries:
        return 'Salaires';
      case ExpenseCategory.marketing:
        return 'Marketing';
      case ExpenseCategory.transport:
        return 'Transport';
      case ExpenseCategory.maintenance:
        return 'Maintenance';
      case ExpenseCategory.other:
      default:
        return 'Autre';
    }
  }
}

@HiveType(typeId: 11) // Ensure typeId is unique
class Expense extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final double amount;

  @HiveField(4)
  final ExpenseCategory category;

  @HiveField(5)
  final String? paymentMethod; // e.g., cash, bank transfer

  @HiveField(6)
  final String? relatedDocumentId; // e.g., invoice number

  const Expense({
    required this.id,
    required this.date,
    required this.description,
    required this.amount,
    required this.category,
    this.paymentMethod,
    this.relatedDocumentId,
  });

  @override
  List<Object?> get props => [id, date, description, amount, category, paymentMethod, relatedDocumentId];

  Expense copyWith({
    String? id,
    DateTime? date,
    String? description,
    double? amount,
    ExpenseCategory? category,
    String? paymentMethod,
    String? relatedDocumentId,
  }) {
    return Expense(
      id: id ?? this.id,
      date: date ?? this.date,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      relatedDocumentId: relatedDocumentId ?? this.relatedDocumentId,
    );
  }
}
