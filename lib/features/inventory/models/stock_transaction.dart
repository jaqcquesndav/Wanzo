import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'stock_transaction.g.dart';

@HiveType(typeId: 32)
@JsonEnum() // Added JsonEnum
enum StockTransactionType {
  @HiveField(0)
  purchase, // Entrée de stock suite à un achat

  @HiveField(1)
  sale, // Sortie de stock suite à une vente

  @HiveField(2)
  adjustment, // Ajustement manuel (positif ou négatif)

  @HiveField(3)
  transferIn, // Entrée de stock suite à un transfert interne

  @HiveField(4)
  transferOut, // Sortie de stock suite à un transfert interne

  @HiveField(5)
  returned, // Retour de marchandise par un client (entrée)

  @HiveField(6)
  damaged, // Marchandise endommagée (sortie)

  @HiveField(7)
  lost, // Marchandise perdue (sortie)

  @HiveField(8)
  initialStock, // Stock initial lors de la création du produit
}

@HiveType(typeId: 33)
@JsonSerializable() // Added JsonSerializable
class StockTransaction extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String productId;

  @HiveField(2)
  final StockTransactionType type;

  @HiveField(3)
  final double quantity; // Peut être négatif pour les sorties

  @HiveField(4)
  final DateTime date;

  @HiveField(5)
  final String? referenceId; // ID de la vente, achat, ou autre document lié

  @HiveField(6)
  final String? notes;

  @HiveField(7)
  final double unitCostInCdf; // Coût unitaire du produit en CDF au moment de la transaction
  @HiveField(8)
  final double totalValueInCdf; // Valeur totale de la transaction en CDF (quantité * coût unitaire en CDF)
  
  @HiveField(9)
  final String? currencyCode; // Code de la devise de la transaction (USD, CDF, etc.)
  
  // productName and unitCost are not part of this model as per InventoryRepository
  // If needed, they should be fetched from the Product model using productId

  const StockTransaction({
    required this.id,
    required this.productId,
    required this.type,
    required this.quantity,
    required this.date,
    this.referenceId,
    this.notes,
    required this.unitCostInCdf,
    required this.totalValueInCdf,
    this.currencyCode,
  });
  factory StockTransaction.fromJson(Map<String, dynamic> json) => _$StockTransactionFromJson(json);
  Map<String, dynamic> toJson() => _$StockTransactionToJson(this);

  @override
  List<Object?> get props => [id, productId, type, quantity, date, referenceId, notes, unitCostInCdf, totalValueInCdf, currencyCode];

  StockTransaction copyWith({
    String? id,
    String? productId,
    StockTransactionType? type,
    double? quantity,
    DateTime? date,
    String? referenceId,
    String? notes,
    double? unitCostInCdf,
    double? totalValueInCdf,
    String? currencyCode,
  }) {
    return StockTransaction(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      date: date ?? this.date,
      referenceId: referenceId ?? this.referenceId,
      notes: notes ?? this.notes,
      unitCostInCdf: unitCostInCdf ?? this.unitCostInCdf,
      totalValueInCdf: totalValueInCdf ?? this.totalValueInCdf,
      currencyCode: currencyCode ?? this.currencyCode,
    );
  }
}

// Extension pour faciliter l'accès à la devise
extension StockTransactionExtension on StockTransaction {
  /// Obtient le code de devise effectif pour cette transaction (CDF par défaut)
  String get effectiveCurrencyCode => currencyCode ?? 'CDF';
}
