import 'package:equatable/equatable.dart';
import '../models/adha_message.dart';

/// États pour le bloc Adha
abstract class AdhaState extends Equatable {
  const AdhaState();

  @override
  List<Object?> get props => [];
}

/// État initial du bloc Adha
class AdhaInitial extends AdhaState {
  const AdhaInitial();
}

/// Chargement en cours
class AdhaLoading extends AdhaState {
  const AdhaLoading();
}

/// Erreur durant une opération
class AdhaError extends AdhaState {
  /// Message d'erreur
  final String message;

  const AdhaError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Conversation active avec Adha
class AdhaConversationActive extends AdhaState {
  /// Conversation en cours
  final AdhaConversation conversation;
  
  /// Indique si l'assistant est en train de répondre
  final bool isProcessing;
  
  /// Indique si la reconnaissance vocale est active
  final bool isVoiceActive;

  const AdhaConversationActive({
    required this.conversation,
    this.isProcessing = false,
    this.isVoiceActive = false,
  });

  /// Crée une copie de l'état avec des valeurs modifiées
  AdhaConversationActive copyWith({
    AdhaConversation? conversation,
    bool? isProcessing,
    bool? isVoiceActive,
  }) {
    return AdhaConversationActive(
      conversation: conversation ?? this.conversation,
      isProcessing: isProcessing ?? this.isProcessing,
      isVoiceActive: isVoiceActive ?? this.isVoiceActive,
    );
  }

  @override
  List<Object?> get props => [conversation, isProcessing, isVoiceActive];
}

/// Liste des conversations disponibles
class AdhaConversationsList extends AdhaState {
  /// Liste des conversations
  final List<AdhaConversation> conversations;

  const AdhaConversationsList(this.conversations);

  @override
  List<Object?> get props => [conversations];
}
