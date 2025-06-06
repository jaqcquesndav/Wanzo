import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../models/financing_request.dart';
import '../services/financing_api_service.dart';
import '../../../core/utils/logger.dart';

class FinancingRepository {
  final List<FinancingRequest> _requests = [];
  final _uuid = const Uuid();
  final FinancingApiService _apiService;
  bool _isOfflineMode = true; // Par défaut, utiliser le mode hors ligne

  FinancingRepository({FinancingApiService? apiService}) 
      : _apiService = apiService ?? FinancingApiService();

  Future<void> init() async {
    // Détecter si on est en mode en ligne ou hors ligne
    // Dans un vrai scénario, vous pourriez vérifier la connectivité ici
    _isOfflineMode = !kIsWeb; // Exemple: Utiliser le mode hors ligne sur mobile, en ligne sur web
    
    // Si on est en mode en ligne, on pourrait synchroniser les données
    if (!_isOfflineMode) {
      try {
        final response = await _apiService.getFinancingRequests();
        if (response.success && response.data != null) {
          _requests.clear();
          _requests.addAll(response.data!);
        }      } catch (e) {
        // En cas d'erreur, revenir au mode hors ligne
        _isOfflineMode = true;
        Logger.error('Erreur lors de l\'initialisation du repository', error: e);
      }
    }
  }

  Future<List<FinancingRequest>> getAllRequests() async {
    if (_isOfflineMode) {
      // Mode hors ligne, utiliser les données en mémoire
      await Future.delayed(const Duration(milliseconds: 300)); // Simuler async
      return List.from(_requests);
    } else {
      // Mode en ligne, appeler l'API
      try {
        final response = await _apiService.getFinancingRequests();
        if (response.success && response.data != null) {
          // Mettre à jour le cache local
          _requests.clear();
          _requests.addAll(response.data!);
          return response.data!;
        } else {
          throw Exception('Erreur lors de la récupération des demandes de financement');
        }      } catch (e) {
        // En cas d'erreur, revenir aux données en mémoire
        Logger.error('Erreur lors de l\'appel à l\'API', error: e);
        return List.from(_requests);
      }
    }
  }

  Future<FinancingRequest> addRequest(FinancingRequest request) async {
    // Assurer que l'ID est généré si non fourni
    final requestWithId = request.id.isEmpty 
        ? request.copyWith(id: _uuid.v4()) 
        : request;
    
    if (_isOfflineMode) {
      // Mode hors ligne, ajouter en mémoire
      await Future.delayed(const Duration(milliseconds: 300)); // Simuler async
      _requests.add(requestWithId);
      return requestWithId;
    } else {
      // Mode en ligne, appeler l'API
      try {
        final response = await _apiService.createFinancingRequest(requestWithId);
        if (response.success && response.data != null) {
          // Ajouter au cache local
          _requests.add(response.data!);
          return response.data!;
        } else {
          throw Exception('Erreur lors de la création de la demande de financement');
        }      } catch (e) {
        // En cas d'erreur, ajouter en mémoire quand même
        Logger.error('Erreur lors de l\'appel à l\'API', error: e);
        _requests.add(requestWithId);
        return requestWithId;
      }
    }
  }

  Future<void> updateRequest(FinancingRequest request) async {
    if (_isOfflineMode) {
      // Mode hors ligne, mettre à jour en mémoire
      await Future.delayed(const Duration(milliseconds: 300)); // Simuler async
      final index = _requests.indexWhere((r) => r.id == request.id);
      if (index != -1) {
        _requests[index] = request;
      } else {
        throw Exception('Demande de financement non trouvée');
      }
    } else {
      // Mode en ligne, appeler l'API
      try {
        final response = await _apiService.updateFinancingRequest(request.id, request);
        if (response.success) {
          // Mettre à jour le cache local
          final index = _requests.indexWhere((r) => r.id == request.id);
          if (index != -1) {
            _requests[index] = response.data ?? request;
          } else {
            // Si pas trouvé localement, ajouter
            _requests.add(response.data ?? request);
          }
        } else {
          throw Exception('Erreur lors de la mise à jour de la demande de financement');
        }      } catch (e) {
        // En cas d'erreur, mettre à jour en mémoire quand même
        Logger.error('Erreur lors de l\'appel à l\'API', error: e);
        final index = _requests.indexWhere((r) => r.id == request.id);
        if (index != -1) {
          _requests[index] = request;
        } else {
          throw Exception('Demande de financement non trouvée');
        }
      }
    }
  }

