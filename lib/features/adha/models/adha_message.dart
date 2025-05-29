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
    // contextInfo n'est pas stocké directement dans AdhaMessage,
    // il est utilisé lors de l'envoi du premier message d'une conversation.
  });

  @override
  List<Object?> get props => [id, content, timestamp, isUserMessage, type];

  factory AdhaMessage.fromJson(Map<String, dynamic> json) {
    return AdhaMessage(
      id: json['id'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isUserMessage: json['isUserMessage'] as bool,
      type: AdhaMessageType.values.firstWhere(
        (e) => e.toString() == 'AdhaMessageType.${json['type']}',
        orElse: () => AdhaMessageType.text, // Default if type is unknown
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
        'isUserMessage': isUserMessage,
        'type': type.toString().split('.').last,
      };

  AdhaMessage copyWith({
    String? id,
    String? content,
    DateTime? timestamp,
    bool? isUserMessage,
    AdhaMessageType? type,
  }) {
    return AdhaMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isUserMessage: isUserMessage ?? this.isUserMessage,
      type: type ?? this.type,
    );
  }
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

  /// Informations de contexte initiales pour cette conversation
  /// Peut être null si le contexte n'est pas applicable ou déjà traité
  final Map<String, dynamic>? initialContextJson; // Stocke le JSON du AdhaContextInfo initial

  const AdhaConversation({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
    this.initialContextJson, // Ajouté au constructeur
  });

  AdhaConversation copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<AdhaMessage>? messages,
    Map<String, dynamic>? initialContextJson,
    bool clearInitialContext = false, // Pour explicitement nullifier le contexte
  }) {
    return AdhaConversation(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
      initialContextJson: clearInitialContext ? null : initialContextJson ?? this.initialContextJson,
    );
  }

  @override
  List<Object?> get props => [id, title, createdAt, updatedAt, messages, initialContextJson];
}
