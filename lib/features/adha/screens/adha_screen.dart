import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wanzo/core/shared_widgets/wanzo_scaffold.dart';
import '../bloc/adha_bloc.dart';
import '../bloc/adha_event.dart';
import '../bloc/adha_state.dart';
import '../models/adha_message.dart'; // Added import for AdhaMessage
import 'chat_message_widget.dart';
import 'voice_recognition_widget.dart';
import '../models/adha_context_info.dart'; // Added for AdhaContextInfo

class AdhaScreen extends StatefulWidget {
  const AdhaScreen({super.key});

  @override
  State<AdhaScreen> createState() => _AdhaScreenState();
}

class _AdhaScreenState extends State<AdhaScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  AdhaMessage? _editingMessage; // To store the message being edited

  @override
  void initState() {
    super.initState();
    context.read<AdhaBloc>().add(const LoadConversations());
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdhaBloc, AdhaState>(
      builder: (context, adhaState) {
        String currentTitle = "Adha - Assistant IA";
        if (adhaState is AdhaConversationActive) {
          currentTitle = adhaState.conversation.title.isNotEmpty
              ? adhaState.conversation.title
              : "Nouvelle Conversation";
        }

        List<Widget> appBarActions = [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Historique des conversations',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Historique des conversations bientôt disponible!'),
                ),
              );
            },
          ),
        ];

        return WanzoScaffold(
          currentIndex: 4, // Index for Adha in BottomNavigationBar
          title: currentTitle,
          appBarActions: appBarActions,
          body: Column(
            children: [
              Expanded(
                child: BlocConsumer<AdhaBloc, AdhaState>(
                  listener: (context, state) {
                    if (state is AdhaConversationActive) {
                      WidgetsBinding.instance
                          .addPostFrameCallback((_) => _scrollToBottom());
                    }
                  },
                  builder: (context, state) {
                    if (state is AdhaInitial) {
                      return _buildFeatureSuggestions(context);
                    } else if (state is AdhaConversationsList && state.conversations.isEmpty) {
                      return _buildFeatureSuggestions(context);
                    } else if (state is AdhaLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is AdhaError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            "Erreur: ${state.message}",
                            style: const TextStyle(color: Colors.red, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    } else if (state is AdhaConversationActive) {
                      return state.conversation.messages.isEmpty
                          ? _buildFeatureSuggestions(context)
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount: state.conversation.messages.length,
                              itemBuilder: (context, index) {
                                final message =
                                    state.conversation.messages[index];
                                return ChatMessageWidget(
                                  message: message,
                                  onEditMessage: (editedMessage) {
                                    setState(() {
                                      _editingMessage = editedMessage;
                                      _messageController.text = editedMessage.content;
                                    });
                                  },
                                );
                              },
                            );
                    } else if (state is AdhaConversationsList && state.conversations.isNotEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Text(
                            "Sélectionnez une conversation (via futur menu) ou démarrez avec les suggestions.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                          ),
                        ),
                      );
                    }
                    return const Center(child: Text("Préparation d'Adha..."));
                  },
                ),
              ),
              if (adhaState is AdhaConversationActive && adhaState.isProcessing)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(strokeWidth: 2),
                        SizedBox(width: 10),
                        Text("Adha réfléchit...")
                      ],
                    ),
                  ),
                ),
              _buildInputRow(context, adhaState),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInputRow(BuildContext context, AdhaState adhaState) {
    bool isConversationActive = adhaState is AdhaConversationActive;
    bool isProcessing = false;
    bool isVoiceActive = false;

    if (isConversationActive) {
      isProcessing = adhaState.isProcessing;
      isVoiceActive = adhaState.isVoiceActive;
    }

    bool canSendMessage = !isProcessing && !isVoiceActive && _messageController.text.trim().isNotEmpty;
    bool canUseVoice = isConversationActive && !isProcessing;
    bool canStartNewConversationViaButton = !isProcessing && _editingMessage == null; // Disable new conversation if editing
    // Placeholder for base context that will be populated by the BLoC
    final AdhaBaseContext placeholderBaseContext = AdhaBaseContext(operationJournalSummary: {}, businessProfile: {});

    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Center(
              child: TextButton.icon(
                icon: Icon(Icons.add_circle_outline, color: Colors.white, size: 18),
                label: Text(
                  'Nouvelle conversation',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  minimumSize: Size(0, 30),
                ),
                onPressed: canStartNewConversationViaButton
                    ? () {
                        final interactionContext = AdhaInteractionContext(
                          interactionType: AdhaInteractionType.directInitiation,
                          sourceIdentifier: 'new_conversation_button',
                        );
                        final contextInfo = AdhaContextInfo(
                           baseContext: placeholderBaseContext, 
                           interactionContext: interactionContext,
                        );
                        // If editing, send an EditMessage event, otherwise NewConversation
                        if (_editingMessage != null) {
                          // Assuming you will create an EditMessage event similar to SendMessage
                          // For now, let's clear editing state and send as new for simplicity
                          // Or, you might want a specific BLoC event for editing.
                          // context.read<AdhaBloc>().add(EditMessage(_editingMessage!.id, _messageController.text.trim(), contextInfo));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('La modification du message n\'est pas encore implémentée dans le BLoC.')),
                          );
                          // For now, just clear editing state
                          setState(() {
                            _editingMessage = null;
                            _messageController.clear();
                          });
                        } else {
                          context.read<AdhaBloc>().add(NewConversation(
                            _messageController.text.trim(), // Use text from controller if any, or empty
                            contextInfo,
                          ));
                        }
                        _messageController.clear();
                      }
                    : null,
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(Icons.attach_file, color: Theme.of(context).colorScheme.primary),
                tooltip: 'Joindre un fichier (bientôt disponible)',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('La fonction d\'import de pièce jointe sera bientôt disponible.')),
                  );
                },
              ),
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: isVoiceActive
                        ? "Parlez maintenant..."
                        : (isConversationActive && !(adhaState.conversation.messages.isEmpty))
                            ? "Écrivez votre message..."
                            : "Commencer une nouvelle conversation...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  minLines: 1,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  enabled: !isProcessing && !isVoiceActive,
                  onChanged: (text) {
                    setState(() {});
                  },
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty && canSendMessage) {
                      AdhaInteractionType interactionType;
                      String sourceIdentifier;

                      if (adhaState is AdhaConversationActive && adhaState.conversation.messages.isNotEmpty) {
                        interactionType = AdhaInteractionType.followUp;
                        sourceIdentifier = 'text_input_follow_up';
                      } else {
                        interactionType = AdhaInteractionType.directInitiation;
                        sourceIdentifier = 'text_input_direct_initiation';
                      }
                      
                      final interactionContext = AdhaInteractionContext(
                        interactionType: interactionType,
                        sourceIdentifier: sourceIdentifier,
                      );
                      final contextInfo = AdhaContextInfo(
                        baseContext: placeholderBaseContext,
                        interactionContext: interactionContext,
                      );
                      // If editing, send an EditMessage event, otherwise SendMessage
                      if (_editingMessage != null) {
                        context.read<AdhaBloc>().add(EditMessage(_editingMessage!.id, value.trim(), contextInfo));
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   const SnackBar(content: Text('La modification du message n\'est pas encore implémentée dans le BLoC.')),
                        // );
                        setState(() {
                          _editingMessage = null; // Reset editing state
                        });
                      } else {
                        context.read<AdhaBloc>().add(SendMessage(
                          value.trim(),
                          contextInfo: contextInfo,
                        ));
                      }
                      _messageController.clear();
                      setState(() {});
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  isVoiceActive ? Icons.mic : Icons.mic_none,
                  color: isVoiceActive ? Colors.redAccent : Theme.of(context).colorScheme.primary,
                ),
                tooltip: isVoiceActive ? 'Arrêter la dictée' : 'Commencer la dictée',
                onPressed: canUseVoice
                  ? () {
                      final adhaBloc = context.read<AdhaBloc>();
                      if (isVoiceActive) {
                        adhaBloc.add(const StopVoiceRecognition());
                      } else {
                        adhaBloc.add(const StartVoiceRecognition());
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (modalContext) {
                            return BlocProvider.value(
                              value: adhaBloc,
                              child: const VoiceRecognitionWidget(),
                            );
                          },
                        ).whenComplete(() {
                          final latestState = adhaBloc.state;
                          if (latestState is AdhaConversationActive && latestState.isVoiceActive) {
                            adhaBloc.add(const StopVoiceRecognition());
                          }
                        });
                      }
                    }
                  : null,
              ),
              FloatingActionButton(
                onPressed: canSendMessage
                    ? () {
                        final message = _messageController.text.trim();
                        if (message.isNotEmpty) {
                          AdhaInteractionType interactionType;
                          String sourceIdentifier;

                          if (adhaState is AdhaConversationActive && adhaState.conversation.messages.isNotEmpty) {
                            interactionType = AdhaInteractionType.followUp;
                            sourceIdentifier = 'fab_send_follow_up';
                          } else {
                            interactionType = AdhaInteractionType.directInitiation;
                            sourceIdentifier = 'fab_send_direct_initiation';
                          }

                          final interactionContext = AdhaInteractionContext(
                            interactionType: interactionType,
                            sourceIdentifier: sourceIdentifier,
                          );
                          final contextInfo = AdhaContextInfo(
                            baseContext: placeholderBaseContext,
                            interactionContext: interactionContext,
                          );
                          // If editing, send an EditMessage event, otherwise SendMessage
                          if (_editingMessage != null) {
                            context.read<AdhaBloc>().add(EditMessage(_editingMessage!.id, message, contextInfo));
                            //  ScaffoldMessenger.of(context).showSnackBar(
                            //   const SnackBar(content: Text('La modification du message n\'est pas encore implémentée dans le BLoC.')),
                            // );
                            setState(() {
                              _editingMessage = null; // Reset editing state
                            });
                          } else {
                            context.read<AdhaBloc>().add(SendMessage(
                              message,
                              contextInfo: contextInfo,
                            ));
                          }
                          _messageController.clear();
                          setState(() {});
                        }
                      }
                    : null,
                backgroundColor: canSendMessage
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
                elevation: 2,
                mini: true,
                heroTag: 'sendMessageFab',
                child: const Icon(Icons.send, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureSuggestions(BuildContext context) {
    final AdhaBaseContext placeholderBaseContext = AdhaBaseContext(operationJournalSummary: {}, businessProfile: {});
    final List<Map<String, dynamic>> features = [
      {
        'icon': Icons.analytics,
        'title': "Analyses de ventes",
        'description': "Quelles sont mes ventes du mois dernier ?",
        'prompt': "Montre-moi les analyses de ventes du mois dernier."
      },
      {
        'icon': Icons.inventory_2,
        'title': "Gestion de stock",
        'description': "Quels produits sont en faible stock ?",
        'prompt': "Liste les produits avec un stock faible."
      },
      {
        'icon': Icons.people,
        'title': "Relations clients",
        'description': "Donne-moi des conseils pour fidéliser mes clients.",
        'prompt': "Comment puis-je améliorer la fidélisation de mes clients ?"
      },
      {
        'icon': Icons.calculate,
        'title': "Calculs financiers",
        'description': "Calcule ma marge brute pour le produit X.",
        'prompt': "Calcule la marge brute pour le produit X."
      },
    ];

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Que puis-je faire pour vous aujourd'hui ?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.9,
              ),
              itemCount: features.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final feature = features[index];
                return InkWell(
                  onTap: () {
                    final interactionContext = AdhaInteractionContext(
                      interactionType: AdhaInteractionType.genericCardAnalysis,
                      sourceIdentifier: 'suggestion_card_${feature['title']?.toString().replaceAll(' ', '_').toLowerCase() ?? 'unknown'}',
                      interactionData: {
                        'cardTitle': feature['title'],
                        'cardPrompt': feature['prompt'],
                      }
                    );
                    final contextInfo = AdhaContextInfo(
                      baseContext: placeholderBaseContext,
                      interactionContext: interactionContext,
                    );
                    context.read<AdhaBloc>().add(SendMessage(
                      feature['prompt'] as String,
                      contextInfo: contextInfo,
                    ));
                  },
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            feature['icon'] as IconData,
                            size: 36,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            feature['title'] as String,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            feature['description'] as String,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
