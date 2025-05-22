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
import 'package:wanzo/features/dashboard/services/journal_service.dart';
import 'package:wanzo/features/settings/bloc/settings_bloc.dart';
import 'package:wanzo/features/settings/bloc/settings_event.dart';
import 'package:wanzo/features/settings/bloc/settings_state.dart';
import 'package:wanzo/features/settings/models/settings.dart'; // Added for CurrencyType
import 'package:wanzo/core/utils/currency_formatter.dart'; // Added for formatCurrency

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
  late SettingsBloc _settingsBloc; // Added SettingsBloc
  late JournalService _journalService; // Added JournalService
  Widget? _expandedViewWidget; // To hold the expanded card's content

  @override
  void initState() {
    super.initState();
    _operationJournalBloc = BlocProvider.of<OperationJournalBloc>(context);
    _salesBloc = BlocProvider.of<SalesBloc>(context);
    _inventoryRepository = RepositoryProvider.of<InventoryRepository>(context);
    _settingsBloc = BlocProvider.of<SettingsBloc>(context); // Initialize SettingsBloc
    _settingsBloc.add(LoadSettings()); // Load settings
    _journalService = JournalService(); // Initialize JournalService

    final now = DateTime.now();
    _operationJournalBloc.add(LoadOperations(
        startDate: DateTime(now.year, now.month, 1),
        endDate: DateTime(now.year, now.month + 1, 0, 23, 59, 59)));

    _salesBloc.add(LoadSalesByDateRange(
        startDate: now.subtract(const Duration(days: 7)),
        endDate: now));
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _expandRecentSales() {
    setState(() {
      _expandedViewWidget = _buildExpandedView(
        title: 'Dernières Ventes',
        content: _buildRecentSalesList(context, CurrencyType.cdf, isExpanded: true), // Pass isExpanded
        onCollapse: _collapseView,
      );
    });
  }

  void _expandOperationsJournal() {
    setState(() {
      _expandedViewWidget = _buildExpandedView(
        title: 'Journal des Opérations',
        content: _buildOperationsJournal(context, CurrencyType.cdf, isExpanded: true), // Pass isExpanded
        onCollapse: _collapseView,
        isJournal: true,
      );
    });
  }

  void _collapseView() {
    setState(() {
      _expandedViewWidget = null;
    });
  }

  Widget _buildExpandedView({
    required String title,
    required Widget content,
    required VoidCallback onCollapse,
    bool isJournal = false,
  }) {
    List<Widget> actions = [];
    if (isJournal) {
      actions.addAll([
        IconButton(
          icon: const Icon(Icons.picture_as_pdf),
          tooltip: 'Exporter en PDF',
          onPressed: () {
            _exportOperationsJournalToPdf();
          },
        ),
        IconButton(
          icon: const Icon(Icons.print),
          tooltip: 'Imprimer',
          onPressed: () {
            _printOperationsJournal();
          },
        ),
      ]);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: onCollapse,
        ),
        actions: actions,
      ),
      body: Padding(
        padding: const EdgeInsets.all(WanzoSpacing.md),
        child: content,
      ),
    );
  }

  void _exportOperationsJournalToPdf() async {
    final journalState = _operationJournalBloc.state;
    final settingsState = _settingsBloc.state;

    if (journalState is OperationJournalLoaded && settingsState is SettingsLoaded) {
      try {
        // Share the PDF
        await _journalService.shareJournal(
          groupedOperations: journalState.groupedOperations,
          startDate: journalState.startDate,
          endDate: journalState.endDate,
          settings: settingsState.settings,
          openingBalance: journalState.openingBalance, // Pass openingBalance
          subject: 'Journal des Opérations Wanzo du ${DateFormat('dd/MM/yyyy', 'fr_FR').format(journalState.startDate)} au ${DateFormat('dd/MM/yyyy', 'fr_FR').format(journalState.endDate)}',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Journal exporté et prêt pour le partage.')),
        );

      } catch (e) {
        print("Error exporting/sharing journal PDF: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'exportation du PDF: $e')),
        );
      }
    } else {
      String message = 'Impossible d\'exporter le PDF. ';
      if (journalState is! OperationJournalLoaded) {
        message += 'Données du journal non chargées. ';
      }
      if (settingsState is! SettingsLoaded) {
        message += 'Paramètres non chargés.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message.trim())),
      );
    }
  }

  void _printOperationsJournal() async {
    final journalState = _operationJournalBloc.state;
    final settingsState = _settingsBloc.state;

    if (journalState is OperationJournalLoaded && settingsState is SettingsLoaded) {
      try {
        await _journalService.printJournal(
          groupedOperations: journalState.groupedOperations,
          startDate: journalState.startDate,
          endDate: journalState.endDate,
          settings: settingsState.settings,
          openingBalance: journalState.openingBalance, // Pass openingBalance
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impression du journal lancée.')),
        );
      } catch (e) {
        print("Error printing journal: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'impression: $e')),
        );
      }
    } else {
      String message = 'Impossible d\'imprimer. ';
      if (journalState is! OperationJournalLoaded) {
        message += 'Données du journal non chargées. ';
      }
      if (settingsState is! SettingsLoaded) {
        message += 'Paramètres non chargés.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message.trim())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsState = context.watch<SettingsBloc>().state; // Watch SettingsBloc
    CurrencyType currencyType = CurrencyType.cdf; // Default currency

    if (settingsState is SettingsLoaded) {
      currencyType = settingsState.settings.currency;
    } else if (settingsState is SettingsUpdated) {
      currencyType = settingsState.settings.currency;
    }

    if (_expandedViewWidget != null) {
      return _expandedViewWidget!;
    }

    return WanzoScaffold(
      currentIndex: 0, // Dashboard = index 0
      title: 'Tableau de bord',
      body: _buildDashboardContent(context, currencyType), // Pass currencyType
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
  Widget _buildDashboardContent(BuildContext context, CurrencyType currencyType) {
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
          _buildHeaderStats(context, currencyType),
          const SizedBox(height: WanzoSpacing.lg),

          // Graphique des ventes récentes
          _buildSalesChart(context, currencyType),
          const SizedBox(height: WanzoSpacing.lg),

          // Section pour les dernières ventes et le journal des opérations
          _buildSalesOperationsCard(context, currencyType),
        ],
      ),
    );
  }

  /// Construit la section responsive pour les ventes récentes et le journal des opérations
  Widget _buildSalesOperationsCard(BuildContext context, CurrencyType currencyType) {
    return _buildRecentSalesAndJournal(
      context,
      currencyType,
      onExpandRecentSales: _expandRecentSales,
      onExpandOperationsJournal: _expandOperationsJournal,
    );
  }

  /// Construit les statistiques d'en-tête
  Widget _buildHeaderStats(BuildContext context, CurrencyType currencyType) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: WanzoSpacing.md,
      mainAxisSpacing: WanzoSpacing.md,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          title: 'Ventes du jour',
          value: 150000,
          currencyType: currencyType,
          icon: Icons.insert_chart,
          color: WanzoColors.primary,
          increase: '+8% vs hier',
        ),
        _buildStatCard(
          title: 'Clients servis',
          value: 24,
          icon: Icons.people,
          color: WanzoColors.info,
          increase: '+3 vs hier',
          isMonetary: false,
        ),
        _buildStatCard(
          title: 'À recevoir',
          value: 450000,
          currencyType: currencyType,
          icon: Icons.account_balance_wallet,
          color: WanzoColors.success,
        ),
        _buildStatCard(
          title: 'Transactions',
          value: 0,
          icon: Icons.receipt_long,
          color: Colors.teal,
          isMonetary: false,
        ),
      ],
    );
  }

  /// Construit une carte de statistique
  Widget _buildStatCard({
    required String title,
    required double value,
    CurrencyType? currencyType,
    required IconData icon,
    required Color color,
    String? increase,
    bool isMonetary = true,
  }) {
    String displayValue;
    if (isMonetary) {
      if (currencyType == null) {
        displayValue = 'N/A';
        print("Warning: currencyType is null for monetary StatCard '$title'");
      } else {
        displayValue = formatCurrency(value, currencyType);
      }
    } else {
      displayValue = NumberFormat.compact().format(value);
    }

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
              displayValue,
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
  Widget _buildSalesChart(BuildContext context, CurrencyType currencyType) {
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
                        reservedSize: 50, // Adjusted for potentially longer currency strings
                        getTitlesWidget: (double value, TitleMeta meta) {
                           // Show only a few labels to avoid clutter
                           if (value == meta.min || value == meta.max || value == (meta.min + meta.max) / 2) {
                            // Assuming chart Y values are raw numbers, format them
                            return Text(formatCurrency(value, currencyType), style: const TextStyle(color: Colors.black54, fontSize: 10), textAlign: TextAlign.left);
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
  Widget _buildRecentSalesAndJournal(
    BuildContext context,
    CurrencyType currencyType,
    {
    required VoidCallback onExpandRecentSales,
    required VoidCallback onExpandOperationsJournal,
  }) {
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
                    _buildRecentSalesList(context, currencyType,
                        isExpanded: false, onExpand: onExpandRecentSales),
                    _buildOperationsJournal(context, currencyType,
                        isExpanded: false, onExpand: onExpandOperationsJournal),
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
  Widget _buildRecentSalesList(BuildContext context, CurrencyType currencyType, {bool isExpanded = false, VoidCallback? onExpand}) {
    return BlocBuilder<SalesBloc, SalesState>(
      builder: (context, state) {
        if (state is SalesLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is SalesError) {
          print("SalesError in _buildRecentSalesList: ${state.message}");
          return Column( // Ensure expand button can be placed if needed
            children: [
              if (!isExpanded && onExpand != null)
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.fullscreen),
                    tooltip: 'Agrandir',
                    onPressed: onExpand,
                  ),
                ),
              Expanded(child: Center(child: Text('Erreur: ${state.message}'))),
            ],
          );
        }
        if (state is SalesLoaded) {
          if (state.sales.isEmpty) {
            print("_buildRecentSalesList: No sales data in SalesLoaded state.");
            return Column(
              children: [
                if (!isExpanded && onExpand != null)
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.fullscreen),
                      tooltip: 'Agrandir',
                      onPressed: onExpand,
                    ),
                  ),
                const Expanded(child: Center(child: Text('Aucune vente récente.'))),
              ],
            );
          }
          final sortedSales = List.from(state.sales);
          sortedSales.sort((a, b) => b.date.compareTo(a.date));
          final recentSales = sortedSales.take(5).toList();

          if (recentSales.isEmpty) {
            print("_buildRecentSalesList: recentSales list is empty after sorting and taking 5.");
            return Column(
              children: [
                if (!isExpanded && onExpand != null)
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.fullscreen),
                      tooltip: 'Agrandir',
                      onPressed: onExpand,
                    ),
                  ),
                const Expanded(child: Center(child: Text('Aucune vente récente à afficher.'))),
              ],
            );
          }

          print("_buildRecentSalesList: Displaying ${recentSales.length} recent sales.");

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isExpanded && onExpand != null)
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.fullscreen),
                    tooltip: 'Agrandir',
                    onPressed: onExpand,
                  ),
                ),
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
                            '${formatCurrency(sale.totalAmount, currencyType)} - ${sale.customerName}',
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
  Widget _buildOperationsJournal(BuildContext context, CurrencyType currencyType, {bool isExpanded = false, VoidCallback? onExpand}) {
    return BlocProvider.value(
      value: _operationJournalBloc,
      child: BlocBuilder<OperationJournalBloc, OperationJournalState>(
        builder: (context, state) {
          if (state is OperationJournalLoading) { // Simplified loading check
            return const Center(child: CircularProgressIndicator());
          }
          if (state is OperationJournalError) {
            return Column( // Ensure expand button can be placed
              children: [
                 Row(
                  children: [
                    // Potentially add a disabled filter or a placeholder
                    const Spacer(), // Pushes button to the right
                    if (!isExpanded && onExpand != null)
                      IconButton(
                        icon: const Icon(Icons.fullscreen),
                        tooltip: 'Agrandir',
                        onPressed: onExpand,
                      ),
                  ],
                ),
                Expanded(child: Center(child: Text('Erreur: ${state.message}', textAlign: TextAlign.center))),
              ],
            );
          }
          if (state is OperationJournalLoaded) {
            if (state.groupedOperations.isEmpty) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildPeriodFilter(state.startDate, state.endDate)),
                      if (!isExpanded && onExpand != null)
                        IconButton(
                          icon: const Icon(Icons.fullscreen),
                          tooltip: 'Agrandir',
                          onPressed: onExpand,
                        ),
                    ],
                  ),
                  const Expanded(
                    child: Center(
                      child: Text('Aucune opération pour cette période.'),
                    ),
                  ),
                ],
              );
            }
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildPeriodFilter(state.startDate, state.endDate)),
                    if (!isExpanded && onExpand != null)
                      IconButton(
                        icon: const Icon(Icons.fullscreen),
                        tooltip: 'Agrandir',
                        onPressed: onExpand,
                      ),
                  ],
                ),
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
                                            formatCurrency(op.amount, currencyType),
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
