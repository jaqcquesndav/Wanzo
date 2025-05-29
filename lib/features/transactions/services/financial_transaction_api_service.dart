import 'package:wanzo/core/services/api_client.dart';
import 'package:wanzo/core/models/api_response.dart';
import 'package:wanzo/features/transactions/models/financial_transaction.dart'; // Assurez-vous que ce modèle existe

class FinancialTransactionApiService {
  final ApiClient _apiClient;

  FinancialTransactionApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<ApiResponse<List<FinancialTransaction>>> getFinancialTransactions({
    int? page,
    int? limit,
    String? dateFrom,
    String? dateTo,
    String? type,
    String? status,
    String? paymentMethodId,
  }) async {
    try {
      final Map<String, String> queryParams = {};
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();
      if (dateFrom != null) queryParams['dateFrom'] = dateFrom;
      if (dateTo != null) queryParams['dateTo'] = dateTo;
      if (type != null) queryParams['type'] = type;
      if (status != null) queryParams['status'] = status;
      if (paymentMethodId != null) queryParams['paymentMethodId'] = paymentMethodId;

      final response = await _apiClient.get('financial-transactions', queryParameters: queryParams, requiresAuth: true);
      if (response != null && response['data'] != null) {
        final transactions = (response['data'] as List)
            .map((transJson) => FinancialTransaction.fromJson(transJson as Map<String, dynamic>))
            .toList();
        return ApiResponse<List<FinancialTransaction>>(
          success: true,
          data: transactions,
          message: response['message'] as String? ?? 'Financial transactions fetched successfully.',
          statusCode: response['statusCode'] as int? ?? 200,
          // paginationInfo: response['pagination'] // Si l'API retourne des infos de pagination
        );
      } else {
        throw ApiException('Invalid response data format from server', responseBody: response, statusCode: response['statusCode'] as int?);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to fetch financial transactions: An unexpected error occurred. \$e');
    }
  }

  Future<ApiResponse<FinancialTransaction>> createFinancialTransaction(FinancialTransaction transaction) async {
    try {
      final response = await _apiClient.post('financial-transactions', body: transaction.toJson(), requiresAuth: true);
      if (response != null && response['data'] != null) {
        final createdTransaction = FinancialTransaction.fromJson(response['data'] as Map<String, dynamic>);
        return ApiResponse<FinancialTransaction>(
          success: true,
          data: createdTransaction,
          message: response['message'] as String? ?? 'Financial transaction created successfully.',
          statusCode: response['statusCode'] as int? ?? 201,
        );
      } else {
        throw ApiException('Invalid response data format from server', responseBody: response, statusCode: response['statusCode'] as int?);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to create financial transaction: An unexpected error occurred. \$e');
    }
  }

  Future<ApiResponse<FinancialTransaction>> getFinancialTransactionById(String id) async {
    try {
      final response = await _apiClient.get('financial-transactions/\$id', requiresAuth: true);
      if (response != null && response['data'] != null) {
        final transaction = FinancialTransaction.fromJson(response['data'] as Map<String, dynamic>);
        return ApiResponse<FinancialTransaction>(
          success: true,
          data: transaction,
          message: response['message'] as String? ?? 'Financial transaction fetched successfully.',
          statusCode: response['statusCode'] as int? ?? 200,
        );
      } else {
        throw ApiException('Invalid response data format from server', responseBody: response, statusCode: response['statusCode'] as int?);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to fetch financial transaction: An unexpected error occurred. \$e');
    }
  }

  Future<ApiResponse<FinancialTransaction>> updateFinancialTransaction(String id, FinancialTransaction transaction) async {
    try {
      final response = await _apiClient.put('financial-transactions/\$id', body: transaction.toJson(), requiresAuth: true);
      if (response != null && response['data'] != null) {
        final updatedTransaction = FinancialTransaction.fromJson(response['data'] as Map<String, dynamic>);
        return ApiResponse<FinancialTransaction>(
          success: true,
          data: updatedTransaction,
          message: response['message'] as String? ?? 'Financial transaction updated successfully.',
          statusCode: response['statusCode'] as int? ?? 200,
        );
      } else {
        throw ApiException('Invalid response data format from server', responseBody: response, statusCode: response['statusCode'] as int?);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to update financial transaction: An unexpected error occurred. \$e');
    }
  }
}

// Assurez-vous que le modèle FinancialTransaction est défini, par exemple:
// c:\\Users\\DevSpace\\Flutter\\wanzo\\lib\\features\\transactions\\models\\financial_transaction.dart
/*
class FinancialTransaction {
  final String id;
  final String userId;
  final DateTime date;
  final double amount;
  final String currency;
  final String type;
  final String description;
  final String status;
  final String? paymentMethodId;
  final String? relatedEntityId;
  final String? relatedEntityType;
  final DateTime createdAt;
  final DateTime updatedAt;

  FinancialTransaction({
    required this.id,
    required this.userId,
    required this.date,
    required this.amount,
    required this.currency,
    required this.type,
    required this.description,
    required this.status,
    this.paymentMethodId,
    this.relatedEntityId,
    this.relatedEntityType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FinancialTransaction.fromJson(Map<String, dynamic> json) {
    return FinancialTransaction(
      id: json['id'] as String,
      userId: json['userId'] as String,
      date: DateTime.parse(json['date'] as String),
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      paymentMethodId: json['paymentMethodId'] as String?,
      relatedEntityId: json['relatedEntityId'] as String?,
      relatedEntityType: json['relatedEntityType'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() { // Pour la création
    return {
      'date': date.toIso8601String(),
      'amount': amount,
      'currency': currency,
      'type': type,
      'description': description,
      'status': status,
      'paymentMethodId': paymentMethodId,
      'relatedEntityId': relatedEntityId,
      'relatedEntityType': relatedEntityType,
      // userId, id, createdAt, updatedAt sont gérés par le backend
    };
  }

  Map<String, dynamic> toJsonForUpdate() { // Pour la mise à jour
    return {
      'date': date.toIso8601String(),
      'amount': amount,
      'currency': currency,
      'type': type,
      'description': description,
      'status': status,
      'paymentMethodId': paymentMethodId,
      'relatedEntityId': relatedEntityId,
      'relatedEntityType': relatedEntityType,
    };
  }
}
*/
