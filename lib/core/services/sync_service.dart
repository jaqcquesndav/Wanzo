// filepath: c:\Users\DevSpace\Flutter\wanzo\lib\core\services\sync_service.dart

import "dart:async";
import "package:flutter/material.dart";
import "../utils/connectivity_service.dart";
import "api_service.dart";
import "database_service.dart";

/// Statut de la synchronisation
enum SyncStatus {
  /// Synchronisation en cours
  syncing,
  
  /// Synchronisation terminée avec succès
  completed,
  
  /// Synchronisation échouée
  failed,
}

/// Service pour gérer la synchronisation des données entre le stockage local et l'API
class SyncService {
  static final SyncService _instance = SyncService._internal();
  
  /// Instance unique du service (singleton)
  factory SyncService() => _instance;
  
  SyncService._internal();
  
  final DatabaseService _databaseService = DatabaseService();
  final ApiService _apiService = ApiService();
  final ConnectivityService _connectivityService = ConnectivityService();
  
  Timer? _syncTimer;
  bool _isSyncing = false;
  final StreamController<SyncStatus> _syncStatusController = StreamController<SyncStatus>.broadcast();
  
  /// Stream qui émet l'état de la synchronisation
  Stream<SyncStatus> get syncStatus => _syncStatusController.stream;
  
  /// Initialise le service de synchronisation
  Future<void> init() async {
    // Planifier une synchronisation régulière
    _setupPeriodicSync();
    
    // Écouter les changements de connectivité via le service de connectivité
    _connectivityService.connectionStatus.addListener(() {
      bool isConnected = _connectivityService.isConnected;
      if (isConnected && !_isSyncing) {
        // Lancer une synchronisation lorsque la connexion est rétablie
        syncData();
      }
    });
  }
  
  /// Configure la synchronisation périodique
  void _setupPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(minutes: 15), (timer) async {
      if (_connectivityService.isConnected && !_isSyncing) {
        await syncData();
      }
    });
  }
  
  /// Synchronise les données avec l'API
  Future<bool> syncData() async {
    if (_isSyncing) return false;
    
    _isSyncing = true;
    _syncStatusController.add(SyncStatus.syncing);
    debugPrint("Démarrage de la synchronisation des données...");
    
    try {
      // Récupérer toutes les opérations en attente
      final pendingOperations = await _databaseService.getPendingOperations();
      debugPrint("${pendingOperations.length} opérations en attente de synchronisation");
      
      if (pendingOperations.isEmpty) {
        _isSyncing = false;
        _syncStatusController.add(SyncStatus.completed);
        return true;
      }
      
      // Synchroniser chaque opération
      for (final operation in pendingOperations) {
        if (!_connectivityService.isConnected) {
          debugPrint("Synchronisation interrompue : connexion perdue");
          _isSyncing = false;
          _syncStatusController.add(SyncStatus.failed);
          return false;
        }
        
        try {
          final endpoint = operation["endpoint"] as String;
          final method = operation["method"] as String;
          final body = operation["body"] as Map<String, dynamic>?;
          final id = operation["id"] as String;
          
          // Exécuter l'opération sur l'API
          await _executeApiOperation(method, endpoint, body);
          
          // Marquer l'opération comme synchronisée
          await _databaseService.markOperationAsSynchronized(id);
          
          debugPrint("Opération $id synchronisée avec succès");
        } catch (e) {
          debugPrint("Erreur lors de la synchronisation d\'une opération: $e");
          // Continuer avec la prochaine opération, celle-ci sera retentée plus tard
        }
      }
      
      // Nettoyer les opérations synchronisées anciennes
      await _databaseService.cleanupSynchronizedOperations();
      
      _isSyncing = false;
      _syncStatusController.add(SyncStatus.completed);
      debugPrint("Synchronisation terminée avec succès");
      return true;
    } catch (e) {
      debugPrint("Erreur lors de la synchronisation: $e");
      _isSyncing = false;
      _syncStatusController.add(SyncStatus.failed);
      return false;
    }
  }
  
  /// Exécute une opération API selon la méthode
  Future<void> _executeApiOperation(String method, String endpoint, Map<String, dynamic>? body) async {
    switch (method) {
      case "GET":
        await _apiService.get(endpoint);
        break;
      case "POST":
        await _apiService.post(endpoint, body: body);
        break;
      case "PUT":
        await _apiService.put(endpoint, body: body);
        break;
      case "DELETE":
        await _apiService.delete(endpoint);
        break;
      default:
        throw Exception("Méthode non supportée: $method");
    }
  }
  
  /// Force une synchronisation immédiate
  Future<bool> forceSyncNow() async {
    if (_isSyncing) return false;
    
    return await syncData();
  }
  
  /// Arrête le service de synchronisation
  void dispose() {
    _syncTimer?.cancel();
    _syncStatusController.close();
  }
}
