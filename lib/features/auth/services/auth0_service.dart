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

  /// Sets the demo user mode active status
  Future<void> setDemoUserActive(bool isActive) async {
    if (isActive) {
      await _secureStorage.write(key: _demoUserKey, value: 'true');
      debugPrint("Auth0Service: Demo user mode explicitly ACTIVATED.");
    } else {
      await _secureStorage.delete(key: _demoUserKey);
      debugPrint("Auth0Service: Demo user mode explicitly DEACTIVATED.");
    }
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
    // Ensure demo mode is active
    await setDemoUserActive(true);

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

      final TokenResponse result = await _appAuth.authorizeAndExchangeCode(
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

      if (result.accessToken == null || result.idToken == null) {
        throw Exception('Login failed: No token received or ID token missing.');
      }

      await _secureStorage.write(key: _accessTokenKey, value: result.accessToken);
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
      // Explicitly delete demo user key on any logout
      await _secureStorage.delete(key: _demoUserKey); 
      debugPrint("Auth0Service: Demo user key deleted on logout.");

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

      final TokenResponse result = await _appAuth.token(
        TokenRequest(
          _auth0ClientId,
          _auth0RedirectUri,
          issuer: 'https://$_auth0Domain',
          refreshToken: refreshToken,
          scopes: ['openid', 'profile', 'email', 'offline_access', 'read:user_id_token'],
          additionalParameters: {'audience': _auth0Audience},
        ),
      );

      if (result.accessToken != null) {
        await _secureStorage.write(key: _accessTokenKey, value: result.accessToken);
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
      // Temporarily allow updates without management API token for fields Auth0 might allow updating directly
      // This is NOT standard for user_metadata. Proper solution needs _getManagementApiToken implemented.
      // However, some basic profile fields might be updatable via /userinfo or other means if not custom metadata.
      // For now, we'll proceed assuming user_metadata update is the goal and requires management token.
      debugPrint("Auth0Service: Management API token is null. Cannot update user_metadata fields like business profile details.");
      // Depending on policy, either throw an error or allow updating only standard claims if possible elsewhere.
      // For this specific function targeting user_metadata, a management token is essential.
      throw Exception('Could not retrieve management API token. User metadata update failed.');
    }

    if (user.id.isEmpty) {
      throw Exception('User ID is missing, cannot update metadata.');
    }

    final url = Uri.parse('https://$_auth0Domain/api/v2/users/${user.id}');
    final Map<String, dynamic> userMetadata = {
      'phone_number': user.phone, // Standard claim, might be handled differently by Auth0
      'name': user.name, // Standard claim
      'picture': user.picture, // Standard claim
      // Custom metadata fields (these typically go into user_metadata)
      'job_title': user.jobTitle,
      'physical_address': user.physicalAddress,
      'id_card': user.idCard,
      'id_card_status': user.idCardStatus?.toString().split('.').last,
      'id_card_status_reason': user.idCardStatusReason,
      'company_id': user.companyId,
      'company_name': user.companyName,
      'rccm_number': user.rccmNumber,
      'company_location': user.companyLocation,
      'business_sector': user.businessSector, // Name of the sector
      'business_sector_id': user.businessSectorId, // ID of the sector
      'business_address': user.businessAddress,
      'business_logo_url': user.businessLogoUrl,
      // Note: Standard claims like email, given_name, family_name are often managed separately or part of root profile.
    };

    final Map<String, dynamic> filteredUserMetadata = {};
    userMetadata.forEach((key, value) {
      if (value != null) {
        // Auth0 expects user_metadata for custom fields.
        // Standard fields like phone_number, name, picture might need to be in the root of the PATCH body
        // or handled by different Auth0 API scopes/endpoints if not part of user_metadata.
        // For simplicity here, we assume all these are intended for user_metadata or Auth0 handles mapping.
        filteredUserMetadata[key] = value;
      }
    });

    if (filteredUserMetadata.isEmpty) {
      debugPrint("Auth0Service: No metadata to update or all values are null.");
      return;
    }

    // Construct the body. Auth0 usually distinguishes between root attributes and metadata.
    // For custom attributes, they should be nested under 'user_metadata'.
    // Standard attributes (like name, picture) might be at the root.
    // This example assumes we are primarily updating user_metadata for custom fields.
    // If phone_number, name, picture are standard OIDC claims, their update path might differ.
    // A more precise implementation would separate standard profile updates from custom metadata updates.

    Map<String, dynamic> bodyToUpdate = {};
    Map<String, dynamic> customMetadataForPayload = {};

    // Separate known standard claims from custom ones for Auth0 PATCH /api/v2/users/{id}
    // This is a common pattern, but exact fields depend on Auth0 setup (e.g. if phone_number is a root attribute)
    if (filteredUserMetadata.containsKey('name')) bodyToUpdate['name'] = filteredUserMetadata.remove('name');
    if (filteredUserMetadata.containsKey('picture')) bodyToUpdate['picture'] = filteredUserMetadata.remove('picture');
    if (filteredUserMetadata.containsKey('phone_number')) bodyToUpdate['phone_number'] = filteredUserMetadata.remove('phone_number');
    // Add other potential root attributes if necessary, e.g., given_name, family_name

    // All remaining fields in filteredUserMetadata are assumed to be custom user_metadata
    customMetadataForPayload = Map.from(filteredUserMetadata);

    if (customMetadataForPayload.isNotEmpty) {
      bodyToUpdate['user_metadata'] = customMetadataForPayload;
    }
    
    if (bodyToUpdate.isEmpty) {
        debugPrint("Auth0Service: No data to update after filtering standard/custom fields.");
        return;
    }

    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $managementApiToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(bodyToUpdate),
    );

    if (response.statusCode != 200) {
      debugPrint('Auth0 Metadata/Profile Update Error: ${response.body}');
      throw Exception('Failed to update Auth0 user profile/metadata: ${response.body}');
    }
    debugPrint("Auth0Service: User profile/metadata updated successfully.");
  }

  Future<String?> _getManagementApiToken() async {
    // TODO: CRITICAL - Implement actual Auth0 Management API token retrieval.
    // This typically involves a backend service making a secure call to the Auth0 /oauth/token endpoint
    // using client_credentials grant type with a Machine-to-Machine application that has permissions
    // to read/write user_metadata (e.g., update:users_app_metadata and read:users_app_metadata scopes).
    // 
    // DO NOT embed client secrets directly in the mobile application.
    // The mobile app should call a secure backend endpoint that you create, 
    // which then obtains and returns the Management API token.
    // 
    // Example of what the backend would do (conceptual):
    // POST https://YOUR_AUTH0_DOMAIN/oauth/token
    // Content-Type: application/x-www-form-urlencoded
    // 
    // client_id=YOUR_M2M_CLIENT_ID&
    // client_secret=YOUR_M2M_CLIENT_SECRET&
    // audience=https://YOUR_AUTH0_DOMAIN/api/v2/&
    // grant_type=client_credentials
    //
    // Returning null will cause updateUserMetadata to fail for metadata fields.
    // debugPrint("Auth0Service: _getManagementApiToken is not implemented. User metadata updates will fail.");
    // return null; // Placeholder - THIS NEEDS SECURE BACKEND IMPLEMENTATION

    final accessToken = await getAccessToken();
    if (accessToken == null) {
      debugPrint("Auth0Service: Cannot get management token without user access token.");
      return null;
    }

    // TODO: Replace with actual API client call
    // final apiClient = ApiClient(); // Assuming you have an ApiClient instance
    // final response = await apiClient.post('/api/auth/management-token', {}, token: accessToken);

    // This is a placeholder for the actual API call using http package for now
    // You should replace this with your ApiClient or http service configured for your app
    final url = Uri.parse('http://localhost:3000/api/auth/management-token'); // Use your actual base URL

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({}), // Empty body as per API_DOCUMENTATION.md
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody['success'] == true && responseBody['data'] != null && responseBody['data']['managementApiToken'] != null) {
          debugPrint("Auth0Service: Management API token retrieved successfully from backend.");
          return responseBody['data']['managementApiToken'] as String;
        } else {
          debugPrint("Auth0Service: Failed to get management token from backend. Response: ${response.body}");
          return null;
        }
      } else {
        debugPrint("Auth0Service: Error calling backend for management token. Status: ${response.statusCode}, Body: ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint("Auth0Service: Exception while calling backend for management token: $e");
      return null;
    }
  }
}
