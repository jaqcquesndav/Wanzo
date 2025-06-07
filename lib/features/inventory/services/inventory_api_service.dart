import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:wanzo/core/services/api_client.dart';
import 'package:wanzo/core/models/api_response.dart'; // Ajout de l'import
import 'package:wanzo/features/inventory/models/product.dart';
import 'package:wanzo/features/inventory/models/stock_transaction.dart';

abstract class InventoryApiService {
  Future<ApiResponse<List<Product>>> getProducts({
    int? page,
    int? limit,
    String? category,
    String? sortBy,
    String? sortOrder,
    String? searchQuery,
  });

  Future<ApiResponse<Product>> createProduct(Product product, {File? image});

  Future<ApiResponse<Product>> getProductById(String id);

  Future<ApiResponse<Product>> updateProduct(String id, Product product, {File? image, bool? removeImage});

  Future<ApiResponse<void>> deleteProduct(String id);

  Future<ApiResponse<List<StockTransaction>>> getStockTransactions({
    String? productId,
    int? page,
    int? limit,
    StockTransactionType? type,
    String? dateFrom,
    String? dateTo,
  });

  Future<ApiResponse<StockTransaction>> createStockTransaction(StockTransaction transaction);

  Future<ApiResponse<StockTransaction>> getStockTransactionById(String id);

  // Future<ApiResponse<StockTransaction>> updateStockTransaction(String id, StockTransaction transaction); // Usually not updated
  // Future<ApiResponse<void>> deleteStockTransaction(String id); // Usually not deleted
}

class InventoryApiServiceImpl implements InventoryApiService {
  final ApiClient _apiClient;

