import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/customer_bloc.dart';
import '../bloc/customer_event.dart';
import '../bloc/customer_state.dart';
import '../models/customer.dart';
import 'customer_details_screen.dart';
import 'add_customer_screen.dart';

/// Écran principal de gestion des clients
class CustomersScreen extends StatefulWidget {
  final bool isEmbedded;
  const CustomersScreen({super.key, this.isEmbedded = false});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    // Charge la liste des clients au démarrage
    context.read<CustomerBloc>().add(const LoadCustomers());
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
              hintText: 'Rechercher un client...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  context.read<CustomerBloc>().add(const LoadCustomers());
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            onChanged: (value) {
              if (value.length > 2) {
                context.read<CustomerBloc>().add(SearchCustomers(value));
              } else if (value.isEmpty) {
                context.read<CustomerBloc>().add(const LoadCustomers());
              }
            },
          ),
        ),
        
        // Liste des clients
        Expanded(
          child: BlocConsumer<CustomerBloc, CustomerState>(
            listener: (context, state) {
              if (state is CustomerError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              } else if (state is CustomerOperationSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            builder: (context, state) {
              if (state is CustomerLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is CustomersLoaded) {
                return _buildCustomersList(state.customers);
              } else if (state is CustomerSearchResults) {
                return _buildCustomersList(
                  state.customers,
                  isSearchResult: true,
                  searchTerm: state.searchTerm,
                );
              } else if (state is TopCustomersLoaded) {
                return _buildCustomersList(
                  state.customers,
                  isTopCustomers: true,
                );
              } else if (state is RecentCustomersLoaded) {
                return _buildCustomersList(
                  state.customers,
                  isRecentCustomers: true,
                );
              } else if (state is CustomerError) {
                return Center(
                  child: Text(
                    'Erreur: ${state.message}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }
              
              return const Center(child: Text('Aucun client à afficher'));
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
        title: const Text('Clients'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
          ),
        ],
      ),
      body: screenContent, // Use the defined screenContent
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddCustomer(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Construit la liste des clients
  Widget _buildCustomersList(
    List<Customer> customers, {
    bool isSearchResult = false,
    bool isTopCustomers = false,
    bool isRecentCustomers = false,
    String searchTerm = '',
  }) {
    if (customers.isEmpty) {
      if (isSearchResult) {
        return Center(
          child: Text('Aucun résultat pour "$searchTerm"'),
        );
      }
      return const Center(
        child: Text('Aucun client disponible'),
      );
    }
    
    // Titre spécial pour les listes filtrées
    Widget? header;
    if (isTopCustomers) {
      header = const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Meilleurs clients par achats',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else if (isRecentCustomers) {
      header = const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Clients récemment ajoutés',
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
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final customer = customers[index];
              return _buildCustomerListItem(customer);
            },
          ),
        ),
      ],
    );
  }

  /// Construit un élément de la liste des clients
  Widget _buildCustomerListItem(Customer customer) {
    final lastPurchaseText = customer.lastPurchaseDate != null
        ? 'Dernier achat: ${_formatDate(customer.lastPurchaseDate!)}'
        : 'Pas d\'achat récent';
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getCategoryColor(customer.category),
          child: Text(
            customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(customer.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(customer.phoneNumber),
            Text(
              'Total des achats: ${_formatCurrency(customer.totalPurchases)} FC',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(lastPurchaseText),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'details') {
              _navigateToCustomerDetails(context, customer);
            } else if (value == 'edit') {
              _navigateToEditCustomer(context, customer);
            } else if (value == 'delete') {
              _showDeleteConfirmation(context, customer);
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
        onTap: () => _navigateToCustomerDetails(context, customer),
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
                title: const Text('Tous les clients'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<CustomerBloc>().add(const LoadCustomers());
                },
              ),
              ListTile(
                leading: const Icon(Icons.star),
                title: const Text('Meilleurs clients'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<CustomerBloc>().add(const LoadTopCustomers());
                },
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Clients récents'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<CustomerBloc>().add(const LoadRecentCustomers());
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
      builder: (context) {
        return AlertDialog(
          title: const Text('Filtrer par catégorie'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: CustomerCategory.values.map((category) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getCategoryColor(category),
                  radius: 12,
                ),
                title: Text(_getCategoryName(category)),
                onTap: () {
                  Navigator.pop(context);
                  // Ici, on pourrait implémenter un filtre par catégorie
                  // Pour l'instant, nous revenons simplement à tous les clients
                  context.read<CustomerBloc>().add(const LoadCustomers());
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
          ],
        );
      },
    );
  }

  /// Affiche une boîte de dialogue de confirmation de suppression
  void _showDeleteConfirmation(BuildContext context, Customer customer) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer le client'),
          content: Text(
            'Êtes-vous sûr de vouloir supprimer ${customer.name} ? Cette action est irréversible.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<CustomerBloc>().add(DeleteCustomer(customer.id));
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  /// Navigation vers l'écran de détails d'un client
  void _navigateToCustomerDetails(BuildContext context, Customer customer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerDetailsScreen(customer: customer),
      ),
    );
  }

  /// Navigation vers l'écran d'ajout d'un client
  void _navigateToAddCustomer(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddCustomerScreen(),
      ),
    );
  }

  /// Navigation vers l'écran de modification d'un client
  void _navigateToEditCustomer(BuildContext context, Customer customer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddCustomerScreen(customer: customer),
      ),
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
        return Colors.orange;
      case CustomerCategory.business:
        return Colors.indigo;
      default:
        return Colors.grey;
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
        return 'Occasionnel';
      case CustomerCategory.business:
        return 'Entreprise';
      default:
        return 'Inconnu';
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
