import 'package:equatable/equatable.dart';
import '../models/adha_context_info.dart'; // Importation ajoutée

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
  final String? conversationId; // Peut être null pour une nouvelle conversation
  final AdhaContextInfo? contextInfo; // Ajouté pour le contexte

  const SendMessage(this.message, {this.conversationId, this.contextInfo});

  @override
  List<Object?> get props => [message, conversationId, contextInfo];
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
  final String initialMessage;
  final AdhaContextInfo contextInfo; // Contexte requis pour une nouvelle conversation

  const NewConversation(this.initialMessage, this.contextInfo);

  @override
  List<Object?> get props => [initialMessage, contextInfo];
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

/// Modification d'un message existant par l'utilisateur
class EditMessage extends AdhaEvent {
  /// ID du message à modifier
  final String messageId;
  /// Nouveau contenu du message
  final String newContent;
  /// Informations de contexte pour la modification
  final AdhaContextInfo contextInfo;

  const EditMessage(this.messageId, this.newContent, this.contextInfo);

  @override
  List<Object?> get props => [messageId, newContent, contextInfo];
}
