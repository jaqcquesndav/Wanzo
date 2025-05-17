import 'package:equatable/equatable.dart';
import '../models/settings.dart';

/// Événement pour mettre à jour les paramètres de notification
class UpdateNotificationSettings extends SettingsEvent {
  /// Notifications push activées
  final bool pushNotificationsEnabled;
  
  /// Notifications in-app activées
  final bool inAppNotificationsEnabled;
  
  /// Notifications par email activées
  final bool emailNotificationsEnabled;
  
  /// Notifications sonores activées
  final bool soundNotificationsEnabled;
  
  const UpdateNotificationSettings({
    required this.pushNotificationsEnabled,
    required this.inAppNotificationsEnabled,
    required this.emailNotificationsEnabled,
    required this.soundNotificationsEnabled,
  });
  
  @override
  List<Object?> get props => [
    pushNotificationsEnabled,
    inAppNotificationsEnabled,
    emailNotificationsEnabled,
    soundNotificationsEnabled,
  ];
}
