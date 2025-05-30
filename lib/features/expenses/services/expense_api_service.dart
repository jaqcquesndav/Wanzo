import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:wanzo/core/services/api_client.dart';
import 'package:wanzo/core/services/image_upload_service.dart';
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
    List<File>? attachments, // Ensure this is the parameter name and type
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
    List<File>? newAttachments, // Ensure this is the parameter name for new files
    List<String>? attachmentUrlsToRemove,
  });

  Future<void> deleteExpense(String id);
}

class ExpenseApiServiceImpl implements ExpenseApiService {
  final ApiClient _apiClient;
  final ImageUploadService _imageUploadService; // Added

  // Updated constructor to accept ImageUploadService
  ExpenseApiServiceImpl(this._apiClient, this._imageUploadService);

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
    final List<dynamic> data = response as List<dynamic>;
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
    List<File>? attachments, // Matches abstract class
  }) async {
    List<String>? attachmentUrls;
    if (attachments != null && attachments.isNotEmpty) {
      attachmentUrls = await _imageUploadService.uploadImages(attachments);
    }

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

    // Send URLs to the backend
    if (attachmentUrls != null && attachmentUrls.isNotEmpty) {
      for (int i = 0; i < attachmentUrls.length; i++) {
        // Assuming backend expects fields like attachmentUrls[0], attachmentUrls[1]
        // or a single field with comma-separated values, adjust as per backend API
        request.fields['attachmentUrls[$i]'] = attachmentUrls[i];
      }
      // If backend expects a single field with a list of URLs (e.g., JSON string or comma-separated):
      // request.fields['attachmentUrls'] = jsonEncode(attachmentUrls); // Example for JSON array
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
    List<File>? newAttachments, // Matches abstract class
    List<String>? attachmentUrlsToRemove,
  }) async {
    List<String>? newUploadedAttachmentUrls;
    if (newAttachments != null && newAttachments.isNotEmpty) {
      newUploadedAttachmentUrls = await _imageUploadService.uploadImages(newAttachments);
    }

    final request = http.MultipartRequest('PUT', Uri.parse('${_apiClient.baseUrl}/expenses/$id'));
    request.headers.addAll(await _apiClient.getHeaders(requiresAuth: true));

    if (date != null) request.fields['date'] = date.toIso8601String();
    if (amount != null) request.fields['amount'] = amount.toString();
    if (motif != null) request.fields['motif'] = motif;
    if (categoryId != null) request.fields['categoryId'] = categoryId;
    if (paymentMethod != null) request.fields['paymentMethod'] = paymentMethod;
    if (supplierId != null) request.fields['supplierId'] = supplierId;
    
    if (attachmentUrlsToRemove != null && attachmentUrlsToRemove.isNotEmpty) {
      for (int i = 0; i < attachmentUrlsToRemove.length; i++) {
        request.fields['attachmentUrlsToRemove[$i]'] = attachmentUrlsToRemove[i];
      }
    }

    // Send newly uploaded URLs to the backend
    if (newUploadedAttachmentUrls != null && newUploadedAttachmentUrls.isNotEmpty) {
      for (int i = 0; i < newUploadedAttachmentUrls.length; i++) {
         // Assuming backend expects fields like newAttachmentUrls[0], newAttachmentUrls[1]
        request.fields['newAttachmentUrls[$i]'] = newUploadedAttachmentUrls[i];
      }
      // If backend expects a single field with a list of URLs:
      // request.fields['newAttachmentUrls'] = jsonEncode(newUploadedAttachmentUrls); // Example
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
