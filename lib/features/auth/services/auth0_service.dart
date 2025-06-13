import 'package:flutter/foundation.dart'; // For kIsWeb if needed later
import 'package:flutter/material.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import '../../../core/services/auth0_management_api_service.dart'; // Unused
import '../models/user.dart';
import '../../../core/utils/connectivity_service.dart';
import '../../../core/config/env_config.dart';
import 'offline_auth_service.dart';

/// Service pour gérer l'authentification avec Auth0
class Auth0Service {
  String get _auth0Domain => EnvConfig.auth0Domain;
  String get _auth0ClientId => EnvConfig.auth0ClientId;
  String get _auth0Audience => EnvConfig.auth0Audience;
  String get _auth0Scheme => EnvConfig.auth0Scheme;

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _idTokenKey = 'id_token';
  static const String _expiresAtKey = 'expires_at';
  static const String _demoUserKey = 'demo_user_active';

  late Auth0 auth0;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final ConnectivityService _connectivityService = ConnectivityService();
  final OfflineAuthService offlineAuthService;

  Auth0Service({required this.offlineAuthService}) {
    auth0 = Auth0(_auth0Domain, _auth0ClientId);
  }

  Future<void> init() async {
    await _connectivityService.init();
  }

  Future<bool> isDemoUserActive() async {
    return await _secureStorage.read(key: _demoUserKey) == 'true';
  }

  Future<void> setDemoUserActive(bool isActive) async {
    if (isActive) {
      await _secureStorage.write(key: _demoUserKey, value: 'true');
      debugPrint("Auth0Service: Demo user mode explicitly ACTIVATED.");
    } else {
      await _secureStorage.delete(key: _demoUserKey);
      debugPrint("Auth0Service: Demo user mode explicitly DEACTIVATED.");
    }
  }

  Future<bool> isAuthenticated() async {
    if (await isDemoUserActive()) {
      debugPrint("Auth0Service: Demo user is active and considered authenticated.");
      return true;
    }
    return await auth0.credentialsManager.hasValidCredentials(minTtl: 60);
  }

  Future<User> loginWithDemoAccount() async {
    debugPrint('Auth0Service: Connexion avec le compte de démonstration');
    await setDemoUserActive(true);

    final demoUser = User(
      id: 'demo-user-id',
      name: 'Utilisateur Démo Wanzo',
      email: 'demo@wanzo.app',
      phone: '+243000000000',
      role: 'admin',
      token: 'mock_demo_access_token_${DateTime.now().millisecondsSinceEpoch}',
      picture: 'https://i.pravatar.cc/150?u=demo@wanzo.app',
      companyId: 'demo-company-id',
      companyName: 'Demo Company SARL',
      idCardStatus: IdStatus.VERIFIED,
      emailVerified: true, // Added for User model compatibility
      phoneVerified: true, // Added for User model compatibility
    );

    await _secureStorage.write(key: _accessTokenKey, value: demoUser.token);
    await _secureStorage.write(key: _idTokenKey, value: 'mock_demo_id_token');
    await _secureStorage.write(key: _expiresAtKey, value: DateTime.now().add(const Duration(days: 365)).millisecondsSinceEpoch.toString());
    await _secureStorage.write(key: _demoUserKey, value: 'true');

    await offlineAuthService.saveUserForOfflineLogin(demoUser);
    await offlineAuthService.setOfflineLoginEnabled(true);
    debugPrint("Auth0Service: Demo user saved for offline login and offline mode enabled.");

    return demoUser;
  }

