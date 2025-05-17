import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../features/auth/services/auth0_service.dart';
import '../utils/connectivity_service.dart';
import 'database_service.dart';

/// Service pour gérer les appels API
class ApiService {
  static final ApiService _instance = ApiService._internal();
  
  /// Instance unique du service (singleton)
  factory ApiService() => _instance;
  
  ApiService._internal();
    // Configuration de l'API
  static const String _apiBaseUrl = 'https://api.wanzo.app'; // À remplacer par l'URL de votre API
  static String get apiBaseUrl => _apiBaseUrl;
  static const Duration _timeout = Duration(seconds: 30);
  static const Duration _cacheExpiration = Duration(hours: 24);
  
  // Services
  final Auth0Service _auth0Service = Auth0Service();
  final ConnectivityService _connectivityService = ConnectivityService();
  final DatabaseService _databaseService = DatabaseService();
    /// Initialise le service
  Future<void> init() async {
    await _connectivityService.init();
    await _auth0Service.init();
  }
  /// Récupère une réponse mise en cache
  Future<Map<String, dynamic>?> _getCachedResponse(String url, String method) async {
    return await _databaseService.getCachedApiResponse(url, method);
  }
  
  /// Met en cache une réponse API
  Future<void> _cacheResponse(String url, String method, Map<String, dynamic> response) async {
    await _databaseService.cacheApiResponse(
      url: url,
      method: method,
      response: response,
      expiration: _cacheExpiration,
    );
  }
  
  /// Vérifie si la requête peut utiliser le cache
  bool _canUseCache(String method) {
    return method == 'GET'; // Seules les requêtes GET sont mises en cache
  }
  
  /// Enregistre une opération pour synchronisation ultérieure
  Future<void> _storeForSync(String endpoint, String method, Map<String, dynamic>? body) async {
    await _databaseService.savePendingOperation(
      endpoint: endpoint,
      method: method,
      body: body,
    );
  }
  
  /// Effectue une requête GET
  Future<Map<String, dynamic>> get(String endpoint, {Map<String, dynamic>? queryParams}) async {
    return _request(
      uri: _buildUri(endpoint, queryParams),
      method: 'GET',
    );
  }
  
  /// Effectue une requête POST
  Future<Map<String, dynamic>> post(String endpoint, {Map<String, dynamic>? body}) async {
    return _request(
      uri: _buildUri(endpoint),
      method: 'POST',
      body: body,
    );
  }
  
  /// Effectue une requête PUT
  Future<Map<String, dynamic>> put(String endpoint, {Map<String, dynamic>? body}) async {
    return _request(
      uri: _buildUri(endpoint),
      method: 'PUT',
      body: body,
    );
  }
  
  /// Effectue une requête DELETE
  Future<Map<String, dynamic>> delete(String endpoint) async {
    return _request(
      uri: _buildUri(endpoint),
      method: 'DELETE',
    );
  }
  
