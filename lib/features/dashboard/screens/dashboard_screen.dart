import 'dart:io'; // Import for File
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // Pour le formatage des dates
import 'package:fl_chart/fl_chart.dart'; // Added import for charts
import '../../../constants/constants.dart';
import '../../../core/shared_widgets/wanzo_scaffold.dart';
import '../../inventory/models/product.dart'; // Import Product model
import '../../inventory/repositories/inventory_repository.dart'; // Import InventoryRepository
import '../../sales/bloc/sales_bloc.dart'; // Import SalesBloc
import '../bloc/operation_journal_bloc.dart';
import '../models/operation_journal_entry.dart';

/// Écran principal du tableau de bord
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late OperationJournalBloc _operationJournalBloc;
  late SalesBloc _salesBloc;
  late InventoryRepository _inventoryRepository;

  @override
  void initState() {
    super.initState();
    _operationJournalBloc = BlocProvider.of<OperationJournalBloc>(context);
    _salesBloc = BlocProvider.of<SalesBloc>(context);
    _inventoryRepository = RepositoryProvider.of<InventoryRepository>(context);

    final now = DateTime.now();
    _operationJournalBloc.add(LoadOperations(
        startDate: DateTime(now.year, now.month, 1),
        endDate: DateTime(now.year, now.month + 1, 0, 23, 59, 59)));

    // Load sales for the last 7 days for the "Dernières Ventes" card
    _salesBloc.add(LoadSalesByDateRange(
        startDate: now.subtract(const Duration(days: 7)),
        endDate: now));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WanzoScaffold(
      currentIndex: 0, // Dashboard = index 0
      title: 'Tableau de bord',
      body: _buildDashboardContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Afficher un menu d'actions rapides
          _showQuickActionsMenu(context);
        },
        backgroundColor: WanzoColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Afficher le menu d'actions rapides
  void _showQuickActionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(WanzoSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Actions rapides',
                  style: TextStyle(
                    fontSize: WanzoTypography.fontSizeLg,
                    fontWeight: WanzoTypography.fontWeightBold,
                  ),
                ),
                const SizedBox(height: WanzoSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildQuickAction(
                      context,
                      icon: Icons.shopping_cart_checkout,
                      label: 'Facturation', // Changed from 'Nouvelle vente'
                      color: WanzoColors.primary,
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/sales/add');
                      },
                    ),
                    _buildQuickAction(
                      context,
                      icon: Icons.attach_money,
                      label: 'Dépense',
                      color: WanzoColors.warning,
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/expenses/add');
                      },
                    ),
                    _buildQuickAction(
                      context,
                      icon: Icons.add_shopping_cart,
                      label: 'Nouveau produit',
                      color: WanzoColors.success,
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/inventory/add');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: WanzoSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildQuickAction(
                      context,
                      icon: Icons.person_add,
                      label: 'Nouveau client',
                      color: WanzoColors.info,
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/customers/add');
                      },
                    ),
                    _buildQuickAction(
                      context,
                      icon: Icons.business,
                      label: 'Nouveau fournisseur',
                      color: Colors.purple,
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/suppliers/add');
                      },
                    ),
                    _buildQuickAction(
                      context,
                      icon: Icons.account_balance,
                      label: 'Financement',
                      color: Colors.orange,
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/financing/add');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Construire une action rapide
  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(WanzoBorderRadius.lg),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(WanzoSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(WanzoSpacing.md),
              decoration: BoxDecoration(
                color: color.withAlpha(26), // Fixed: Changed from withOpacity(0.1)
                borderRadius: BorderRadius.circular(WanzoBorderRadius.md),
              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(height: WanzoSpacing.sm),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontWeight: WanzoTypography.fontWeightMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construit le contenu du tableau de bord
  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(WanzoSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo Wanzo en haut du tableau de bord
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: WanzoSpacing.lg),
              child: Image.asset(
                'assets/images/logo_with_text.png',
                height: 60,
                errorBuilder: (context, error, stackTrace) {
                  return const Text('Wanzo',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: WanzoColors.primary
                    ),
                  );
                },
              ),
            ),
          ),

          // En-tête avec les statistiques principales
          _buildHeaderStats(),
          const SizedBox(height: WanzoSpacing.lg),

          // Graphique des ventes récentes
          _buildSalesChart(),
          const SizedBox(height: WanzoSpacing.lg),

          // Section pour les dernières ventes et le journal des opérations
          _buildSalesOperationsCard(),
        ],
      ),
    );
  }

  /// Construit la section responsive pour les ventes récentes et le journal des opérations
  Widget _buildSalesOperationsCard() {
    return _buildRecentSalesAndJournal();
  }

  /// Construit les statistiques d'en-tête
  Widget _buildHeaderStats() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: WanzoSpacing.md,
      mainAxisSpacing: WanzoSpacing.md,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          title: 'Ventes du jour',
          value: '150.000 FC',
          icon: Icons.insert_chart,
          color: WanzoColors.primary,
          increase: '+8% vs hier',
        ),
        _buildStatCard(
          title: 'Clients servis',
          value: '24',
          icon: Icons.people,
          color: WanzoColors.info,
          increase: '+3 vs hier',
        ),
        _buildStatCard(
          title: 'À recevoir',
          value: '450.000 FC',
          icon: Icons.account_balance_wallet,
          color: WanzoColors.success,
        ),
        _buildStatCard(
          title: 'Transactions',
          value: 'N/A',
          icon: Icons.receipt_long,
          color: Colors.teal,
        ),
      ],
    );
  }

  /// Construit une carte de statistique
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? increase,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(WanzoBorderRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(WanzoSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: WanzoTypography.fontSizeSm,
                    color: Colors.grey,
                  ),
                ),
                Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: WanzoTypography.fontSizeLg,
                fontWeight: WanzoTypography.fontWeightBold,
              ),
            ),
            if (increase != null)
              Text(
                increase,
                style: TextStyle(
                  fontSize: WanzoTypography.fontSizeXs,
                  color: increase.contains('+') ? WanzoColors.success : WanzoColors.error,
                  fontWeight: WanzoTypography.fontWeightMedium,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Construit un graphique des ventes récentes
  Widget _buildSalesChart() {
    // Mock data for the last 7 days
    final List<FlSpot> spots = [
      const FlSpot(0, 3), // Day 1
      const FlSpot(1, 5), // Day 2
      const FlSpot(2, 4), // Day 3
      const FlSpot(3, 7), // Day 4
      const FlSpot(4, 6), // Day 5
      const FlSpot(5, 8), // Day 6
      const FlSpot(6, 7), // Day 7
    ];

    if (spots.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WanzoBorderRadius.md),
        ),
        child: Padding(
          padding: const EdgeInsets.all(WanzoSpacing.md),
          child: SizedBox(
            height: 200, // Consistent height with the chart
            child: Center(
              child: Text(
                'Aucune donnée de vente disponible pour le graphique.',
                style: TextStyle(
                  fontSize: WanzoTypography.fontSizeMd,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    }

    // Find min and max Y values for chart scaling
    double minY = spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
    double maxY = spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    // Add some padding to min/max Y if they are too close or same
    if (maxY == minY) {
        minY -= 1;
        maxY += 1;
    } else {
        final diff = maxY - minY;
        minY -= diff * 0.1; // 10% padding below
        maxY += diff * 0.1; // 10% padding above
    }
    if (minY < 0) minY = 0; // Ensure minY is not negative if data is non-negative


    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(WanzoBorderRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(WanzoSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aperçu des ventes (7 derniers jours)',
              style: TextStyle(
                fontSize: WanzoTypography.fontSizeLg,
                fontWeight: WanzoTypography.fontWeightBold,
              ),
            ),
            const SizedBox(height: WanzoSpacing.lg), // Increased spacing
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  minY: minY,
                  maxY: maxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    getDrawingHorizontalLine: (value) {
                      return const FlLine(
                        color: Colors.grey,
                        strokeWidth: 0.2,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return const FlLine(
                        color: Colors.grey,
                        strokeWidth: 0.2,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final days = ['J-6', 'J-5', 'J-4', 'J-3', 'J-2', 'Hier', 'Auj.'];
                          if (value.toInt() >= 0 && value.toInt() < days.length) {
                             return SideTitleWidget(
                               meta: meta, // Added based on error messages
                               space: 8.0,
                               child: Text(days[value.toInt()], style: const TextStyle(color: Colors.black54, fontSize: 10)),
                              );
                          }
                          return Container();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (double value, TitleMeta meta) {
                           // Show only a few labels to avoid clutter
                           if (value == meta.min || value == meta.max || value == (meta.min + meta.max) / 2) {
                            return Text(NumberFormat.compact().format(value * 10000), style: const TextStyle(color: Colors.black54, fontSize: 10), textAlign: TextAlign.left);
                           }
                           return Container();
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: WanzoColors.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(
                        show: false,
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: WanzoColors.primary.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construit la liste des ventes récentes et le journal des opérations
  Widget _buildRecentSalesAndJournal() {
    return DefaultTabController(
      length: 2,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WanzoBorderRadius.md),
        ),
        child: Padding(
          padding: const EdgeInsets.all(WanzoSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Make column take minimum necessary space
            children: [
              const TabBar(
                labelColor: WanzoColors.primary,
                unselectedLabelColor: Colors.grey,
                indicatorColor: WanzoColors.primary,
                tabs: [
                  Tab(text: 'Dernières Ventes'),
                  Tab(text: 'Journal des Opérations'),
                ],
              ),
              const SizedBox(height: WanzoSpacing.md),
              SizedBox(
                height: 320, // Reduced height from 350 to 320
                child: TabBarView(
                  children: [
                    _buildRecentSalesList(),
                    _buildOperationsJournal(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construit la liste des ventes récentes pour l'onglet
  Widget _buildRecentSalesList() {
    return BlocBuilder<SalesBloc, SalesState>(
      builder: (context, state) {
        if (state is SalesLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is SalesError) {
          print("SalesError in _buildRecentSalesList: ${state.message}"); // Added logging
          return Center(child: Text('Erreur: ${state.message}'));
        }
        if (state is SalesLoaded) {
          if (state.sales.isEmpty) {
            print("_buildRecentSalesList: No sales data in SalesLoaded state."); // Added logging
            return const Center(child: Text('Aucune vente récente.'));
          }
          // Sort sales by date descending
          final sortedSales = List.from(state.sales);
          sortedSales.sort((a, b) => b.date.compareTo(a.date));
          // Take the last 5 or fewer if not enough sales
          final recentSales = sortedSales.take(5).toList();

          if (recentSales.isEmpty) {
            print("_buildRecentSalesList: recentSales list is empty after sorting and taking 5."); // Added logging
            return const Center(child: Text('Aucune vente récente à afficher.'));
          }

          print("_buildRecentSalesList: Displaying ${recentSales.length} recent sales."); // Added logging

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: recentSales.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    if (index >= recentSales.length) { // Defensive check
                      print("Error: Index out of bounds in _buildRecentSalesList itemBuilder. Index: $index, Length: ${recentSales.length}");
                      return const ListTile(title: Text("Erreur d'affichage"));
                    }
                    final sale = recentSales[index];

                    if (sale.items == null) {
                      print("Error: sale.items is null for sale ID: ${sale.id}");
                      return ListTile(
                        title: Text('Erreur de données pour la vente ${sale.id}'),
                        subtitle: const Text('Les articles de la vente sont indisponibles.'),
                      );
                    }

                    final firstItem = sale.items.isNotEmpty ? sale.items.first : null;
                    Product? product;
                    if (firstItem != null) {
                      try {
                        product = _inventoryRepository.getProductById(firstItem.productId);
                      } catch (e) {
                        print("Error fetching product ${firstItem.productId}: $e");
                        product = null;
                      }
                    }

                    Widget leadingWidget;
                    if (product != null) {
                      final p = product; // Create a non-nullable local variable
                      if (p.imagePath != null && p.imagePath!.isNotEmpty) {
                        leadingWidget = ClipRRect(
                          borderRadius: BorderRadius.circular(WanzoBorderRadius.sm),
                          child: Image.file(
                            File(p.imagePath!),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              String initials = (p.name.isNotEmpty) ? p.name[0].toUpperCase() : "P";
                              return CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.grey[300],
                                child: Text(initials, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
                              );
                            },
                          ),
                        );
                      } else if (p.name.isNotEmpty) {
                        String initials = p.name[0].toUpperCase();
                        leadingWidget = CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.grey[300],
                          child: Text(initials, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
                        );
                      } else {
                        leadingWidget = Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(WanzoBorderRadius.sm),
                          ),
                          child: const Icon(Icons.shopping_bag, size: 30, color: Colors.grey),
                        );
                      }
                    } else {
                      leadingWidget = Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(WanzoBorderRadius.sm),
                        ),
                        child: const Icon(Icons.shopping_bag, size: 30, color: Colors.grey),
                      );
                    }

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: leadingWidget,
                      title: Text(
                        firstItem?.productName ?? 'Vente multiple',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${NumberFormat.currency(locale: 'fr_FR', symbol: 'FC', decimalDigits: 0).format(sale.totalAmount)} - ${sale.customerName}',
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Payé via: ${sale.paymentMethod}',
                            style: TextStyle(fontSize: WanzoTypography.fontSizeXs, color: Colors.grey[700]),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            DateFormat('dd/MM/yy HH:mm', 'fr_FR').format(sale.date),
                            style: TextStyle(fontSize: WanzoTypography.fontSizeXs, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // TODO: Ouvrir le détail de la vente
                        // context.push('/sales/details/${sale.id}');
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: WanzoSpacing.sm),
              Center(
                child: TextButton(
                  onPressed: () {
                    context.push('/sales');
                  },
                  child: const Text('Voir toutes les ventes'),
                ),
              ),
            ],
          );
        }
        return const Center(child: Text('Chargement des ventes...'));
      },
    );
  }

  /// Construit le journal des opérations
  Widget _buildOperationsJournal() {
    return BlocProvider.value(
      value: _operationJournalBloc,
      child: BlocBuilder<OperationJournalBloc, OperationJournalState>(
        builder: (context, state) {
          if (state is OperationJournalLoading && state is! OperationJournalLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is OperationJournalError) {
            return Center(
                child: Text('Erreur: ${state.message}', textAlign: TextAlign.center));
          }
          if (state is OperationJournalLoaded) {
            if (state.groupedOperations.isEmpty) {
              return const Center(
                child: Text('Aucune opération pour cette période.'),
              );
            }
            return Column(
              children: [
                _buildPeriodFilter(state.startDate, state.endDate),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.groupedOperations.keys.length,
                    itemBuilder: (context, index) {
                      final dateKey = state.groupedOperations.keys.elementAt(index);
                      final operationsOnDate = state.groupedOperations[dateKey]!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: WanzoSpacing.sm, horizontal: WanzoSpacing.xs),
                            child: Text(
                              DateFormat('EEEE, d MMMM yyyy', 'fr_FR').format(dateKey),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: WanzoTypography.fontSizeMd,
                                color: WanzoColors.primary,
                              ),
                            ),
                          ),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                                  child: DataTable(
                                    columnSpacing: 10,
                                    horizontalMargin: 0,
                                    headingRowHeight: 30,
                                    dataRowMinHeight: 30,
                                    dataRowMaxHeight: 60,
                                    columns: const [
                                      DataColumn(label: Text('Heure')),
                                      DataColumn(label: Text('Description')),
                                      DataColumn(label: Text('Type')),
                                      DataColumn(label: Text('Montant', textAlign: TextAlign.end)),
                                    ],
                                    rows: operationsOnDate.map((op) {
                                      return DataRow(
                                        cells: [
                                          DataCell(Text(DateFormat('HH:mm').format(op.date))),
                                          DataCell(Text(op.description, overflow: TextOverflow.ellipsis, maxLines: 2)),
                                          DataCell(Text(op.type.displayName)),
                                          DataCell(Text(
                                            NumberFormat.currency(locale: 'fr_FR', symbol: 'FC', decimalDigits: 0).format(op.amount),
                                            textAlign: TextAlign.end,
                                            style: TextStyle(color: op.amount < 0 ? WanzoColors.error : WanzoColors.success),
                                          )),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              );
                            }
                          ),
                          const Divider(),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          }
          return const Center(child: Text('Initialisation...'));
        },
      ),
    );
  }

  Widget _buildPeriodFilter(DateTime currentStart, DateTime currentEnd) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: WanzoSpacing.sm),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.date_range, size: 18),
                label: Text('Du: ${DateFormat('dd/MM/yy').format(currentStart)}', style: const TextStyle(fontSize: WanzoTypography.fontSizeXs)),
                onPressed: () async {
                  final newDate = await showDatePicker(
                    context: context,
                    initialDate: currentStart,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    locale: const Locale('fr', 'FR'),
                  );
                  if (newDate != null) {
                    _operationJournalBloc.add(FilterPeriodChanged(newStartDate: newDate));
                  }
                },
              ),
              TextButton.icon(
                icon: const Icon(Icons.date_range, size: 18),
                label: Text('Au: ${DateFormat('dd/MM/yy').format(currentEnd)}', style: const TextStyle(fontSize: WanzoTypography.fontSizeXs)),
                onPressed: () async {
                  final newDate = await showDatePicker(
                    context: context,
                    initialDate: currentEnd,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    locale: const Locale('fr', 'FR'),
                  );
                  if (newDate != null) {
                    final endOfDay = DateTime(newDate.year, newDate.month, newDate.day, 23, 59, 59);
                    _operationJournalBloc.add(FilterPeriodChanged(newEndDate: endOfDay));
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: WanzoSpacing.xs),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: WanzoSpacing.xs / 2),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: WanzoSpacing.sm)),
                    child: const Text('Aujourd\'hui', style: TextStyle(fontSize: WanzoTypography.fontSizeXs)),
                    onPressed: () {
                      final now = DateTime.now();
                      _operationJournalBloc.add(FilterPeriodChanged(
                        newStartDate: DateTime(now.year, now.month, now.day),
                        newEndDate: DateTime(now.year, now.month, now.day, 23, 59, 59),
                      ));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: WanzoSpacing.xs / 2),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: WanzoSpacing.sm)),
                    child: const Text('Ce mois-ci', style: TextStyle(fontSize: WanzoTypography.fontSizeXs)),
                    onPressed: () {
                      final now = DateTime.now();
                      _operationJournalBloc.add(FilterPeriodChanged(
                        newStartDate: DateTime(now.year, now.month, 1),
                        newEndDate: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
                      ));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: WanzoSpacing.xs / 2),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: WanzoSpacing.sm)),
                    child: const Text('Cette année', style: TextStyle(fontSize: WanzoTypography.fontSizeXs)),
                    onPressed: () {
                      final now = DateTime.now();
                      _operationJournalBloc.add(FilterPeriodChanged(
                        newStartDate: DateTime(now.year, 1, 1),
                        newEndDate: DateTime(now.year, 12, 31, 23, 59, 59),
                      ));
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Classe représentant un élément de navigation
class NavigationItem {
  final IconData icon;
  final String label;

  NavigationItem({
    required this.icon,
    required this.label,
  });
}
