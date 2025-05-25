import 'package:hive/hive.dart';
import '../models/adha_message.dart';
import '../models/adha_context_info.dart';

/// Repository pour gérer les interactions avec l'assistant Adha
class AdhaRepository {
  static const _conversationsBoxName = 'adha_conversations';
  late Box<AdhaConversation> _conversationsBox;

  /// Initialise le repository
  Future<void> init() async {
    // Les adaptateurs sont désormais enregistrés dans registerAdapters()
    _conversationsBox = await Hive.openBox<AdhaConversation>(_conversationsBoxName);
  }

  /// Récupère toutes les conversations
  Future<List<AdhaConversation>> getConversations() async {
    return _conversationsBox.values.toList();
  }

  /// Récupère une conversation spécifique
  Future<AdhaConversation?> getConversation(String conversationId) async {
    return _conversationsBox.get(conversationId);
  }

  /// Sauvegarde une conversation
  Future<void> saveConversation(AdhaConversation conversation) async {
    await _conversationsBox.put(conversation.id, conversation);
  }

  /// Supprime une conversation
  Future<void> deleteConversation(String conversationId) async {
    await _conversationsBox.delete(conversationId);
  }

  /// Envoie un message à l'API Adha et retourne la réponse
  Future<String> sendMessage({
    required String conversationId,
    required String message,
    AdhaContextInfo? contextInfo,
  }) async {
    // Dans une version réelle, cette méthode ferait un appel à une API IA
    // L'appel API devrait inclure le message et contextInfo si présent
    // Exemple (pseudo-code pour l'appel API):
    // final response = await apiClient.post('/api/adha/message', data: {
    //   'text': message,
    //   'conversationId': conversationId, // ou null si nouvelle conversation
    //   'timestamp': DateTime.now().toIso8601String(),
    //   if (contextInfo != null) 'contextInfo': contextInfo.toJson(),
    // });
    // return response.data['data']['replyText'];

    // Pour l'instant, nous simulons une réponse
    await Future.delayed(const Duration(seconds: 1));
    
    if (message.toLowerCase().contains('bonjour') || 
        message.toLowerCase().contains('salut') ||
        message.toLowerCase().contains('hello')) {
      return "Bonjour ! Je suis Adha, votre assistant pour la gestion de votre entreprise. Comment puis-je vous aider aujourd'hui ?";
    }
    
    if (message.toLowerCase().contains('vente')) {
      return "Concernant les ventes, voici quelques informations :\n\n"
          "- Vous avez réalisé 25 ventes cette semaine\n"
          "- Le montant total des ventes est de 1 250 000 FC\n"
          "- Votre meilleur jour était mercredi avec 450 000 FC\n\n"
          "Souhaitez-vous voir un récapitulatif détaillé ou analyser une tendance particulière ?";
    }
    
    if (message.toLowerCase().contains('stock') || message.toLowerCase().contains('produit')) {
      return "Concernant votre inventaire :\n\n"
          "- Vous avez 120 produits en stock\n"
          "- 8 produits sont en alerte de stock bas\n"
          "- La valeur totale de votre stock est de 3 750 000 FC\n\n"
          "Souhaitez-vous connaître les produits les plus vendus ou ceux à réapprovisionner en priorité ?";
    }
    
    if (message.toLowerCase().contains('graphique') || message.toLowerCase().contains('statistique')) {
      return "```python\nimport matplotlib.pyplot as plt\nimport numpy as np\n\n"
          "# Données des ventes sur 7 jours\n"
          "jours = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim']\n"
          "ventes = [120000, 180000, 450000, 200000, 150000, 80000, 70000]\n\n"
          "plt.figure(figsize=(10, 6))\n"
          "plt.bar(jours, ventes, color='skyblue')\n"
          "plt.xlabel('Jour de la semaine')\n"
          "plt.ylabel('Ventes (FC)')\n"
          "plt.title('Ventes quotidiennes de la semaine')\n"
          "plt.grid(axis='y', linestyle='--', alpha=0.7)\n"
          "plt.show()\n```\n\n"
          "Voici un graphique des ventes de cette semaine. Comme vous pouvez le constater, mercredi a été votre meilleure journée.";
    }
    
    if (message.toLowerCase().contains('math') || message.toLowerCase().contains('formule') || message.toLowerCase().contains('calcul')) {
      return r"""Pour calculer votre marge bénéficiaire, vous pouvez utiliser la formule suivante :

$$Marge = \\frac{Prix\\_vente - Coût\\_achat}{Prix\\_vente} \\times 100\\%$$

Par exemple, si vous achetez un produit à 7 500 FC et le vendez à 10 000 FC, votre marge est de :

$$Marge = \\frac{10000 - 7500}{10000} \\times 100\\% = 25\\%$$""";
    }
    
    return "Merci pour votre message. Je suis là pour vous aider à gérer votre entreprise. "
        "N'hésitez pas à me poser des questions sur vos ventes, votre stock, ou à me demander "
        "des analyses et des conseils pour améliorer votre activité.";
  }
}