  Future<void> deleteRequest(String id) async {
    if (_isOfflineMode) {
      // Mode hors ligne, supprimer en mémoire
      await Future.delayed(const Duration(milliseconds: 300)); // Simuler async
      _requests.removeWhere((r) => r.id == id);
    } else {
      // Mode en ligne, appeler l'API
      try {
        final response = await _apiService.deleteFinancingRequest(id);
        if (response.success) {
          // Supprimer du cache local
          _requests.removeWhere((r) => r.id == id);
        } else {
          throw Exception('Erreur lors de la suppression de la demande de financement');
        }      } catch (e) {
        // En cas d'erreur, supprimer en mémoire quand même
        Logger.error('Erreur lors de l\'appel à l\'API', error: e);
        _requests.removeWhere((r) => r.id == id);
      }
    }
  }

  Future<FinancingRequest> approveFinancingRequest({
    required String requestId,
    required DateTime approvalDate,
    double? interestRate,
    int? termMonths,
    double? monthlyPayment,
  }) async {
    if (_isOfflineMode) {
      // Mode hors ligne, mettre à jour en mémoire
      await Future.delayed(const Duration(milliseconds: 300)); // Simuler async
      final index = _requests.indexWhere((r) => r.id == requestId);
      if (index != -1) {
        final request = _requests[index];
        final updatedRequest = request.copyWith(
          status: 'approved',
          approvalDate: approvalDate,
          interestRate: interestRate,
          termMonths: termMonths,
          monthlyPayment: monthlyPayment,
        );
        _requests[index] = updatedRequest;
        return updatedRequest;
      } else {
        throw Exception('Demande de financement non trouvée');
      }
    } else {
      // Mode en ligne, appeler l'API
      try {
        final response = await _apiService.approveFinancingRequest(
          requestId,
          approvalDate: approvalDate,
          interestRate: interestRate,
          termMonths: termMonths,
          monthlyPayment: monthlyPayment,
        );
        if (response.success && response.data != null) {
          // Mettre à jour le cache local
          final index = _requests.indexWhere((r) => r.id == requestId);
          if (index != -1) {
            _requests[index] = response.data!;
          } else {
            // Si pas trouvé localement, ajouter
            _requests.add(response.data!);
          }
          return response.data!;
        } else {
          throw Exception('Erreur lors de l\'approbation de la demande de financement');
        }      } catch (e) {
        // En cas d'erreur, mettre à jour en mémoire quand même
        Logger.error('Erreur lors de l\'appel à l\'API', error: e);
        final index = _requests.indexWhere((r) => r.id == requestId);
        if (index != -1) {
          final request = _requests[index];
          final updatedRequest = request.copyWith(
            status: 'approved',
            approvalDate: approvalDate,
            interestRate: interestRate,
            termMonths: termMonths,
            monthlyPayment: monthlyPayment,
          );
          _requests[index] = updatedRequest;
          return updatedRequest;
        } else {
          throw Exception('Demande de financement non trouvée');
        }
      }
    }
  }

  Future<FinancingRequest> disburseFunds({
    required String requestId,
    required DateTime disbursementDate,
    List<DateTime>? scheduledPayments,
  }) async {
    if (_isOfflineMode) {
      // Mode hors ligne, mettre à jour en mémoire
      await Future.delayed(const Duration(milliseconds: 300)); // Simuler async
      final index = _requests.indexWhere((r) => r.id == requestId);
      if (index != -1) {
        final request = _requests[index];
        final updatedRequest = request.copyWith(
          status: 'disbursed',
          disbursementDate: disbursementDate,
          scheduledPayments: scheduledPayments,
        );
        _requests[index] = updatedRequest;
        return updatedRequest;
      } else {
        throw Exception('Demande de financement non trouvée');
      }
    } else {
      // Mode en ligne, appeler l'API
      try {
        final response = await _apiService.disburseFunds(
          requestId,
          disbursementDate: disbursementDate,
          scheduledPayments: scheduledPayments,
        );
        if (response.success && response.data != null) {
          // Mettre à jour le cache local
          final index = _requests.indexWhere((r) => r.id == requestId);
          if (index != -1) {
            _requests[index] = response.data!;
          } else {
            // Si pas trouvé localement, ajouter
            _requests.add(response.data!);
          }
          return response.data!;
        } else {
          throw Exception('Erreur lors du déblocage des fonds');
        }      } catch (e) {
        // En cas d'erreur, mettre à jour en mémoire quand même
        Logger.error('Erreur lors de l\'appel à l\'API', error: e);
        final index = _requests.indexWhere((r) => r.id == requestId);
        if (index != -1) {
          final request = _requests[index];
          final updatedRequest = request.copyWith(
            status: 'disbursed',
            disbursementDate: disbursementDate,
            scheduledPayments: scheduledPayments,
          );
          _requests[index] = updatedRequest;
          return updatedRequest;
        } else {
          throw Exception('Demande de financement non trouvée');
        }
      }
    }
  }

