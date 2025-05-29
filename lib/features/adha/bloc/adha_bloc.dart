import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../repositories/adha_repository.dart';
import '../../auth/repositories/auth_repository.dart'; // Corrected path
import '../../dashboard/repositories/operation_journal_repository.dart'; // Corrected path
import '../../auth/models/user.dart'; // For User model
// For OperationJournalEntry model

import 'adha_event.dart';
import 'adha_state.dart';
import '../models/adha_message.dart';
import '../models/adha_context_info.dart';

/// BLoC pour gérer l'interaction avec l'assistant Adha
class AdhaBloc extends Bloc<AdhaEvent, AdhaState> {
  final AdhaRepository adhaRepository;
  final AuthRepository authRepository;
  final OperationJournalRepository operationJournalRepository;
  final _uuid = const Uuid();
  String? _currentlyActiveConversationId; // Added to track active conversation

  AdhaBloc({
    required this.adhaRepository,
    required this.authRepository,
    required this.operationJournalRepository,
  }) : super(const AdhaInitial()) {
    _currentlyActiveConversationId = null; // Explicitly null at start
    on<SendMessage>(_onSendMessage);
    on<LoadConversations>(_onLoadConversations);
    on<LoadConversation>(_onLoadConversation);
    on<NewConversation>(_onNewConversation);
    on<DeleteConversation>(_onDeleteConversation);
    on<StartVoiceRecognition>(_onStartVoiceRecognition);
    on<StopVoiceRecognition>(_onStopVoiceRecognition);
  }

  // Helper to build AdhaContextInfo
  Future<AdhaContextInfo> _buildContextInfo(
      AdhaInteractionType interactionType,
      {String? sourceIdentifier,
      Map<String, dynamic>? interactionData,
      String? conversationId // Optional: to determine if it's a follow-up if not explicitly set
      }) async {
    // 1. Fetch Business Profile
    Map<String, dynamic> businessProfileData = {};
    try {
      final User? currentUser = await authRepository.getCurrentUser();
      if (currentUser != null) {
        businessProfileData = {
          'businessName': currentUser.companyName,
          'businessSector': currentUser.businessSector,
          'rccmNumber': currentUser.rccmNumber,
          'companyLocation': currentUser.companyLocation,
          'contactName': currentUser.name,
          'contactEmail': currentUser.email,
          'contactPhone': currentUser.phone,
          // Add other relevant fields from User model as per API_DOCUMENTATION (Section L)
        };
      } else {
        // Fallback or default business profile if no user is found
        businessProfileData = {
          'businessName': 'Wanzo Demo Business (Default)',
          'businessSector': 'N/A',
        };
      }
    } catch (e) {
      // Handle error fetching user profile
      // ignore: avoid_print
      print('Error fetching business profile for Adha context: $e');
      businessProfileData = {
        'businessName': 'Error Fetching Profile',
        'businessSector': 'Error',
      };
    }

    // 2. Fetch Operation Journal Summary
    Map<String, dynamic> operationJournalSummaryData = {};
    try {
      final recentEntries = await operationJournalRepository.getRecentEntries(limit: 5);
      final summaryMetrics = await operationJournalRepository.getSummaryMetrics(); 

      operationJournalSummaryData = {
        'recentEntries': recentEntries, // Assuming getRecentEntries returns List<Map<String, dynamic>>
        'summaryMetrics': summaryMetrics, // Assuming getSummaryMetrics returns Map<String, dynamic>
      };
    } catch (e) {
      // Handle error fetching journal summary
      // ignore: avoid_print
      print('Error fetching operation journal summary for Adha context: $e');
      operationJournalSummaryData = {
        'recentEntries': [],
        'summaryMetrics': {'error': e.toString()},
      };
    }
    
    final baseContext = AdhaBaseContext(
      operationJournalSummary: operationJournalSummaryData,
      businessProfile: businessProfileData,
    );

    AdhaInteractionType finalInteractionType = interactionType;
    if (conversationId != null && interactionType != AdhaInteractionType.genericCardAnalysis) {
        finalInteractionType = AdhaInteractionType.followUp;
    }

    final interactionContext = AdhaInteractionContext(
      interactionType: finalInteractionType,
      sourceIdentifier: sourceIdentifier,
      interactionData: interactionData,
    );

    return AdhaContextInfo(
      baseContext: baseContext,
      interactionContext: interactionContext,
    );
  }

