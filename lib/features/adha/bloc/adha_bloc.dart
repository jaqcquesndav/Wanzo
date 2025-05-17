import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../repositories/adha_repository.dart';
import 'adha_event.dart';
import 'adha_state.dart';
import '../models/adha_message.dart';

/// BLoC pour gérer l'interaction avec l'assistant Adha
class AdhaBloc extends Bloc<AdhaEvent, AdhaState> {
  /// Repository pour accéder aux données d'Adha
  final AdhaRepository adhaRepository;
  
  /// Générateur d'identifiants uniques
  final _uuid = const Uuid();

  AdhaBloc({required this.adhaRepository}) : super(const AdhaInitial()) {
    on<SendMessage>(_onSendMessage);
    on<LoadConversations>(_onLoadConversations);
    on<LoadConversation>(_onLoadConversation);
    on<NewConversation>(_onNewConversation);
    on<DeleteConversation>(_onDeleteConversation);
    on<StartVoiceRecognition>(_onStartVoiceRecognition);
    on<StopVoiceRecognition>(_onStopVoiceRecognition);
  }

  /// Gère l'envoi d'un message à Adha
  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<AdhaState> emit,
  ) async {
    // Vérifie si une conversation est active
    if (state is! AdhaConversationActive) {
      await _createNewConversationWithMessage(event.message, emit);
      return;
    }

    final currentState = state as AdhaConversationActive;
    final currentConversation = currentState.conversation;
    
    final userMessage = AdhaMessage(
      id: _uuid.v4(),
      content: event.message,
      timestamp: DateTime.now(),
      isUserMessage: true,
    );
    
    final updatedMessages = List<AdhaMessage>.from(currentConversation.messages)..add(userMessage);
    final updatedConversation = AdhaConversation(
      id: currentConversation.id,
      title: currentConversation.title,
      createdAt: currentConversation.createdAt,
      updatedAt: DateTime.now(),
      messages: updatedMessages,
    );
    
    emit(AdhaConversationActive(
      conversation: updatedConversation,
      isProcessing: true,
      isVoiceActive: currentState.isVoiceActive,
    ));
    
    try {
      final responseContent = await adhaRepository.sendMessage(
        conversationId: currentConversation.id,
        message: event.message,
      );
      
      final adhaMessage = AdhaMessage(
        id: _uuid.v4(),
        content: responseContent,
        timestamp: DateTime.now(),
        isUserMessage: false,
        type: _detectMessageType(responseContent),
      );
      
      final finalMessages = List<AdhaMessage>.from(updatedMessages)..add(adhaMessage);
      final finalConversation = AdhaConversation(
        id: currentConversation.id,
        title: currentConversation.title,
        createdAt: currentConversation.createdAt,
        updatedAt: DateTime.now(),
        messages: finalMessages,
      );
      
      await adhaRepository.saveConversation(finalConversation);
      
      emit(AdhaConversationActive(
        conversation: finalConversation,
        isProcessing: false,
        isVoiceActive: currentState.isVoiceActive,
      ));
    } catch (e) {
      emit(AdhaError("Erreur lors de l'envoi du message: $e"));
      emit(currentState.copyWith(isProcessing: false));
    }
  }

  Future<void> _createNewConversationWithMessage(
    String message,
    Emitter<AdhaState> emit,
  ) async {
    bool previousVoiceState = false;
    if (state is AdhaConversationActive) {
      previousVoiceState = (state as AdhaConversationActive).isVoiceActive;
    }

    try {
      final conversationId = _uuid.v4();
      final userMessage = AdhaMessage(
        id: _uuid.v4(),
        content: message,
        timestamp: DateTime.now(),
        isUserMessage: true,
      );
      
      final newConversation = AdhaConversation(
        id: conversationId,
        title: _generateConversationTitle(message),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        messages: [userMessage],
      );
      
      emit(AdhaConversationActive(
        conversation: newConversation,
        isProcessing: true,
        isVoiceActive: previousVoiceState,
      ));
      
      final responseContent = await adhaRepository.sendMessage(
        conversationId: conversationId,
        message: message,
      );
      
      final adhaMessage = AdhaMessage(
        id: _uuid.v4(),
        content: responseContent,
        timestamp: DateTime.now(),
        isUserMessage: false,
        type: _detectMessageType(responseContent),
      );
      
      final updatedConversation = AdhaConversation(
        id: conversationId,
        title: newConversation.title,
        createdAt: newConversation.createdAt,
        updatedAt: DateTime.now(),
        messages: [userMessage, adhaMessage],
      );
      
      await adhaRepository.saveConversation(updatedConversation);
      
      emit(AdhaConversationActive(
        conversation: updatedConversation,
        isProcessing: false,
        isVoiceActive: previousVoiceState,
      ));
    } catch (e) {
      emit(AdhaError('Erreur lors de la création de la conversation: $e'));
      emit(const AdhaInitial());
    }
  }

  Future<void> _onLoadConversations(
    LoadConversations event,
    Emitter<AdhaState> emit,
  ) async {
    emit(const AdhaLoading());
    try {
      final conversations = await adhaRepository.getConversations();
      if (conversations.isEmpty) {
        final newConversation = AdhaConversation(
          id: _uuid.v4(),
          title: 'Nouvelle conversation',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          messages: [],
        );
        await adhaRepository.saveConversation(newConversation);
        emit(AdhaConversationActive(conversation: newConversation));
      } else {
        conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        emit(AdhaConversationActive(conversation: conversations.first));
      }
    } catch (e) {
      emit(AdhaError('Erreur lors du chargement des conversations: $e'));
    }
  }

  Future<void> _onLoadConversation(
    LoadConversation event,
    Emitter<AdhaState> emit,
  ) async {
    emit(const AdhaLoading());
    try {
      final conversation = await adhaRepository.getConversation(event.conversationId);
      if (conversation != null) {
        emit(AdhaConversationActive(conversation: conversation));
      } else {
        emit(const AdhaError('Conversation non trouvée'));
        add(const LoadConversations());
      }
    } catch (e) {
      emit(AdhaError('Erreur lors du chargement de la conversation: $e'));
    }
  }

  Future<void> _onNewConversation(
    NewConversation event,
    Emitter<AdhaState> emit,
  ) async {
    bool previousVoiceState = false;
    if (state is AdhaConversationActive) {
      previousVoiceState = (state as AdhaConversationActive).isVoiceActive;
    }

    final newConversation = AdhaConversation(
      id: _uuid.v4(),
      title: 'Nouvelle conversation',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      messages: [],
    );
    await adhaRepository.saveConversation(newConversation);
    emit(AdhaConversationActive(
      conversation: newConversation,
      isVoiceActive: previousVoiceState,
    ));
  }

  Future<void> _onDeleteConversation(
    DeleteConversation event,
    Emitter<AdhaState> emit,
  ) async {
    try {
      await adhaRepository.deleteConversation(event.conversationId);
      add(const LoadConversations());
    } catch (e) {
      emit(AdhaError('Erreur lors de la suppression de la conversation: $e'));
    }
  }

  Future<void> _onStartVoiceRecognition(
    StartVoiceRecognition event,
    Emitter<AdhaState> emit,
  ) async {
    if (state is AdhaConversationActive) {
      final currentState = state as AdhaConversationActive;
      if (!currentState.isProcessing) {
         emit(currentState.copyWith(isVoiceActive: true));
      }
    } else {
      final newConversation = AdhaConversation(
        id: _uuid.v4(),
        title: 'Conversation vocale',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        messages: [],
      );
      await adhaRepository.saveConversation(newConversation);
      emit(AdhaConversationActive(conversation: newConversation, isVoiceActive: true));
    }
  }

  Future<void> _onStopVoiceRecognition(
    StopVoiceRecognition event,
    Emitter<AdhaState> emit,
  ) async {
    if (state is AdhaConversationActive) {
      final currentState = state as AdhaConversationActive;
      emit(currentState.copyWith(isVoiceActive: false));
    }
  }

  String _generateConversationTitle(String firstMessage) {
    String title = firstMessage.replaceAll('\n', ' ');
    if (title.length > 30) {
      title = '${title.substring(0, 27)}...';
    }
    return title.isEmpty ? "Nouvelle Conversation" : title;
  }

  AdhaMessageType _detectMessageType(String content) {
    if (content.contains('```python') || content.contains('```javascript') || content.contains('```dart') || content.contains('```')) {
      return AdhaMessageType.code;
    } else if (content.contains(r'\begin{equation}') || content.contains(r'$$')) {
      return AdhaMessageType.latex;
    } else if (content.contains('<graph>') || content.contains('plt.show()')) {
      return AdhaMessageType.graph;
    }
    return AdhaMessageType.text;
  }
}