  InventoryApiServiceImpl(this._apiClient);
  @override
  Future<ApiResponse<List<Product>>> getProducts({
    int? page,
    int? limit,
    String? category,
    String? sortBy,
    String? sortOrder,
    String? searchQuery,
  }) async {
    try {
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
      final products = data.map((json) => Product.fromJson(json as Map<String, dynamic>)).toList();
      
      return ApiResponse<List<Product>>(
        success: true,
        data: products,
        message: 'Products fetched successfully',
        statusCode: 200,
      );
    } on ApiException catch (e) {
      return ApiResponse<List<Product>>(
        success: false,
        data: null,
        message: e.message,
        statusCode: e.statusCode ?? 500,
      );
    } catch (e) {
      return ApiResponse<List<Product>>(
        success: false,
        data: null,
        message: 'Failed to fetch products: ${e.toString()}',
        statusCode: 500,
      );
    }
  }
  @override
  Future<ApiResponse<Product>> createProduct(Product product, {File? image}) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('${_apiClient.baseUrl}/inventory/products'));
      request.headers.addAll(await _apiClient.getHeaders(requiresAuth: true));

      request.fields.addAll(product.toJson().map((key, value) => MapEntry(key, value.toString()))); // Convert all values to string

      if (image != null) {
        request.files.add(await http.MultipartFile.fromPath('image', image.path));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final responseData = _apiClient.handleResponse(response);
      final productData = Product.fromJson(responseData as Map<String, dynamic>);
      
      return ApiResponse<Product>(
        success: true,
        data: productData,
        message: 'Product created successfully',
        statusCode: 201,
      );
    } on ApiException catch (e) {
      return ApiResponse<Product>(
        success: false,
        data: null,
        message: e.message,
        statusCode: e.statusCode ?? 500,
      );
    } catch (e) {
      return ApiResponse<Product>(
        success: false,
        data: null,
        message: 'Failed to create product: ${e.toString()}',
        statusCode: 500,
      );
    }
  }
  @override
  Future<ApiResponse<Product>> getProductById(String id) async {
    try {
      final response = await _apiClient.get('inventory/products/$id', requiresAuth: true);
      final productData = Product.fromJson(response as Map<String, dynamic>);
      
      return ApiResponse<Product>(
        success: true,
        data: productData,
        message: 'Product fetched successfully',
        statusCode: 200,
      );
    } on ApiException catch (e) {
      return ApiResponse<Product>(
        success: false,
        data: null,
        message: e.message,
        statusCode: e.statusCode ?? 500,
      );
    } catch (e) {
      return ApiResponse<Product>(
        success: false,
        data: null,
        message: 'Failed to fetch product: ${e.toString()}',
        statusCode: 500,
      );
    }
  }
  @override
  Future<ApiResponse<Product>> updateProduct(String id, Product product, {File? image, bool? removeImage}) async {
    try {
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
      final updatedProduct = Product.fromJson(responseData as Map<String, dynamic>);
      
      return ApiResponse<Product>(
        success: true,
        data: updatedProduct,
        message: 'Product updated successfully',
        statusCode: 200,
      );
    } on ApiException catch (e) {
      return ApiResponse<Product>(
        success: false,
        data: null,
        message: e.message,
        statusCode: e.statusCode ?? 500,
      );
    } catch (e) {
      return ApiResponse<Product>(
        success: false,
        data: null,
        message: 'Failed to update product: ${e.toString()}',
        statusCode: 500,
      );
    }
  }
  @override
  Future<ApiResponse<void>> deleteProduct(String id) async {
    try {
      await _apiClient.delete('inventory/products/$id', requiresAuth: true);
      return ApiResponse<void>(
        success: true,
        data: null,
        message: 'Product deleted successfully',
        statusCode: 200,
      );
    } on ApiException catch (e) {
      return ApiResponse<void>(
        success: false,
        data: null,
        message: e.message,
        statusCode: e.statusCode ?? 500,
      );
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        data: null,
        message: 'Failed to delete product: ${e.toString()}',
        statusCode: 500,
      );
    }
  }
  @override
  Future<ApiResponse<List<StockTransaction>>> getStockTransactions({
    String? productId,
    int? page,
    int? limit,
    StockTransactionType? type,
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      final queryParameters = <String, String>{
        if (productId != null) 'productId': productId,
        if (page != null) 'page': page.toString(),
        if (limit != null) 'limit': limit.toString(),
        if (type != null) 'type': type.name, // Assuming enum .name gives the string representation
        if (dateFrom != null) 'dateFrom': dateFrom,
        if (dateTo != null) 'dateTo': dateTo,
      };
      final response = await _apiClient.get('inventory/stock-transactions', 
          queryParameters: queryParameters, requiresAuth: true);
      final List<dynamic> data = response as List<dynamic>;
      final transactions = data.map((json) => 
          StockTransaction.fromJson(json as Map<String, dynamic>)).toList();
      
      return ApiResponse<List<StockTransaction>>(
        success: true,
        data: transactions,
        message: 'Stock transactions fetched successfully',
        statusCode: 200,
      );
    } on ApiException catch (e) {
      return ApiResponse<List<StockTransaction>>(
        success: false,
        data: null,
        message: e.message,
        statusCode: e.statusCode ?? 500,
      );
    } catch (e) {
      return ApiResponse<List<StockTransaction>>(
        success: false,
        data: null,
        message: 'Failed to fetch stock transactions: ${e.toString()}',
        statusCode: 500,
      );
    }
  }
  @override
  Future<ApiResponse<StockTransaction>> createStockTransaction(StockTransaction transaction) async {
    try {
      final response = await _apiClient.post('inventory/stock-transactions', 
          body: transaction.toJson(), requiresAuth: true);
      final transactionData = StockTransaction.fromJson(response as Map<String, dynamic>);
      
      return ApiResponse<StockTransaction>(
        success: true,
        data: transactionData,
        message: 'Stock transaction created successfully',
        statusCode: 201,
      );
    } on ApiException catch (e) {
      return ApiResponse<StockTransaction>(
        success: false,
        data: null,
        message: e.message,
        statusCode: e.statusCode ?? 500,
      );
    } catch (e) {
      return ApiResponse<StockTransaction>(
        success: false,
        data: null,
        message: 'Failed to create stock transaction: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<ApiResponse<StockTransaction>> getStockTransactionById(String id) async {
    try {
      final response = await _apiClient.get('inventory/stock-transactions/$id', requiresAuth: true);
      final transactionData = StockTransaction.fromJson(response as Map<String, dynamic>);
      
      return ApiResponse<StockTransaction>(
        success: true,
        data: transactionData,
        message: 'Stock transaction fetched successfully',
        statusCode: 200,
      );
    } on ApiException catch (e) {
      return ApiResponse<StockTransaction>(
        success: false,
        data: null,
        message: e.message,
        statusCode: e.statusCode ?? 500,
      );
    } catch (e) {
      return ApiResponse<StockTransaction>(
        success: false,
        data: null,
        message: 'Failed to fetch stock transaction: ${e.toString()}',
        statusCode: 500,
      );
    }
  }
}