  /// Se connecte à Auth0 en utilisant les pages d'authentification d'Auth0 directement
  Future<User> login() async {
    try {
      debugPrint("Auth0Service: Attempting Auth0 login with hosted login page. Clearing demo user flag.");
      await setDemoUserActive(false);
      await auth0.credentialsManager.clearCredentials();

      debugPrint("Auth0Service: Using client ID: $_auth0ClientId");
      debugPrint("Auth0Service: Using domain: $_auth0Domain");
      debugPrint("Auth0Service: Using audience: $_auth0Audience");
      debugPrint("Auth0Service: Using scheme: $_auth0Scheme");

      // Utiliser directement les pages d'authentification d'Auth0 au lieu des pages intégrées
      final Credentials credentials = await auth0
          .webAuthentication(scheme: _auth0Scheme)
          .login(
            audience: _auth0Audience,
            scopes: {'openid', 'profile', 'email', 'offline_access', 'read:user_id_token'},
            // Utilisation du mode Universal Login d'Auth0
            parameters: {
              'prompt': 'login', // Force l'affichage de la page de login même si l'utilisateur est déjà connecté
            },
          );

      await _saveCredentials(credentials);
      debugPrint("Auth0Service: Login successful, tokens stored. Credentials expire at: ${credentials.expiresAt}");

      final user = await getUserInfoFromSdk();
      if (user != null) {
        await offlineAuthService.saveUserForOfflineLogin(user);
        return user;
      } else {
        throw Exception('Failed to get user info after login.');
      }
    } on WebAuthenticationException catch (e) {
      final String eMessage = e.message.toLowerCase();
      // Ensure details is converted to string before toLowerCase()
      final String eDetails = e.details.toString().toLowerCase();
      debugPrint('WebAuthenticationException during login: ${e.message}. Details: ${e.details}.');

      bool userCancelled = eMessage.contains('cancel') || eDetails.contains('cancel') ||
                           eMessage.contains('user_cancelled') || eDetails.contains('user_cancelled') ||
                           eMessage.contains('user closed') || eDetails.contains('user closed') ||
                           eMessage.contains('a0.session.user_cancelled') || eDetails.contains('a0.session.user_cancelled');

      if (userCancelled) {
        debugPrint('User cancelled login flow.');
      } else {
        final offlineUser = await offlineAuthService.getLastLoggedInUser();
        if (offlineUser != null) {
          debugPrint('Returning last logged in user due to online login failure (WebAuthenticationException).');
          return offlineUser;
        }
      }
      rethrow;
    } on CredentialsManagerException catch (e) { // Specific catch block for CredentialsManagerException
      debugPrint('CredentialsManagerException during login: ${e.message}. Details: ${e.details}.');
      final offlineUser = await offlineAuthService.getLastLoggedInUser();
      if (offlineUser != null) {
        debugPrint('Returning last logged in user due to online login failure (CredentialsManagerException).');
        return offlineUser;
      }
      rethrow;
    } on ApiException catch (e) {
      debugPrint('ApiException during login: Status: ${e.statusCode}. Details: ${e.toString()}');
      final offlineUser = await offlineAuthService.getLastLoggedInUser();
      if (offlineUser != null) {
        debugPrint('Returning last logged in user due to online login failure (ApiException).');
        return offlineUser;
      }
      rethrow;
    } catch (e) {
      debugPrint('Generic error during login: $e');
      final offlineUser = await offlineAuthService.getLastLoggedInUser();
      if (offlineUser != null) {
        debugPrint('Returning last logged in user due to online login failure (Generic Error).');
        return offlineUser;
      }
      rethrow;
    }
  }

  Future<void> _saveCredentials(Credentials credentials) async {
    await _secureStorage.write(key: _accessTokenKey, value: credentials.accessToken);
    await _secureStorage.write(key: _idTokenKey, value: credentials.idToken);
    if (credentials.refreshToken != null) {
      await _secureStorage.write(key: _refreshTokenKey, value: credentials.refreshToken!);
    }
    await _secureStorage.write(key: _expiresAtKey, value: credentials.expiresAt.millisecondsSinceEpoch.toString());
  }

