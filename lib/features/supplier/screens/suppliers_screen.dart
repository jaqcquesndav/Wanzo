import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/supplier_bloc.dart';
import '../bloc/supplier_event.dart';
import '../bloc/supplier_state.dart';
import '../models/supplier.dart';
import 'supplier_details_screen.dart';
import 'add_supplier_screen.dart';

/// Écran principal de gestion des fournisseurs
class SuppliersScreen extends StatefulWidget {
  final bool isEmbedded;
  const SuppliersScreen({super.key, this.isEmbedded = false});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    // Charge la liste des fournisseurs au démarrage
    context.read<SupplierBloc>().add(const LoadSuppliers());
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget screenContent = Column(
      children: [
        // Barre de recherche
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Rechercher un fournisseur...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  context.read<SupplierBloc>().add(const LoadSuppliers());
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            onChanged: (value) {
              if (value.length > 2) {
                context.read<SupplierBloc>().add(SearchSuppliers(value));
              } else if (value.isEmpty) {
                context.read<SupplierBloc>().add(const LoadSuppliers());
              }
            },
          ),
        ),
        
        // Liste des fournisseurs
        Expanded(
          child: BlocConsumer<SupplierBloc, SupplierState>(
            listener: (context, state) {
              if (state is SupplierError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              } else if (state is SupplierOperationSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            builder: (context, state) {
              if (state is SupplierLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is SuppliersLoaded) {
                return _buildSuppliersList(state.suppliers);
              } else if (state is SupplierSearchResults) {
                return _buildSuppliersList(
                  state.suppliers,
                  isSearchResult: true,
                  searchTerm: state.searchTerm,
                );
              } else if (state is TopSuppliersLoaded) {
                return _buildSuppliersList(
                  state.suppliers,
                  isTopSuppliers: true,
                );
              } else if (state is RecentSuppliersLoaded) {
                return _buildSuppliersList(
                  state.suppliers,
                  isRecentSuppliers: true,
                );
              } else if (state is SupplierError) {
                return Center(
                  child: Text(
                    'Erreur: ${state.message}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }
              
              return const Center(child: Text('Aucun fournisseur à afficher'));
            },
          ),
        ),
      ],
    );

    if (widget.isEmbedded) {
      return screenContent; // Return only the content for embedding
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fournisseurs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
          ),
        ],
      ),
      body: screenContent, // Use the defined screenContent
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddSupplier(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Construit la liste des fournisseurs
  Widget _buildSuppliersList(
    List<Supplier> suppliers, {
    bool isSearchResult = false,
    bool isTopSuppliers = false,
    bool isRecentSuppliers = false,
    String searchTerm = '',
  }) {
    if (suppliers.isEmpty) {
      if (isSearchResult) {
        return Center(
          child: Text('Aucun résultat pour "$searchTerm"'),
        );
      }
      return const Center(
        child: Text('Aucun fournisseur disponible'),
      );
    }
    
    // Titre spécial pour les listes filtrées
    Widget? header;
    if (isTopSuppliers) {
      header = const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Principaux fournisseurs par achats',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else if (isRecentSuppliers) {
      header = const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Fournisseurs récemment ajoutés',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else if (isSearchResult) {
      header = Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Résultats pour "$searchTerm"',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (header != null) header,
        Expanded(
          child: ListView.builder(
            itemCount: suppliers.length,
            itemBuilder: (context, index) {
              final supplier = suppliers[index];
              return _buildSupplierListItem(supplier);
            },
          ),
        ),
      ],
    );
  }

  /// Construit un élément de la liste des fournisseurs
  Widget _buildSupplierListItem(Supplier supplier) {
    final lastPurchaseText = supplier.lastPurchaseDate != null
        ? 'Dernier achat: ${_formatDate(supplier.lastPurchaseDate!)}'
        : 'Pas d\\\'achat récent';
    
    final categoryColor = _getCategoryColor(context, supplier.category); // Pass context

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: categoryColor, // Use theme color
          child: Text(
            supplier.name.isNotEmpty ? supplier.name[0].toUpperCase() : '?',
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer), // Ensure text is visible
          ),
        ),
        title: Text(supplier.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(supplier.contactPerson.isNotEmpty 
              ? 'Contact: ${supplier.contactPerson}'
              : supplier.phoneNumber),
            Text(
              'Total des achats: ${_formatCurrency(supplier.totalPurchases)} FC',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(lastPurchaseText),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'details') {
              _navigateToSupplierDetails(context, supplier);
            } else if (value == 'edit') {
              _navigateToEditSupplier(context, supplier);
            } else if (value == 'delete') {
              _showDeleteConfirmation(context, supplier);
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'details',
              child: Text('Voir détails'),
            ),
            const PopupMenuItem<String>(
              value: 'edit',
              child: Text('Modifier'),
            ),
            const PopupMenuItem<String>(
              value: 'delete',
              child: Text('Supprimer'),
            ),
          ],
        ),
        onTap: () => _navigateToSupplierDetails(context, supplier),
      ),
    );
  }

  /// Affiche les options de filtrage
  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.list),
                title: const Text('Tous les fournisseurs'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<SupplierBloc>().add(const LoadSuppliers());
                },
              ),
              ListTile(
                leading: const Icon(Icons.star),
                title: const Text('Principaux fournisseurs'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<SupplierBloc>().add(const LoadTopSuppliers());
                },
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Fournisseurs récents'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<SupplierBloc>().add(const LoadRecentSuppliers());
                },
              ),
              ListTile(
                leading: const Icon(Icons.category),
                title: const Text('Par catégorie'),
                onTap: () {
                  Navigator.pop(context);
                  _showCategoriesFilter();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Affiche les options de filtrage par catégorie
  void _showCategoriesFilter() {
    showDialog(
      context: context,
      builder: (dialogContext) { // Changed context to dialogContext to avoid conflict
        return AlertDialog(
          title: const Text('Filtrer par catégorie'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: SupplierCategory.values.map((category) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getCategoryColor(context, category), // Pass context
                  radius: 12,
                  child: Text( // Adding a contrasting text for better visibility if needed
                    _getCategoryName(category)[0],
                    style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onPrimaryContainer),
                  ),
                ),
                title: Text(_getCategoryName(category)),
                onTap: () {
                  Navigator.pop(dialogContext); // Use dialogContext
                  // Ici, on pourrait implémenter un filtre par catégorie
                  // Pour l'instant, nous revenons simplement à tous les fournisseurs
                  context.read<SupplierBloc>().add(const LoadSuppliers());
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext), // Use dialogContext
              child: const Text('Annuler'),
            ),
          ],
        );
      },
    );
  }

  /// Affiche une boîte de dialogue de confirmation de suppression
  void _showDeleteConfirmation(BuildContext context, Supplier supplier) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer le fournisseur'),
          content: Text(
            'Êtes-vous sûr de vouloir supprimer ${supplier.name} ? Cette action est irréversible.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<SupplierBloc>().add(DeleteSupplier(supplier.id));
              },
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error), // Use theme color
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  /// Navigation vers l'écran de détails d'un fournisseur
  void _navigateToSupplierDetails(BuildContext context, Supplier supplier) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SupplierDetailsScreen(supplier: supplier),
      ),
    );
  }

  /// Navigation vers l'écran d'ajout d'un fournisseur
  void _navigateToAddSupplier(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddSupplierScreen(),
      ),
    );
  }

  /// Navigation vers l'écran de modification d'un fournisseur
  void _navigateToEditSupplier(BuildContext context, Supplier supplier) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddSupplierScreen(supplier: supplier),
      ),
    );
  }
  /// Retourne la couleur associée à une catégorie de fournisseur
  Color _getCategoryColor(BuildContext context, SupplierCategory category) { // Added BuildContext
    switch (category) {
      case SupplierCategory.strategic:
        return Theme.of(context).colorScheme.primary;
      case SupplierCategory.regular:
        return Theme.of(context).colorScheme.secondary;
      case SupplierCategory.newSupplier:
        return Theme.of(context).colorScheme.tertiary;
      case SupplierCategory.occasional:
        return Theme.of(context).colorScheme.surfaceVariant;
      case SupplierCategory.international:
        return Theme.of(context).colorScheme.primaryContainer;
    }
  }
  /// Retourne le nom d\'une catégorie de fournisseur
  String _getCategoryName(SupplierCategory category) {
    switch (category) {
      case SupplierCategory.strategic:
        return 'Stratégique';
      case SupplierCategory.regular:
        return 'Régulier';
      case SupplierCategory.newSupplier:
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