  Future<FinancingRequest> recordPayment({
    required String requestId,
    required DateTime paymentDate,
    required double amount,
  }) async {
    if (_isOfflineMode) {
      // Mode hors ligne, mettre à jour en mémoire
      await Future.delayed(const Duration(milliseconds: 300)); // Simuler async
      final index = _requests.indexWhere((r) => r.id == requestId);
      if (index != -1) {
        final request = _requests[index];
        
        // Vérifier que le statut est correct
        if (request.status != 'disbursed' && request.status != 'repaying') {
          throw Exception('La demande doit être au statut "disbursed" ou "repaying" pour enregistrer un paiement');
        }
        
        // Ajouter le paiement
        List<DateTime> completedPayments = request.completedPayments?.toList() ?? [];
        completedPayments.add(paymentDate);
        
        // Mettre à jour le statut
        String status = 'repaying';
        if (request.scheduledPayments != null && 
            completedPayments.length >= request.scheduledPayments!.length) {
          status = 'fully_repaid';
        }
        
        final updatedRequest = request.copyWith(
          status: status,
          completedPayments: completedPayments,
        );
        _requests[index] = updatedRequest;
        return updatedRequest;
      } else {
        throw Exception('Demande de financement non trouvée');
      }
    } else {
      // Mode en ligne, appeler l'API
      try {
        final response = await _apiService.recordPayment(
          requestId,
          paymentDate: paymentDate,
          amount: amount,
        );
        if (response.success && response.data != null) {
          // Mettre à jour le cache local
          final index = _requests.indexWhere((r) => r.id == requestId);
          if (index != -1) {
            _requests[index] = response.data!;
          } else {
            // Si pas trouvé localement, ajouter
            _requests.add(response.data!);
          }
          return response.data!;
        } else {
          throw Exception('Erreur lors de l\'enregistrement du paiement');
        }
      } catch (e) {
        // En cas d'erreur, mettre à jour en mémoire quand même
        print('Erreur lors de l\'appel à l\'API: $e');
        final index = _requests.indexWhere((r) => r.id == requestId);
        if (index != -1) {
          final request = _requests[index];
          
          // Vérifier que le statut est correct
          if (request.status != 'disbursed' && request.status != 'repaying') {
            throw Exception('La demande doit être au statut "disbursed" ou "repaying" pour enregistrer un paiement');
          }
          
          // Ajouter le paiement
          List<DateTime> completedPayments = request.completedPayments?.toList() ?? [];
          completedPayments.add(paymentDate);
          
          // Mettre à jour le statut
          String status = 'repaying';
          if (request.scheduledPayments != null && 
              completedPayments.length >= request.scheduledPayments!.length) {
            status = 'fully_repaid';
          }
          
          final updatedRequest = request.copyWith(
            status: status,
            completedPayments: completedPayments,
          );
          _requests[index] = updatedRequest;
          return updatedRequest;
        } else {
          throw Exception('Demande de financement non trouvée');
        }
      }
    }
  }

  // Méthode pour filtrer les demandes par type, statut ou produit financier
  Future<List<FinancingRequest>> getFilteredRequests({
    FinancingType? type,
    String? status,
    FinancialProduct? financialProduct,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    final allRequests = await getAllRequests();
    
    return allRequests.where((request) {
      bool matchesType = type == null || request.type == type;
      bool matchesStatus = status == null || request.status == status;
      bool matchesProduct = financialProduct == null || request.financialProduct == financialProduct;
      
      bool matchesDateRange = true;
      if (dateFrom != null) {
        matchesDateRange = matchesDateRange && request.requestDate.isAfter(dateFrom);
      }
      if (dateTo != null) {
        matchesDateRange = matchesDateRange && request.requestDate.isBefore(dateTo.add(const Duration(days: 1)));
      }
      
      return matchesType && matchesStatus && matchesProduct && matchesDateRange;
    }).toList();
  }
}