  Future<void> logout() async {
    try {
      final bool wasDemoUser = await isDemoUserActive();
      debugPrint("Auth0Service: Logging out. Was demo user: $wasDemoUser");

      if (!wasDemoUser) {
        try {
          await auth0.webAuthentication(scheme: _auth0Scheme).logout();
          debugPrint("Auth0Service: Auth0 SDK web logout initiated.");
        } on WebAuthenticationException catch (e) {
          debugPrint("Auth0Service: WebAuthenticationException during web logout: ${e.message}. Details: ${e.details}. Proceeding with local cleanup.");
        } catch (e) {
          debugPrint("Auth0Service: Generic error during web logout: $e. Proceeding with local cleanup.");
        }
      }

      await _secureStorage.delete(key: _accessTokenKey);
      await _secureStorage.delete(key: _refreshTokenKey);
      await _secureStorage.delete(key: _idTokenKey);
      await _secureStorage.delete(key: _expiresAtKey);
      await _secureStorage.delete(key: _demoUserKey);
      debugPrint("Auth0Service: All local tokens and demo key deleted.");

      if (!wasDemoUser) {
        try {
          await auth0.credentialsManager.clearCredentials();
          debugPrint("Auth0Service: Cleared credentials from CredentialsManager.");
        } on CredentialsManagerException catch (e) {
          debugPrint("Auth0Service: CredentialsManagerException during clearCredentials: ${e.message}. Details: ${e.details}.");
        } catch (e) {
          debugPrint("Auth0Service: Generic error during clearCredentials: $e.");
        }
      }

      if (!wasDemoUser) {
        final keepOfflineData = await offlineAuthService.isOfflineLoginEnabled();
        if (!keepOfflineData) {
          await offlineAuthService.clearOfflineData(); // Corrected method name
          debugPrint('Auth0Service: Offline user data cleared for non-demo user.');
        }
      } else {
        debugPrint('Auth0Service: Demo user logout. Offline data retained by default.');
      }
    } catch (e) {
      debugPrint('Error during logout: $e');
    }
  }

  Future<String?> getAccessToken() async {
    if (await isDemoUserActive()) {
      debugPrint("Auth0Service: Demo user active. Returning demo access token.");
      return await _secureStorage.read(key: _accessTokenKey);
    }

    try {
      final credentials = await auth0.credentialsManager.credentials(minTtl: 60);
      await _saveCredentials(credentials);
      return credentials.accessToken;
    } on CredentialsManagerException catch (e) {
      debugPrint('CredentialsManagerException getting access token: ${e.message}. Details: ${e.details}. Logging out.'); // Removed cause
      await logout();
      return null;
    } catch (e) {
      debugPrint('Generic error getting access token: $e. Logging out.');
      await logout();
      return null;
    }
  }

  Future<String?> refreshAccessToken() async {
    if (await isDemoUserActive()) {
      debugPrint("Auth0Service: Demo user active, no refresh needed for demo token.");
      return await _secureStorage.read(key: _accessTokenKey);
    }
    try {
      debugPrint("Auth0Service: Attempting to renew credentials via SDK (credentialsManager.credentials with minTtl).");
      final Credentials credentials = await auth0.credentialsManager.credentials(minTtl: 60);

      await _saveCredentials(credentials);
      debugPrint("Auth0Service: Credentials renewed/validated successfully. Access token available.");
      return credentials.accessToken;
    } on CredentialsManagerException catch (e) {
      debugPrint('CredentialsManagerException during token refresh: ${e.message}. Details: ${e.details}. Logging out.');
      await logout();
      return null;
    } catch (e) {
      debugPrint('Generic error during token refresh: $e. Logging out.');
      await logout();
      return null;
    }
  }

