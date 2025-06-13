// filepath: c:\Users\DevSpace\Flutter\wanzo\lib\features\auth\services\offline_auth_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sqflite/sqflite.dart';
import '../models/user.dart';
import '../../../core/services/database_service.dart';
import '../../../core/utils/connectivity_service.dart';

/// Service pour gérer l'authentification en mode hors ligne
class OfflineAuthService {
  static const String _lastUserKey = 'lastLoggedInUser';
  static const String _offlineLoginEnabledKey = 'offlineLoginEnabled';
    final FlutterSecureStorage _secureStorage;
  final DatabaseService _databaseService;
  // ConnectivityService is used in canLoginOffline and other methods through _databaseService
  
  /// Constructeur
  OfflineAuthService({
    required FlutterSecureStorage secureStorage,
    required DatabaseService databaseService,
    required ConnectivityService connectivityService,
  }) : _secureStorage = secureStorage,
       _databaseService = databaseService;
  
  /// Vérifie si l'authentification hors ligne est activée
  Future<bool> isOfflineLoginEnabled() async {
    final value = await _secureStorage.read(key: _offlineLoginEnabledKey);
    return value == 'true';
  }
  
  /// Active ou désactive l'authentification hors ligne
  Future<void> setOfflineLoginEnabled(bool enabled) async {
    await _secureStorage.write(
      key: _offlineLoginEnabledKey, 
      value: enabled.toString(),
    );
  }
  
  /// Sauvegarde les informations de l'utilisateur pour l'authentification hors ligne
  Future<void> saveUserForOfflineLogin(User user) async {
    try {
      // Enregistrer l'utilisateur dans le stockage sécurisé
      await _secureStorage.write(
        key: _lastUserKey,
        value: jsonEncode(user.toJson()),
      );
      
      debugPrint('Utilisateur sauvegardé pour l\'authentification hors ligne');
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde de l\'utilisateur pour l\'authentification hors ligne: $e');
    }
  }
  
  /// Récupère l'utilisateur sauvegardé pour l'authentification hors ligne
  Future<User?> getLastLoggedInUser() async {
    try {
      final userData = await _secureStorage.read(key: _lastUserKey);
      
      if (userData != null) {
        final userJson = jsonDecode(userData) as Map<String, dynamic>;
        return User.fromJson(userJson);
      }
    } catch (e) {
      debugPrint('Erreur lors de la récupération de l\'utilisateur hors ligne: $e');
    }
    
    return null;
  }
  
  /// Supprime les informations de l\'utilisateur pour l\'authentification hors ligne
  Future<void> clearOfflineData() async {
    await _secureStorage.delete(key: _lastUserKey);
    // Potentially also delete other offline data if necessary, e.g., from local DB
    // await _databaseService.database.then((db) => db.delete('user_specific_table', where: 'userId = ?', whereArgs: [userId]));
    debugPrint("OfflineAuthService: Cleared last logged in user from secure storage.");
  }
  
  /// Vérifie si l'utilisateur peut se connecter en mode hors ligne
  Future<bool> canLoginOffline() async {
    if (!await isOfflineLoginEnabled()) {
      return false;
    }
    
    final user = await getLastLoggedInUser();
    return user != null;
  }
  
  /// Met à jour le cache des données utilisateur
  Future<void> updateUserDataCache(User user, Map<String, dynamic> userData) async {
    try {
      final db = await _databaseService.database;
      
      // Stocker les données utilisateur dans la base de données locale
      await db.insert(
        'user_data_cache',
        {
          'user_id': user.id,
          'data_type': 'profile',
          'data': jsonEncode(userData),
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      debugPrint('Données utilisateur mises en cache pour ${user.id}');
    } catch (e) {
      debugPrint('Erreur lors de la mise en cache des données utilisateur: $e');
    }
  }
  
  /// Récupère les données utilisateur mises en cache
  Future<Map<String, dynamic>?> getCachedUserData(String userId) async {
    try {
      final db = await _databaseService.database;
      
      final List<Map<String, dynamic>> results = await db.query(
        'user_data_cache',
        where: 'user_id = ? AND data_type = ?',
        whereArgs: [userId, 'profile'],
        orderBy: 'timestamp DESC',
        limit: 1,
      );
      
      if (results.isNotEmpty) {
        final cachedData = results.first;
        final dataStr = cachedData['data'] as String;
        return jsonDecode(dataStr) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('Erreur lors de la récupération des données utilisateur en cache: $e');
    }
    
    return null;
  }
}
