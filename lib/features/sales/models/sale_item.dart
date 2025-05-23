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
  
  /// Prix unitaire
  @HiveField(3)
  final double unitPrice;
  
  /// Montant total pour cet article (prix unitaire * quantité)
  @HiveField(4)
  final double totalPrice;
  
  /// Constructeur
  const SaleItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
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
  }) {
    return SaleItem(
      productId: productId,
      productName: productName,
      quantity: quantity,
      unitPrice: unitPrice,
      totalPrice: quantity * unitPrice,
    );
  }
  
  /// Méthode pour créer une copie de cet item avec des valeurs modifiées
  SaleItem copyWith({
    String? productId,
    String? productName,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
  }) {
    return SaleItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
  
  @override
  List<Object?> get props => [productId, productName, quantity, unitPrice, totalPrice];
}
