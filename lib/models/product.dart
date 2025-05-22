import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'product.g.dart';

@JsonSerializable()
@HiveType(typeId: 3) // Unique typeId for Product
class Product extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String? description;
  @HiveField(3)
  final double price;
  @HiveField(4)
  final int quantityInStock;
  @HiveField(5)
  final String? categoryId;
  @HiveField(6)
  final String? supplierId;
  @HiveField(7)
  final String? imageUrl;
  @HiveField(8)
  final DateTime createdAt;
  @HiveField(9)
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.quantityInStock,
    this.categoryId,
    this.supplierId,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    price,
    quantityInStock,
    categoryId,
    supplierId,
    imageUrl,
    createdAt,
    updatedAt,
  ];

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);
}
