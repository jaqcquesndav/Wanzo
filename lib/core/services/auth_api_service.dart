import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/api_response.dart';
import '../../features/auth/models/user.dart';
import '../../features/company/models/registration_request.dart';
import './api_client.dart';

class AuthApiService {
  final ApiClient _apiClient;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  AuthApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<ApiResponse<User>> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        'auth/login',
        body: { // Named argument: body
          'email': email,
          'password': password,
        },
        requiresAuth: false,
      );

      if (response != null && response['data'] != null && response['data']['user'] != null && response['data']['token'] != null) {
        final user = User.fromJson(response['data']['user'] as Map<String, dynamic>);
        final token = response['data']['token'] as String;
        
        await _secureStorage.write(key: 'auth_token', value: token);

        return ApiResponse<User>(
          success: true,
          data: user, 
          message: response['message'] as String? ?? "Login successful",
          statusCode: response['statusCode'] as int? ?? 200
        );
      } else {
        throw ApiException('Invalid login response data format from server', responseBody: response, statusCode: response['statusCode'] as int?);
      }
    } on ApiException {
      rethrow; 
    } catch (e) {
      throw ApiException('Login failed: An unexpected error occurred. $e');
    }
  }

  Future<ApiResponse<User>> register(RegistrationRequest registrationRequest) async {
    try {
      final response = await _apiClient.post(
        'auth/register', 
        body: registrationRequest.toJson(), // Named argument: body
        requiresAuth: false,
      );

      if (response != null && response['data'] != null && response['data']['user'] != null && response['data']['token'] != null) {
        final user = User.fromJson(response['data']['user'] as Map<String, dynamic>);
        final token = response['data']['token'] as String;

        await _secureStorage.write(key: 'auth_token', value: token);

        return ApiResponse<User>(
          success: true,
          data: user, 
          message: response['message'] as String? ?? "Registration successful",
          statusCode: response['statusCode'] as int? ?? 201
        );
      } else {
        throw ApiException('Invalid registration response data format from server', responseBody: response, statusCode: response['statusCode'] as int?);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Registration failed: An unexpected error occurred. $e');
    }
  }

  Future<void> logout() async {
    try {
      await _secureStorage.delete(key: 'auth_token');
      // Optional: Call a backend logout endpoint if it exists
      // await _apiClient.post('auth/logout', body: {}, requiresAuth: true);
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      if (token == null) {
        return null;
      }
      final response = await _apiClient.get('auth/me', requiresAuth: true);
      if (response != null && response['data'] != null && response['data']['user'] != null) {
         return User.fromJson(response['data']['user'] as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error fetching current user: $e');
      if (e is ApiException && e.statusCode == 401) {
         await _secureStorage.delete(key: 'auth_token');
      }
      return null;
    }
  }

  Future<String?> refreshToken() async {
    print('Refresh token logic not yet implemented.');
    return null;
  }
}
