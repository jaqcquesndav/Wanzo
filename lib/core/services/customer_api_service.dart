import '../models/api_response.dart';
import '../../features/customers/models/customer.dart';
import './api_client.dart';

class CustomerApiService {
  final ApiClient _apiClient;

  CustomerApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<ApiResponse<List<Customer>>> getCustomers({Map<String, String>? queryParams}) async {
    try {
      final response = await _apiClient.get('customers', queryParameters: queryParams, requiresAuth: true);
      if (response != null && response['data'] != null) {
        final customers = (response['data'] as List)
            .map((customerJson) => Customer.fromJson(customerJson as Map<String, dynamic>))
            .toList();
        return ApiResponse<List<Customer>>(
          success: true,
          data: customers,
          message: response['message'] as String? ?? 'Customers fetched successfully.',
          statusCode: response['statusCode'] as int? ?? 200,
        );
      } else {
        throw ApiException('Invalid response data format from server', responseBody: response, statusCode: response['statusCode'] as int?);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to fetch customers: An unexpected error occurred. \$e');
    }
  }

  Future<ApiResponse<Customer>> getCustomerById(String id) async {
    try {
      final response = await _apiClient.get('customers/\$id', requiresAuth: true);
      if (response != null && response['data'] != null) {
        final customer = Customer.fromJson(response['data'] as Map<String, dynamic>);
        return ApiResponse<Customer>(
          success: true,
          data: customer,
          message: response['message'] as String? ?? 'Customer fetched successfully.',
          statusCode: response['statusCode'] as int? ?? 200,
        );
      } else {
        throw ApiException('Invalid response data format from server', responseBody: response, statusCode: response['statusCode'] as int?);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to fetch customer: An unexpected error occurred. \$e');
    }
  }

  Future<ApiResponse<Customer>> createCustomer(Customer customer) async {
    try {
      final response = await _apiClient.post('customers', body: customer.toJson(), requiresAuth: true);
      if (response != null && response['data'] != null) {
        final createdCustomer = Customer.fromJson(response['data'] as Map<String, dynamic>);
        return ApiResponse<Customer>(
          success: true,
          data: createdCustomer,
          message: response['message'] as String? ?? 'Customer created successfully.',
          statusCode: response['statusCode'] as int? ?? 201,
        );
      } else {
        throw ApiException('Invalid response data format from server', responseBody: response, statusCode: response['statusCode'] as int?);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to create customer: An unexpected error occurred. \$e');
    }
  }

  Future<ApiResponse<Customer>> updateCustomer(String id, Customer customer) async {
    try {
      final response = await _apiClient.put('customers/\$id', body: customer.toJson(), requiresAuth: true);
      if (response != null && response['data'] != null) {
        final updatedCustomer = Customer.fromJson(response['data'] as Map<String, dynamic>);
        return ApiResponse<Customer>(
          success: true,
          data: updatedCustomer,
          message: response['message'] as String? ?? 'Customer updated successfully.',
          statusCode: response['statusCode'] as int? ?? 200,
        );
      } else {
        throw ApiException('Invalid response data format from server', responseBody: response, statusCode: response['statusCode'] as int?);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to update customer: An unexpected error occurred. \$e');
    }
  }

  Future<ApiResponse<void>> deleteCustomer(String id) async {
    try {
      final response = await _apiClient.delete('customers/\$id', requiresAuth: true);
      return ApiResponse<void>(
        success: true,
        message: response['message'] as String? ?? 'Customer deleted successfully.',
        statusCode: response['statusCode'] as int? ?? 200,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to delete customer: An unexpected error occurred. \$e');
    }
  }
}
