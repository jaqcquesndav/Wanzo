import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuration des variables d'environnement pour l'application Wanzo
/// Cette classe centralise toutes les URLs et configurations pour les différents environnements
class EnvConfig {
  /// URL de l'API Gateway, point d'entrée principal pour toutes les requêtes
  static String get apiGatewayUrl => dotenv.env['API_GATEWAY_URL'] ?? 'http://localhost:8000/api';
  
  /// URLs des services directs (à utiliser uniquement si nécessaire)
  static String get authServiceUrl => dotenv.env['AUTH_SERVICE_URL'] ?? 'http://localhost:3000/api';
  static String get appMobileServiceUrl => dotenv.env['APP_MOBILE_SERVICE_URL'] ?? 'http://localhost:3006/api';
  static String get adminServiceUrl => dotenv.env['ADMIN_SERVICE_URL'] ?? 'http://localhost:3001/api';
  
  /// Configuration Auth0
  static String get auth0Domain => dotenv.env['AUTH0_DOMAIN'] ?? 'dev-tezmln0tk0g1gouf.eu.auth0.com';
  static String get auth0ClientId => dotenv.env['AUTH0_CLIENT_ID'] ?? '43d64kgsVYyCZHEFsax7zlRBVUiraCKL';
  static String get auth0Audience => dotenv.env['AUTH0_AUDIENCE'] ?? 'https://api.wanzo.com';
  static String get auth0RedirectUri => dotenv.env['AUTH0_REDIRECT_URI'] ?? 'com.wanzo.app://login-callback';
  static String get auth0LogoutUri => dotenv.env['AUTH0_LOGOUT_URI'] ?? 'com.wanzo.app://logout-callback';
  static String get auth0Scheme => dotenv.env['AUTH0_SCHEME'] ?? 'com.example.wanzo'; // Added

  /// Retourne l'URL appropriée selon l'environnement (dev, staging, prod)
  static String getBaseUrl({bool useApiGateway = true}) {
    // Par défaut, utiliser l'API Gateway comme point d'entrée
    if (useApiGateway) {
      return apiGatewayUrl;
    }
    
    // Sinon, retourner l'URL du service demandé
    return authServiceUrl;
  }
  
  /// Remplace localhost par l'adresse IP pour les appareils physiques
  static String getDeviceCompatibleUrl(String url) {
    // Si nous sommes en mode développement sur un appareil physique,
    // il faut remplacer localhost par l'adresse IP de la machine de développement
    final devIpAddress = dotenv.env['DEV_IP_ADDRESS'];
    
    if (devIpAddress != null && devIpAddress.isNotEmpty && url.contains('localhost')) {
      return url.replaceAll('localhost', devIpAddress);
    }
    
    return url;
  }
}
