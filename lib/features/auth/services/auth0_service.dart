import 'dart:convert';
import 'package:flutter/foundation.dart'; // Import for kDebugMode
import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../../settings/models/settings.dart';
import '../../../core/utils/connectivity_service.dart';
import '../../../core/services/database_service.dart';
import 'offline_auth_service.dart';

/// Service pour gérer l'authentification avec Auth0
class Auth0Service {
  static final Auth0Service _instance = Auth0Service._internal();

  /// Instance unique du service (singleton)
  factory Auth0Service() => _instance;

  Auth0Service._internal();

  // Configuration pour Auth0
  static const String _auth0Domain = 'dev-wanzo.us.auth0.com'; // Utiliser AppConfig dans un environnement réel
  static const String _auth0ClientId = 'Xm7YJXs0LGX5iG1KLR8wPlmK8gnjVrns'; // Utiliser AppConfig dans un environnement réel
  static const String _auth0RedirectUri = 'com.wanzo.app://login-callback';
  static const String _auth0Issuer = 'https://$_auth0Domain';
  static const String _auth0UserInfoEndpoint = 'https://$_auth0Domain/userinfo';

  // Clés pour le stockage sécurisé
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _idTokenKey = 'id_token';
  static const String _expiresAtKey = 'expires_at';
  static const String _demoUserKey = 'demo_user_active'; // Key to indicate demo user

  // Instances pour l'authentification
  final FlutterAppAuth _appAuth = FlutterAppAuth();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final ConnectivityService _connectivityService = ConnectivityService();
  final DatabaseService _databaseService = DatabaseService();

  // Initialize offlineAuthService directly
  late final OfflineAuthService offlineAuthService = OfflineAuthService(
    secureStorage: _secureStorage,
    databaseService: _databaseService,
    connectivityService: _connectivityService,
  );

  /// Initialise le service
  Future<void> init() async {
    await _connectivityService.init();
    // offlineAuthService is already initialized
  }

  /// Checks if the demo user mode is currently active
  Future<bool> isDemoUserActive() async {
    return await _secureStorage.read(key: _demoUserKey) == 'true';
  }

  /// Vérifie si l'utilisateur est authentifié (Auth0 ou Démo)
  Future<bool> isAuthenticated() async {
    final isDemoUser = await _secureStorage.read(key: _demoUserKey);
    if (isDemoUser == 'true') {
      return true; // Demo user is considered authenticated
    }

    final expiresAt = await _secureStorage.read(key: _expiresAtKey);
    final accessToken = await _secureStorage.read(key: _accessTokenKey);

    if (accessToken == null || expiresAt == null) {
      return false;
    }

    // Vérifier si le token est expiré
    final expiryDate = DateTime.fromMillisecondsSinceEpoch(int.parse(expiresAt));
    final now = DateTime.now();

    return expiryDate.isAfter(now);
  }

  /// Effectue la connexion avec un compte de démonstration
  Future<User> loginWithDemoAccount() async {
    debugPrint('Connexion avec le compte de démonstration');
    final demoUser = User(
      id: 'demo-user-id',
      name: 'Utilisateur Démo Wanzo',
      email: 'demo@wanzo.app',
      phone: '+243000000000',
      role: 'admin', // Ou 'user' selon les besoins de test
      token: 'mock_demo_access_token_${DateTime.now().millisecondsSinceEpoch}',
      picture: 'https://i.pravatar.cc/150?u=demo@wanzo.app',
    );

    // Simuler la sauvegarde des tokens pour le mode démo
    await _secureStorage.write(key: _accessTokenKey, value: demoUser.token);
    await _secureStorage.write(key: _idTokenKey, value: 'mock_demo_id_token');
    // Set a far future expiry for demo user or manage differently if needed
    await _secureStorage.write(key: _expiresAtKey, value: DateTime.now().add(const Duration(days: 30)).millisecondsSinceEpoch.toString());
    await _secureStorage.write(key: _demoUserKey, value: 'true'); // Mark as demo user

    // Sauvegarder l'utilisateur pour l'authentification hors ligne (même pour le démo)
    await offlineAuthService.saveUserForOfflineLogin(demoUser);
    await offlineAuthService.setOfflineLoginEnabled(true); // Enable offline for demo

    return demoUser;
  }

