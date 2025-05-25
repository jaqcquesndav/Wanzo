import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // Pour le formatage des dates
import 'package:fl_chart/fl_chart.dart'; // Added import for charts
import '../../../constants/constants.dart';
import '../../../core/shared_widgets/wanzo_scaffold.dart';
import 'package:wanzo/features/sales/bloc/sales_bloc.dart'; // Import SalesBloc
import 'package:wanzo/features/sales/models/sale.dart'; // Import Sale model
import '../bloc/operation_journal_bloc.dart';
import 'package:wanzo/features/dashboard/bloc/dashboard_bloc.dart'; // Corrected: Import BLoC, not parts
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
  late SettingsBloc _settingsBloc; // Added SettingsBloc
  late JournalService _journalService; // Added JournalService
  late DashboardBloc _dashboardBloc; // Added
  Widget? _expandedViewWidget; // To hold the expanded card\'s content

  @override
  void initState() {
    super.initState();
    _operationJournalBloc = BlocProvider.of<OperationJournalBloc>(context);
    _salesBloc = BlocProvider.of<SalesBloc>(context);
    _settingsBloc = BlocProvider.of<SettingsBloc>(context); 
    _dashboardBloc = BlocProvider.of<DashboardBloc>(context); // Initialize DashboardBloc
    _settingsBloc.add(LoadSettings()); 
    _journalService = JournalService(); 

    final now = DateTime.now();
    _operationJournalBloc.add(LoadOperations(
        startDate: DateTime(now.year, now.month, 1),
        endDate: DateTime(now.year, now.month + 1, 0, 23, 59, 59)));

    _salesBloc.add(LoadSalesByDateRange(
        startDate: now.subtract(const Duration(days: 7)),
        endDate: now));
    _dashboardBloc.add(LoadDashboardData(date: now)); // Dispatch event to load data
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
        PopupMenuButton<String>(
          icon: const Icon(Icons.filter_list),
          tooltip: 'Filtrer par période',
          onSelected: (value) {
            DateTime now = DateTime.now();
            DateTime startDate;
            DateTime endDate = now;

            if (value == 'today') {
              startDate = DateTime(now.year, now.month, now.day);
              endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
            } else if (value == 'this_month') {
              startDate = DateTime(now.year, now.month, 1);
              endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
            } else if (value == 'this_year') {
              startDate = DateTime(now.year, 1, 1);
              endDate = DateTime(now.year, 12, 31, 23, 59, 59);
            } else if (value == 'custom') {
              _selectDateRange(context);
              return; 
            } else {
              // Default to current month if something unexpected happens
              startDate = DateTime(now.year, now.month, 1);
              endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
            }
            _operationJournalBloc.add(FilterPeriodChanged(newStartDate: startDate, newEndDate: endDate));
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'today',
              child: Text("Aujourd'hui"), // Corrected escaping for apostrophe
            ),
            const PopupMenuItem<String>(
              value: 'this_month',
              child: Text('Ce mois-ci'),
            ),
            const PopupMenuItem<String>(
              value: 'this_year',
              child: Text('Cette année'),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem<String>(
              value: 'custom',
              child: Text('Personnalisé...'),
            ),
          ],
        ),
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

  void _selectDateRange(BuildContext context) async {
    final currentState = _operationJournalBloc.state;
    DateTime initialStart;
    DateTime initialEnd;

    if (currentState is OperationJournalLoaded) {
      initialStart = currentState.startDate;
      initialEnd = currentState.endDate;
    } else {
      // Default to last 30 days if state is not loaded
      initialStart = DateTime.now().subtract(const Duration(days: 30));
      initialEnd = DateTime.now();
    }

    final initialDateRange = DateTimeRange(
      start: initialStart,
      end: initialEnd,
    );

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)), // Allow selecting future dates up to a year
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            // Customize colors if needed
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      // Ensure endDate includes the whole day
      final endDate = DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59);
      _operationJournalBloc.add(FilterPeriodChanged(newStartDate: picked.start, newEndDate: endDate));
    }
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

        if (!mounted) return; // Add this check
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Journal exporté et prêt pour le partage.')),
        );

      } catch (e) {
        // print("Error exporting/sharing journal PDF: $e"); // Replaced with logger or removed
        if (!mounted) return; // Add this check
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
      if (!mounted) return; // Add this check
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
        if (!mounted) return; // Add this check
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impression du journal lancée.')),
        );
      } catch (e) {
        // print("Error printing journal: $e"); // Replaced with logger or removed
        if (!mounted) return; // Add this check
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
      if (!mounted) return; // Add this check
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
        backgroundColor: Theme.of(context).colorScheme.primary, // Use theme color
        child: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary), // Use theme color for FAB icon
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
                Text(
                  'Actions rapides',
                  style: TextStyle(
                    fontSize: WanzoTypography.fontSizeLg,
                    fontWeight: WanzoTypography.fontWeightBold,
                    color: Theme.of(context).colorScheme.onSurface, // Use theme color
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
                      color: Theme.of(context).colorScheme.primary, // Use theme color
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/sales/add');
                      },
                    ),
                    _buildQuickAction(
                      context,
                      icon: Icons.attach_money,
                      label: 'Dépense',
                      color: Theme.of(context).colorScheme.error, // Use theme color for warning/error
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/expenses/add');
                      },
                    ),
                    _buildQuickAction(
                      context,
                      icon: Icons.add_shopping_cart,
                      label: 'Nouveau produit',
                      color: Theme.of(context).colorScheme.secondary, // Use theme color for success/secondary
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
                      color: Theme.of(context).colorScheme.tertiary, // Use theme color for info/tertiary
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/customers/add');
                      },
                    ),
                    _buildQuickAction(
                      context,
                      icon: Icons.business,
                      label: 'Nouveau fournisseur',
                      color: Theme.of(context).colorScheme.tertiaryContainer, // Use theme color
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/suppliers/add');
                      },
                    ),
                    _buildQuickAction(
                      context,
                      icon: Icons.account_balance,
                      label: 'Financement',
                      color: Theme.of(context).colorScheme.secondaryContainer, // Use theme color
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
                color: color.withAlpha(50), // Adjusted opacity for better visibility with theme colors
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
                color: color, // Color is now passed from theme
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
                  return Text('Wanzo',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  );
                },
              ),
            ),
          ),

          // En-tête avec les statistiques principales
          BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) {
              if (state is DashboardLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is DashboardError) {
                return Center(child: Text('Erreur: ${state.message}'));
              } else if (state is DashboardLoaded) {
                return _buildHeaderStats(context, currencyType, state);
              }
              // Show a default/loading state for DashboardInitial or other unhandled states
              return _buildHeaderStats(context, currencyType, null); 
            },
          ),
          const SizedBox(height: WanzoSpacing.lg),

          // Graphique des ventes
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

  /// Construit l'en-tête avec les statistiques principales
  Widget _buildHeaderStats(BuildContext context, CurrencyType currencyType, DashboardLoaded? dashboardState) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Ventes du jour',
                value: dashboardState?.salesToday ?? 0.0,
                currencyType: currencyType,
                icon: Icons.trending_up,
                color: Theme.of(context).colorScheme.primary,
                onTap: () => context.push('/sales'),
              ),
            ),
            const SizedBox(width: WanzoSpacing.md),
            Expanded(
              child: _buildStatCard(
                title: 'Clients servis',
                value: dashboardState?.clientsServedToday.toDouble() ?? 0.0,
                isMonetary: false,
                icon: Icons.people,
                color: Theme.of(context).colorScheme.secondary,
                onTap: () => context.push('/customers'),
              ),
            ),
          ],
        ),
        const SizedBox(height: WanzoSpacing.md),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Créances clients',
                value: dashboardState?.receivables ?? 0.0,
                currencyType: currencyType,
                icon: Icons.account_balance_wallet,
                color: Theme.of(context).colorScheme.tertiary,
                onTap: () => context.push('/sales/receivables'),
              ),
            ),
            const SizedBox(width: WanzoSpacing.md),
            Expanded(
              child: _buildStatCard(
                title: 'Transactions',
                value: dashboardState?.transactionsToday.toDouble() ?? 0.0,
                isMonetary: false,
                icon: Icons.receipt_long,
                color: Theme.of(context).colorScheme.errorContainer,
                onTap: () => _expandOperationsJournal(),
              ),
            ),
          ],
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
    VoidCallback? onTap, // Added onTap parameter
  }) {
    String displayValue;
    if (isMonetary) {
      if (currencyType == null) {
        displayValue = 'N/A';
      } else {
        displayValue = formatCurrency(value, currencyType);
      }
    } else {
      // Ensure non-monetary values are formatted as integers if they don't have decimal parts
      if (value == value.truncateToDouble()) {
        displayValue = NumberFormat.compact().format(value.toInt());
      } else {
        displayValue = NumberFormat.compact().format(value);
      }
    }

    return InkWell( 
      onTap: onTap, 
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WanzoBorderRadius.md),
        ),
        child: SizedBox( // Added SizedBox to provide bounded height
          height: 130.0, // Adjust height as needed for UI consistency
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
                        title,
                        style: TextStyle(
                          fontSize: WanzoTypography.fontSizeSm,
                          color: Theme.of(context).colorScheme.onSurface.withAlpha((0.7 * 255).round()),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1, // Prevent title from taking too much vertical space
                      ),
                    ),
                    Icon(
                      icon,
                      color: color,
                      size: 24,
                    ),
                  ],
                ),
                const Spacer(), // Spacer will now work within the bounded height of SizedBox
                Column( // Group bottom texts
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayValue,
                      style: TextStyle(
                        fontSize: WanzoTypography.fontSizeXl,
                        fontWeight: WanzoTypography.fontWeightBold,
                        color: color,
                      ),
                    ),
                    if (increase != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0), // Add a small gap
                        child: Text(
                          increase,
                          style: TextStyle(
                            fontSize: WanzoTypography.fontSizeXs,
                            color: increase.contains('+') ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.error,
                            fontWeight: WanzoTypography.fontWeightMedium,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Construit un graphique des ventes récentes
  Widget _buildSalesChart(BuildContext context, CurrencyType currencyType) {
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
            Text(
              'Aperçu des ventes (7 derniers jours)',
              style: TextStyle(
                fontSize: WanzoTypography.fontSizeLg,
                fontWeight: WanzoTypography.fontWeightBold,
                color: Theme.of(context).colorScheme.onSurface, // Use theme color
              ),
            ),
            const SizedBox(height: WanzoSpacing.lg),
            SizedBox(
              height: 200,
              child: BlocBuilder<SalesBloc, SalesState>(
                builder: (context, state) {
                  if (state is SalesLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is SalesLoaded) {
                    if (state.sales.isEmpty) {
                      return const Center(child: Text('Aucune vente enregistrée récemment.'));
                    }
                    // Préparer les données pour le graphique
                    final salesData = _prepareSalesChartData(state.sales, currencyType);
                    return LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Theme.of(context).dividerColor.withAlpha((0.5 * 255).round()),
                              strokeWidth: 1,
                            );
                          },
                          getDrawingVerticalLine: (value) {
                            return FlLine(
                              color: Theme.of(context).dividerColor.withAlpha((0.5 * 255).round()),
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 50,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  formatCurrency(value, currencyType),
                                  style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withAlpha((0.7 * 255).round())),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                // Afficher les jours de la semaine
                                final day = DateTime.now().subtract(Duration(days: 6 - value.toInt()));
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    DateFormat('E', 'fr_FR').format(day),
                                    style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withAlpha((0.7 * 255).round())),
                                  ),
                                );
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: Theme.of(context).dividerColor, width: 1),
                        ),
                        minX: 0,
                        maxX: 6,
                        minY: 0,
                        maxY: salesData.isNotEmpty ? salesData.map((d) => d.y).reduce((a, b) => a > b ? a : b) * 1.2 : 100, // Ajuster le max Y, handle empty data
                        lineBarsData: [
                          LineChartBarData(
                            spots: salesData,
                            isCurved: true,
                            color: Theme.of(context).colorScheme.primary,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Theme.of(context).colorScheme.primary.withAlpha((0.2 * 255).round()),
                            ),
                          ),
                        ],
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipItems: (touchedSpots) {
                              return touchedSpots.map((spot) {
                                final date = DateTime.now().subtract(Duration(days: 6 - spot.x.toInt()));
                                return LineTooltipItem(
                                  '${DateFormat('dd/MM', 'fr_FR').format(date)}\\n${formatCurrency(spot.y, currencyType)}',
                                  TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.bold),
                                );
                              }).toList();
                            },
                            tooltipBorder: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                            getTooltipColor: (touchedSpot) => Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    );
                  } else if (state is SalesError) {
                    return Center(child: Text('Erreur: ${state.message}'));
                  }
                  return const Center(child: Text('Chargement des ventes...'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _prepareSalesChartData(List<Sale> sales, CurrencyType currencyType) {
    final Map<int, double> dailySales = {};
    final now = DateTime.now();

    for (int i = 0; i < 7; i++) {
      dailySales[i] = 0.0; // Initialiser les 7 derniers jours à 0
    }

    for (final sale in sales) {
      final saleDate = sale.date;
      final difference = now.difference(saleDate).inDays;
      if (difference >= 0 && difference < 7) {
        final dayIndex = 6 - difference; // 0 = 6 jours avant, 6 = aujourd'hui
        dailySales[dayIndex] = (dailySales[dayIndex] ?? 0) + sale.totalAmount;
      }
    }
    return dailySales.entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList();
  }

  /// Construit la section des dernières ventes et du journal des opérations
  Widget _buildRecentSalesAndJournal(
    BuildContext context,
    CurrencyType currencyType,
  {required VoidCallback onExpandRecentSales, required VoidCallback onExpandOperationsJournal}
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(WanzoBorderRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(WanzoSpacing.md),
        child: Column(
          children: [
            _buildSectionHeader(
              context,
              title: 'Dernières Ventes',
              onViewAll: onExpandRecentSales, // Utiliser le callback pour l'expansion
            ),
            _buildRecentSalesList(context, currencyType),
            const SizedBox(height: WanzoSpacing.md),
            const Divider(),
            const SizedBox(height: WanzoSpacing.md),
            _buildSectionHeader(
              context,
              title: 'Journal des Opérations',
              onViewAll: onExpandOperationsJournal, // Utiliser le callback pour l'expansion
            ),
            _buildOperationsJournal(context, currencyType),
          ],
        ),
      ),
    ); // Ensure Card is properly closed
  }

  /// Construit l'en-tête d'une section
  Widget _buildSectionHeader(BuildContext context, {required String title, VoidCallback? onViewAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: WanzoTypography.fontSizeLg,
            fontWeight: WanzoTypography.fontWeightBold,
            color: Theme.of(context).colorScheme.onSurface, // Use theme color
          ),
        ),
        if (onViewAll != null)
          TextButton(
            onPressed: onViewAll,
            child: Text(
              'Voir tout',
              style: TextStyle(color: Theme.of(context).colorScheme.primary), // Use theme color
            ),
          ),
      ],
    );
  }

  /// Construit la liste des dernières ventes
  Widget _buildRecentSalesList(BuildContext context, CurrencyType currencyType, {bool isExpanded = false}) {
    return BlocBuilder<SalesBloc, SalesState>(
      builder: (context, state) {
        if (state is SalesLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is SalesLoaded) {
          if (state.sales.isEmpty) {
            return const Center(child: Text('Aucune vente récente.'));
          }
          // Afficher seulement les 5 dernières ventes ou toutes si isExpanded est vrai
          final salesToShow = isExpanded ? state.sales : state.sales.take(5).toList();
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: salesToShow.length,
            itemBuilder: (context, index) {
              final sale = salesToShow[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary.withAlpha((0.1 * 255).round()), // Use theme color
                  child: Icon(Icons.receipt, color: Theme.of(context).colorScheme.primary), // Use theme color
                ),
                title: Text('Vente #${sale.id.substring(0, 5)}...'),
                subtitle: Text(
                    '${sale.customerName.isNotEmpty ? sale.customerName : 'Client Comptant'} - ${DateFormat('dd/MM/yyyy').format(sale.date)}'),
                trailing: Text(
                  formatCurrency(sale.totalAmount, currencyType),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary, // Use theme color
                  ),
                ),
                onTap: () => context.push('/sales/${sale.id}'),
              );
            },
            separatorBuilder: (context, index) => const Divider(height: 1),
          );
        } else if (state is SalesError) {
          return Center(child: Text('Erreur: ${state.message}'));
        }
        return const Center(child: Text('Chargement des ventes...'));
      },
    );
  }

  /// Construit le journal des opérations
  Widget _buildOperationsJournal(BuildContext context, CurrencyType currencyType, {bool isExpanded = false}) {
    return BlocBuilder<OperationJournalBloc, OperationJournalState>(
      builder: (context, state) {
        if (state is OperationJournalLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is OperationJournalLoaded) {
          if (state.groupedOperations.isEmpty) {
            return const Center(child: Text('Aucune opération récente.'));
          }

          // Aplatir les opérations groupées pour l'affichage
          final allOperations = state.groupedOperations.entries
              .expand((entry) => entry.value)
              .toList();
          allOperations.sort((a, b) => b.date.compareTo(a.date)); // Trier par date décroissante

          final operationsToShow = isExpanded ? allOperations : allOperations.take(5).toList();

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: operationsToShow.length,
            itemBuilder: (context, index) {
              final operation = operationsToShow[index];
              final isCredit = operation.type == OperationType.cashIn || 
                               operation.type == OperationType.saleCash || 
                               operation.type == OperationType.saleCredit || 
                               operation.type == OperationType.saleInstallment || 
                               operation.type == OperationType.customerPayment || 
                               operation.type == OperationType.financingApproved;
              final icon = isCredit ? Icons.arrow_downward : Icons.arrow_upward;
              final color = isCredit ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.error; // Use theme color for success (credit)

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: color.withAlpha((0.1 * 255).round()),
                  child: Icon(icon, color: color),
                ),
                title: Text(operation.description),
                subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(operation.date)),
                trailing: Text(
                  '${isCredit ? '+' : '-'}${formatCurrency(operation.amount, currencyType)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) => const Divider(height: 1),
          );
        } else if (state is OperationJournalError) {
          return Center(child: Text('Erreur: ${state.message}'));
        }
        return const Center(child: Text('Chargement du journal...'));
      },
    );
  }
}