  Future<User?> getUserInfoFromSdk() async {
    if (await isDemoUserActive()) {
      final demoToken = await _secureStorage.read(key: _accessTokenKey);
      final demoUser = await offlineAuthService.getLastLoggedInUser();
      if (demoUser != null && demoUser.token == demoToken) {
        debugPrint("Auth0Service: Demo user active. Returning stored demo user from offline service.");
        return demoUser;
      }
      debugPrint("Auth0Service: Demo user active but no matching user found in offline store. This shouldn't happen.");
      return null;
    }

    debugPrint("Auth0Service: Fetching user info using auth0.api.userProfile().");
    try {
      String? accessToken;
      if (await auth0.credentialsManager.hasValidCredentials(minTtl: 5)) {
        final creds = await auth0.credentialsManager.credentials();
        accessToken = creds.accessToken;
      } else {
        debugPrint("Auth0Service: No valid credentials to fetch user info. Attempting refresh.");
        accessToken = await refreshAccessToken();
        if (accessToken == null) {
          debugPrint("Auth0Service: Refresh failed. Cannot fetch user info.");
          return null;
        }
      }

      final UserProfile userProfile = await auth0.api.userProfile(accessToken: accessToken);
      final Credentials currentCredentials = await auth0.credentialsManager.credentials();

      return User(
        id: userProfile.sub, // sub is non-nullable in UserProfile
        name: userProfile.name ?? userProfile.nickname ?? 'N/A',
        email: userProfile.email ?? 'N/A',
        emailVerified: userProfile.isEmailVerified ?? false,
        picture: userProfile.pictureUrl?.toString(),
        phone: userProfile.customClaims?['https://wanzo.app/phone_number'] as String? ?? userProfile.phoneNumber ?? '',
        phoneVerified: userProfile.isPhoneNumberVerified ?? false,
        role: _extractRole(userProfile.customClaims?['https://wanzo.app/roles']),
        companyId: userProfile.customClaims?['https://wanzo.app/company_id'] as String?,
        companyName: userProfile.customClaims?['https://wanzo.app/company_name'] as String?,
        idCardStatus: _parseIdStatus(userProfile.customClaims?['https://wanzo.app/id_card_status'] as String?),
        token: currentCredentials.accessToken,
      );
    } on ApiException catch (e) { // Specific catch block for ApiException
      debugPrint('ApiException fetching user info: Status: ${e.statusCode}, Details: ${e.toString()}');
      return null;
    } catch (e) {
      debugPrint('Generic error fetching user info with auth0.api.userProfile(): $e');
      return null;
    }
  }

  // Add compatibility method for old code still using getUserInfo
  Future<User?> getUserInfo(String accessToken) async {
    // Simply delegate to getUserInfoFromSdk
    return await getUserInfoFromSdk();
  }

  String _extractRole(dynamic rolesClaim) {
    if (rolesClaim is List && rolesClaim.isNotEmpty) {
      return rolesClaim.first as String? ?? 'user';
    } else if (rolesClaim is String) {
      return rolesClaim;
    }
    return 'user';
  }

  IdStatus _parseIdStatus(String? statusString) {
    if (statusString == null) return IdStatus.UNKNOWN;
    switch (statusString.toLowerCase()) {
      case 'pending':
        return IdStatus.PENDING;
      case 'verified':
        return IdStatus.VERIFIED;
      case 'rejected':
        return IdStatus.REJECTED;
      default:
        return IdStatus.UNKNOWN;
    }
  }

  Future<String?> getIdToken() async {
    if (await isDemoUserActive()) {
      return await _secureStorage.read(key: _idTokenKey);
    }
    try {
      if (await auth0.credentialsManager.hasValidCredentials()) {
        final credentials = await auth0.credentialsManager.credentials();
        return credentials.idToken;
      }
    } on CredentialsManagerException catch (e) {
      debugPrint('CredentialsManagerException getting id token: ${e.message}. Details: ${e.details}.');
    }
    return null;
  }

  /// Sends a password reset email using Auth0's API
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      debugPrint('Auth0Service: Sending password reset email to $email');
      await auth0.api.resetPassword(
        email: email,
        connection: 'Username-Password-Authentication', // This is typically the default connection
      );
      debugPrint('Auth0Service: Password reset email sent successfully');
    } on ApiException catch (e) {
      debugPrint('ApiException during password reset: Status: ${e.statusCode}. Details: ${e.toString()}');
      rethrow;
    } catch (e) {
      debugPrint('Generic error during password reset: $e');
      rethrow;
    }
  }
}

// Assuming IdStatus enum exists, e.g.:
// enum IdStatus { NOT_UPLOADED, PENDING, VERIFIED, REJECTED }
// User model needs to be compatible with UserProfile fields (e.g. emailVerified, phoneVerified)
