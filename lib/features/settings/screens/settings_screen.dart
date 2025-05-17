import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';
import '../models/settings.dart';
import 'company_settings_screen.dart';
import 'invoice_settings_screen.dart';
import 'display_settings_screen.dart';
import 'inventory_settings_screen.dart';
import 'backup_settings_screen.dart';
import 'notification_settings_screen.dart';

/// Écran principal des paramètres
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    // Charge les paramètres au démarrage
    context.read<SettingsBloc>().add(const LoadSettings());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state is SettingsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is SettingsUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is SettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SettingsLoaded || state is SettingsUpdated) {
            final settings = state is SettingsLoaded
                ? state.settings
                : (state as SettingsUpdated).settings;
            
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo Wanzo en haut de l'écran des paramètres
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/logo_with_text.png',
                          height: 60,
                          errorBuilder: (context, error, stackTrace) {
                            return const Text(
                              'WANZO',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Version 1.0.0',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Liste des sections de paramètres
                  _buildSettingsList(settings),
                ],
              ),
            );
          }
          
          return const Center(child: Text('Chargement des paramètres...'));
        },
      ),
    );
  }

  /// Construit la liste des paramètres
  Widget _buildSettingsList(Settings settings) {
    return ListView(
      shrinkWrap: true, // Add this to make ListView take space of its children
      physics: const NeverScrollableScrollPhysics(), // Disable scrolling for this ListView
      children: [
        _buildSettingsCard(
          icon: Icons.business,
          title: 'Informations de l\'entreprise',
          subtitle: 'Nom, adresse, logo, informations fiscales',
          onTap: () => _navigateToCompanySettings(settings),
        ),
        _buildSettingsCard(
          icon: Icons.receipt_long,
          title: 'Paramètres de facturation',
          subtitle: 'Devise, format de facture, taxes',
          onTap: () => _navigateToInvoiceSettings(settings),
        ),
        _buildSettingsCard(
          icon: Icons.palette,
          title: 'Apparence et affichage',
          subtitle: 'Thème, langue, format de date',
          onTap: () => _navigateToDisplaySettings(settings),
        ),
        _buildSettingsCard(
          icon: Icons.inventory_2,
          title: 'Paramètres d\'inventaire',
          subtitle: 'Catégories par défaut, alertes de stock bas',
          onTap: () => _navigateToInventorySettings(settings),
        ),        _buildSettingsCard(
          icon: Icons.backup,
          title: 'Sauvegarde et rapports',
          subtitle: 'Paramètres de sauvegarde, exportation, emails',
          onTap: () => _navigateToBackupSettings(settings),
        ),
        _buildSettingsCard(
          icon: Icons.notifications,
          title: 'Notifications',
          subtitle: 'Paramètres des notifications push, in-app et email',
          onTap: () => _navigateToNotificationSettings(settings),
        ),
        const SizedBox(height: 16),
        _buildResetButton(),
      ],
    );
  }

  /// Construit une carte pour un groupe de paramètres
  Widget _buildSettingsCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: Icon(
          icon,
          size: 40,
          color: Theme.of(context).primaryColor,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  /// Construit le bouton de réinitialisation des paramètres
  Widget _buildResetButton() {
    return ElevatedButton.icon(
      onPressed: _confirmReset,
      icon: const Icon(Icons.restore),
      label: const Text('Réinitialiser les paramètres'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  /// Affiche une boîte de dialogue de confirmation pour la réinitialisation
  void _confirmReset() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Réinitialiser les paramètres'),
          content: const Text(
            'Êtes-vous sûr de vouloir réinitialiser tous les paramètres aux valeurs par défaut ? Cette action est irréversible.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<SettingsBloc>().add(const ResetSettings());
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Réinitialiser'),
            ),
          ],
        );
      },
    );
  }

  /// Navigation vers les paramètres de l'entreprise
  void _navigateToCompanySettings(Settings settings) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompanySettingsScreen(settings: settings),
      ),
    );
  }

  /// Navigation vers les paramètres de facturation
  void _navigateToInvoiceSettings(Settings settings) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InvoiceSettingsScreen(settings: settings),
      ),
    );
  }

  /// Navigation vers les paramètres d'affichage
  void _navigateToDisplaySettings(Settings settings) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DisplaySettingsScreen(settings: settings),
      ),
    );
  }

  /// Navigation vers les paramètres d'inventaire
  void _navigateToInventorySettings(Settings settings) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InventorySettingsScreen(settings: settings),
      ),
    );
  }

  /// Navigation vers les paramètres de sauvegarde
  void _navigateToBackupSettings(Settings settings) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BackupSettingsScreen(settings: settings),
      ),
    );
  }
  /// Navigue vers les paramètres de notification
  void _navigateToNotificationSettings(Settings settings) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationSettingsScreen(settings: settings),
      ),
    );
  }
}
