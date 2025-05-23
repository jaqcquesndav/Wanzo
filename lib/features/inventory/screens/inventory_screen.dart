import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:io'; // Added for File support
import '../../../constants/spacing.dart';
import '../../../constants/typography.dart';
import '../../../core/shared_widgets/wanzo_scaffold.dart';
import '../bloc/inventory_bloc.dart';
import '../bloc/inventory_event.dart';
import '../bloc/inventory_state.dart';
import '../models/product.dart';
import '../models/stock_transaction.dart'; // Added import

/// Écran principal de gestion de l'inventaire
class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Chargement initial des produits
    context.read<InventoryBloc>().add(const LoadProducts());
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WanzoScaffold(
      currentIndex: 2, // Stock a l'index 2
      title: 'Gestion des produits',
      appBarActions: [
        // Bouton de recherche
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => _showSearchDialog(context),
        ),
        // Filtrer par catégorie
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () => _showFilterDialog(context),
        ),
      ],
      body: Column(
        children: [
          // TabBar doit être placé dans le body pour le style
          Material(
            color: Theme.of(context).primaryColor,
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Tous les produits'),
                Tab(text: 'Stock faible'),
                Tab(text: 'Transactions'),
              ],
              onTap: (index) {
                if (index == 0) {
                  context.read<InventoryBloc>().add(const LoadProducts());
                } else if (index == 1) {
                  context.read<InventoryBloc>().add(const LoadLowStockProducts());
                } else if (index == 2) {
                  context.read<InventoryBloc>().add(const LoadAllTransactions());
                }
              },
            ),
          ),
          // TabBarView remplit le reste de l'espace
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Onglet "Tous les produits"
                BlocBuilder<InventoryBloc, InventoryState>(
                  builder: (context, state) {
                    if (state is InventoryLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is ProductsLoaded) {
                      return _buildProductsList(context, state);
                    } else if (state is InventoryError) {
                      return _buildErrorWidget(context, state.message);
                    } else {
                      return const Center(child: Text('Aucun produit disponible'));
                    }
                  },
                ),
                // Onglet "Stock faible"
                BlocBuilder<InventoryBloc, InventoryState>(
                  builder: (context, state) {
                    if (state is InventoryLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is ProductsLoaded) {
                      return _buildProductsList(context, state, lowStockOnly: true);
                    } else if (state is InventoryError) {
                      return _buildErrorWidget(context, state.message);
                    } else {
                      return const Center(child: Text('Aucun produit à stock faible'));
                    }
                  },
                ),
                // Onglet "Transactions"
                BlocBuilder<InventoryBloc, InventoryState>(
                  builder: (context, state) {
                    if (state is InventoryLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is TransactionsLoaded) {
                      return _buildTransactionsList(context, state.transactions);
                    } else if (state is InventoryError) {
                      return _buildErrorWidget(context, state.message);
                    } else {
                      return const Center(child: Text('Aucune transaction disponible'));
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _tabController.index != 2
          ? FloatingActionButton(
              onPressed: () => context.push('/inventory/add'),
              backgroundColor: Theme.of(context).colorScheme.primary, // Use theme color
              child: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary), // Use theme color for icon
            )
          : null,
    );
  }

  /// Afficher la boîte de dialogue de recherche
  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rechercher un produit'),
          content: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Nom ou référence du produit',
              prefixIcon: Icon(Icons.search),
            ),
            onSubmitted: (value) {
              Navigator.pop(context);
              if (value.isNotEmpty) {
                context.read<InventoryBloc>().add(SearchProducts(value));
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                if (_searchController.text.isNotEmpty) {
                  context.read<InventoryBloc>().add(SearchProducts(_searchController.text));
                }
              },
              child: const Text('Rechercher'),
            ),
          ],
        );
      },
    );
  }
  
  /// Afficher la boîte de dialogue de filtre
  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filtrer par catégorie'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: BlocBuilder<InventoryBloc, InventoryState>(
              builder: (context, state) {
                final categories = state is ProductsLoaded
                    ? state.products
                        .map((p) => p.category)
                        .toSet()
                        .toList()
                    : <ProductCategory>[];
                
                if (categories.isEmpty) {
                  return const Center(child: Text('Aucune catégorie disponible'));
                }
                
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return ListTile(
                      title: Text(category.toString().split('.').last),
                      onTap: () {
                        Navigator.pop(context);
                        context.read<InventoryBloc>().add(LoadProductsByCategory(category));
                      },
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<InventoryBloc>().add(const LoadProducts()); // Réinitialiser le filtre
              },
              child: const Text('Tout afficher'),
            ),
          ],
        );
      },
    );
  }
  
  /// Construire la liste des produits
  Widget _buildProductsList(BuildContext context, ProductsLoaded state, {bool lowStockOnly = false}) {
    final products = lowStockOnly
        ? state.products.where((p) => p.stockQuantity <= p.alertThreshold).toList()
        : state.products;
    
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              lowStockOnly ? Icons.check_circle : Icons.inventory_2,
              size: 64,
              color: lowStockOnly ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.onSurface.withAlpha((0.4 * 255).round()), // Use theme color
            ),
            const SizedBox(height: 16),
            Text(
              lowStockOnly
                  ? 'Aucun produit à stock faible'
                  : 'Aucun produit dans l\'inventaire',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (!lowStockOnly)
              ElevatedButton.icon(
                onPressed: () => context.push('/inventory/add'),
                icon: const Icon(Icons.add),
                label: const Text('Ajouter un produit'),
              ),
          ],
        ),
      );
    }
    
    final currencyFormat = NumberFormat.currency(
      symbol: 'FC',
      decimalDigits: 0,
    );
    
    return ListView.separated(
      padding: const EdgeInsets.all(WanzoSpacing.md),
      itemCount: products.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final product = products[index];
        final isLowStock = product.stockQuantity <= product.alertThreshold;
        
        Widget? leadingWidget;
        if (product.imagePath != null && product.imagePath!.isNotEmpty) {
          leadingWidget = SizedBox(
            width: 50, // Define a fixed width for the image
            height: 50, // Define a fixed height for the image
            child: ClipRRect(
              borderRadius: BorderRadius.circular(WanzoSpacing.sm), // Optional: for rounded corners
              child: Image.file(
                File(product.imagePath!),
                fit: BoxFit.cover, // Ensure the image covers the space
                errorBuilder: (context, error, stackTrace) {
                  // Fallback for image loading errors
                  return CircleAvatar(
                    radius: 25,
                    backgroundColor: Theme.of(context).colorScheme.surfaceVariant, // Use theme color
                    child: Text(
                      product.name.isNotEmpty ? product.name[0].toUpperCase() : 'P',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold), // Use theme color
                    ),
                  );
                },
              ),
            ),
          );
        } else {
          // Fallback if no image path is available
          leadingWidget = CircleAvatar(
            radius: 25,
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant, // Use theme color
            child: Text(
              product.name.isNotEmpty ? product.name[0].toUpperCase() : 'P',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold), // Use theme color
            ),
          );
        }
        
        return ListTile(
          leading: leadingWidget, // Added leading widget for the image
          contentPadding: const EdgeInsets.symmetric(
            vertical: WanzoSpacing.sm,
            horizontal: WanzoSpacing.md,
          ),
          title: Text(
            product.name,
            style: const TextStyle(
              fontWeight: WanzoTypography.fontWeightMedium,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: WanzoSpacing.xs),
              Text('Prix: ${currencyFormat.format(product.sellingPrice)}'),
              Text(
                'Stock: ${product.stockQuantity} ${product.unit.toString().split('.').last}',
                style: TextStyle(
                  color: isLowStock ? Theme.of(context).colorScheme.error : null, // Use theme color
                  fontWeight: isLowStock ? WanzoTypography.fontWeightBold : null,
                ),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => context.push('/inventory/edit/${product.id}'),
              ),
              IconButton(
                icon: const Icon(Icons.add_box),
                onPressed: () => _showAddStockDialog(context, product),
              ),
            ],
          ),
          onTap: () => context.push('/inventory/${product.id}'), // Added missing parenthesis
        );
      },
    );
  }
  
  /// Construire la liste des transactions
  Widget _buildTransactionsList(BuildContext context, List<StockTransaction> transactions) {
    // Temporairement, retourner un widget vide car StockTransaction n'est pas encore implémenté
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withAlpha((0.4 * 255).round()), // Use theme color
          ),
          const SizedBox(height: 16),
          const Text(
            'Gestion des transactions à venir',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
  
  /// Construire le widget d'erreur
  Widget _buildErrorWidget(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error, // Use theme color
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Relancer le chargement en fonction de l'onglet actif
              final currentIndex = _tabController.index;
              if (currentIndex == 0) {
                context.read<InventoryBloc>().add(const LoadProducts());
              } else if (currentIndex == 1) {
                context.read<InventoryBloc>().add(const LoadLowStockProducts());
              } else if (currentIndex == 2) {
                context.read<InventoryBloc>().add(const LoadAllTransactions());
              }
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.errorContainer, // Use theme color
              foregroundColor: Theme.of(context).colorScheme.onErrorContainer, // Use theme color
            ),
          ),
        ],
      ),
    );
  }

  /// Afficher la boîte de dialogue pour ajouter du stock
  void _showAddStockDialog(BuildContext context, Product product) {
    final quantityController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Ajouter du stock pour ${product.name}'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Stock actuel: ${product.stockQuantity} ${product.unit.toString().split('.').last}'),
                TextFormField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Quantité à ajouter',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer une quantité';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Veuillez entrer un nombre valide';
                    }
                    if (double.parse(value) <= 0) {
                      return 'La quantité doit être positive';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final quantity = double.parse(quantityController.text);
                  final transaction = StockTransaction(
                    id: 'temp_id_${DateTime.now().millisecondsSinceEpoch}', // Generate a temporary ID or handle ID generation in BLoC/Repository
                    productId: product.id,
                    type: StockTransactionType.adjustment, // Corrected enum constant
                    quantity: quantity,
                    date: DateTime.now(),
                    // Optional: Add other fields like reason, relatedDocumentId if needed
                  );
                  context.read<InventoryBloc>().add(AddStockTransaction(transaction));
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }
}
