import 'package:equatable/equatable.dart';

class PaymentMethod extends Equatable {
  final String id;
  final String name; // e.g., "Visa **** 4242" or "Orange Money"
  final String type; // e.g., "card", "mobile_money", "manual"
  final String? details; // e.g., "Expires 12/25" or phone number

  const PaymentMethod({
    required this.id,
    required this.name,
    required this.type,
    this.details,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      details: json['details'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, name, type, details];
}
