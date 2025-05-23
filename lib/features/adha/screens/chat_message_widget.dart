import 'package:flutter/material.dart';
import '../models/adha_message.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';

/// Widget pour afficher un message dans la conversation avec Adha
class ChatMessageWidget extends StatelessWidget {
  /// Le message à afficher
  final AdhaMessage message;

  const ChatMessageWidget({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUserMessage;
    final bubbleColor = isUser 
        ? Theme.of(context).primaryColor.withAlpha((0.2 * 255).round())
        : Colors.grey.withAlpha((0.1 * 255).round());
    final textColor = isUser 
        ? Theme.of(context).primaryColor
        : Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) 
            _buildAvatar(),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  // Contenu du message en fonction de son type
                  _buildMessageContent(context, textColor),
                  
                  // Timestamp du message
                  const SizedBox(height: 4),
                  Text(
                    _formatTimestamp(message.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: textColor.withAlpha((0.6 * 255).round()),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (isUser) 
            _buildAvatar(),
        ],
      ),
    );
  }

  /// Construit le contenu du message en fonction de son type
  Widget _buildMessageContent(BuildContext context, Color textColor) {
    switch (message.type) {
      case AdhaMessageType.text:
        return _buildTextMessage(context, textColor);
      case AdhaMessageType.code:
        return _buildCodeMessage(context);
      case AdhaMessageType.latex:
        return _buildLatexMessage();
      case AdhaMessageType.graph:
        return _buildGraphMessage(context); // Pass context
      case AdhaMessageType.media:
        return _buildMediaMessage();
    }
  }

  /// Construit un message texte simple
  Widget _buildTextMessage(BuildContext context, Color textColor) {
    return MarkdownBody(
      data: message.content,
      styleSheet: MarkdownStyleSheet(
        p: TextStyle(color: textColor, fontSize: 16),
        strong: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        em: TextStyle(color: textColor, fontStyle: FontStyle.italic),
        blockquote: TextStyle(color: textColor.withAlpha((0.7 * 255).round()), fontSize: 16),
        blockquoteDecoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 4.0,
            ),
          ),
        ),
      ),
      shrinkWrap: true,
    );
  }

  /// Construit un message avec du code
  Widget _buildCodeMessage(BuildContext context) {
    // Extrait le code des blocs de code markdown ```
    final pattern = RegExp(r'```(\w+)?\n([\s\S]*?)\n```');
    final match = pattern.firstMatch(message.content);
    
    String language = 'dart';
    String code = message.content;
    
    if (match != null) {
      language = match.group(1) ?? 'dart';
      code = match.group(2) ?? message.content;
    }
    
    // Pour les petits extraits de code, on utilise le widget de coloration syntaxique
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!pattern.hasMatch(message.content))
          Text(
            message.content.split('```').first.trim(),
            style: const TextStyle(fontSize: 16),
          ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.black.withAlpha((0.7 * 255).round()) 
                : Colors.grey[200], 
            borderRadius: BorderRadius.circular(8),
          ),
          child: HighlightView(
            code,
            language: language,
            theme: githubTheme,
            padding: const EdgeInsets.all(8),
            textStyle: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
            ),
          ),
        ),
        if (message.content.split('```').length > 2)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              message.content.split('```').last.trim(),
              style: const TextStyle(fontSize: 16),
            ),
          ),
      ],
    );
  }

  /// Construit un message avec des formules LaTeX
  Widget _buildLatexMessage() {
    final parts = message.content.split(RegExp(r'(\$\$[\s\S]*?\$\$)'));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: parts.map((part) {
        final latexReg = RegExp(r'^\$\$(.*)\$\$$', dotAll: true);
        if (latexReg.hasMatch(part)) {
          final formula = latexReg.firstMatch(part)!.group(1)!.trim();
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                formula,
                style: const TextStyle(fontSize: 18, fontFamily: 'monospace'),
              ),
            ),
          );
        } else {
          return Text(
            part.trim(),
            style: const TextStyle(fontSize: 16),
          );
        }
      }).toList(),
    );
  }

  /// Construit un message avec un graphique
  Widget _buildGraphMessage(BuildContext context) {
    // Dans une application réelle, on générerait un graphique à partir du code Python
    // Ici, on simule avec un message expliquant que le graphique serait affiché
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (message.content.contains('```python'))
          _buildCodeMessage(context),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey.withAlpha((0.2 * 255).round()),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bar_chart, size: 48, color: Colors.grey),
                SizedBox(height: 8),
                Text(
                  "Graphique: Ventes quotidiennes",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Dans la version finale, ce graphique serait généré à partir du code",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          message.content.split('```').last.trim(),
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  /// Construit un message avec un contenu multimédia
  Widget _buildMediaMessage() {
    // Implémentation basique, à développer selon les besoins
    return const Text("Contenu multimédia non supporté pour le moment");
  }

  /// Construit l'avatar pour le message
  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 16,
      backgroundColor: message.isUserMessage 
          ? Colors.blue.withAlpha((0.2 * 255).round())
          : Colors.purple.withAlpha((0.2 * 255).round()),
      child: Icon(
        message.isUserMessage ? Icons.person : Icons.smart_toy,
        size: 18,
        color: message.isUserMessage ? Colors.blue : Colors.purple,
      ),
    );
  }

  /// Formatte l'horodatage du message
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
    );
    
    if (messageDate == today) {
      // Aujourd'hui, affiche seulement l'heure
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      // Hier
      return 'Hier, ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      // Date complète
      return '${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')}/${timestamp.year}, ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}
