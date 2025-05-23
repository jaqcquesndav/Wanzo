// filepath: c:\Users\DevSpace\Flutter\wanzo\lib\core\services\sync_service.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'package:wanzo/core/utils/connectivity_service.dart'; // Corrected import
import 'package:wanzo/core/services/api_service.dart'; // Corrected import
import 'package:wanzo/core/services/api_client.dart'; // Corrected import
import 'package:wanzo/core/services/database_service.dart'; // Corrected import
import 'package:wanzo/core/services/customer_api_service.dart';
import 'package:wanzo/core/services/sale_api_service.dart';
import 'package:wanzo/features/inventory/models/product.dart';
import 'package:wanzo/features/customers/models/customer.dart';
import 'package:wanzo/features/sales/models/sale.dart';
import 'package:wanzo/core/services/product_api_service.dart';

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
  final ProductApiService _productApiService;
  final CustomerApiService _customerApiService;
  final SaleApiService _saleApiService;
  final Box<String> _syncStatusBox;

  SyncService({
    required ProductApiService productApiService,
    required CustomerApiService customerApiService,
    required SaleApiService saleApiService,
    required Box<String> syncStatusBox,
  })  : _productApiService = productApiService,
        _customerApiService = customerApiService,
        _saleApiService = saleApiService,
        _syncStatusBox = syncStatusBox;

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
      if (_connectivityService.isConnected && !_isSyncing) {
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

  /// Vérifie la connectivité
  Future<bool> isConnected() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }

  /// Synchronise les données avec l'API
  Future<bool> syncData() async {
    if (_isSyncing) return false;

    _isSyncing = true;
    _syncStatusController.add(SyncStatus.syncing);
    debugPrint('Démarrage de la synchronisation des données...');

    try {
      // Récupérer toutes les opérations en attente
      final pendingOperations = await _databaseService.getPendingOperations();
      debugPrint('${pendingOperations.length} opérations en attente de synchronisation');

      if (pendingOperations.isEmpty) {
        _isSyncing = false;
        _syncStatusController.add(SyncStatus.completed);
        return true;
      }

      // Synchroniser chaque opération
      for (final operation in pendingOperations) {
        if (!_connectivityService.isConnected) {
          debugPrint('Synchronisation interrompue : connexion perdue');
          _isSyncing = false;
          _syncStatusController.add(SyncStatus.failed);
          return false;
        }

        try {
          final endpoint = operation['endpoint'] as String;
          final method = operation['method'] as String;
          final body = operation['body'] as Map<String, dynamic>?;
          final id = operation['id'] as String;

          // Exécuter l'opération sur l'API
          await _executeApiOperation(method, endpoint, body);

          // Marquer l'opération comme synchronisée
          await _databaseService.markOperationAsSynchronized(id);

          debugPrint('Opération $id synchronisée avec succès');
        } catch (e) {
          debugPrint('Erreur lors de la synchronisation d\'une opération: $e');
          // Continuer avec la prochaine opération, celle-ci sera retentée plus tard
        }
      }

      // Nettoyer les opérations synchronisées anciennes
      await _databaseService.cleanupSynchronizedOperations();

      _isSyncing = false;
      _syncStatusController.add(SyncStatus.completed);
      debugPrint('Synchronisation terminée avec succès');
      return true;
    } catch (e) {
      debugPrint('Erreur lors de la synchronisation: $e');
      _isSyncing = false;
      _syncStatusController.add(SyncStatus.failed);
      return false;
    }
  }

  /// Exécute une opération API selon la méthode
  Future<void> _executeApiOperation(String method, String endpoint, Map<String, dynamic>? body) async {
    switch (method) {
      case 'GET':
        await _apiService.get(endpoint);
        break;
      case 'POST':
        await _apiService.post(endpoint, body: body);
        break;
      case 'PUT':
        await _apiService.put(endpoint, body: body);
        break;
      case 'DELETE':
        await _apiService.delete(endpoint);
        break;
      default:
        throw Exception('Méthode non supportée: $method');
    }
  }

  /// Force une synchronisation immédiate
  Future<bool> forceSyncNow() async {
    if (_isSyncing) return false;

    return await syncData();
  }

  /// Synchronise toutes les données
  Future<void> syncAll({bool forceFullSync = false}) async {
    if (_isSyncing) {
      return;
    }
    _isSyncing = true;

    try {
      await _syncProducts(forceFullSync: forceFullSync);
      await _syncCustomers(forceFullSync: forceFullSync);
      await _syncSales(forceFullSync: forceFullSync);
    } catch (e) {
      // Consider re-throwing or handling more gracefully
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _syncProducts({bool forceFullSync = false}) async {
    final productBox = Hive.box<Product>('productsBox');
    final String lastSyncKey = 'product_last_sync';
    Map<String, String> queryParams = {};

    if (!forceFullSync && _syncStatusBox.containsKey(lastSyncKey)) {
      final lastSyncDate = _syncStatusBox.get(lastSyncKey)!;
      queryParams['updated_after'] = lastSyncDate; // Use lastSyncDate
    }

    try {
      final apiResponse = await _productApiService.getProducts(queryParameters: queryParams.isNotEmpty ? queryParams : null);
      if (apiResponse.success && apiResponse.data != null) {
        for (var product in apiResponse.data!) {
          await productBox.put(product.id, product);
        }
        await _syncStatusBox.put(lastSyncKey, DateTime.now().toIso8601String());
      } else {
        debugPrint('Failed to sync products: ${apiResponse.message}');
      }
    } catch (e) {
      if (e is ApiException) {
        debugPrint('ApiException during product sync: ${e.message}');
      } else {
        debugPrint('Exception during product sync: $e');
      }
    }
  }

  Future<void> _syncCustomers({bool forceFullSync = false}) async {
    final customerBox = Hive.box<Customer>('customersBox');
    final String lastSyncKey = 'customer_last_sync';
    Map<String, String> queryParams = {};

    if (!forceFullSync && _syncStatusBox.containsKey(lastSyncKey)) {
      final lastSyncDate = _syncStatusBox.get(lastSyncKey)!;
      queryParams['updated_after'] = lastSyncDate; // Use lastSyncDate
    }

    try {
      final apiResponse = await _customerApiService.getCustomers(queryParams: queryParams.isNotEmpty ? queryParams : null);
      if (apiResponse.success && apiResponse.data != null) {
        for (var customer in apiResponse.data!) {
          await customerBox.put(customer.id, customer);
        }
        await _syncStatusBox.put(lastSyncKey, DateTime.now().toIso8601String());
      } else {
        debugPrint('Failed to sync customers: ${apiResponse.message}');
      }
    } catch (e) {
      if (e is ApiException) {
        debugPrint('ApiException during customer sync: ${e.message}');
      } else {
        debugPrint('Exception during customer sync: $e');
      }
    }
  }

  Future<void> _syncSales({bool forceFullSync = false}) async {
    final saleBox = Hive.box<Sale>('salesBox');
    final String lastSyncKey = 'sale_last_sync';
    Map<String, String> queryParams = {};

    if (!forceFullSync && _syncStatusBox.containsKey(lastSyncKey)) {
      final lastSyncDate = _syncStatusBox.get(lastSyncKey)!;
      queryParams['updated_after'] = lastSyncDate; // Use lastSyncDate
    }

    try {
      final apiResponse = await _saleApiService.getSales(queryParameters: queryParams.isNotEmpty ? queryParams : null);
      if (apiResponse.success && apiResponse.data != null) {
        for (var sale in apiResponse.data!) {
          await saleBox.put(sale.id, sale);
        }
        await _syncStatusBox.put(lastSyncKey, DateTime.now().toIso8601String());
      } else {
        debugPrint('Failed to sync sales: ${apiResponse.message}');
      }
    } catch (e) {
      if (e is ApiException) {
        debugPrint('ApiException during sale sync: ${e.message}');
      } else {
        debugPrint('Exception during sale sync: $e');
      }
    }
  }

  /// Arrête le service de synchronisation
  void dispose() {
    _syncTimer?.cancel();
    _syncStatusController.close();
  }
}