  /// Effectue la connexion avec Auth0 en utilisant le flux PKCE
  /// Retourne l'utilisateur connecté
  Future<User> login() async {
    try {
      await _secureStorage.delete(key: _demoUserKey); // Clear demo user flag if any

      // Vérifier la connectivité
      if (!_connectivityService.isConnected) {
        // Essayer la connexion en mode hors ligne
        return await _loginOffline();
      }

      // Configuration Auth0
      final authorizationTokenRequest = AuthorizationTokenRequest(
        _auth0ClientId,
        _auth0RedirectUri,
        issuer: _auth0Issuer,
        scopes: ['openid', 'profile', 'email', 'offline_access'],
        promptValues: ['login'],
      );

      // Lancer le flux d'authentification
      final result = await _appAuth.authorizeAndExchangeCode(
        authorizationTokenRequest,
      );

      if (result == null) {
        throw Exception("L'authentification a échoué");
      }

      // Stocker les tokens de manière sécurisée
      await _saveTokens(
        accessToken: result.accessToken!,
        refreshToken: result.refreshToken,
        idToken: result.idToken!,
        expiresIn: result.accessTokenExpirationDateTime!.millisecondsSinceEpoch,
      );

      // Récupérer les informations utilisateur
      final user = await getUserInfo(result.accessToken!);

      // Sauvegarder l'utilisateur pour l'authentification hors ligne
      await offlineAuthService.saveUserForOfflineLogin(user);

      // Activer la connexion hors ligne par défaut
      await offlineAuthService.setOfflineLoginEnabled(true);

      return user;
    } catch (e) {
      debugPrint('Erreur lors de la connexion Auth0: $e');
      // En cas d'erreur, essayer la connexion hors ligne
      if (await offlineAuthService.canLoginOffline()) {
        debugPrint('Tentative de connexion hors ligne après échec de la connexion en ligne');
        return await _loginOffline();
      }

      throw Exception('Échec de l\'authentification: $e');
    }
  }

  /// Effectue une connexion en mode hors ligne
  Future<User> _loginOffline() async {
    debugPrint('Tentative de connexion en mode hors ligne');
    final isDemoUser = await _secureStorage.read(key: _demoUserKey);
    if (isDemoUser == 'true') {
      // If it was a demo user, try to retrieve that
      final user = await offlineAuthService.getLastLoggedInUser();
      if (user != null && user.id == 'demo-user-id') {
        // ensure it's the demo user
        debugPrint('Connexion hors ligne réussie pour l\'utilisateur démo ${user.email}');
        return user;
      }
    }

    if (await offlineAuthService.canLoginOffline()) {
      final user = await offlineAuthService.getLastLoggedInUser();
      if (user != null) {
        debugPrint('Connexion hors ligne réussie pour ${user.email}');
        // Re-save tokens to ensure expiry is updated if needed, or handle session locally
        await _saveTokens(
          accessToken: user.token, // Assuming token is stored in User model for offline
          idToken: await _secureStorage.read(key: _idTokenKey) ?? 'offline_id_token', // May need to store/mock this
          expiresIn: DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch, // Provide a short valid window
        );
        return user;
      }
    }

    throw Exception('Aucune connexion Internet disponible et authentification hors ligne impossible.');
  }

  /// Effectue la déconnexion
  Future<void> logout() async {
    try {
      // Supprimer les tokens
      await _secureStorage.delete(key: _accessTokenKey);
      await _secureStorage.delete(key: _refreshTokenKey);
      await _secureStorage.delete(key: _idTokenKey);
      await _secureStorage.delete(key: _expiresAtKey);
      await _secureStorage.delete(key: _demoUserKey); // Clear demo user flag

      // Nettoyer les données d'authentification hors ligne si demandé
      final keepOfflineData = await offlineAuthService.isOfflineLoginEnabled();
      if (!keepOfflineData) {
        await offlineAuthService.clearOfflineUserData();
        debugPrint('Données d\'authentification hors ligne supprimées');
      }
    } catch (e) {
      debugPrint('Erreur lors de la déconnexion: $e');
      throw Exception('Échec de la déconnexion: $e');
    }
  }

