import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/supplier_bloc.dart';
import '../bloc/supplier_event.dart';
import '../bloc/supplier_state.dart';
import '../models/supplier.dart';
import 'add_supplier_screen.dart';

/// Écran de détails d'un fournisseur
class SupplierDetailsScreen extends StatelessWidget {
  /// Fournisseur à afficher
  final Supplier? supplier;
  
  /// ID du fournisseur
  final String supplierId;

  const SupplierDetailsScreen({
    super.key, 
    this.supplier,
    this.supplierId = '',
  });
  @override
  Widget build(BuildContext context) {
    // Si le fournisseur n'est pas fourni, le charger depuis le repository
    if (supplier == null && supplierId.isNotEmpty) {
      context.read<SupplierBloc>().add(LoadSupplier(supplierId));
      
      return Scaffold(
        appBar: AppBar(
          title: const Text('Détails du fournisseur'),
        ),
        body: BlocBuilder<SupplierBloc, SupplierState>(
          builder: (context, state) {
            if (state is SupplierLoading) {
              return const Center(child: CircularProgressIndicator());            } else if (state is SupplierLoaded) {
              return _buildSupplierDetails(context, state.supplier);
            } else if (state is SupplierError) {
              return Center(child: Text('Erreur: ${state.message}'));
            }
            return const Center(child: Text('Fournisseur non trouvé'));
          },
        ),
      );
    }
    
    // Si le fournisseur est déjà fourni, afficher directement les détails
    return _buildSupplierDetails(context, supplier!);
  }
  
  /// Construit l'écran de détails du fournisseur
  Widget _buildSupplierDetails(BuildContext context, Supplier supplier) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du fournisseur'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEditSupplier(context, supplier),
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
                    backgroundColor: _getCategoryColor(supplier.category),
                    child: Text(
                      supplier.name.isNotEmpty ? supplier.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 36,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    supplier.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(                color: Color.fromRGBO(
                        _getCategoryColor(supplier.category).red.toInt(),
                        _getCategoryColor(supplier.category).green.toInt(),
                        _getCategoryColor(supplier.category).blue.toInt(),
                        0.2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _getCategoryName(supplier.category),
                      style: TextStyle(
                        color: _getCategoryColor(supplier.category),
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
                    
                    // Personne à contacter
                    if (supplier.contactPerson.isNotEmpty) ...[
                      _buildInfoRow(
                        Icons.person,
                        'Contact',
                        supplier.contactPerson,
                      ),
                      const SizedBox(height: 12),
                    ],
                    
                    // Téléphone
                    _buildInfoRow(
                      Icons.phone,
                      'Téléphone',
                      supplier.phoneNumber,
                      onTap: () => _makePhoneCall(context, supplier.phoneNumber),
                    ),
                    const SizedBox(height: 12),
                    
                    // Email
                    if (supplier.email.isNotEmpty) ...[
                      _buildInfoRow(
                        Icons.email,
                        'Email',
                        supplier.email,
                        onTap: () => _sendEmail(context, supplier.email),
                      ),
                      const SizedBox(height: 12),
                    ],
                    
                    // Adresse
                    if (supplier.address.isNotEmpty) ...[
                      _buildInfoRow(
                        Icons.location_on,
                        'Adresse',
                        supplier.address,
                        onTap: () => _openMap(context, supplier.address),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Carte d'informations commerciales
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informations commerciales',
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
                      '${_formatCurrency(supplier.totalPurchases)} FC',
                    ),
                    const SizedBox(height: 12),
                    
                    // Dernier achat
                    _buildInfoRow(
                      Icons.calendar_today,
                      'Dernier achat',
                      supplier.lastPurchaseDate != null
                          ? _formatDate(supplier.lastPurchaseDate!)
                          : 'Aucun achat enregistré',
                    ),
                    const SizedBox(height: 12),
                    
                    // Délai de livraison
                    _buildInfoRow(
                      Icons.timer,
                      'Délai de livraison',
                      supplier.deliveryTimeInDays > 0
                          ? '${supplier.deliveryTimeInDays} jour(s)'
                          : 'Non spécifié',
                    ),
                    const SizedBox(height: 12),
                    
                    // Conditions de paiement
                    if (supplier.paymentTerms.isNotEmpty) ...[
                      _buildInfoRow(
                        Icons.payment,
                        'Conditions de paiement',
                        supplier.paymentTerms,
                      ),
                      const SizedBox(height: 12),
                    ],
                    
                    // Fournisseur depuis
                    _buildInfoRow(
                      Icons.access_time,
                      'Fournisseur depuis',
                      _formatDate(supplier.createdAt),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Notes
            if (supplier.notes.isNotEmpty) ...[
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
                      Text(supplier.notes),
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
                  Icons.shopping_cart,
                  'Passer commande',
                  onPressed: () => _placeOrder(context),
                ),
                _buildActionButton(
                  context,
                  Icons.phone,
                  'Appeler',
                  onPressed: () => _makePhoneCall(context, supplier.phoneNumber),
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
  }
  /// Navigation vers l'écran de modification du fournisseur
  void _navigateToEditSupplier(BuildContext context, Supplier supplier) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddSupplierScreen(supplier: supplier),
      ),    ).then((value) {
      // Rafraîchir les données si le widget est toujours monté
      if (context.mounted) {
        context.read<SupplierBloc>().add(LoadSupplier(supplier.id));
      }
    });
  }

  /// Passe une commande auprès de ce fournisseur
  void _placeOrder(BuildContext context) {
    // TODO: Implémenter le passage de commande
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
  }  /// Confirme la suppression du fournisseur
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Supprimer le fournisseur'),
          content: Text(
            'Êtes-vous sûr de vouloir supprimer ${supplier!.name} ? Cette action est irréversible.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<SupplierBloc>().add(DeleteSupplier(supplier!.id));
                Navigator.pop(context); // Retourne à l'écran précédent
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }
  /// Retourne la couleur associée à une catégorie de fournisseur
  Color _getCategoryColor(SupplierCategory category) {
    switch (category) {
      case SupplierCategory.strategic:
        return Colors.indigo;
      case SupplierCategory.regular:
        return Colors.blue;      case SupplierCategory.newSupplier:
        return Colors.green;
      case SupplierCategory.occasional:
        return Colors.orange;
      case SupplierCategory.international:
        return Colors.purple;
    }
  }
  /// Retourne le nom d'une catégorie de fournisseur
  String _getCategoryName(SupplierCategory category) {
    switch (category) {
      case SupplierCategory.strategic:
        return 'Stratégique';
      case SupplierCategory.regular:
        return 'Régulier';      case SupplierCategory.newSupplier:
        return 'Nouveau';
      case SupplierCategory.occasional:
        return 'Occasionnel';
      case SupplierCategory.international:
        return 'International';
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
