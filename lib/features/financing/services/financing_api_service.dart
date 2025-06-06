import 'package:wanzo/core/services/api_client.dart';
import 'package:wanzo/core/models/api_response.dart';
import 'package:wanzo/features/financing/models/financing_request.dart';

class FinancingApiService {
  final ApiClient _apiClient;

  FinancingApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Récupère la liste des demandes de financement
  /// Paramètres optionnels:
  /// - status: statut de la demande (pending, approved, rejected, etc.)
  /// - type: type de financement (cashCredit, investmentCredit, leasing, etc.)
  /// - financialProduct: produit financier (cashFlow, investment, equipment, etc.)
  Future<ApiResponse<List<FinancingRequest>>> getFinancingRequests({
    String? status,
    FinancingType? type,
    FinancialProduct? financialProduct,
    DateTime? dateFrom,
    DateTime? dateTo,
    int? page,
    int? limit,
  }) async {
    try {
      final Map<String, String> queryParams = {};
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();
      if (status != null) queryParams['status'] = status;
      if (type != null) queryParams['type'] = type.toString().split('.').last;
      if (financialProduct != null) queryParams['financialProduct'] = financialProduct.toString().split('.').last;
      if (dateFrom != null) queryParams['dateFrom'] = dateFrom.toIso8601String();
      if (dateTo != null) queryParams['dateTo'] = dateTo.toIso8601String();

      final response = await _apiClient.get('financing-requests', queryParameters: queryParams, requiresAuth: true);
      
      if (response != null && response['data'] != null) {
        final requests = (response['data'] as List)
            .map((reqJson) => FinancingRequest.fromJson(reqJson as Map<String, dynamic>))
            .toList();
        
        return ApiResponse<List<FinancingRequest>>(
          success: true,
          data: requests,
          message: response['message'] as String? ?? 'Demandes de financement récupérées avec succès.',
          statusCode: response['statusCode'] as int? ?? 200,
        );
      } else {
        throw ApiException(
          'Format de réponse invalide du serveur', 
          responseBody: response, 
          statusCode: response['statusCode'] as int?
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Échec de récupération des demandes de financement: Une erreur inattendue est survenue. $e');
    }
  }
  /// Crée une nouvelle demande de financement
  Future<ApiResponse<FinancingRequest>> createFinancingRequest(FinancingRequest request) async {
    try {
      final response = await _apiClient.post('financing-requests', body: request.toJson(), requiresAuth: true);
      
      if (response != null && response['data'] != null) {
        final createdRequest = FinancingRequest.fromJson(response['data'] as Map<String, dynamic>);
        
        return ApiResponse<FinancingRequest>(
          success: true,
          data: createdRequest,
          message: response['message'] as String? ?? 'Demande de financement créée avec succès.',
          statusCode: response['statusCode'] as int? ?? 201,
        );
      } else {
        throw ApiException(
          'Format de réponse invalide du serveur', 
          responseBody: response, 
          statusCode: response['statusCode'] as int?
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Échec de création de la demande de financement: Une erreur inattendue est survenue. $e');
    }
  }

  /// Récupère une demande de financement par son ID
  Future<ApiResponse<FinancingRequest>> getFinancingRequestById(String id) async {
    try {
      final response = await _apiClient.get('financing-requests/$id', requiresAuth: true);
      
      if (response != null && response['data'] != null) {
        final request = FinancingRequest.fromJson(response['data'] as Map<String, dynamic>);
        
        return ApiResponse<FinancingRequest>(
          success: true,
          data: request,
          message: response['message'] as String? ?? 'Demande de financement récupérée avec succès.',
          statusCode: response['statusCode'] as int? ?? 200,
        );
      } else {
        throw ApiException(
          'Format de réponse invalide du serveur', 
          responseBody: response, 
          statusCode: response['statusCode'] as int?
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Échec de récupération de la demande de financement: Une erreur inattendue est survenue. $e');
    }
  }
  /// Met à jour une demande de financement existante
  Future<ApiResponse<FinancingRequest>> updateFinancingRequest(String id, FinancingRequest request) async {
    try {
      final response = await _apiClient.put('financing-requests/$id', body: request.toJson(), requiresAuth: true);
      
      if (response != null && response['data'] != null) {
        final updatedRequest = FinancingRequest.fromJson(response['data'] as Map<String, dynamic>);
        
        return ApiResponse<FinancingRequest>(
          success: true,
          data: updatedRequest,
          message: response['message'] as String? ?? 'Demande de financement mise à jour avec succès.',
          statusCode: response['statusCode'] as int? ?? 200,
        );
      } else {
        throw ApiException(
          'Format de réponse invalide du serveur', 
          responseBody: response, 
          statusCode: response['statusCode'] as int?
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Échec de mise à jour de la demande de financement: Une erreur inattendue est survenue. $e');
    }
  }

  /// Supprime une demande de financement
  Future<ApiResponse<void>> deleteFinancingRequest(String id) async {
    try {
      final response = await _apiClient.delete('financing-requests/$id', requiresAuth: true);
      
      return ApiResponse<void>(
        success: true,
        data: null,
        message: response != null && response['message'] != null 
            ? response['message'] as String 
            : 'Demande de financement supprimée avec succès.',
        statusCode: response != null && response['statusCode'] != null 
            ? response['statusCode'] as int 
            : 200,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Échec de suppression de la demande de financement: Une erreur inattendue est survenue. $e');
    }
  }
  /// Approuve une demande de financement
  Future<ApiResponse<FinancingRequest>> approveFinancingRequest(
    String id, {
    required DateTime approvalDate,
    double? interestRate,
    int? termMonths,
    double? monthlyPayment,
  }) async {
    try {
      final Map<String, dynamic> requestData = {
        'approvalDate': approvalDate.toIso8601String(),
        'status': 'approved',
      };

      if (interestRate != null) {
        requestData['interestRate'] = interestRate;
      }
      if (termMonths != null) {
        requestData['termMonths'] = termMonths;
      }
      if (monthlyPayment != null) {
        requestData['monthlyPayment'] = monthlyPayment;
      }

      final response = await _apiClient.put('financing-requests/$id/approve', body: requestData, requiresAuth: true);
      
      if (response != null && response['data'] != null) {
        final approvedRequest = FinancingRequest.fromJson(response['data'] as Map<String, dynamic>);
        
        return ApiResponse<FinancingRequest>(
          success: true,
          data: approvedRequest,
          message: response['message'] as String? ?? 'Demande de financement approuvée avec succès.',
          statusCode: response['statusCode'] as int? ?? 200,
        );
      } else {
        throw ApiException(
          'Format de réponse invalide du serveur', 
          responseBody: response, 
          statusCode: response['statusCode'] as int?
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Échec d\'approbation de la demande de financement: Une erreur inattendue est survenue. $e');
    }
  }
  /// Débloque les fonds pour une demande de financement
  Future<ApiResponse<FinancingRequest>> disburseFunds(
    String id, {
    required DateTime disbursementDate,
    List<DateTime>? scheduledPayments,
  }) async {
    try {
      final Map<String, dynamic> requestData = {
        'disbursementDate': disbursementDate.toIso8601String(),
        'status': 'disbursed',
      };

      if (scheduledPayments != null) {
        requestData['scheduledPayments'] = scheduledPayments.map((date) => date.toIso8601String()).toList();
      }

      final response = await _apiClient.put('financing-requests/$id/disburse', body: requestData, requiresAuth: true);
      
      if (response != null && response['data'] != null) {
        final disbursedRequest = FinancingRequest.fromJson(response['data'] as Map<String, dynamic>);
        
        return ApiResponse<FinancingRequest>(
          success: true,
          data: disbursedRequest,
          message: response['message'] as String? ?? 'Fonds débloqués avec succès.',
          statusCode: response['statusCode'] as int? ?? 200,
        );
      } else {
        throw ApiException(
          'Format de réponse invalide du serveur', 
          responseBody: response, 
          statusCode: response['statusCode'] as int?
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Échec de déblocage des fonds: Une erreur inattendue est survenue. $e');
    }
  }
  /// Enregistre un paiement pour une demande de financement
  Future<ApiResponse<FinancingRequest>> recordPayment(
    String id, {
    required DateTime paymentDate,
    required double amount,
  }) async {
    try {
      final Map<String, dynamic> requestData = {
        'paymentDate': paymentDate.toIso8601String(),
        'amount': amount,
      };

      final response = await _apiClient.post('financing-requests/$id/payments', body: requestData, requiresAuth: true);
      
      if (response != null && response['data'] != null) {
        final updatedRequest = FinancingRequest.fromJson(response['data'] as Map<String, dynamic>);
        
        return ApiResponse<FinancingRequest>(
          success: true,
          data: updatedRequest,
          message: response['message'] as String? ?? 'Paiement enregistré avec succès.',
          statusCode: response['statusCode'] as int? ?? 200,
        );
      } else {
        throw ApiException(
          'Format de réponse invalide du serveur', 
          responseBody: response, 
          statusCode: response['statusCode'] as int?
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Échec d\'enregistrement du paiement: Une erreur inattendue est survenue. $e');
    }
  }
}
