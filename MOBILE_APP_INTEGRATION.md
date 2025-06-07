# Guide d'intégration de l'Application Mobile avec le Backend Wanzo

Ce document explique comment configurer l'application mobile Flutter pour qu'elle communique correctement avec l'architecture microservices de Wanzo, en utilisant l'API Gateway, Auth0 pour l'authentification, et l'accès aux services spécifiques comme app_mobile_service.

## Architecture de Communication

L'application mobile doit suivre le flux suivant pour communiquer avec le backend :

1. **Authentication** : Utilisation d'Auth0 pour l'authentification des utilisateurs
2. **API Gateway** : Point d'entrée principal pour toutes les requêtes
3. **Microservices** : Accès aux fonctionnalités spécifiques via les différents microservices

```
┌─────────────┐       ┌────────────┐       ┌───────────────┐
│ App Mobile  │──────▶│  Auth0     │──────▶│ JWT Token     │
└─────────────┘       └────────────┘       └───────────────┘
       │                                            │
       │                                            ▼
       │                                    ┌───────────────┐
       └───────────────────────────────────▶│  API Gateway  │
                                            └───────────────┘
                                                    │
                    ┌────────────────────────┬─────┴─────┬─────────────────────┐
                    ▼                        ▼           ▼                     ▼
            ┌───────────────┐        ┌─────────────┐    ┌───────────────┐     ┌───────────────┐
            │ Auth Service  │        │ App Mobile  │    │ Admin Service │     │ Autres        │
            │ (port 3000)   │        │ Service     │    │ (port 3001)   │     │ Microservices │
            └───────────────┘        │ (port 3006) │    └───────────────┘     └───────────────┘
                                     └─────────────┘
```

## Configuration Requise pour l'Application Flutter

### 1. Endpoints et Variables d'Environnement

Votre application Flutter utilise maintenant une configuration basée sur des variables d'environnement. Dans le fichier `lib/core/config/env_config.dart` :

```dart
// Fichier env_config.dart pour les variables d'environnement

class EnvConfig {
  // API Gateway comme point d'entrée principal
  static String get apiGatewayUrl => dotenv.env['API_GATEWAY_URL'] ?? 'http://localhost:8000/api';
  
  // URLs des services directs (à utiliser uniquement si nécessaire)
  static String get authServiceUrl => dotenv.env['AUTH_SERVICE_URL'] ?? 'http://localhost:3000/api';
  static String get appMobileServiceUrl => dotenv.env['APP_MOBILE_SERVICE_URL'] ?? 'http://localhost:3006/api';
  static String get adminServiceUrl => dotenv.env['ADMIN_SERVICE_URL'] ?? 'http://localhost:3001/api';
  
  // Configuration Auth0
  static String get auth0Domain => dotenv.env['AUTH0_DOMAIN'] ?? 'dev-tezmln0tk0g1gouf.eu.auth0.com';
  static String get auth0ClientId => dotenv.env['AUTH0_CLIENT_ID'] ?? '43d64kgsVYyCZHEFsax7zlRBVUiraCKL';
  static String get auth0Audience => dotenv.env['AUTH0_AUDIENCE'] ?? 'https://api.wanzo.com';
  static String get auth0RedirectUri => dotenv.env['AUTH0_REDIRECT_URI'] ?? 'com.wanzo.app://login-callback';
  static String get auth0LogoutUri => dotenv.env['AUTH0_LOGOUT_URI'] ?? 'com.wanzo.app://logout-callback';
  
  // Méthode pour obtenir l'URL de base appropriée
  static String getBaseUrl({bool useApiGateway = true}) {
    // Par défaut, utiliser l'API Gateway comme point d'entrée
    if (useApiGateway) {
      return apiGatewayUrl;
    }
    
    // Sinon, retourner l'URL du service demandé
    return authServiceUrl;
  }
}
```

⚠️ **Important** : Pour le développement sur des appareils physiques, remplacez `localhost` par l'adresse IP de votre machine où sont hébergés les services backend ou utilisez les variables d'environnement appropriées.

### 2. Configuration Auth0

Assurez-vous que votre application est correctement configurée pour utiliser Auth0 :

1. **Dépendances Flutter requises** :
   - `flutter_appauth`: Pour gérer le flux d'authentification OAuth2
   - `flutter_secure_storage`: Pour stocker en toute sécurité les tokens
   - `http`: Pour les appels API
   - `jwt_decoder`: Pour décoder et analyser les JWT tokens
   - `flutter_dotenv`: Pour gérer les variables d'environnement
   - `hive`: Pour le stockage local et le cache API
   - `connectivity_plus`: Pour la détection de la connectivité réseau

2. **Redirection URIs** :
   - Dans le tableau de bord Auth0, configurez les URI de redirection suivants :
     - Login Callback: `com.wanzo.app://login-callback`
     - Logout Callback: `com.wanzo.app://logout-callback`

