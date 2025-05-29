import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:wanzo/core/services/api_client.dart';
import 'package:wanzo/features/expenses/models/expense.dart';

// Removed: part 'expense_api_service.g.dart';
// Removed: import 'package:dio/dio.dart';
// Removed: import 'package:retrofit/retrofit.dart';

// Removed @RestApi annotation
abstract class ExpenseApiService {
  Future<List<Expense>> getExpenses({
    int? page,
    int? limit,
    String? dateFrom,
    String? dateTo,
    String? categoryId,
    String? sortBy,
    String? sortOrder,
  });

  Future<Expense> createExpense(
    DateTime date,
    double amount,
    String motif,
    String categoryId,
    String paymentMethod,
    String? supplierId, {
    List<File>? attachments, // Changed from MultipartFile to File
  });

  Future<Expense> getExpenseById(String id);

  Future<Expense> updateExpense(
    String id,
    DateTime? date,
    double? amount,
    String? motif,
    String? categoryId,
    String? paymentMethod,
    String? supplierId, {
    List<File>? attachments, // Changed from MultipartFile to File
    List<String>? attachmentUrlsToRemove,
  });

  Future<void> deleteExpense(String id);
}

class ExpenseApiServiceImpl implements ExpenseApiService {
  final ApiClient _apiClient;

  ExpenseApiServiceImpl(this._apiClient);

  @override
  Future<List<Expense>> getExpenses({
    int? page,
    int? limit,
    String? dateFrom,
    String? dateTo,
    String? categoryId,
    String? sortBy,
    String? sortOrder,
  }) async {
    final queryParameters = <String, String>{
      if (page != null) 'page': page.toString(),
      if (limit != null) 'limit': limit.toString(),
      if (dateFrom != null) 'dateFrom': dateFrom,
      if (dateTo != null) 'dateTo': dateTo,
      if (categoryId != null) 'categoryId': categoryId,
      if (sortBy != null) 'sortBy': sortBy,
      if (sortOrder != null) 'sortOrder': sortOrder,
    };
    final response = await _apiClient.get('expenses', queryParameters: queryParameters, requiresAuth: true);
    final List<dynamic> data = response as List<dynamic>; // Assuming response is List
    return data.map((json) => Expense.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<Expense> createExpense(
    DateTime date,
    double amount,
    String motif,
    String categoryId,
    String paymentMethod,
    String? supplierId, {
    List<File>? attachments,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse('${_apiClient.baseUrl}/expenses'));
    request.headers.addAll(await _apiClient.getHeaders(requiresAuth: true));

    request.fields['date'] = date.toIso8601String();
    request.fields['amount'] = amount.toString();
    request.fields['motif'] = motif;
    request.fields['categoryId'] = categoryId;
    request.fields['paymentMethod'] = paymentMethod;
    if (supplierId != null) {
      request.fields['supplierId'] = supplierId;
    }

    if (attachments != null) {
      for (var attachment in attachments) {
        request.files.add(await http.MultipartFile.fromPath('attachments', attachment.path));
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final responseData = _apiClient.handleResponse(response);
    return Expense.fromJson(responseData as Map<String, dynamic>);
  }

  @override
  Future<Expense> getExpenseById(String id) async {
    final response = await _apiClient.get('expenses/$id', requiresAuth: true);
    return Expense.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<Expense> updateExpense(
    String id,
    DateTime? date,
    double? amount,
    String? motif,
    String? categoryId,
    String? paymentMethod,
    String? supplierId, {
    List<File>? attachments,
    List<String>? attachmentUrlsToRemove,
  }) async {
    final request = http.MultipartRequest('PUT', Uri.parse('${_apiClient.baseUrl}/expenses/$id'));
    request.headers.addAll(await _apiClient.getHeaders(requiresAuth: true));

    if (date != null) request.fields['date'] = date.toIso8601String();
    if (amount != null) request.fields['amount'] = amount.toString();
    if (motif != null) request.fields['motif'] = motif;
    if (categoryId != null) request.fields['categoryId'] = categoryId;
    if (paymentMethod != null) request.fields['paymentMethod'] = paymentMethod;
    if (supplierId != null) request.fields['supplierId'] = supplierId;
    if (attachmentUrlsToRemove != null) {
      // Backend needs to know how to handle this, e.g., "attachmentUrlsToRemove[]"
      for (int i = 0; i < attachmentUrlsToRemove.length; i++) {
        request.fields['attachmentUrlsToRemove[$i]'] = attachmentUrlsToRemove[i];
      }
    }

    if (attachments != null) {
      for (var attachment in attachments) {
        request.files.add(await http.MultipartFile.fromPath('attachments', attachment.path));
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final responseData = _apiClient.handleResponse(response);
    return Expense.fromJson(responseData as Map<String, dynamic>);
  }

  @override
  Future<void> deleteExpense(String id) async {
    await _apiClient.delete('expenses/$id', requiresAuth: true);
  }
}

// Helper methods in ApiClient need to be public or used internally if they are private.
// Specifically, _getHeaders and _handleResponse are used here indirectly or directly.
// For _handleResponse, we need to ensure it's accessible or replicate its logic.
// For _baseUrl, we need a public getter in ApiClient.

// Add a factory constructor for easy creation, or update DI setup
// Example: static ExpenseApiService create(ApiClient client) => ExpenseApiServiceImpl(client);
