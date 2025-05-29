import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:wanzo/core/services/api_client.dart';
import 'package:wanzo/features/inventory/models/product.dart';
import 'package:wanzo/features/inventory/models/stock_transaction.dart';

abstract class InventoryApiService {
  Future<List<Product>> getProducts({
    int? page,
    int? limit,
    String? category,
    String? sortBy,
    String? sortOrder,
    String? searchQuery,
  });

  Future<Product> createProduct(Product product, {File? image});

  Future<Product> getProductById(String id);

  Future<Product> updateProduct(String id, Product product, {File? image, bool? removeImage});

  Future<void> deleteProduct(String id);

  Future<List<StockTransaction>> getStockTransactions({
    String? productId,
    int? page,
    int? limit,
    StockTransactionType? type,
    String? dateFrom,
    String? dateTo,
  });

  Future<StockTransaction> createStockTransaction(StockTransaction transaction);

  Future<StockTransaction> getStockTransactionById(String id);

  // Future<StockTransaction> updateStockTransaction(String id, StockTransaction transaction); // Usually not updated
  // Future<void> deleteStockTransaction(String id); // Usually not deleted
}

class InventoryApiServiceImpl implements InventoryApiService {
  final ApiClient _apiClient;

  InventoryApiServiceImpl(this._apiClient);

  @override
  Future<List<Product>> getProducts({
    int? page,
    int? limit,
    String? category,
    String? sortBy,
    String? sortOrder,
    String? searchQuery,
  }) async {
    final queryParameters = <String, String>{
      if (page != null) 'page': page.toString(),
      if (limit != null) 'limit': limit.toString(),
      if (category != null) 'category': category,
      if (sortBy != null) 'sortBy': sortBy,
      if (sortOrder != null) 'sortOrder': sortOrder,
      if (searchQuery != null) 'q': searchQuery,
    };
    final response = await _apiClient.get('inventory/products', queryParameters: queryParameters, requiresAuth: true);
    final List<dynamic> data = response as List<dynamic>;
    return data.map((json) => Product.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<Product> createProduct(Product product, {File? image}) async {
    final request = http.MultipartRequest('POST', Uri.parse('${_apiClient.baseUrl}/inventory/products'));
    request.headers.addAll(await _apiClient.getHeaders(requiresAuth: true));

    request.fields.addAll(product.toJson().map((key, value) => MapEntry(key, value.toString()))); // Convert all values to string

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final responseData = _apiClient.handleResponse(response);
    return Product.fromJson(responseData as Map<String, dynamic>);
  }

  @override
  Future<Product> getProductById(String id) async {
    final response = await _apiClient.get('inventory/products/$id', requiresAuth: true);
    return Product.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<Product> updateProduct(String id, Product product, {File? image, bool? removeImage}) async {
    final request = http.MultipartRequest('PUT', Uri.parse('${_apiClient.baseUrl}/inventory/products/$id'));
    request.headers.addAll(await _apiClient.getHeaders(requiresAuth: true));

    request.fields.addAll(product.toJson().map((key, value) => MapEntry(key, value.toString())));
    if (removeImage == true) {
      request.fields['removeImage'] = 'true';
    }

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final responseData = _apiClient.handleResponse(response);
    return Product.fromJson(responseData as Map<String, dynamic>);
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _apiClient.delete('inventory/products/$id', requiresAuth: true);
  }

  @override
  Future<List<StockTransaction>> getStockTransactions({
    String? productId,
    int? page,
    int? limit,
    StockTransactionType? type,
    String? dateFrom,
    String? dateTo,
  }) async {
    final queryParameters = <String, String>{
      if (productId != null) 'productId': productId,
      if (page != null) 'page': page.toString(),
      if (limit != null) 'limit': limit.toString(),
      if (type != null) 'type': type.name, // Assuming enum .name gives the string representation
      if (dateFrom != null) 'dateFrom': dateFrom,
      if (dateTo != null) 'dateTo': dateTo,
    };
    final response = await _apiClient.get('inventory/stock-transactions', queryParameters: queryParameters, requiresAuth: true);
    final List<dynamic> data = response as List<dynamic>;
    // Assuming StockTransaction.fromJson exists
    return data.map((json) => StockTransaction.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<StockTransaction> createStockTransaction(StockTransaction transaction) async {
    final response = await _apiClient.post('inventory/stock-transactions', body: transaction.toJson(), requiresAuth: true);
    // Assuming StockTransaction.fromJson exists
    return StockTransaction.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<StockTransaction> getStockTransactionById(String id) async {
    final response = await _apiClient.get('inventory/stock-transactions/$id', requiresAuth: true);
    // Assuming StockTransaction.fromJson exists
    return StockTransaction.fromJson(response as Map<String, dynamic>);
  }
}
