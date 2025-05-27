import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart'; // Added import

part 'sale_item.g.dart';

/// Modèle représentant un élément de vente (un produit vendu avec sa quantité et son prix)
@HiveType(typeId: 41) // Unique typeId for SaleItem
@JsonSerializable(explicitToJson: true) // Added annotation
class SaleItem extends Equatable {
  /// Identifiant du produit
  @HiveField(0)
  final String productId;
  
  /// Nom du produit
  @HiveField(1)
  final String productName;
  
  /// Quantité vendue
  @HiveField(2)
  final int quantity;
  
  /// Prix unitaire (in transaction currency)
  @HiveField(3)
  final double unitPrice;
  
  /// Montant total pour cet article (prix unitaire * quantité, in transaction currency)
  @HiveField(4)
  final double totalPrice;

  /// Code de la devise de la transaction (par exemple, "USD", "CDF")
  @HiveField(5)
  final String currencyCode;

  /// Taux de change vers CDF au moment de la transaction
  /// (Si currencyCode est "CDF", exchangeRate est 1.0)
  @HiveField(6)
  final double exchangeRate;

  /// Prix unitaire en CDF
  @HiveField(7)
  final double unitPriceInCdf;

  /// Montant total pour cet article en CDF
  @HiveField(8)
  final double totalPriceInCdf;
  
  /// Constructeur
  const SaleItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.currencyCode,
    required this.exchangeRate,
    required this.unitPriceInCdf,
    required this.totalPriceInCdf,
  });
  
  // Added fromJson factory and toJson method for JsonSerializable
  factory SaleItem.fromJson(Map<String, dynamic> json) => _$SaleItemFromJson(json);
  Map<String, dynamic> toJson() => _$SaleItemToJson(this);
  
  /// Méthode pour créer un item avec le total calculé automatiquement
  factory SaleItem.withCalculatedTotal({
    required String productId,
    required String productName,
    required int quantity,
    required double unitPrice,
    required String currencyCode,
    required double exchangeRate, // Rate to convert currencyCode to CDF
  }) {
    final calculatedTotalPrice = quantity * unitPrice;
    return SaleItem(
      productId: productId,
      productName: productName,
      quantity: quantity,
      unitPrice: unitPrice,
      totalPrice: calculatedTotalPrice,
      currencyCode: currencyCode,
      exchangeRate: exchangeRate,
      unitPriceInCdf: unitPrice * exchangeRate,
      totalPriceInCdf: calculatedTotalPrice * exchangeRate,
    );
  }
  
  /// Méthode pour créer une copie de cet item avec des valeurs modifiées
  SaleItem copyWith({
    String? productId,
    String? productName,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
    String? currencyCode,
    double? exchangeRate,
    double? unitPriceInCdf,
    double? totalPriceInCdf,
  }) {
    return SaleItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      currencyCode: currencyCode ?? this.currencyCode,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      unitPriceInCdf: unitPriceInCdf ?? this.unitPriceInCdf,
      totalPriceInCdf: totalPriceInCdf ?? this.totalPriceInCdf,
    );
  }
  
  @override
  List<Object?> get props => [
    productId, 
    productName, 
    quantity, 
    unitPrice, 
    totalPrice,
    currencyCode,
    exchangeRate,
    unitPriceInCdf,
    totalPriceInCdf,
  ];
}
