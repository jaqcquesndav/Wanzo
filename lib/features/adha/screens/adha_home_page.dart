import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/adha_bloc.dart';
import '../bloc/adha_event.dart';
import '../models/adha_context_info.dart'; // Added import
import 'adha_screen.dart';

/// Page d'accueil de l'assistant Adha
class AdhaHomePage extends StatelessWidget {
  const AdhaHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Adha - Assistant IA"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Animation d'un robot IA (à remplacer par votre propre asset Lottie)
            SizedBox(
              height: 200,
              child: Center(
                child: CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.purple.withAlpha((0.1 * 255).round()), // Fixed deprecated withOpacity
                  child: const Icon(
                    Icons.smart_toy,
                    size: 80,
                    color: Colors.purple,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Titre et description
            const Text(
              "Adha, votre assistant d'entreprise intelligent",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            const Text(
              "Posez-moi des questions sur votre entreprise et je vous aiderai à prendre les meilleures décisions grâce à des analyses et des conseils personnalisés.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            // Grille de fonctionnalités
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildFeatureCard(
                  context,
                  Icons.analytics,
                  "Analyses de ventes",
                  "Obtenez des insights sur vos performances commerciales",
                ),
                _buildFeatureCard(
                  context,
                  Icons.inventory_2,
                  "Gestion de stock",
                  "Suivez et optimisez votre inventaire",
                ),
                _buildFeatureCard(
                  context,
                  Icons.people,
                  "Relations clients",
                  "Conseils pour fidéliser vos clients",
                ),
                _buildFeatureCard(
                  context,
                  Icons.calculate,
                  "Calculs financiers",
                  "Projections et analyses financières",
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Bouton pour démarrer une conversation
            ElevatedButton.icon(
              onPressed: () {
                // Crée une nouvelle conversation et navigue vers l'écran de chat
                final contextInfo = AdhaContextInfo(
                  baseContext: AdhaBaseContext(
                    businessProfile: {}, // Will be populated by AdhaBloc
                    operationJournalSummary: {}, // Will be populated by AdhaBloc
                  ),
                  interactionContext: AdhaInteractionContext(
                    interactionType: AdhaInteractionType.directInitiation, // Corrected enum & removed const
                  ),
                );
                context.read<AdhaBloc>().add(NewConversation("Bonjour Adha!", contextInfo)); // Fixed arguments
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AdhaScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.chat),
              label: const Text(
                "Commencer une conversation",
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                minimumSize: const Size(double.infinity, 54),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Bouton pour voir l'historique des conversations
            OutlinedButton.icon(
              onPressed: () {
                // Charge les conversations existantes et navigue vers l'écran de chat
                context.read<AdhaBloc>().add(const LoadConversations());
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AdhaScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.history),
              label: const Text(
                "Voir mes conversations",
                style: TextStyle(fontSize: 16),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                minimumSize: const Size(double.infinity, 54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construit une carte de fonctionnalité
  Widget _buildFeatureCard(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 36,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
