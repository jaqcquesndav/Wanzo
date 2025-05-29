import 'dart:io';
import 'dart:convert'; // For jsonDecode if needed for multipart
import 'package:wanzo/core/services/api_client.dart';
import 'package:wanzo/core/models/api_response.dart';
import 'package:wanzo/features/documents/models/document_model.dart'; // Assurez-vous que ce modèle existe

class DocumentApiService {
  final ApiClient _apiClient;

  DocumentApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<ApiResponse<Document>> uploadDocument({
    required File file,
    required String entityId,
    required String entityType,
  }) async {
    try {
      final httpResponse = await _apiClient.postMultipart(
        'documents/upload', // Assumed endpoint
        file: file,
        fileField: 'documentFile', // Backend expected field name for the file
        fields: { // Additional data sent along with the file
          'entityId': entityId,
          'entityType': entityType,
        },
        requiresAuth: true,
      );

      final Map<String, dynamic>? responseData = httpResponse.body.isNotEmpty
          ? jsonDecode(httpResponse.body) as Map<String, dynamic>?
          : null;

      if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
        if (responseData != null && responseData['data'] != null) {
          final newDocument = Document.fromJson(responseData['data'] as Map<String, dynamic>);
          return ApiResponse<Document>(
            success: true,
            data: newDocument,
            message: responseData['message'] as String? ?? 'Document uploaded successfully.',
            statusCode: httpResponse.statusCode,
          );
        } else {
          throw ApiException('Invalid response data format from server for document upload', responseBody: httpResponse.body, statusCode: httpResponse.statusCode);
        }
      } else {
        throw ApiException(
          responseData?['message'] as String? ?? 'Failed to upload document',
          statusCode: httpResponse.statusCode,
          responseBody: httpResponse.body,
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to upload document: An unexpected error occurred. $e');
    }
  }

  Future<ApiResponse<List<Document>>> getDocuments({
    String? entityId,
    String? entityType,
    String? documentType,
    int? page,
    int? limit,
  }) async {
    try {
      final Map<String, String> queryParams = {};
      if (entityId != null) queryParams['entityId'] = entityId;
      if (entityType != null) queryParams['entityType'] = entityType;
      if (documentType != null) queryParams['documentType'] = documentType;
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();

      final response = await _apiClient.get('documents', queryParameters: queryParams, requiresAuth: true);
      if (response != null && response['data'] != null) {
        final documents = (response['data'] as List)
            .map((docJson) => Document.fromJson(docJson as Map<String, dynamic>))
            .toList();
        return ApiResponse<List<Document>>(
          success: true,
          data: documents,
          message: response['message'] as String? ?? 'Documents fetched successfully.',
          statusCode: response['statusCode'] as int? ?? 200,
          // paginationInfo: response['pagination'] // Si votre API retourne des infos de pagination
        );
      } else {
        throw ApiException('Invalid response data format from server', responseBody: response, statusCode: response['statusCode'] as int?);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to fetch documents: An unexpected error occurred. \$e');
    }
  }

  Future<ApiResponse<Document>> getDocumentById(String id) async {
    try {
      final response = await _apiClient.get('documents/\$id', requiresAuth: true);
      if (response != null && response['data'] != null) {
        final document = Document.fromJson(response['data'] as Map<String, dynamic>);
        return ApiResponse<Document>(
          success: true,
          data: document,
          message: response['message'] as String? ?? 'Document fetched successfully.',
          statusCode: response['statusCode'] as int? ?? 200,
        );
      } else {
        throw ApiException('Invalid response data format from server', responseBody: response, statusCode: response['statusCode'] as int?);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to fetch document: An unexpected error occurred. \$e');
    }
  }

  Future<ApiResponse<void>> deleteDocument(String id) async {
    try {
      await _apiClient.delete('documents/\$id', requiresAuth: true);
      // Pour DELETE, une réponse réussie peut ne pas avoir de 'data'.
      // Le simple fait de ne pas avoir d'exception est souvent suffisant.
      return ApiResponse<void>(
        success: true,
        message: 'Document deleted successfully.',
        statusCode: 200, // Ou 204 si le backend retourne No Content
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to delete document: An unexpected error occurred. \$e');
    }
  }
}

// Assurez-vous que le modèle Document est défini, par exemple:
// c:\\Users\\DevSpace\\Flutter\\wanzo\\lib\\features\\documents\\models\\document_model.dart
/*
class Document {
  final String id;
  final String fileName;
  final String fileUrl;
  final String documentType;
  final String entityId;
  final String entityType;
  final DateTime uploadedAt;
  final String? description; // Ajouté pour correspondre à l'upload

  Document({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    required this.documentType,
    required this.entityId,
    required this.entityType,
    required this.uploadedAt,
    this.description,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'] as String,
      fileName: json['fileName'] as String,
      fileUrl: json['fileUrl'] as String,
      documentType: json['documentType'] as String,
      entityId: json['entityId'] as String,
      entityType: json['entityType'] as String,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
      description: json['description'] as String?,
    );
  }
}
*/
