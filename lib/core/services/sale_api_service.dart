import '../models/api_response.dart';
import '../../features/sales/models/sale.dart';
import './api_client.dart';

class SaleApiService {
  final ApiClient _apiClient;

  SaleApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<ApiResponse<List<Sale>>> getSales({Map<String, String>? queryParameters}) async {
    try {
      final response = await _apiClient.get('sales', queryParameters: queryParameters, requiresAuth: true);
      if (response != null && response['data'] != null) {
        final sales = (response['data'] as List)
            .map((saleJson) => Sale.fromJson(saleJson as Map<String, dynamic>))
            .toList();
        return ApiResponse<List<Sale>>(
          success: true,
          data: sales,
          message: response['message'] as String? ?? 'Sales fetched successfully.',
          statusCode: response['statusCode'] as int? ?? 200,
        );
      } else {
        throw ApiException('Invalid response data format from server', responseBody: response, statusCode: response['statusCode'] as int?);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to fetch sales: An unexpected error occurred. \$e');
    }
  }

  Future<ApiResponse<Sale>> getSaleById(String id) async {
    try {
      final response = await _apiClient.get('sales/\$id', requiresAuth: true);
      if (response != null && response['data'] != null) {
        final sale = Sale.fromJson(response['data'] as Map<String, dynamic>);
        return ApiResponse<Sale>(
          success: true,
          data: sale,
          message: response['message'] as String? ?? 'Sale fetched successfully.',
          statusCode: response['statusCode'] as int? ?? 200,
        );
      } else {
        throw ApiException('Invalid response data format from server', responseBody: response, statusCode: response['statusCode'] as int?);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to fetch sale: An unexpected error occurred. \$e');
    }
  }

  Future<ApiResponse<Sale>> createSale(Sale sale) async {
    try {
      final response = await _apiClient.post('sales', body: sale.toJson(), requiresAuth: true);
      if (response != null && response['data'] != null) {
        final createdSale = Sale.fromJson(response['data'] as Map<String, dynamic>);
        return ApiResponse<Sale>(
          success: true,
          data: createdSale,
          message: response['message'] as String? ?? 'Sale created successfully.',
          statusCode: response['statusCode'] as int? ?? 201,
        );
      } else {
        throw ApiException('Invalid response data format from server', responseBody: response, statusCode: response['statusCode'] as int?);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to create sale: An unexpected error occurred. \$e');
    }
  }

  Future<ApiResponse<Sale>> updateSale(String id, Sale sale) async {
    try {
      final response = await _apiClient.put('sales/\$id', body: sale.toJson(), requiresAuth: true);
      if (response != null && response['data'] != null) {
        final updatedSale = Sale.fromJson(response['data'] as Map<String, dynamic>);
        return ApiResponse<Sale>(
          success: true,
          data: updatedSale,
          message: response['message'] as String? ?? 'Sale updated successfully.',
          statusCode: response['statusCode'] as int? ?? 200,
        );
      } else {
        throw ApiException('Invalid response data format from server', responseBody: response, statusCode: response['statusCode'] as int?);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to update sale: An unexpected error occurred. \$e');
    }
  }

  Future<ApiResponse<void>> deleteSale(String id) async {
    try {
      final response = await _apiClient.delete('sales/\$id', requiresAuth: true);
      return ApiResponse<void>(
        success: true,
        message: response['message'] as String? ?? 'Sale deleted successfully.',
        statusCode: response['statusCode'] as int? ?? 200,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to delete sale: An unexpected error occurred. \$e');
    }
  }
}
