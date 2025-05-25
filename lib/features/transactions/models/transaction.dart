import 'package:equatable/equatable.dart';

// Placeholder for Transaction model. Define as needed.
class Transaction extends Equatable {
  final String id;
  final DateTime date;
  final double amount;
  final String type; // e.g., 'sale', 'expense', 'payment_in', 'payment_out'
  final String description;

  const Transaction({
    required this.id,
    required this.date,
    required this.amount,
    required this.type,
    required this.description,
  });

  @override
  List<Object?> get props => [id, date, amount, type, description];
}