3. **Types de Grant** :
   - Activez les types "Authorization Code" et "Refresh Token"
   - Vérifiez que l'audience `https://api.wanzo.com` est configurée correctement

4. **Configuration Android** :
   Ajoutez les configurations suivantes dans `android/app/src/main/AndroidManifest.xml` :

   ```xml
   <intent-filter>
     <action android:name="android.intent.action.VIEW" />
     <category android:name="android.intent.category.DEFAULT" />
     <category android:name="android.intent.category.BROWSABLE" />
     <data
         android:scheme="com.wanzo.app"
         android:host="login-callback" />
   </intent-filter>
   
   <intent-filter>
     <action android:name="android.intent.action.VIEW" />
     <category android:name="android.intent.category.DEFAULT" />
     <category android:name="android.intent.category.BROWSABLE" />
     <data
         android:scheme="com.wanzo.app"
         android:host="logout-callback" />
   </intent-filter>
   ```

5. **Configuration iOS** :
   Ajoutez les configurations suivantes dans `ios/Runner/Info.plist` :

   ```xml
   <key>CFBundleURLTypes</key>
   <array>
     <dict>
       <key>CFBundleTypeRole</key>
       <string>Editor</string>
       <key>CFBundleURLName</key>
       <string>com.wanzo.app</string>
       <key>CFBundleURLSchemes</key>
       <array>
         <string>com.wanzo.app</string>
       </array>
     </dict>
   </array>
   ```

### 3. Gestion des Tokens JWT

L'application gère les tokens JWT avec une approche sécurisée :

1. **Stockage sécurisé** : Utilisation de `flutter_secure_storage` pour stocker les tokens
2. **Rafraîchissement automatique** : Logique pour rafraîchir les tokens expirés implémentée dans `Auth0Service`
3. **Envoi dans les en-têtes** : Inclusion du token dans l'en-tête `Authorization: Bearer <token>` pour toutes les requêtes API

Voici un exemple du gestionnaire de tokens implémenté dans l'application :

```dart
// Extrait de Auth0Service
Future<String?> getAccessToken() async {
  try {
    // Vérifier la connectivité
    final hasConnection = await _connectivityService.isConnected();
    if (!hasConnection) {
      // En mode hors ligne, on peut utiliser un token stocké localement ou 
      // passer au mode d'authentification hors ligne
      return await offlineAuthService.getAccessToken();
    }

    // Vérifier si un token existe déjà
    final storedAccessToken = await _secureStorage.read(key: _accessTokenKey);
    final expiresAtString = await _secureStorage.read(key: _expiresAtKey);

    if (storedAccessToken == null || expiresAtString == null) {
      return null;
    }

    // Vérifier si le token a expiré
    final expiresAt = DateTime.parse(expiresAtString);
    if (DateTime.now().isAfter(expiresAt.subtract(const Duration(minutes: 5)))) {
      // Token expiré ou proche de l'expiration, essayer de le rafraîchir
      final refreshed = await _refreshTokens();
      if (!refreshed) return null;
      return await _secureStorage.read(key: _accessTokenKey);
    }

    // Token valide
    return storedAccessToken;
  } catch (e) {
    AppLogger.error('Error getting access token: $e');
    return null;
  }
}
```

### 4. Appels API

L'application utilise une classe `ApiClient` pour gérer les appels API avec prise en charge du mode hors ligne et du cache :

```dart
// Exemple simplifié de la classe ApiClient
class ApiClient {
  final String _baseUrl;
  final http.Client _httpClient;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  Auth0Service? _auth0Service;

  // Singleton pattern implementation
  static final ApiClient _instance = ApiClient._internal(
    useApiGateway: true,
  );
  
  // Factory constructor
  factory ApiClient() => _instance;

  // Private constructor
  ApiClient._internal({
    http.Client? httpClient,
    bool useApiGateway = true,
  })  : _httpClient = httpClient ?? http.Client(),
        _baseUrl = EnvConfig.getBaseUrl(useApiGateway: useApiGateway);

  // Configure with Auth0Service
  static void configure({Auth0Service? auth0Service}) {
    _instance._auth0Service = auth0Service;
  }

  // Get method with cache support
  Future<Map<String, dynamic>?> get(
    String endpoint, {
    Map<String, String>? queryParameters,
    bool requiresAuth = false,
    bool useCache = true,
    Duration cacheDuration = ApiCacheService.defaultCacheDuration,
  }) async {
    try {
      // Build URL and headers
      final uri = Uri.parse('$_baseUrl/$endpoint').replace(
        queryParameters: queryParameters,
      );
      
      final headers = await getHeaders(requiresAuth: requiresAuth);
      
      // Check cache if enabled
      final String cacheKey = uri.toString();
      if (useCache) {
        final cachedResponse = await ApiCacheService().getCachedResponse(cacheKey);
        if (cachedResponse != null) {
          return cachedResponse;
        }
      }
      
      // Make the API call
      final response = await _httpClient.get(uri, headers: headers);
      
      // Handle the response
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
        
        // Cache the successful response if caching is enabled
        if (useCache) {
          await ApiCacheService().cacheResponse(cacheKey, responseBody, cacheDuration);
        }
        
        return responseBody;
      } else {
        throw ApiException(
          'HTTP Error: ${response.statusCode}',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }
}
```

