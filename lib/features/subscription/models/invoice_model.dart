import 'package:equatable/equatable.dart';

class Invoice extends Equatable {
  final String id;
  final DateTime date;
  final double amount;
  final String status;
  final String? downloadUrl; // Optional: for a direct download link

  const Invoice({
    required this.id,
    required this.date,
    required this.amount,
    required this.status,
    this.downloadUrl,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
      downloadUrl: json['downloadUrl'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, date, amount, status, downloadUrl];
}
