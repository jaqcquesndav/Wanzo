import 'package:equatable/equatable.dart';

/// Message envoyé ou reçu dans la conversation avec Adha
class AdhaMessage extends Equatable {
  /// ID unique du message
  final String id;
  
  /// Contenu du message
  final String content;
  
  /// Date d'envoi du message
  final DateTime timestamp;
  
  /// Indique si le message provient de l'utilisateur ou d'Adha
  final bool isUserMessage;
  
  /// Type de contenu du message
  final AdhaMessageType type;

  const AdhaMessage({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.isUserMessage,
    this.type = AdhaMessageType.text,
  });

  @override
  List<Object?> get props => [id, content, timestamp, isUserMessage, type];
}

/// Types de contenu de message supportés par Adha
enum AdhaMessageType {
  /// Message texte simple
  text,
  
  /// Formule mathématique (LaTeX)
  latex,
  
  /// Graphique (généré à partir de code Python)
  graph,
  
  /// Code avec coloration syntaxique
  code,
  
  /// Message multimédia (image, audio)
  media,
}

/// Conversation avec l'assistant Adha
class AdhaConversation extends Equatable {
  /// ID unique de la conversation
  final String id;
  
  /// Titre de la conversation
  final String title;
  
  /// Date de création de la conversation
  final DateTime createdAt;
  
  /// Date de la dernière mise à jour
  final DateTime updatedAt;
  
  /// Liste des messages de la conversation
  final List<AdhaMessage> messages;

  const AdhaConversation({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
  });

  @override
  List<Object?> get props => [id, title, createdAt, updatedAt, messages];
}
