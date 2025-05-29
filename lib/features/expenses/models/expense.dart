import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart'; // Added for json_serializable

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
        return 'Autre';
    }
  }
}

@JsonSerializable() // Added for json_serializable
@HiveType(typeId: 11) // Ensure typeId is unique
class Expense extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  @JsonKey(name: 'motif') // Map 'motif' from JSON to 'motif' in Dart
  final String motif; // Renamed from description

  @HiveField(3)
  final double amount;

  @HiveField(4)
  final ExpenseCategory category;

  @HiveField(5)
  final String? paymentMethod; // e.g., cash, bank transfer

  @HiveField(6)
  @JsonKey(name: 'attachmentUrls') // Map 'attachmentUrls' from JSON
  final List<String>? attachmentUrls; // Changed from relatedDocumentId (String?) to List<String>?

  @HiveField(7) // New HiveField, ensure unique index
  @JsonKey(name: 'supplierId') // Map 'supplierId' from JSON
  final String? supplierId; // Added supplierId

  const Expense({
    required this.id,
    required this.date,
    required this.motif, // Updated from description
    required this.amount,
    required this.category,
    this.paymentMethod,
    this.attachmentUrls, // Updated from relatedDocumentId
    this.supplierId, // Added supplierId
  });

  @override
  List<Object?> get props => [id, date, motif, amount, category, paymentMethod, attachmentUrls, supplierId]; // Updated props

  Expense copyWith({
    String? id,
    DateTime? date,
    String? motif, // Updated from description
    double? amount,
    ExpenseCategory? category,
    String? paymentMethod,
    List<String>? attachmentUrls, // Updated from relatedDocumentId
    String? supplierId, // Added supplierId
  }) {
    return Expense(
      id: id ?? this.id,
      date: date ?? this.date,
      motif: motif ?? this.motif, // Updated from description
      amount: amount ?? this.amount,
      category: category ?? this.category,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      attachmentUrls: attachmentUrls ?? this.attachmentUrls, // Updated
      supplierId: supplierId ?? this.supplierId, // Added
    );
  }

  // Add fromJson and toJson factory constructors for json_serializable
  factory Expense.fromJson(Map<String, dynamic> json) => _$ExpenseFromJson(json);
  Map<String, dynamic> toJson() => _$ExpenseToJson(this);
}
