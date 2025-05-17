import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../constants/colors.dart';
import '../../../constants/spacing.dart';
import '../../../constants/typography.dart';
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
          
          // Contenu principal de l'écran
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
                                padding: const EdgeInsets.all(WanzoSpacing.md),
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
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: WanzoColors.error,
                        ),
                        const SizedBox(height: WanzoSpacing.md),
                        Text(
                          'Erreur: ${state.message}',
                          style: TextStyle(
                            fontSize: 18,
                            color: WanzoColors.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: WanzoSpacing.lg),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.refresh),
                          label: const Text('Réessayer'),
                          onPressed: () => context.read<SalesBloc>().add(const LoadSales()),
                        ),
                      ],
                    ),
                  );
                } else {
                  return const Center(child: Text('État inconnu'));
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddSale(context),
        backgroundColor: WanzoColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
  
  /// Affiche le dialogue de filtre
  void _showFilterDialog(BuildContext context) {
    // Date actuelle
    final now = DateTime.now();
    // Début du mois
    final startOfMonth = DateTime(now.year, now.month, 1);
    // Formats de date
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    // Dates sélectionnées
    DateTime startDate = startOfMonth;
    DateTime endDate = now;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Filtrer les ventes'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Période', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: WanzoSpacing.sm),
                  
                  // Sélection de date de début
                  ListTile(
                    title: const Text('Du'),
                    subtitle: Text(dateFormat.format(startDate)),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: startDate,
                        firstDate: DateTime(2020),
                        lastDate: now,
                      );
                      if (picked != null) {
                        setState(() {
                          startDate = picked;
                        });
                      }
                    },
                    leading: const Icon(Icons.calendar_today),
                  ),
                  
                  // Sélection de date de fin
                  ListTile(
                    title: const Text('Au'),
                    subtitle: Text(dateFormat.format(endDate)),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: endDate,
                        firstDate: startDate,
                        lastDate: now,
                      );
                      if (picked != null) {
                        setState(() {
                          endDate = picked;
                        });
                      }
                    },
                    leading: const Icon(Icons.calendar_today),
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
                  child: const Text('Filtrer'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  /// Construire le sommaire des ventes
  Widget _buildSalesSummary(SalesLoaded state) {
    final currencyFormat = NumberFormat.currency(
      symbol: 'FC',
      decimalDigits: 0,
    );
    
    return Card(
      margin: const EdgeInsets.all(WanzoSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(WanzoSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currencyFormat.format(state.totalAmount),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: WanzoTypography.fontWeightBold,
                      color: WanzoColors.primary,
                    ),
                  ),
                  const Text(
                    'Montant total',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${state.sales.length}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: WanzoTypography.fontWeightBold,
                    ),
                  ),
                  const Text(
                    'Ventes',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${state.sales.where((s) => s.status == SaleStatus.pending).length}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: WanzoTypography.fontWeightBold,
                      color: WanzoColors.warning,
                    ),
                  ),
                  const Text(
                    'En attente',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Construire un élément de vente
  Widget _buildSaleItem(BuildContext context, Sale sale) {
    final currencyFormat = NumberFormat.currency(
      symbol: 'FC',
      decimalDigits: 0,
    );
    
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    
    return Card(
      margin: const EdgeInsets.only(bottom: WanzoSpacing.md),
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
                  Expanded(
                    child: Text(
                      'Vente #${sale.id.substring(0, 8)}',
                      style: const TextStyle(
                        fontWeight: WanzoTypography.fontWeightBold,
                        fontSize: WanzoTypography.fontSizeMd,
                      ),
                    ),
                  ),
                  _buildStatusChip(sale.status),
                ],
              ),
              const SizedBox(height: WanzoSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Client: ${sale.customerName.isNotEmpty ? sale.customerName : 'Client occasionnel'}',
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    dateFormat.format(sale.date),
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: WanzoTypography.fontSizeSm,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: WanzoSpacing.sm),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${sale.items.length} article${sale.items.length > 1 ? 's' : ''}',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: WanzoTypography.fontSizeSm,
                    ),
                  ),
                  Text(
                    currencyFormat.format(sale.totalAmount),
                    style: const TextStyle(
                      fontWeight: WanzoTypography.fontWeightBold,
                      fontSize: WanzoTypography.fontSizeLg,
                      color: WanzoColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Construire une puce d'état
  Widget _buildStatusChip(SaleStatus status) {
    Color color;
    String label;
    
    switch (status) {
      case SaleStatus.pending:
        color = WanzoColors.warning;
        label = 'En attente';
        break;
      case SaleStatus.completed:
        color = WanzoColors.success;
        label = 'Terminée';
        break;
      case SaleStatus.cancelled:
        color = WanzoColors.error;
        label = 'Annulée';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: WanzoSpacing.sm,
        vertical: WanzoSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: WanzoTypography.fontWeightMedium,
          fontSize: WanzoTypography.fontSizeSm,
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
    context.push('/sales/${sale.id}');
  }
}