  /// Gère l'envoi d'un message à Adha
  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<AdhaState> emit,
  ) async {
    AdhaConversation currentConversation;
    AdhaContextInfo contextInfoForApi;
    AdhaConversationActive? previousState = state is AdhaConversationActive ? (state as AdhaConversationActive) : null;


    if (state is AdhaConversationActive) {
      final currentState = state as AdhaConversationActive;
      currentConversation = currentState.conversation;
      contextInfoForApi = await _buildContextInfo(
        event.contextInfo?.interactionContext.interactionType ?? AdhaInteractionType.followUp,
        sourceIdentifier: event.contextInfo?.interactionContext.sourceIdentifier,
        interactionData: event.contextInfo?.interactionContext.interactionData,
        conversationId: currentConversation.id,
      );
    } else {
      if (event.contextInfo == null) {
        emit(const AdhaError("ContextInfo est requis pour démarrer une nouvelle conversation."));
        return;
      }
      final newConversationId = _uuid.v4();
      currentConversation = AdhaConversation(
        id: newConversationId,
        title: _generateConversationTitle(event.message),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        messages: [],
      );
      contextInfoForApi = await _buildContextInfo(
        event.contextInfo!.interactionContext.interactionType,
        sourceIdentifier: event.contextInfo!.interactionContext.sourceIdentifier,
        interactionData: event.contextInfo!.interactionContext.interactionData,
      );
    }

    final userMessage = AdhaMessage(
      id: _uuid.v4(),
      content: event.message,
      timestamp: DateTime.now(),
      isUserMessage: true,
    );
    
    final updatedMessages = List<AdhaMessage>.from(currentConversation.messages)..add(userMessage);
    final updatedConversationWithUserMsg = currentConversation.copyWith(
      messages: updatedMessages,
      updatedAt: DateTime.now(),
    );
    
    emit(AdhaConversationActive(
      conversation: updatedConversationWithUserMsg,
      isProcessing: true,
      isVoiceActive: previousState?.isVoiceActive ?? false,
    ));
    
    try {
      final responseContent = await adhaRepository.sendMessage(
        conversationId: currentConversation.id,
        message: event.message,
        contextInfo: contextInfoForApi,
      );
      
      final adhaMessage = AdhaMessage(
        id: _uuid.v4(),
        content: responseContent,
        timestamp: DateTime.now(),
        isUserMessage: false,
        type: _detectMessageType(responseContent),
      );
      
      final finalMessages = List<AdhaMessage>.from(updatedMessages)..add(adhaMessage);
      final finalConversation = updatedConversationWithUserMsg.copyWith(
        messages: finalMessages,
        updatedAt: DateTime.now(),
      );
      
      await adhaRepository.saveConversation(finalConversation);
      _currentlyActiveConversationId = finalConversation.id; // Set active ID
      
      emit(AdhaConversationActive(
        conversation: finalConversation,
        isProcessing: false,
        isVoiceActive: previousState?.isVoiceActive ?? false,
      ));
    } catch (e) {
      emit(AdhaError("Erreur lors de l'envoi du message: $e"));
      if (previousState != null) {
        emit(previousState.copyWith(isProcessing: false));
      } else {
         // If there was no previous active state, emit a new one based on current conversation
         emit(AdhaConversationActive(
           conversation: updatedConversationWithUserMsg, // or currentConversation if preferred
           isProcessing: false,
           isVoiceActive: false,
         ));
      }
    }
  }

  Future<void> _onNewConversation(
    NewConversation event,
    Emitter<AdhaState> emit,
  ) async {
    // If the initial message is empty and the source is the new conversation button,
    // or more generally, if we want to reset to the initial suggestion view.
    if (event.initialMessage.isEmpty && event.contextInfo.interactionContext.sourceIdentifier == 'new_conversation_button') {
      _currentlyActiveConversationId = null; // Clear active ID
      emit(const AdhaInitial());
      // Optionally, if you want to ensure a default "empty" conversation is ready in the background
      // you could load conversations which might create one if none exist.
      // add(const LoadConversations()); 
      return;
    }

    emit(const AdhaLoading());
    AdhaConversationActive? previousState = state is AdhaConversationActive ? (state as AdhaConversationActive) : null;
    try {
      final newConversationId = _uuid.v4();
      final userMessage = AdhaMessage(
        id: _uuid.v4(),
        content: event.initialMessage,
        timestamp: DateTime.now(),
        isUserMessage: true,
      );

      final contextInfoForApi = await _buildContextInfo(
        event.contextInfo.interactionContext.interactionType, 
        sourceIdentifier: event.contextInfo.interactionContext.sourceIdentifier,
        interactionData: event.contextInfo.interactionContext.interactionData,
      );

      AdhaConversation newConversation = AdhaConversation(
        id: newConversationId,
        title: _generateConversationTitle(event.initialMessage),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        messages: event.initialMessage.isNotEmpty ? [userMessage] : [], // Ensure messages list is empty if initialMessage is empty
      );

      // If initialMessage is empty, we might not want to immediately process.
      // The AdhaInitial state should be shown.
      // However, the current structure proceeds to send a message.
      // This part might need review if an empty initialMessage is truly intended for _onNewConversation
      // beyond just resetting to AdhaInitial via the button.
      // For now, assuming if initialMessage is not empty, we proceed.

      if (event.initialMessage.isEmpty) {
         // This case should ideally be fully handled by the AdhaInitial emission above
         // if the intent is just to go to suggestions.
         // If a "new blank conversation" is to be created and made active without a message,
         // then _currentlyActiveConversationId should be set.
         // For now, the button press path (empty message) clears the ID and emits AdhaInitial.
         // If this event is called with an empty message NOT from the button,
         // it implies creating a blank, active conversation.
         if (event.contextInfo.interactionContext.sourceIdentifier != 'new_conversation_button') {
            await adhaRepository.saveConversation(newConversation);
            _currentlyActiveConversationId = newConversation.id;
            emit(AdhaConversationActive(conversation: newConversation, isProcessing: false));
         }
         return;
      }


      // Proceed if initialMessage is not empty
      emit(AdhaConversationActive(
        conversation: newConversation,
        isProcessing: true, 
        isVoiceActive: previousState?.isVoiceActive ?? false,
      ));

      final responseContent = await adhaRepository.sendMessage(
        conversationId: newConversationId,
        message: event.initialMessage,
        contextInfo: contextInfoForApi,
      );

      final adhaMessage = AdhaMessage(
        id: _uuid.v4(),
        content: responseContent,
        timestamp: DateTime.now(),
        isUserMessage: false,
        type: _detectMessageType(responseContent),
      );

      final updatedConversationWithResponse = newConversation.copyWith(
        messages: List<AdhaMessage>.from(newConversation.messages)..add(adhaMessage),
        updatedAt: DateTime.now(),
      );

      await adhaRepository.saveConversation(updatedConversationWithResponse);
      _currentlyActiveConversationId = updatedConversationWithResponse.id; // Set active ID

      emit(AdhaConversationActive(
        conversation: updatedConversationWithResponse,
        isProcessing: false,
        isVoiceActive: previousState?.isVoiceActive ?? false,
      ));
    } catch (e) {
      emit(AdhaError("Erreur lors de la création de la nouvelle conversation: $e"));
    }
  }

  Future<void> _onLoadConversations(
    LoadConversations event,
    Emitter<AdhaState> emit,
  ) async {
    emit(const AdhaLoading());
    try {
      // Case 1: User explicitly wants the initial screen (_currentlyActiveConversationId is null).
      if (_currentlyActiveConversationId == null) {
        emit(const AdhaInitial());
        // Optional: In the background, ensure a default conversation exists if the repository is empty,
        // but don't make it active here as the user wants the initial screen.
        // This part is removed to strictly adhere to showing AdhaInitial if ID is null.
        // If no conversations exist at all, AdhaInitial is fine, user can start one.
        return;
      }

      // Case 2: A specific conversation is supposed to be active. Load it.
      // (_currentlyActiveConversationId is NOT null here)
      final AdhaConversation? conversation = await adhaRepository.getConversation(_currentlyActiveConversationId!);
      if (conversation != null) {
        emit(AdhaConversationActive(conversation: conversation));
      } else {
        // The active conversation ID was stored, but the conversation is gone from the repo.
        // This is an inconsistent state. Fallback: clear the active ID and go to AdhaInitial.
        _currentlyActiveConversationId = null; // Clear the bad ID
        emit(const AdhaInitial()); // Go to initial screen as a safe fallback
      }
    } catch (e) {
      _currentlyActiveConversationId = null; // Clear on error to prevent broken state
      emit(AdhaError('Erreur lors du chargement des conversations: $e'));
      // Optionally, after error, try to emit AdhaInitial so user is not stuck on error screen.
      // emit(const AdhaInitial());
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
        _currentlyActiveConversationId = conversation.id; // Set active ID
        emit(AdhaConversationActive(conversation: conversation));
      } else {
        emit(const AdhaError('Conversation non trouvée'));
        add(const LoadConversations());
      }
    } catch (e) {
      emit(AdhaError('Erreur lors du chargement de la conversation: $e'));
    }
  }

  Future<void> _onDeleteConversation(
    DeleteConversation event,
    Emitter<AdhaState> emit,
  ) async {
    try {
      await adhaRepository.deleteConversation(event.conversationId);
      if (_currentlyActiveConversationId == event.conversationId) {
        _currentlyActiveConversationId = null; // Clear active ID if it was deleted
      }
      add(const LoadConversations()); // Reload, will go to AdhaInitial if active ID is now null
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
         // _currentlyActiveConversationId remains what it was, voice is just an input method for current/new convo
      }
    } else {
      // This case implies starting voice recognition when not in an active conversation (e.g. from AdhaInitial)
      // A new conversation should be implicitly started or prepared.
      final newConversationId = _uuid.v4();
      final newConversation = AdhaConversation(
        id: newConversationId,
        title: 'Conversation vocale', // Temporary title
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        messages: [],
      );
      // Don't save or set active ID yet, wait for actual speech input.
      // The AdhaConversationActive state here is to enable voice input UI.
      // The actual conversation will be formed by SendMessage after voice input.
      emit(AdhaConversationActive(conversation: newConversation, isVoiceActive: true, isProcessing: false));
      // _currentlyActiveConversationId should ideally be set when the first message from voice is processed.
      // For now, if voice is started from AdhaInitial, _currentlyActiveConversationId is still null.
      // SendMessage will handle creating/activating the conversation.
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
    if (content.contains('```')) {
      return AdhaMessageType.code;
    } else if (content.contains(r'\begin{equation}') || content.contains(r'$$')) {
      return AdhaMessageType.latex;
    } else if (content.contains('<graph>') || content.contains('plt.show()')) {
      return AdhaMessageType.graph;
    }
    return AdhaMessageType.text;
  }
}
