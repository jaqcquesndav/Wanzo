import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../constants/colors.dart';
import '../../../constants/spacing.dart';
import '../../../core/shared_widgets/wanzo_scaffold.dart';
import '../bloc/sales_bloc.dart';
import '../models/sale.dart';

/// Écran principal de gestion des ventes
class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Chargement initial des ventes
    context.read<SalesBloc>().add(const LoadSales());
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WanzoScaffold(
      currentIndex: 1, // Ventes a l'index 1
      title: 'Gestion des ventes',
      appBarActions: [
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () => _showFilterDialog(context),
        ),
      ],
      body: Column(
        children: [
          // TabBar pour les filtres de vente
          Material(
            color: Theme.of(context).primaryColor,
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Toutes'),
                Tab(text: 'En attente'),
                Tab(text: 'Terminées'),
              ],
              onTap: (index) {
                if (index == 0) {
                  context.read<SalesBloc>().add(const LoadSales());
                } else if (index == 1) {
                  context.read<SalesBloc>().add(const LoadSalesByStatus(SaleStatus.pending));
                } else if (index == 2) {
                  context.read<SalesBloc>().add(const LoadSalesByStatus(SaleStatus.completed));
                }
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<SalesBloc, SalesState>(
              builder: (context, state) {
                if (state is SalesLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is SalesLoaded) {
                  return Column(
                    children: [
                      // Sommaire des ventes
                      _buildSalesSummary(state),
                      
                      // Liste des ventes
                      Expanded(
                        child: state.sales.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.shopping_cart,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: WanzoSpacing.md),
                                    const Text(
                                      'Aucune vente trouvée',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    const SizedBox(height: WanzoSpacing.lg),
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.add),
                                      label: const Text('Ajouter une vente'),
                                      onPressed: () => _navigateToAddSale(context),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: state.sales.length,
                                itemBuilder: (context, index) {
                                  final sale = state.sales[index];
                                  return _buildSaleItem(context, sale);
                                },
                              ),
                      ),
                    ],
                  );
                } else if (state is SalesError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: WanzoColors.error,
                          size: 60,
                        ),
                        const SizedBox(height: WanzoSpacing.md),
                        Text(
                          'Erreur: ${state.message}',
                          style: const TextStyle(color: WanzoColors.error),
                        ),
                        const SizedBox(height: WanzoSpacing.lg),
                        ElevatedButton(
                          onPressed: () => context.read<SalesBloc>().add(const LoadSales()),
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  );
                }
                
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddSale(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Afficher le dialogue de filtre
  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        DateTime startDate = DateTime.now().subtract(const Duration(days: 30));
        DateTime endDate = DateTime.now();
        
        return AlertDialog(
          title: const Text('Filtrer les ventes'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Champ de date de début
              ListTile(
                title: const Text('Date de début'),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(startDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: startDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    startDate = date;
                  }
                },
              ),
              
              // Champ de date de fin
              ListTile(
                title: const Text('Date de fin'),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(endDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: endDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    endDate = date;
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<SalesBloc>().add(
                  LoadSalesByDateRange(
                    startDate: startDate,
                    endDate: endDate,
                  ),
                );
              },
              child: const Text('Appliquer'),
            ),
          ],
        );
      },
    );
  }

  /// Construire le résumé des ventes
  Widget _buildSalesSummary(SalesLoaded state) {
    final currencyFormat = NumberFormat.currency(
      symbol: 'FC',
      decimalDigits: 0,
    );
    
    return Container(
      padding: const EdgeInsets.all(WanzoSpacing.md),
      color: Theme.of(context).cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total des ventes',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    currencyFormat.format(state.totalAmount),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Nombre de ventes',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    state.sales.length.toString(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Construire un élément de la liste des ventes
  Widget _buildSaleItem(BuildContext context, Sale sale) {
    final currencyFormat = NumberFormat.currency(
      symbol: 'FC',
      decimalDigits: 0,
    );
    
    Color statusColor;
    String statusText;
    
    // Déterminer la couleur et le texte en fonction du statut
    switch (sale.status) {
      case SaleStatus.pending:
        statusColor = Colors.orange;
        statusText = 'En attente';
        break;
      case SaleStatus.completed:
        statusColor = Colors.green;
        statusText = 'Terminée';
        break;
      case SaleStatus.cancelled:
        statusColor = Colors.red;
        statusText = 'Annulée';
        break;
    }
    
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: WanzoSpacing.md,
        vertical: WanzoSpacing.sm,
      ),
      child: InkWell(
        onTap: () => _navigateToSaleDetails(context, sale),
        child: Padding(
          padding: const EdgeInsets.all(WanzoSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Numéro de la vente et date
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vente #${sale.id.substring(0, 8)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: WanzoSpacing.xs),
                      Text(
                        DateFormat('dd/MM/yyyy HH:mm').format(sale.date),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  
                  // Badge de statut
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: WanzoSpacing.sm,
                      vertical: WanzoSpacing.xs / 2,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(26), // Changed from withOpacity(0.1)
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              const Divider(height: WanzoSpacing.lg),
              
              // Informations du client
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: WanzoSpacing.xs),
                  Text(
                    sale.customerName,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              
              const SizedBox(height: WanzoSpacing.sm),
              
              // Nombre d'articles
              Row(
                children: [
                  const Icon(Icons.shopping_bag, size: 16, color: Colors.grey),
                  const SizedBox(width: WanzoSpacing.xs),
                  Text(
                    '${sale.items.length} article${sale.items.length > 1 ? 's' : ''}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              
              const SizedBox(height: WanzoSpacing.sm),
              
              // Montant total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total:',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    currencyFormat.format(sale.totalAmount),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              
              // Statut de paiement
              if (!sale.isFullyPaid) ...[
                const SizedBox(height: WanzoSpacing.xs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Reste à payer:',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.red,
                      ),
                    ),
                    Text(
                      currencyFormat.format(sale.remainingAmount),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Naviguer vers l'écran d'ajout de vente
  void _navigateToAddSale(BuildContext context) {
    context.push('/sales/add');
  }

  /// Naviguer vers l'écran de détails de vente
  void _navigateToSaleDetails(BuildContext context, Sale sale) {
    context.push('/sales/${sale.id}', extra: sale);
  }
}
