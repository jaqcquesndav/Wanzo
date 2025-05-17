import 'package:hive/hive.dart';
import '../../features/auth/models/user.dart';
import '../../features/notifications/models/notification_model.dart';
import '../../features/adha/models/adha_message.dart'; // Import Adha models
import '../../features/adha/models/adha_adapters.dart'; // Import Adha adapters

/// Enregistre tous les adaptateurs Hive nécessaires
void registerHiveAdapters() {
  // User models
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(UserAdapter());
  }
  
  // Notification models
  if (!Hive.isAdapterRegistered(9)) {
    Hive.registerAdapter(NotificationModelAdapter());
  }
  
  if (!Hive.isAdapterRegistered(10)) {
    Hive.registerAdapter(NotificationTypeAdapter());
  }

  // Adha models
  if (!Hive.isAdapterRegistered(100)) { // typeId for AdhaMessageAdapter
    Hive.registerAdapter(AdhaMessageAdapter());
  }
  if (!Hive.isAdapterRegistered(101)) { // typeId for AdhaMessageTypeAdapter
    Hive.registerAdapter(AdhaMessageTypeAdapter());
  }
  if (!Hive.isAdapterRegistered(102)) { // typeId for AdhaConversationAdapter
    Hive.registerAdapter(AdhaConversationAdapter());
  }
  
  // Add other adapters here
}
