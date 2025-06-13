import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/auth0_service.dart';
import '../../../core/utils/connectivity_service.dart';

/// Classe gérant la connexion et la persistance des données utilisateur
class AuthRepository {
  /// Clé utilisée pour le stockage des données utilisateur dans Hive
  static const String _userBoxName = 'userBox';
  
  /// Clé utilisée pour le stockage du token d'authentification
  static const String _tokenKey = 'auth_token'; 

  final Auth0Service _auth0Service; // Changed to be non-final and initialized in constructor
  final ConnectivityService _connectivityService = ConnectivityService();

  User? _currentUser;

  AuthRepository({required Auth0Service auth0Service}) : _auth0Service = auth0Service; // Constructor to inject Auth0Service

  /// Méthode d'initialisation
  Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserAdapter());
    }
    await Hive.openBox<User>(_userBoxName);
    await _connectivityService.init();
    await _auth0Service.init();
  }

  /// Authentifie un utilisateur.
  Future<User> login(String email, String password) async {
    try {
      User user;
      // La logique pour déterminer s'il faut utiliser Auth0 ou le compte démo est dans Auth0Service.
      // Si l'intention est de se connecter avec le compte démo, AuthBloc devrait appeler loginWithDemoAccount.
      // Cette méthode `login` est pour la connexion standard.
      debugPrint('AuthRepository: Tentative de connexion standard (non-démo) via Auth0Service.login');
      user = await _auth0Service.login(); 
      
      await _saveUserData(user);
      _currentUser = user;
      return user;
    } catch (e) {
      debugPrint('AuthRepository: Erreur lors de la connexion standard: $e');
      if (!_connectivityService.isConnected) {
        debugPrint('AuthRepository: Mode hors ligne détecté après échec de connexion. Tentative de récupération du dernier utilisateur connecté.');
        final offlineUser = await _auth0Service.offlineAuthService.getLastLoggedInUser();
        if (offlineUser != null) {
          // Vérifier si cet utilisateur hors ligne est l'utilisateur démo
          // Cela est géré implicitement si getLastLoggedInUser peut retourner le démo.
          debugPrint('AuthRepository: Utilisation de l\'utilisateur stocké localement (potentiellement démo) via OfflineAuthService.');
          await _saveUserData(offlineUser);
          _currentUser = offlineUser;
          return offlineUser;
        }
      }
      throw Exception('Échec de l\'authentification: $e');
    }
  }

  /// Authentifie avec le compte de démonstration.
  Future<User> loginWithDemoAccount() async {
    try {
      debugPrint('AuthRepository: Tentative de connexion avec le compte de démonstration via Auth0Service');
      // Demo user active flag should be set by AuthBloc before calling this
      final User user = await _auth0Service.loginWithDemoAccount();
      await _saveUserData(user);
      _currentUser = user;
      return user;
    } catch (e) {
      debugPrint('AuthRepository: Erreur lors de la connexion avec le compte de démonstration: $e');
      // Ensure demo user key is cleared on failure by Auth0Service
      await _auth0Service.setDemoUserActive(false);
      throw Exception('Échec de la connexion de démonstration: $e');
    }
  }

  /// Déconnecte l'utilisateur actuel
  Future<void> logout() async {
    try {
      await _auth0Service.logout(); // Auth0Service handles clearing its own tokens including demo key
      
      final userBox = Hive.box<User>(_userBoxName);
      await userBox.clear();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      debugPrint('Données utilisateur local et token SharedPreferences supprimés.');
      // No need to explicitly clear demo key here, logout in Auth0Service should handle it.
    } catch (e) {
      debugPrint('Erreur lors de la déconnexion: $e');
      throw Exception('Échec de la déconnexion: $e');
    }
  }

  /// Envoie un email de réinitialisation de mot de passe
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      // Appeler la méthode correspondante dans Auth0Service
      // Cette méthode devra être implémentée dans Auth0Service
      await _auth0Service.sendPasswordResetEmail(email);
      debugPrint('Email de réinitialisation de mot de passe envoyé à $email');
    } catch (e) {
      debugPrint('Erreur lors de l\'envoi de l\'email de réinitialisation: $e');
      throw Exception('Échec de l\'envoi de l\'email de réinitialisation: $e');
    }
  }

  /// Récupère l'utilisateur actuel s'il est connecté
  Future<User?> getCurrentUser() async {
    // Si l'utilisateur démo est actif, il devrait être récupéré par les mécanismes standards
    // car Auth0Service.isAuthenticated() et Auth0Service.getAccessToken() le gèrent.
    if (await _auth0Service.isDemoUserActive()) {
        debugPrint("AuthRepository: Demo user is active. Attempting to retrieve from offlineAuthService.");
        final demoUser = await _auth0Service.offlineAuthService.getLastLoggedInUser();
        if (demoUser != null) {
            await _saveUserData(demoUser); // Assurer la cohérence avec la boîte Hive locale
            _currentUser = demoUser;
            return demoUser;
        }
        // Si l'utilisateur démo est actif mais non trouvé hors ligne, cela pourrait être un état inattendu.
        // Peut-être forcer un logout ou une tentative de re-login démo ? Pour l'instant, on continue.
         debugPrint("AuthRepository: Demo user is active but not found in offlineAuthService. This might be an issue.");
    }

    // Prioritize Auth0Service for current user status (handles demo user implicitly via its own checks)
    if (await _auth0Service.isAuthenticated()) {
        final accessToken = await _auth0Service.getAccessToken();
        if (accessToken != null) {
            try {
                 // Attempt to get user info from Auth0 if online, or from offline storage
                if (_connectivityService.isConnected && !(await _auth0Service.isDemoUserActive())) { // Use the new public method
                    final user = await _auth0Service.getUserInfo(accessToken);
                    if (user != null) { // Add null check for user before saving
                      await _saveUserData(user); // Update local cache
                    }
                    return user;
                } else {
                    // Fallback to offline user if demo or actually offline
                    final offlineUser = await _auth0Service.offlineAuthService.getLastLoggedInUser();
                    if (offlineUser != null) { // Add null check for offlineUser before saving
                        await _saveUserData(offlineUser);
                    }
                    return offlineUser;
                }
            } catch (e) {
                debugPrint("Erreur getInfo/offline user in getCurrentUser: $e");
                // Fallback to Hive box if Auth0 fails unexpectedly
            }
        }
    }
    
    // Fallback to local Hive box if Auth0Service doesn't yield a user
    final userBox = Hive.box<User>(_userBoxName);
    if (userBox.isNotEmpty) {
      return userBox.getAt(0);
    }
    
    // Aucun utilisateur trouvé
    return null;
  }

  /// Vérifie si un utilisateur est connecté
  Future<bool> isLoggedIn() async {
    // Delegate to Auth0Service
    return await _auth0Service.isAuthenticated();
  }

  /// Sauvegarde les données de l'utilisateur
  Future<void> _saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    // Storing the token from user model might be okay, but Auth0Service should be the source of truth for tokens
    if (user.token != null) { // Add null check for user.token
      await prefs.setString(_tokenKey, user.token!);
    } else {
      await prefs.remove(_tokenKey); // Remove token if null
    }
    
    final userBox = Hive.box<User>(_userBoxName);
    await userBox.clear(); // Supprime l'ancien utilisateur s'il existe
    await userBox.add(user);
  }

  /// Updates the user profile data in the backend and local cache.
  Future<void> updateUserProfile(User user, {File? profileImage}) async {
    final User userToUpdate = user.copyWith(); // Create a copy to ensure original is not mutated unexpectedly
    _currentUser = userToUpdate;

    await _saveUserData(userToUpdate);

    if (profileImage != null) {
      // TODO: Gérer le téléchargement de l'image de profil
    }

    // final token = await _auth0Service.getAccessToken(); // Commented out as updateUserMetadata is
    // if (token != null) {                                // Commented out
    //   try {                                             // Commented out
    //     // Corrected method name if it was a typo, or ensure it exists in Auth0Service
    //     // await _auth0Service.updateUserMetadata(token, userToUpdate); // Commented out
    //   } catch (e) {                                     // Commented out
    //     debugPrint('Error updating Auth0 profile/metadata: $e'); // Commented out
    //   }                                                 // Commented out
    // }                                                   // Commented out
  }

  /// Updates the local user data and metadata in Auth0.
  Future<void> updateLocalUser(User user) async {
    _currentUser = user;
    await _saveUserData(user);
    // final String? currentToken = await _auth0Service.getAccessToken(); // Commented out
    // if (currentToken != null && _currentUser != null) {                // Commented out
    //   // Corrected method name if it was a typo, or ensure it exists in Auth0Service
    //   // await _auth0Service.updateUserMetadata(currentToken, _currentUser!); // Commented out
    // }                                                                  // Commented out
  }

  /// Récupère l'utilisateur avec une option pour forcer la récupération distante
  Future<User?> getUser({bool forceRemote = false}) async {
    if (!forceRemote && _currentUser != null) {
      return _currentUser;
    }

    final token = await _auth0Service.getAccessToken();
    if (token == null) {
      // Pas de token, essayer de charger depuis le stockage hors ligne
      _currentUser = await _auth0Service.offlineAuthService.getLastLoggedInUser();
      return _currentUser;
    } else {
      // Essayer de récupérer depuis le service distant (Auth0)
      final remoteUser = await _auth0Service.getUserInfo(token); // token is non-null here
      if (remoteUser != null) {
        await _auth0Service.offlineAuthService.saveUserForOfflineLogin(remoteUser); // Correct method name
        _currentUser = remoteUser;
        return _currentUser;
      }
    }
    return null;
  }

  /// Sets the demo user active state.
  Future<void> setDemoUserActive(bool isActive) async {
    await _auth0Service.setDemoUserActive(isActive);
  }
}
