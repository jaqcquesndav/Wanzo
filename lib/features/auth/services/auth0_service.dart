import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../../../core/utils/connectivity_service.dart';
import 'offline_auth_service.dart';

/// Service pour gérer l'authentification avec Auth0
class Auth0Service {
  static const String _auth0Domain = 'dev-wanzo.us.auth0.com'; // Utiliser AppConfig dans un environnement réel
  static const String _auth0ClientId = 'Xm7YJXs0LGX5iG1KLR8wPlmK8gnjVrns'; // Utiliser AppConfig dans un environnement réel
  static const String _auth0RedirectUri = 'com.wanzo.app://login-callback';
  static const String _auth0Audience = 'https://$_auth0Domain';

  // Clés pour le stockage sécurisé
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _idTokenKey = 'id_token';
  static const String _expiresAtKey = 'expires_at';
  static const String _demoUserKey = 'demo_user_active'; // Key to indicate demo user

  final FlutterAppAuth _appAuth = const FlutterAppAuth();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final ConnectivityService _connectivityService = ConnectivityService();
  final OfflineAuthService offlineAuthService;

  Auth0Service({required this.offlineAuthService});

  /// Initialise le service
  Future<void> init() async {
    await _connectivityService.init();
  }

  /// Checks if the demo user mode is currently active
  Future<bool> isDemoUserActive() async {
    return await _secureStorage.read(key: _demoUserKey) == 'true';
  }

