import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Added for token storage

// TODO: Consider a more robust error handling strategy (custom exceptions)
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic responseBody;

  ApiException(this.message, {this.statusCode, this.responseBody});

  @override
  String toString() {
    return 'ApiException: $message (Status Code: $statusCode)';
  }
}

class ApiClient {
  final String _baseUrl = 'http://localhost:3000/api';
  final http.Client _httpClient;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(); // Added

  // Private constructor
  ApiClient._internal({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  // Singleton instance
  static final ApiClient _instance = ApiClient._internal();

  // Factory constructor to return the singleton instance
  factory ApiClient() => _instance;

  Future<Map<String, String>> _getHeaders({bool requiresAuth = false}) async {
    final headers = <String, String>{
      HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
      HttpHeaders.acceptHeader: 'application/json',
    };
    if (requiresAuth) {
      String? token = await _secureStorage.read(key: 'auth_token');
      if (token != null) {
        headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<dynamic> get(String endpoint, {Map<String, String>? queryParameters, bool requiresAuth = false}) async { // Added queryParameters
    final url = Uri.parse('$_baseUrl/$endpoint').replace(queryParameters: queryParameters); // Use queryParameters
    try {
      final response = await _httpClient.get(
        url,
        headers: await _getHeaders(requiresAuth: requiresAuth),
      );
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Network error: Could not connect to the server.');
    } on HttpException {
      throw ApiException('Network error: Could not find the server.');
    } on FormatException {
      throw ApiException('Network error: Bad response format.');
    } catch (e) {
      throw ApiException('An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<dynamic> post(String endpoint, {dynamic body, bool requiresAuth = false}) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    try {
      final response = await _httpClient.post(
        url,
        headers: await _getHeaders(requiresAuth: requiresAuth),
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Network error: Could not connect to the server.');
    } on HttpException {
      throw ApiException('Network error: Could not find the server.');
    } on FormatException {
      throw ApiException('Network error: Bad response format.');
    } catch (e) {
      throw ApiException('An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<dynamic> put(String endpoint, {dynamic body, bool requiresAuth = false}) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    try {
      final response = await _httpClient.put(
        url,
        headers: await _getHeaders(requiresAuth: requiresAuth),
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Network error: Could not connect to the server.');
    } on HttpException {
      throw ApiException('Network error: Could not find the server.');
    } on FormatException {
      throw ApiException('Network error: Bad response format.');
    } catch (e) {
      throw ApiException('An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<dynamic> delete(String endpoint, {bool requiresAuth = false}) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    try {
      final response = await _httpClient.delete(
        url,
        headers: await _getHeaders(requiresAuth: requiresAuth),
      );
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Network error: Could not connect to the server.');
    } on HttpException {
      throw ApiException('Network error: Could not find the server.');
    } on FormatException {
      throw ApiException('Network error: Bad response format.');
    } catch (e) {
      throw ApiException('An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<http.Response> postMultipart(String endpoint, {required File file, required String fileField, Map<String, String>? fields, bool requiresAuth = false}) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    try {
      var request = http.MultipartRequest('POST', url);
      request.headers.addAll(await _getHeaders(requiresAuth: requiresAuth));
      if (fields != null) {
        request.fields.addAll(fields);
      }
      request.files.add(await http.MultipartFile.fromPath(
        fileField,
        file.path,
        // contentType: MediaType('image', 'jpeg'), // Example, adjust as needed
      ));
      final streamedResponse = await _httpClient.send(request);
      final response = await http.Response.fromStream(streamedResponse);
      // We return the raw http.Response here because _handleResponse expects JSON
      // and multipart responses might not always be JSON or might need different handling.
      // The caller (SubscriptionRepository) will handle parsing.
      return response;
    } on SocketException {
      throw ApiException('Network error: Could not connect to the server.');
    } on HttpException {
      throw ApiException('Network error: Could not find the server.');
    } catch (e) {
      throw ApiException('An unexpected error occurred during multipart POST: ${e.toString()}');
    }
  }

  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final responseBody = response.body;

    if (statusCode >= 200 && statusCode < 300) {
      if (responseBody.isEmpty) {
        return null; // Or an empty map/list depending on expected response
      }
      try {
        return jsonDecode(responseBody);
      } catch (e) {
        throw ApiException('Error decoding JSON response', statusCode: statusCode, responseBody: responseBody);
      }
    } else if (statusCode == 400) {
      throw ApiException('Bad request', statusCode: statusCode, responseBody: responseBody);
    } else if (statusCode == 401) {
      throw ApiException('Unauthorized', statusCode: statusCode, responseBody: responseBody);
      // TODO: Potentially trigger re-authentication flow
    } else if (statusCode == 403) {
      throw ApiException('Forbidden', statusCode: statusCode, responseBody: responseBody);
    } else if (statusCode == 404) {
      throw ApiException('Resource not found', statusCode: statusCode, responseBody: responseBody);
    } else if (statusCode >= 500 && statusCode < 600) {
      throw ApiException('Server error', statusCode: statusCode, responseBody: responseBody);
    } else {
      throw ApiException('Unhandled HTTP error', statusCode: statusCode, responseBody: responseBody);
    }
  }

  // Method to close the http client when it's no longer needed.
  // Call this in your app's dispose method or when the ApiClient is no longer in use.
  void dispose() {
    _httpClient.close();
  }
}