Pour les opérations de création, mise à jour et suppression, l'application utilise des services API spécifiques par domaine (customers, inventory, financing, etc.) qui utilisent tous le `ApiClient` comme base.

## Points à vérifier pour assurer une connexion correcte

1. **Vérifiez les tokens** :
   - Assurez-vous que les tokens JWT sont correctement reçus d'Auth0
   - Vérifiez que les tokens contiennent bien l'audience `https://api.wanzo.com`
   - Confirmez que le token est envoyé avec chaque requête API

2. **Dépannage de l'API Gateway** :
   - Si vous recevez des erreurs 401, vérifiez que le token est valide et non expiré
   - Si vous recevez des erreurs 403, vérifiez les permissions de l'utilisateur
   - Si vous rencontrez des problèmes de CORS, assurez-vous que les en-têtes appropriés sont configurés côté serveur

3. **Tests de bout en bout** :
   - Testez le flux complet : authentification → obtention du token → appel API
   - Vérifiez le rafraîchissement du token : laissez le token expirer et confirmez qu'il est automatiquement rafraîchi
   - Testez la déconnexion : assurez-vous que les tokens sont correctement supprimés

4. **Fonctionnalités hors ligne** :
   - Vérifiez que l'application détecte correctement l'état de la connectivité
   - Assurez-vous que les données sont correctement mises en cache pour une utilisation hors ligne
   - Testez la synchronisation des données lorsque la connexion est rétablie

## Environnements de déploiement

Adaptez vos configurations selon l'environnement en utilisant des fichiers `.env` différents :

- **Développement** (`dev.env`) : 
  ```
  API_GATEWAY_URL=http://192.168.1.x:8000/api
  AUTH_SERVICE_URL=http://192.168.1.x:3000/api
  APP_MOBILE_SERVICE_URL=http://192.168.1.x:3006/api
  AUTH0_DOMAIN=dev-tezmln0tk0g1gouf.eu.auth0.com
  AUTH0_CLIENT_ID=43d64kgsVYyCZHEFsax7zlRBVUiraCKL
  ```

- **Test** (`test.env`) :
  ```
  API_GATEWAY_URL=https://test-api.wanzo.com/api
  AUTH_SERVICE_URL=https://test-auth.wanzo.com/api
  APP_MOBILE_SERVICE_URL=https://test-mobile.wanzo.com/api
  AUTH0_DOMAIN=dev-tezmln0tk0g1gouf.eu.auth0.com
  AUTH0_CLIENT_ID=43d64kgsVYyCZHEFsax7zlRBVUiraCKL
  ```

- **Production** (`prod.env`) :
  ```
  API_GATEWAY_URL=https://api.wanzo.com/api
  AUTH_SERVICE_URL=https://auth.wanzo.com/api
  APP_MOBILE_SERVICE_URL=https://mobile.wanzo.com/api
  AUTH0_DOMAIN=wanzo.eu.auth0.com
  AUTH0_CLIENT_ID=production_client_id
  ```

Pour charger le fichier d'environnement approprié au démarrage de l'application :

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Déterminer quel fichier .env charger selon l'environnement
  String envFile = 'assets/env/dev.env';
  #if (dart.library.io)
  const envName = String.fromEnvironment('ENV', defaultValue: 'dev');
  if (envName == 'prod') {
    envFile = 'assets/env/prod.env';
  } else if (envName == 'test') {
    envFile = 'assets/env/test.env';
  }
  #endif

  // Charger les variables d'environnement
  await dotenv.load(fileName: envFile);
  
  // Initialiser les services
  await initServices();
  
  runApp(const MyApp());
}
```

## Assistance et dépannage

Si vous rencontrez des problèmes de connexion :

1. **Logs et débogage** :
   - Activez les logs détaillés dans l'application mobile
   - Vérifiez les logs du serveur pour les erreurs d'authentification ou d'autorisation

2. **Outils de débogage** :
   - Utilisez Postman ou Insomnia pour tester les API indépendamment de l'application
   - Vérifiez les tokens JWT sur [jwt.io](https://jwt.io) pour confirmer leur validité

3. **Support** :
   - Pour les problèmes d'authentification : contactez l'équipe Auth0 ou l'administrateur Auth0
   - Pour les problèmes d'API : contactez l'équipe backend

---

En suivant ces instructions, votre application mobile Flutter devrait pouvoir se connecter correctement au backend Wanzo, en utilisant Auth0 pour l'authentification et l'API Gateway pour accéder aux différents microservices.
