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

  AdhaBloc({
    required this.adhaRepository,
    required this.authRepository,
    required this.operationJournalRepository,
  }) : super(const AdhaInitial()) {
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
        messages: [userMessage],
      );

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
      final conversations = await adhaRepository.getConversations();
      if (conversations.isEmpty) {
        final newConversationId = _uuid.v4();
        final newConversation = AdhaConversation(
          id: newConversationId,
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
      final newConversationId = _uuid.v4();
      final newConversation = AdhaConversation(
        id: newConversationId,
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
