import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/auth0_service.dart';
import '../../../core/utils/connectivity_service.dart';
import '../../../core/services/file_storage_service.dart'; // Import FileStorageService

/// Classe gérant la connexion et la persistance des données utilisateur
class AuthRepository {
  /// Clé utilisée pour le stockage des données utilisateur dans Hive
  static const String _userBoxName = 'userBox';
  
  /// Clé utilisée pour le stockage du token d'authentification
  static const String _tokenKey = 'auth_token'; 

  final Auth0Service _auth0Service = Auth0Service();
  final ConnectivityService _connectivityService = ConnectivityService();
  final FileStorageService _fileStorageService = FileStorageService(); // Instantiate FileStorageService

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
      debugPrint('Tentative de connexion avec Auth0 via AuthRepository.login');
      user = await _auth0Service.login(); // Directly call Auth0 login
      
      await _saveUserData(user);
      return user;
    } catch (e) {
      debugPrint('Erreur lors de la connexion dans AuthRepository: $e');
      // Tenter de récupérer l'utilisateur hors ligne en dernier recours
      if (!_connectivityService.isConnected) {
        final currentUser = await _auth0Service.offlineAuthService.getLastLoggedInUser();
        if (currentUser != null) {
          debugPrint('Utilisation de l\'utilisateur stocké localement via OfflineAuthService');
          await _saveUserData(currentUser); // Ensure local Hive box is also updated
          return currentUser;
        }
      }
      throw Exception('Échec de l\'authentification: $e');
    }
  }

  /// Authentifie avec le compte de démonstration.
  Future<User> loginWithDemoAccount() async {
    try {
      debugPrint('Tentative de connexion avec le compte de démonstration via AuthRepository');
      final User user = await _auth0Service.loginWithDemoAccount();
      await _saveUserData(user);
      return user;
    } catch (e) {
      debugPrint('Erreur lors de la connexion avec le compte de démonstration: $e');
      throw Exception('Échec de la connexion de démonstration: $e');
    }
  }

  /// Déconnecte l'utilisateur actuel
  Future<void> logout() async {
    try {
      await _auth0Service.logout(); // Auth0Service handles clearing its own tokens
      
      final userBox = Hive.box<User>(_userBoxName);
      await userBox.clear();
      
      // SharedPreferences token clearing might be redundant if Auth0Service is the source of truth
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      debugPrint('Données utilisateur local et token SharedPreferences supprimés.');
    } catch (e) {
      debugPrint('Erreur lors de la déconnexion: $e');
      throw Exception('Échec de la déconnexion: $e');
    }
  }

  /// Récupère l'utilisateur actuel s'il est connecté
  Future<User?> getCurrentUser() async {
    // Prioritize Auth0Service for current user status
    if (await _auth0Service.isAuthenticated()) {
        final accessToken = await _auth0Service.getAccessToken();
        if (accessToken != null) {
            try {
                 // Attempt to get user info from Auth0 if online, or from offline storage
                if (_connectivityService.isConnected && !(await _auth0Service.isDemoUserActive())) { // Use the new public method
                    final user = await _auth0Service.getUserInfo(accessToken);
                    await _saveUserData(user); // Update local cache
                    return user;
                } else {
                    // Fallback to offline user if demo or actually offline
                    final offlineUser = await _auth0Service.offlineAuthService.getLastLoggedInUser();
                    if (offlineUser != null) {
                        await _saveUserData(offlineUser);
                        return offlineUser;
                    }
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
    await prefs.setString(_tokenKey, user.token); 
    
    final userBox = Hive.box<User>(_userBoxName);
    await userBox.clear(); // Supprime l'ancien utilisateur s'il existe
    await userBox.add(user);
  }

  /// Updates the user profile data in the backend and local cache.
  Future<User> updateUserProfile(User updatedUser, {File? profileImageFile}) async { // Added profileImageFile parameter
    User userToUpdate = updatedUser;
    if (profileImageFile != null) {
      // Upload the image and get the URL
      final imageUrl = await _fileStorageService.uploadProfileImage(profileImageFile, updatedUser.id);
      if (imageUrl != null) {
        userToUpdate = userToUpdate.copyWith(picture: imageUrl);
      } else {
        // Handle image upload failure if necessary, e.g., by logging or showing a message
        debugPrint('Failed to upload profile image.');
      }
    }

    // TODO: Implement the actual API call to update user data on your backend.
    // For now, we will simulate a delay and then save locally.
    debugPrint('Simulating API call to update user profile for: ${userToUpdate.email}');
    await Future.delayed(const Duration(seconds: 1)); // Simulate network latency

    // After successful backend update, save the updated user data locally.
    await _saveUserData(userToUpdate);
    debugPrint('User profile updated and saved locally.');
    return userToUpdate;
  }
}
