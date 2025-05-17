/// Constantes de configuration pour l'application
class AppConfig {
  /// Configuration Auth0
  static const String auth0Domain = 'dev-wanzo.us.auth0.com'; // À remplacer par votre domaine Auth0
  static const String auth0ClientId = 'Xm7YJXs0LGX5iG1KLR8wPlmK8gnjVrns'; // À remplacer par votre client ID
  static const String auth0RedirectUri = 'com.wanzo.app://login-callback';
  
  /// URL de l'API
  static const String apiBaseUrl = 'https://api.wanzo.app';
  
  /// Délai d'attente pour les requêtes API
  static const int apiTimeoutSeconds = 30;
  
  /// Version de l'application
  static const String appVersion = '1.0.0';
  
  /// Mode de développement (true pour développement, false pour production)
  static const bool devMode = true;
}
