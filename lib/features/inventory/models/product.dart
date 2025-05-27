import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'product.g.dart';

/// Catégorie de produit
@HiveType(typeId: 20)
@JsonEnum()
enum ProductCategory {
  @HiveField(0)
  food,        // Alimentation
  
  @HiveField(1)
  drink,       // Boissons
  
  @HiveField(2)
  electronics, // Électronique
  
  @HiveField(3)
  clothing,    // Vêtements
  
  @HiveField(4)
  household,   // Articles ménagers
  
  @HiveField(5)
  hygiene,     // Hygiène et beauté
  
  @HiveField(6)
  office,      // Fournitures de bureau
  
  @HiveField(7)
  other,       // Autres
}

/// Unité de mesure d'un produit
@HiveType(typeId: 21)
@JsonEnum()
enum ProductUnit {
  @HiveField(0)
  piece,      // Pièce
  
  @HiveField(1)
  kg,         // Kilogramme
  
  @HiveField(2)
  g,          // Gramme
  
  @HiveField(3)
  l,          // Litre
  
  @HiveField(4)
  ml,         // Millilitre
  
  @HiveField(5)
  package,    // Paquet
  
  @HiveField(6)
  box,        // Boîte
  
  @HiveField(7)
  other,      // Autre
}

/// Modèle représentant un produit dans l'inventaire
@HiveType(typeId: 22)
@JsonSerializable(explicitToJson: true)
class Product extends Equatable {
  /// Identifiant unique du produit
  @HiveField(0)
  final String id;
  
  /// Nom du produit
  @HiveField(1)
  final String name;
  
  /// Description du produit
  @HiveField(2)
  final String description;
  
  /// Code barres ou référence
  @HiveField(3)
  final String barcode;
  
  /// Catégorie du produit
  @HiveField(4)
  final ProductCategory category;
  
  /// Prix d'achat en CDF
  @HiveField(5)
  final double costPriceInCdf;
  
  /// Prix de vente en CDF
  @HiveField(6)
  final double sellingPriceInCdf;
  
  /// Quantité en stock
  @HiveField(7)
  final double stockQuantity;
  
  /// Unité de mesure
  @HiveField(8)
  final ProductUnit unit;
  
  /// Niveau d'alerte de stock bas
  @HiveField(9)
  final double alertThreshold;
  
  /// Date d'ajout dans l'inventaire
  @HiveField(10)
  final DateTime createdAt;
  
  /// Date de dernière mise à jour
  @HiveField(11)
  final DateTime updatedAt;

  /// Chemin de l'image du produit (optionnel)
  @HiveField(12)
  final String? imagePath; 

  /// Devise dans laquelle les prix ont été saisis
  @HiveField(13)
  final String inputCurrencyCode;

  /// Taux de change utilisé lors de la saisie (par rapport au CDF)
  @HiveField(14)
  final double inputExchangeRate;

  /// Prix d'achat dans la devise de saisie
  @HiveField(15)
  final double costPriceInInputCurrency;

  /// Prix de vente dans la devise de saisie
  @HiveField(16)
  final double sellingPriceInInputCurrency;
  
  /// Constructeur
  const Product({
    required this.id,
    required this.name,
    this.description = '',
    this.barcode = '',
    required this.category,
    required this.costPriceInCdf,
    required this.sellingPriceInCdf,
    required this.stockQuantity,
    required this.unit,
    this.alertThreshold = 5,
    required this.createdAt,
    required this.updatedAt,
    this.imagePath,
    required this.inputCurrencyCode,
    required this.inputExchangeRate,
    required this.costPriceInInputCurrency,
    required this.sellingPriceInInputCurrency,
  });

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);
  
  /// Vérifie si le stock est bas
  bool get isLowStock => stockQuantity <= alertThreshold;
  
  /// Marge bénéficiaire en CDF
  double get profitMarginInCdf => sellingPriceInCdf - costPriceInCdf;
  
  /// Pourcentage de marge en CDF
  double get profitPercentageInCdf => costPriceInCdf > 0 ? (profitMarginInCdf / costPriceInCdf) * 100 : 0;
  
  /// Valeur totale du stock pour ce produit en CDF
  double get stockValueInCdf => stockQuantity * costPriceInCdf;

  /// Crée une copie du produit avec des attributs modifiés
  Product copyWith({
    String? id,
    String? name,
    String? description,
    String? barcode,
    ProductCategory? category,
    double? costPriceInCdf,
    double? sellingPriceInCdf,
    double? stockQuantity,
    ProductUnit? unit,
    double? alertThreshold,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? imagePath,
    String? inputCurrencyCode,
    double? inputExchangeRate,
    double? costPriceInInputCurrency,
    double? sellingPriceInInputCurrency,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      barcode: barcode ?? this.barcode,
      category: category ?? this.category,
      costPriceInCdf: costPriceInCdf ?? this.costPriceInCdf,
      sellingPriceInCdf: sellingPriceInCdf ?? this.sellingPriceInCdf,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      unit: unit ?? this.unit,
      alertThreshold: alertThreshold ?? this.alertThreshold,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imagePath: imagePath ?? this.imagePath,
      inputCurrencyCode: inputCurrencyCode ?? this.inputCurrencyCode,
      inputExchangeRate: inputExchangeRate ?? this.inputExchangeRate,
      costPriceInInputCurrency: costPriceInInputCurrency ?? this.costPriceInInputCurrency,
      sellingPriceInInputCurrency: sellingPriceInInputCurrency ?? this.sellingPriceInInputCurrency,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    barcode,
    category,
    costPriceInCdf,
    sellingPriceInCdf,
    stockQuantity,
    unit,
    alertThreshold,
    createdAt,
    updatedAt,
    imagePath,
    inputCurrencyCode,
    inputExchangeRate,
    costPriceInInputCurrency,
    sellingPriceInInputCurrency,
  ];
}
