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
  final String id; // Server ID

  @JsonKey(includeIfNull: false)
  final String? localId; // Local unique ID

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
  final List<String>? attachmentUrls; // Synced Cloudinary URLs

  @JsonKey(includeToJson: false, includeFromJson: false) // Only for local use before sync
  final List<String>? localAttachmentPaths;

  @HiveField(7) // New HiveField, ensure unique index
  @JsonKey(name: 'supplierId') // Map 'supplierId' from JSON
  final String? supplierId; // Added supplierId

  @JsonKey(includeIfNull: false)
  final String? beneficiary;

  @JsonKey(includeIfNull: false)
  final String? notes;
  
  @JsonKey(includeIfNull: false)
  final String? userId;

  @JsonKey(includeIfNull: false)
  final DateTime? createdAt;

  @JsonKey(includeIfNull: false)
  final DateTime? updatedAt;

  @JsonKey(includeToJson: false, includeFromJson: false)
  final String? syncStatus;

  @JsonKey(includeToJson: false, includeFromJson: false)
  final DateTime? lastSyncAttempt;

  @JsonKey(includeToJson: false, includeFromJson: false)
  final String? errorMessage;

  const Expense({
    required this.id,
    this.localId,
    required this.date,
    required this.motif, // Updated from description
    required this.amount,
    required this.category,
    this.paymentMethod,
    this.attachmentUrls, // Updated from relatedDocumentId
    this.localAttachmentPaths,
    this.supplierId, // Added supplierId
    this.beneficiary,
    this.notes,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.syncStatus,
    this.lastSyncAttempt,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
        id,
        localId,
        date,
        motif,
        amount,
        category,
        paymentMethod,
        attachmentUrls,
        localAttachmentPaths,
        supplierId,
        beneficiary,
        notes,
        userId,
        createdAt,
        updatedAt,
        syncStatus,
        lastSyncAttempt,
        errorMessage,
      ]; // Updated props

  Expense copyWith({
    String? id,
    String? localId,
    DateTime? date,
    String? motif, // Updated from description
    double? amount,
    ExpenseCategory? category,
    String? paymentMethod,
    List<String>? attachmentUrls, // Updated from relatedDocumentId
    List<String>? localAttachmentPaths,
    String? supplierId, // Added supplierId
    String? beneficiary,
    String? notes,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
    DateTime? lastSyncAttempt,
    String? errorMessage,
  }) {
    return Expense(
      id: id ?? this.id,
      localId: localId ?? this.localId,
      date: date ?? this.date,
      motif: motif ?? this.motif, // Updated from description
      amount: amount ?? this.amount,
      category: category ?? this.category,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      attachmentUrls: attachmentUrls ?? this.attachmentUrls, // Updated
      localAttachmentPaths: localAttachmentPaths ?? this.localAttachmentPaths,
      supplierId: supplierId ?? this.supplierId, // Added
      beneficiary: beneficiary ?? this.beneficiary,
      notes: notes ?? this.notes,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncAttempt: lastSyncAttempt ?? this.lastSyncAttempt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  // Add fromJson and toJson factory constructors for json_serializable
  factory Expense.fromJson(Map<String, dynamic> json) => _$ExpenseFromJson(json);
  Map<String, dynamic> toJson() => _$ExpenseToJson(this);

  String get hiveKey {
    // If 'id' (server ID) is empty, it implies it's a new, unsynced item,
    // so 'localId' (if available and not empty) should be its key in Hive.
    if (id.isEmpty && localId != null && localId!.isNotEmpty) {
      return localId!;
    }
    // Otherwise, 'id' (server ID) is assumed to be the key.
    // This covers synced items and items fetched from the API.
    return id;
  }
}