  /// Vérifie si l'utilisateur est authentifié (Auth0 ou Démo)
  Future<bool> isAuthenticated() async {
    final isDemoUser = await _secureStorage.read(key: _demoUserKey);
    if (isDemoUser == 'true') {
      debugPrint("Auth0Service: Demo user is active and considered authenticated.");
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
    debugPrint('Auth0Service: Connexion avec le compte de démonstration');
    final demoUser = User(
      id: 'demo-user-id',
      name: 'Utilisateur Démo Wanzo',
      email: 'demo@wanzo.app',
      phone: '+243000000000',
      role: 'admin', // Ou 'user' selon les besoins de test
      token: 'mock_demo_access_token_${DateTime.now().millisecondsSinceEpoch}',
      picture: 'https://i.pravatar.cc/150?u=demo@wanzo.app',
      companyId: 'demo-company-id',
      companyName: 'Demo Company SARL',
      idCardStatus: IdStatus.VERIFIED,
    );

    // Simuler la sauvegarde des tokens pour le mode démo
    await _secureStorage.write(key: _accessTokenKey, value: demoUser.token);
    await _secureStorage.write(key: _idTokenKey, value: 'mock_demo_id_token');
    await _secureStorage.write(key: _expiresAtKey, value: DateTime.now().add(const Duration(days: 365)).millisecondsSinceEpoch.toString()); // Longer expiry
    await _secureStorage.write(key: _demoUserKey, value: 'true'); // Mark as demo user

    // Sauvegarder l'utilisateur pour l'authentification hors ligne (même pour le démo)
    await offlineAuthService.saveUserForOfflineLogin(demoUser);
    await offlineAuthService.setOfflineLoginEnabled(true); // Enable offline for demo
    debugPrint("Auth0Service: Demo user saved for offline login and offline mode enabled.");

    return demoUser;
  }

  /// Effectue la connexion avec Auth0 en utilisant le flux PKCE
  /// Retourne l'utilisateur connecté
  Future<User> login() async {
    try {
      debugPrint("Auth0Service: Attempting standard Auth0 login. Clearing demo user flag.");
      await _secureStorage.delete(key: _demoUserKey); // Clear demo user flag if any

      final TokenResponse? result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          _auth0ClientId,
          _auth0RedirectUri,
          issuer: 'https://$_auth0Domain',
          scopes: ['openid', 'profile', 'email', 'offline_access', 'read:user_id_token'],
          additionalParameters: {
            'audience': _auth0Audience,
          },
        ),
      );

      if (result?.accessToken == null || result?.idToken == null) {
        throw Exception('Login failed: No token received or ID token missing.');
      }

      await _secureStorage.write(key: _accessTokenKey, value: result!.accessToken);
      await _secureStorage.write(key: _idTokenKey, value: result.idToken);
      if (result.refreshToken != null) {
        await _secureStorage.write(key: _refreshTokenKey, value: result.refreshToken);
      }

      final user = await getUserInfo(result.accessToken!);
      if (user != null) {
        await offlineAuthService.saveUserForOfflineLogin(user);
        return user;
      } else {
        throw Exception('Failed to get user info after login.');
      }
    } catch (e) {
      debugPrint('Auth0 Login Error: $e');
      if (e is! Exception || !e.toString().contains('User cancelled flow')) {
        final offlineUser = await offlineAuthService.getLastLoggedInUser();
        if (offlineUser != null) {
          debugPrint('Returning last logged in user due to online login failure.');
          return offlineUser;
        }
      }
      rethrow;
    }
  }

  /// Effectue la déconnexion
  Future<void> logout() async {
    try {
      final bool wasDemoUser = await isDemoUserActive();
      debugPrint("Auth0Service: Logging out. Was demo user: $wasDemoUser");

      await _secureStorage.delete(key: _accessTokenKey);
      await _secureStorage.delete(key: _refreshTokenKey);
      await _secureStorage.delete(key: _idTokenKey);
      await _secureStorage.delete(key: _expiresAtKey);
      await _secureStorage.delete(key: _demoUserKey);

      if (!wasDemoUser) {
        final keepOfflineData = await offlineAuthService.isOfflineLoginEnabled();
        if (!keepOfflineData) {
          await offlineAuthService.clearOfflineUserData();
          debugPrint('Auth0Service: Données d\'authentification hors ligne supprimées pour l\'utilisateur non-démo.');
        }
      } else {
        debugPrint('Auth0Service: Logout du compte démo. Les données hors ligne sont conservées par défaut.');
      }
    } catch (e) {
      debugPrint('Erreur lors de la déconnexion: $e');
      throw Exception('Échec de la déconnexion: $e');
    }
  }

  /// Récupère un token d'accès valide, rafraîchit si nécessaire
  Future<String?> getAccessToken() async {
    try {
      if (await isDemoUserActive()) {
        final demoToken = await _secureStorage.read(key: _accessTokenKey);
        debugPrint("Auth0Service: Demo user active. Returning demo access token.");
        return demoToken;
      }

      final expiresAt = await _secureStorage.read(key: _expiresAtKey);
      final accessToken = await _secureStorage.read(key: _accessTokenKey);
      final refreshToken = await _secureStorage.read(key: _refreshTokenKey);

      if (accessToken == null) {
        return null;
      }

      if (expiresAt != null) {
        final expiryDate = DateTime.fromMillisecondsSinceEpoch(int.parse(expiresAt));
        final now = DateTime.now();

        if (expiryDate.isBefore(now.add(const Duration(minutes: 5)))) {
          if (refreshToken != null && _connectivityService.isConnected) {
            return await refreshAccessToken();
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
  Future<String?> refreshAccessToken() async {
    try {
      final String? refreshToken = await _secureStorage.read(key: _refreshTokenKey);
      if (refreshToken == null) {
        debugPrint('No refresh token available.');
        await logout();
        return null;
      }

      final TokenResponse? result = await _appAuth.token(
        TokenRequest(
          _auth0ClientId,
          _auth0RedirectUri,
          issuer: 'https://$_auth0Domain',
          refreshToken: refreshToken,
          scopes: ['openid', 'profile', 'email', 'offline_access', 'read:user_id_token'],
          additionalParameters: {'audience': _auth0Audience},
        ),
      );

      if (result?.accessToken != null) {
        await _secureStorage.write(key: _accessTokenKey, value: result!.accessToken);
        if (result.idToken != null) {
          await _secureStorage.write(key: _idTokenKey, value: result.idToken);
        }
        if (result.refreshToken != null) {
          await _secureStorage.write(key: _refreshTokenKey, value: result.refreshToken);
        }
        return result.accessToken;
      } else {
        debugPrint('Failed to refresh access token. Logging out.');
        await logout();
        return null;
      }
    } catch (e) {
      debugPrint('Error refreshing access token: $e. Logging out.');
      await logout();
      return null;
    }
  }

  /// Récupère les informations de l'utilisateur à partir du token d'accès
  Future<User?> getUserInfo(String token) async {
    if (await isDemoUserActive()) {
      final demoUser = await offlineAuthService.getLastLoggedInUser();
      if (demoUser != null && demoUser.token == token) {
        debugPrint("Auth0Service: Demo user active. Returning stored demo user from offline service.");
        return demoUser;
      }
    }

    debugPrint("Auth0Service: Fetching user info from Auth0 endpoint.");
    final url = Uri.parse('https://$_auth0Domain/userinfo');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> profile = jsonDecode(response.body);

      final idTokenString = await _secureStorage.read(key: _idTokenKey);
      if (idTokenString != null) {
        try {
          final parts = idTokenString.split('.');
          if (parts.length == 3) {
            final payload = jsonDecode(
              utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
            ) as Map<String, dynamic>;

            profile = {...profile, ...payload};
          }
        } catch (e) {
          debugPrint('Error decoding ID token: $e');
        }
      }

      final Map<String, dynamic> customClaims = {};
      profile.forEach((key, value) {
        if (key.startsWith('https://wanzo.app/')) {
          customClaims[key.replaceFirst('https://wanzo.app/', '')] = value;
        }
      });

      final finalProfile = {...profile, ...customClaims};

      if (finalProfile['id'] == null && finalProfile['sub'] != null) {
        finalProfile['id'] = finalProfile['sub'];
      }
      if (finalProfile['phone'] == null && finalProfile['phone_number'] != null) {
        finalProfile['phone'] = finalProfile['phone_number'];
      }

      return User.fromJson(finalProfile);
    } else {
      debugPrint('Failed to get user info: ${response.body}');
      return null;
    }
  }

  /// Envoie un email de réinitialisation de mot de passe via Auth0.
  Future<void> sendPasswordResetEmail(String email) async {
    final String url = 'https://$_auth0Domain/dbconnections/change_password';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'client_id': _auth0ClientId,
          'email': email,
          'connection': 'Username-Password-Authentication',
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Email de réinitialisation de mot de passe envoyé avec succès à $email');
      } else {
        debugPrint('Échec de l\'envoi de l\'email de réinitialisation: ${response.statusCode} - ${response.body}');
        throw Exception('Échec de l\'envoi de l\'email de réinitialisation: ${response.body}');
      }
    } catch (e) {
      debugPrint('Erreur lors de la demande de réinitialisation de mot de passe: $e');
      throw Exception('Erreur lors de la demande de réinitialisation de mot de passe: $e');
    }
  }

  /// Met à jour les métadonnées utilisateur Auth0
  Future<void> updateUserMetadata(String token, User user) async {
    final managementApiToken = await _getManagementApiToken();
    if (managementApiToken == null) {
      throw Exception('Could not retrieve management API token.');
    }

    if (user.id.isEmpty) {
      throw Exception('User ID is missing, cannot update metadata.');
    }

    final url = Uri.parse('https://$_auth0Domain/api/v2/users/${user.id}');
    final Map<String, dynamic> userMetadata = {
      'phone_number': user.phone,
      'job_title': user.jobTitle,
      'physical_address': user.physicalAddress,
      'id_card': user.idCard,
      'id_card_status': user.idCardStatus?.toString().split('.').last,
      'id_card_status_reason': user.idCardStatusReason,
      'company_id': user.companyId,
      'company_name': user.companyName,
      'rccm_number': user.rccmNumber,
      'company_location': user.companyLocation,
      'business_sector': user.businessSector,
    };

    final Map<String, dynamic> filteredUserMetadata = {};
    userMetadata.forEach((key, value) {
      if (value != null) {
        filteredUserMetadata[key] = value;
      }
    });

    if (filteredUserMetadata.isEmpty) {
      return;
    }

    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $managementApiToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'user_metadata': filteredUserMetadata}),
    );

    if (response.statusCode != 200) {
      debugPrint('Auth0 Metadata Update Error: ${response.body}');
      throw Exception('Failed to update Auth0 user metadata: ${response.body}');
    }
  }

  Future<String?> _getManagementApiToken() async {
    return null; // Placeholder
  }
}
