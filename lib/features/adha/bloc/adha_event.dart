import 'package:equatable/equatable.dart';

/// Événements pour le bloc Adha
abstract class AdhaEvent extends Equatable {
  const AdhaEvent();

  @override
  List<Object?> get props => [];
}

/// Envoi d'un nouveau message à Adha
class SendMessage extends AdhaEvent {
  /// Contenu du message
  final String message;

  const SendMessage(this.message);

  @override
  List<Object?> get props => [message];
}

/// Chargement de l'historique des conversations
class LoadConversations extends AdhaEvent {
  const LoadConversations();
}

/// Chargement d'une conversation spécifique
class LoadConversation extends AdhaEvent {
  /// ID de la conversation à charger
  final String conversationId;

  const LoadConversation(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

/// Création d'une nouvelle conversation
class NewConversation extends AdhaEvent {
  const NewConversation();
}

/// Suppression d'une conversation
class DeleteConversation extends AdhaEvent {
  /// ID de la conversation à supprimer
  final String conversationId;

  const DeleteConversation(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

/// Activation de la reconnaissance vocale pour interagir avec Adha
class StartVoiceRecognition extends AdhaEvent {
  const StartVoiceRecognition();
}

/// Arrêt de la reconnaissance vocale
class StopVoiceRecognition extends AdhaEvent {
  const StopVoiceRecognition();
}
