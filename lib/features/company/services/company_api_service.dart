import 'dart:io'; // Added for File type
import 'dart:convert'; // Added for jsonDecode
import 'package:wanzo/core/services/api_client.dart';
import 'package:wanzo/core/models/api_response.dart';
import 'package:wanzo/features/company/models/company_profile.dart'; // Assurez-vous que ce modèle existe

class CompanyApiService {
  final ApiClient _apiClient;

  CompanyApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<ApiResponse<CompanyProfile>> getCompanyProfile() async {
    try {
      final response = await _apiClient.get('company', requiresAuth: true);
      if (response != null && response['data'] != null) {
        final profile = CompanyProfile.fromJson(response['data'] as Map<String, dynamic>);
        return ApiResponse<CompanyProfile>(
          success: true,
          data: profile,
          message: response['message'] as String? ?? 'Company profile fetched successfully.',
          statusCode: response['statusCode'] as int? ?? 200,
        );
      } else {
        throw ApiException('Invalid response data format from server', responseBody: response, statusCode: response['statusCode'] as int?);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to fetch company profile: An unexpected error occurred. \$e');
    }
  }

  Future<ApiResponse<CompanyProfile>> updateCompanyProfile(CompanyProfile profile) async {
    try {
      final response = await _apiClient.put('company', body: profile.toJson(), requiresAuth: true);
      if (response != null && response['data'] != null) {
        final updatedProfile = CompanyProfile.fromJson(response['data'] as Map<String, dynamic>);
        return ApiResponse<CompanyProfile>(
          success: true,
          data: updatedProfile,
          message: response['message'] as String? ?? 'Company profile updated successfully.',
          statusCode: response['statusCode'] as int? ?? 200,
        );
      } else {
        throw ApiException('Invalid response data format from server', responseBody: response, statusCode: response['statusCode'] as int?);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to update company profile: An unexpected error occurred. \$e');
    }
  }

  // Assurez-vous d'avoir une méthode pour gérer l'upload de fichiers dans ApiClient
  // Exemple: Future<dynamic> postMultipart(String endpoint, {required File file, required String fileField, Map<String, String>? fields, bool requiresAuth = false})
  Future<ApiResponse<String>> uploadCompanyLogo(File logoFile) async {
    try {
      final httpResponse = await _apiClient.postMultipart(
        'company/logo',
        file: logoFile,
        fileField: 'logoFile', // Doit correspondre à ce que le backend attend
        requiresAuth: true,
      );

      // Decode the response body from JSON string to Map
      final Map<String, dynamic>? responseData = httpResponse.body.isNotEmpty
          ? jsonDecode(httpResponse.body) as Map<String, dynamic>?
          : null;

      if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
        if (responseData != null && responseData['data'] != null && responseData['data']['logoUrl'] != null) {
          return ApiResponse<String>(
            success: true,
            data: responseData['data']['logoUrl'] as String,
            message: responseData['message'] as String? ?? 'Company logo uploaded successfully.',
            statusCode: httpResponse.statusCode,
          );
        } else {
          throw ApiException('Invalid response data format from server for logo upload', responseBody: httpResponse.body, statusCode: httpResponse.statusCode);
        }
      } else {
        // Handle error responses based on statusCode
        throw ApiException(
          responseData?['message'] as String? ?? 'Failed to upload company logo',
          statusCode: httpResponse.statusCode,
          responseBody: httpResponse.body,
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to upload company logo: An unexpected error occurred. $e');
    }
  }
}

// Assurez-vous que le modèle CompanyProfile est défini, par exemple:
// c:\\Users\\DevSpace\\Flutter\\wanzo\\lib\\features\\company\\models\\company_profile.dart
/*
class CompanyProfile {
  final String id;
  final String name;
  final String? registrationNumber;
  final String? taxId;
  final String? address;
  final String? city;
  final String? country;
  final String? phoneNumber;
  final String? email;
  final String? website;
  final String? logoUrl;
  final String? industry;
  final DateTime createdAt;
  final DateTime updatedAt;

  CompanyProfile({
    required this.id,
    required this.name,
    this.registrationNumber,
    this.taxId,
    this.address,
    this.city,
    this.country,
    this.phoneNumber,
    this.email,
    this.website,
    this.logoUrl,
    this.industry,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CompanyProfile.fromJson(Map<String, dynamic> json) {
    return CompanyProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      registrationNumber: json['registrationNumber'] as String?,
      taxId: json['taxId'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
      logoUrl: json['logoUrl'] as String?,
      industry: json['industry'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'registrationNumber': registrationNumber,
      'taxId': taxId,
      'address': address,
      'city': city,
      'country': country,
      'phoneNumber': phoneNumber,
      'email': email,
      'website': website,
      'industry': industry,
      // id, createdAt, updatedAt, logoUrl ne sont généralement pas envoyés lors d'un update de cette manière
    };
  }
}
*/
