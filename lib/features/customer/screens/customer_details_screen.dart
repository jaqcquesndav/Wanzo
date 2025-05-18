import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/customer_bloc.dart';
import '../bloc/customer_event.dart';
import '../bloc/customer_state.dart';
import '../models/customer.dart';
import 'add_customer_screen.dart';

/// Écran de détails d'un client
class CustomerDetailsScreen extends StatelessWidget {
  /// Client à afficher
  final Customer? customer;
  
  /// ID du client
  final String customerId;

  const CustomerDetailsScreen({
    super.key, 
    this.customer,
    this.customerId = '',
  });
  @override
  Widget build(BuildContext context) {
    // Si le client n'est pas fourni, le charger depuis le repository
    if (customer == null && customerId.isNotEmpty) {
      context.read<CustomerBloc>().add(LoadCustomer(customerId));
      
      return Scaffold(
        appBar: AppBar(
          title: const Text('Détails du client'),
        ),
        body: BlocBuilder<CustomerBloc, CustomerState>(
          builder: (context, state) {            if (state is CustomerLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CustomerLoaded) {
              return _buildCustomerDetails(context, state.customer);
            } else if (state is CustomerError) {
              return Center(child: Text('Erreur: ${state.message}'));
            }
            return const Center(child: Text('Client non trouvé'));
          },
        ),
      );
    }
    
    // Si le client est déjà fourni, afficher directement les détails
    return _buildCustomerDetails(context, customer!);
  }
  
  /// Construit l'écran de détails du client
  Widget _buildCustomerDetails(BuildContext context, Customer customer) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du client'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEditCustomer(context, customer),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec avatar et informations principales
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: _getCategoryColor(customer.category),
                    child: Text(
                      customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 36,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    customer.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),                    decoration: BoxDecoration(
                      color: _getCategoryColor(customer.category).withAlpha(51), // 0.2 * 255 = ~51
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _getCategoryName(customer.category),
                      style: TextStyle(
                        color: _getCategoryColor(customer.category),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Carte d'informations de contact
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informations de contact',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    
                    // Téléphone
                    _buildInfoRow(
                      Icons.phone,
                      'Téléphone',
                      customer.phoneNumber,
                      onTap: () => _makePhoneCall(context, customer.phoneNumber),
                    ),
                    const SizedBox(height: 12),
                    
                    // Email
                    if (customer.email?.isNotEmpty ?? false) ...[
                      _buildInfoRow(
                        Icons.email,
                        'Email',
                        customer.email ?? '', // Provide default value
                        onTap: () => _sendEmail(context, customer.email ?? ''), // Provide default value
                      ),
                      const SizedBox(height: 12),
                    ],
                    
                    // Adresse
                    if (customer.address?.isNotEmpty ?? false) ...[
                      _buildInfoRow(
                        Icons.location_on,
                        'Adresse',
                        customer.address ?? '', // Provide default value
                        onTap: () => _openMap(context, customer.address ?? ''), // Provide default value
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Carte de statistiques d'achat
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Statistiques d\'achat',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    
                    // Total des achats
                    _buildInfoRow(
                      Icons.attach_money,
                      'Total des achats',
                      '${_formatCurrency(customer.totalPurchases)} FC',
                    ),
                    const SizedBox(height: 12),
                    
                    // Dernier achat
                    _buildInfoRow(
                      Icons.calendar_today,
                      'Dernier achat',
                      customer.lastPurchaseDate != null
                          ? _formatDate(customer.lastPurchaseDate!)
                          : 'Aucun achat enregistré',
                    ),
                    const SizedBox(height: 12),
                    
                    // Client depuis
                    _buildInfoRow(
                      Icons.access_time,
                      'Client depuis',
                      _formatDate(customer.createdAt),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Notes
            if (customer.notes?.isNotEmpty ?? false) ...[
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Notes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text(customer.notes ?? ''), // Provide default value
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Boutons d'action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  context,
                  Icons.add_shopping_cart,
                  'Ajouter une vente',
                  onPressed: () => _addSale(context),
                ),
                _buildActionButton(
                  context,
                  Icons.phone,
                  'Appeler',
                  onPressed: () => _makePhoneCall(context, customer.phoneNumber),
                ),
                _buildActionButton(
                  context,
                  Icons.delete,
                  'Supprimer',
                  color: Colors.red,
                  onPressed: () => _confirmDelete(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Construit une ligne d'information
  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construit un bouton d'action
  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label, {
    required VoidCallback onPressed,
    Color? color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      ),
    );
  }  /// Navigation vers l'écran de modification du client
  void _navigateToEditCustomer(BuildContext context, Customer customer) {
    final BuildContext currentContext = context;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddCustomerScreen(customer: customer),
      ),
    ).then((value) {
      // Vérifier que le widget est toujours monté avant d'utiliser le contexte
      if (currentContext.mounted) {
        // Rafraîchir les données
        currentContext.read<CustomerBloc>().add(LoadCustomer(customer.id));
      }
    });
  }

  /// Ajoute une vente pour ce client
  void _addSale(BuildContext context) {
    // TODO: Implémenter l'ajout de vente pour ce client
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonctionnalité à implémenter')),
    );
  }

  /// Effectue un appel téléphonique
  void _makePhoneCall(BuildContext context, String phoneNumber) {
    // TODO: Implémenter l'appel téléphonique
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Appel vers $phoneNumber')),
    );
  }

  /// Envoie un email
  void _sendEmail(BuildContext context, String email) {
    // TODO: Implémenter l'envoi d'email
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Email vers $email')),
    );
  }

  /// Ouvre la carte pour voir l'adresse
  void _openMap(BuildContext context, String address) {
    // TODO: Implémenter l'ouverture de la carte
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ouverture de la carte pour $address')),
    );
  }

  /// Confirme la suppression du client
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer le client'),          content: Text(
            'Êtes-vous sûr de vouloir supprimer ${customer?.name ?? "ce client"} ? Cette action est irréversible.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(              onPressed: () {
                if (customer != null) {
                  Navigator.pop(context);
                  context.read<CustomerBloc>().add(DeleteCustomer(customer!.id));
                  Navigator.pop(context); // Retourne à l'écran précédent
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  /// Retourne la couleur associée à une catégorie de client
  Color _getCategoryColor(CustomerCategory category) {
    switch (category) {
      case CustomerCategory.vip:
        return Colors.purple;
      case CustomerCategory.regular:
        return Colors.blue;
      case CustomerCategory.new_customer:
        return Colors.green;
      case CustomerCategory.occasional:
        return Colors.orange;      case CustomerCategory.business:
        return Colors.indigo;
    }
  }

  /// Retourne le nom d'une catégorie de client
  String _getCategoryName(CustomerCategory category) {
    switch (category) {
      case CustomerCategory.vip:
        return 'VIP';
      case CustomerCategory.regular:
        return 'Régulier';
      case CustomerCategory.new_customer:
        return 'Nouveau';
      case CustomerCategory.occasional:
        return 'Occasionnel';      case CustomerCategory.business:
        return 'Entreprise';
    }
  }

  /// Formate un montant en devise
  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
  }

  /// Formate une date
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
