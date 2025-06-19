// lib/config/environment.dart
class Environment {
  static const String DEV = 'dev';
  static const String STAGING = 'staging';
  static const String PROD = 'prod';
  
  static const String currentEnvironment = DEV;
    static String get baseUrl {
    switch (currentEnvironment) {
      case DEV:
        return "http://192.168.1.65:8000/mobile"; // Adresse IP actuelle
      case STAGING:
        return "https://api-staging.wanzo.be/mobile";
      case PROD:
        return "https://api.wanzo.be/mobile";
      default:
        return "http://192.168.1.65:8000/mobile";
    }
  }
}