  /// Construit l'URI pour la requête
  Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParams]) {
    final url = '$_apiBaseUrl/$endpoint';
    
    if (queryParams != null) {
      return Uri.parse(url).replace(
        queryParameters: queryParams.map((key, value) => MapEntry(key, value.toString())),
      );
    }
    
    return Uri.parse(url);
  }
  /// Effectue une requête HTTP avec gestion des erreurs et du token d'authentification
  Future<Map<String, dynamic>> _request({
    required Uri uri,
    required String method,
    Map<String, dynamic>? body,
    bool useOfflineCache = true,
  }) async {
    try {
      // Vérifier la connectivité
      if (!_connectivityService.isConnected) {
        debugPrint('Mode hors ligne: tentative de récupération des données du cache');
        // Si le mode offline est activé, essayer de récupérer les données du cache
        if (useOfflineCache) {
          final cachedData = await _getCachedResponse(uri.toString(), method);
          if (cachedData != null) {
            return cachedData;
          }
        }
        
        // Si c'est une requête de type écriture (POST, PUT, DELETE), stocker pour synchronisation future
        if (method != 'GET' && body != null) {
          final endpoint = uri.path.replaceFirst(_apiBaseUrl, '');
          await _databaseService.savePendingOperation(
            endpoint: endpoint,
            method: method,
            body: body,
          );
          debugPrint('Opération enregistrée pour synchronisation ultérieure: $method $endpoint');
          return {'success': true, 'message': 'Opération enregistrée pour synchronisation ultérieure'};
        }
        
        throw const SocketException('Aucune connexion Internet disponible');
      }
      
      // Récupérer le token d'authentification
      final token = await _auth0Service.getAccessToken();
      
      // Préparer les en-têtes de la requête
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
      
      http.Response response;
      
      // Effectuer la requête selon la méthode
      switch (method) {
        case 'GET':
          response = await http.get(
            uri,
            headers: headers,
          ).timeout(_timeout);
          break;
          
        case 'POST':
          response = await http.post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(_timeout);
          break;
          
        case 'PUT':
          response = await http.put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(_timeout);
          break;
          
        case 'DELETE':
          response = await http.delete(
            uri,
            headers: headers,
          ).timeout(_timeout);
          break;
          
        default:
          throw Exception('Méthode HTTP non supportée: $method');
      }
      
      // Traiter la réponse
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          return {};
        }
        
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        
        // Mettre en cache les réponses des requêtes GET
        if (method == 'GET' && useOfflineCache) {
          await _databaseService.cacheApiResponse(
            url: uri.toString(),
            method: method,
            response: responseData,
            expiration: _cacheExpiration,
          );
        }
        
        return responseData;
      } else {
        // Gérer les erreurs HTTP
        _handleHttpError(response);
        throw Exception('Erreur HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }    } on SocketException catch (e) {
      debugPrint('Erreur de socket: $e');
      
      // En cas de problème de connexion, vérifier si une version en cache est disponible
      if (_canUseCache(method)) {
        final cachedResponse = await _getCachedResponse(uri.toString(), method);
        if (cachedResponse != null) {
          debugPrint('Utilisation de la réponse en cache pour: ${uri.toString()}');
          return cachedResponse;
        }
      }
      
      // Pour les méthodes d'écriture (POST, PUT, DELETE), enregistrer pour synchronisation ultérieure
      if (!_canUseCache(method) && body != null) {
        final endpoint = uri.toString().replaceFirst(_apiBaseUrl, '');
        await _storeForSync(endpoint, method, body);
        debugPrint('Opération stockée pour synchronisation ultérieure: $method ${uri.toString()}');
        return {'success': true, 'message': 'Opération stockée pour synchronisation ultérieure'};
      }
      
      throw Exception('Problème de connexion réseau. Veuillez vérifier votre connexion Internet.');
    } on TimeoutException catch (e) {
      debugPrint('Délai d\'attente dépassé: $e');
      
      // Même logique que pour les erreurs de socket
      if (_canUseCache(method)) {
        final cachedResponse = await _getCachedResponse(uri.toString(), method);
        if (cachedResponse != null) {
          debugPrint('Utilisation de la réponse en cache pour: ${uri.toString()}');
          return cachedResponse;
        }
      }
      
      throw Exception('La requête a pris trop de temps. Veuillez réessayer.');
    } catch (e) {
      debugPrint('Erreur lors de la requête API: $e');
      throw Exception('Une erreur s\'est produite: $e');
    }
  }
  
  /// Gère les erreurs HTTP spécifiques
  void _handleHttpError(http.Response response) {
    final statusCode = response.statusCode;
    
    switch (statusCode) {
      case 401:
        // Non autorisé - problème d'authentification
        debugPrint('Erreur 401: Non autorisé');
        throw Exception('Session expirée. Veuillez vous reconnecter.');
        
      case 403:
        // Interdit - problème d'autorisation
        debugPrint('Erreur 403: Accès refusé');
        throw Exception('Vous n\'avez pas les droits nécessaires pour effectuer cette action.');
        
      case 404:
        // Non trouvé
        debugPrint('Erreur 404: Ressource non trouvée');
        throw Exception('La ressource demandée n\'existe pas.');
        
      case 500:
      case 502:
      case 503:
      case 504:
        // Erreurs serveur
        debugPrint('Erreur serveur: ${response.statusCode}');
        throw Exception('Une erreur serveur s\'est produite. Veuillez réessayer plus tard.');
        
      default:
        // Autres erreurs
        debugPrint('Erreur HTTP ${response.statusCode}: ${response.reasonPhrase}');
        try {
          final errorData = jsonDecode(response.body);
          final errorMessage = errorData['message'] ?? errorData['error'] ?? 'Une erreur s\'est produite.';
          throw Exception(errorMessage);
        } catch (_) {
          throw Exception('Une erreur s\'est produite (${response.statusCode}).');
        }
    }
  }
}