  /// Récupère un token d'accès valide, rafraîchit si nécessaire
  Future<String?> getAccessToken() async {
    try {
      // Vérifier si le token est expiré
      final expiresAt = await _secureStorage.read(key: _expiresAtKey);
      final accessToken = await _secureStorage.read(key: _accessTokenKey);
      final refreshToken = await _secureStorage.read(key: _refreshTokenKey);

      if (accessToken == null) {
        return null;
      }

      // Si la date d'expiration est passée, rafraîchir le token
      if (expiresAt != null) {
        final expiryDate = DateTime.fromMillisecondsSinceEpoch(int.parse(expiresAt));
        final now = DateTime.now();

        // Rafraîchir si le token expire dans moins de 5 minutes
        if (expiryDate.isBefore(now.add(const Duration(minutes: 5)))) {
          if (refreshToken != null && _connectivityService.isConnected) {
            return await _refreshAccessToken(refreshToken);
          }
        }
      }

      return accessToken;
    } catch (e) {
      debugPrint('Erreur lors de la récupération du token d\'accès: $e');
      return null;
    }
  }

  /// Rafraîchit le token d'accès
  Future<String?> _refreshAccessToken(String refreshToken) async {
    try {
      final result = await _appAuth.token(
        TokenRequest(
          _auth0ClientId,
          _auth0RedirectUri,
          issuer: _auth0Issuer,
          refreshToken: refreshToken,
          scopes: ['openid', 'profile', 'email', 'offline_access'],
        ),
      );

      if (result == null || result.accessToken == null) {
        throw Exception("Le rafraîchissement du token a échoué");
      }

      // Mettre à jour les tokens stockés
      await _saveTokens(
        accessToken: result.accessToken!,
        refreshToken: result.refreshToken ?? refreshToken,
        idToken: result.idToken!,
        expiresIn: result.accessTokenExpirationDateTime!.millisecondsSinceEpoch,
      );

      return result.accessToken;
    } catch (e) {
      debugPrint('Erreur lors du rafraîchissement du token: $e');
      // En cas d'échec, supprimer les tokens pour forcer une nouvelle connexion
      await logout();
      return null;
    }
  }

  /// Récupère les informations de l'utilisateur à partir du token d'accès
  Future<User> getUserInfo(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse(_auth0UserInfoEndpoint),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);

        // Créer l'utilisateur à partir des données Auth0
        return User(
          id: userData['sub'] ?? '',
          name: userData['name'] ?? '',
          email: userData['email'] ?? '',
          phone: userData['phone_number'] ?? '',
          role: _determineUserRole(userData),
          token: accessToken,
          picture: userData['picture'],
        );
      } else {
        throw Exception('Échec de la récupération des informations utilisateur: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erreur lors de la récupération des informations utilisateur: $e');
      throw Exception('Échec de la récupération des informations utilisateur: $e');
    }
  }

  /// Détermine le rôle de l'utilisateur à partir des données Auth0
  String _determineUserRole(Map<String, dynamic> userData) {
    // Vérifier les rôles dans les métadonnées Auth0
    final roles = userData['https://wanzo.app/roles'] as List<dynamic>?;

    if (roles != null && roles.isNotEmpty) {
      if (roles.contains('admin')) {
        return 'admin';
      } else if (roles.contains('manager')) {
        return 'manager';
      }
    }

    // Par défaut, utilisateur standard
    return 'user';
  }

  /// Sauvegarde les tokens de manière sécurisée
  Future<void> _saveTokens({
    required String accessToken,
    required String idToken,
    String? refreshToken,
    required int expiresIn,
  }) async {
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    await _secureStorage.write(key: _idTokenKey, value: idToken);
    await _secureStorage.write(key: _expiresAtKey, value: expiresIn.toString());

    if (refreshToken != null) {
      await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    }

    // Ensure demo flag is cleared when real tokens are saved
    await _secureStorage.delete(key: _demoUserKey);
  }
}
