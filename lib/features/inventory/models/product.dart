import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'product.g.dart';

/// Catégorie de produit
@HiveType(typeId: 20)
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
  
  /// Prix d'achat
  @HiveField(5)
  final double costPrice;
  
  /// Prix de vente
  @HiveField(6)
  final double sellingPrice;
  
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
  
  /// Constructeur
  const Product({
    required this.id,
    required this.name,
    this.description = '',
    this.barcode = '',
    required this.category,
    required this.costPrice,
    required this.sellingPrice,
    required this.stockQuantity,
    required this.unit,
    this.alertThreshold = 5,
    required this.createdAt,
    required this.updatedAt,
    this.imagePath,
  });
  
  /// Vérifie si le stock est bas
  bool get isLowStock => stockQuantity <= alertThreshold;
  
  /// Marge bénéficiaire
  double get profitMargin => sellingPrice - costPrice;
  
  /// Pourcentage de marge
  double get profitPercentage => costPrice > 0 ? (profitMargin / costPrice) * 100 : 0;
  
  /// Valeur totale du stock pour ce produit
  double get stockValue => stockQuantity * costPrice;

  /// Crée une copie du produit avec des attributs modifiés
  Product copyWith({
    String? id,
    String? name,
    String? description,
    String? barcode,
    ProductCategory? category,
    double? costPrice,
    double? sellingPrice,
    double? stockQuantity,
    ProductUnit? unit,
    double? alertThreshold,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? imagePath, // Added imagePath
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      barcode: barcode ?? this.barcode,
      category: category ?? this.category,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      unit: unit ?? this.unit,
      alertThreshold: alertThreshold ?? this.alertThreshold,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imagePath: imagePath ?? this.imagePath, // Added imagePath
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    barcode,
    category,
    costPrice,
    sellingPrice,
    stockQuantity,
    unit,
    alertThreshold,
    createdAt,
    updatedAt,
    imagePath, // Added imagePath
  ];
}
