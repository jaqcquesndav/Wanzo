import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:wanzo/core/services/api_client.dart';
import 'package:wanzo/features/invoice/models/invoice.dart';

abstract class InvoiceApiService {
  Future<List<Invoice>> getInvoices({
    int? page,
    int? limit,
    String? customerId,
    InvoiceStatus? status,
    String? dateFrom,
    String? dateTo,
    String? sortBy,
    String? sortOrder,
    String? searchQuery, // For invoice number or customer name
  });

  Future<Invoice> createInvoice(Invoice invoice, {File? pdfAttachment}); // PDF could be generated client or server side

  Future<Invoice> getInvoiceById(String id);

  Future<Invoice> updateInvoice(String id, Invoice invoice, {File? pdfAttachment});

  Future<void> deleteInvoice(String id);

  Future<Invoice> updateInvoiceStatus(String id, InvoiceStatus status);

  Future<void> sendInvoiceByEmail(String id, String emailAddress);
}

class InvoiceApiServiceImpl implements InvoiceApiService {
  final ApiClient _apiClient;

  InvoiceApiServiceImpl(this._apiClient);

  @override
  Future<List<Invoice>> getInvoices({
    int? page,
    int? limit,
    String? customerId,
    InvoiceStatus? status,
    String? dateFrom,
    String? dateTo,
    String? sortBy,
    String? sortOrder,
    String? searchQuery,
  }) async {
    final queryParameters = <String, String>{
      if (page != null) 'page': page.toString(),
      if (limit != null) 'limit': limit.toString(),
      if (customerId != null) 'customerId': customerId,
      if (status != null) 'status': status.name,
      if (dateFrom != null) 'dateFrom': dateFrom,
      if (dateTo != null) 'dateTo': dateTo,
      if (sortBy != null) 'sortBy': sortBy,
      if (sortOrder != null) 'sortOrder': sortOrder,
      if (searchQuery != null) 'q': searchQuery,
    };
    final response = await _apiClient.get('invoices', queryParameters: queryParameters, requiresAuth: true);
    final List<dynamic> data = response as List<dynamic>; // Assuming API returns a list
    return data.map((json) => Invoice.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<Invoice> createInvoice(Invoice invoice, {File? pdfAttachment}) async {
    // If PDF is attached, it implies a multipart request. Otherwise, JSON.
    if (pdfAttachment != null) {
      final request = http.MultipartRequest('POST', Uri.parse('${_apiClient.baseUrl}/invoices'));
      request.headers.addAll(await _apiClient.getHeaders(requiresAuth: true));
      request.fields['invoiceData'] = invoice.toJson().toString(); // Send invoice data as a JSON string
      request.files.add(await http.MultipartFile.fromPath('pdf', pdfAttachment.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final responseData = _apiClient.handleResponse(response);
      return Invoice.fromJson(responseData as Map<String, dynamic>);
    } else {
      final response = await _apiClient.post('invoices', body: invoice.toJson(), requiresAuth: true);
      return Invoice.fromJson(response as Map<String, dynamic>);
    }
  }

  @override
  Future<Invoice> getInvoiceById(String id) async {
    final response = await _apiClient.get('invoices/$id', requiresAuth: true);
    return Invoice.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<Invoice> updateInvoice(String id, Invoice invoice, {File? pdfAttachment}) async {
     if (pdfAttachment != null) {
      final request = http.MultipartRequest('PUT', Uri.parse('${_apiClient.baseUrl}/invoices/$id'));
      request.headers.addAll(await _apiClient.getHeaders(requiresAuth: true));
      request.fields['invoiceData'] = invoice.toJson().toString();
      request.files.add(await http.MultipartFile.fromPath('pdf', pdfAttachment.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final responseData = _apiClient.handleResponse(response);
      return Invoice.fromJson(responseData as Map<String, dynamic>);
    } else {
      final response = await _apiClient.put('invoices/$id', body: invoice.toJson(), requiresAuth: true);
      return Invoice.fromJson(response as Map<String, dynamic>);
    }
  }

  @override
  Future<void> deleteInvoice(String id) async {
    await _apiClient.delete('invoices/$id', requiresAuth: true);
  }

  @override
  Future<Invoice> updateInvoiceStatus(String id, InvoiceStatus status) async {
    final response = await _apiClient.put(
      'invoices/$id/status',
      body: {'status': status.name},
      requiresAuth: true,
    );
    return Invoice.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<void> sendInvoiceByEmail(String id, String emailAddress) async {
    await _apiClient.post(
      'invoices/$id/send-email',
      body: {'email': emailAddress},
      requiresAuth: true,
    );
    // This endpoint might return a success/failure message or the updated invoice, adjust as needed.
  }
}
