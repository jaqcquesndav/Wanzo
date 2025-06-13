import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:wanzo/l10n/app_localizations.dart'; // Corrected import path
import 'package:go_router/go_router.dart';

import 'package:wanzo/core/shared_widgets/wanzo_scaffold.dart';
import 'package:wanzo/core/utils/currency_formatter.dart';
import 'package:wanzo/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:wanzo/features/dashboard/bloc/operation_journal_bloc.dart';
import 'package:wanzo/features/dashboard/services/journal_service.dart';
import 'package:wanzo/features/sales/bloc/sales_bloc.dart';
import 'package:wanzo/features/sales/models/sale.dart';
import 'package:wanzo/features/settings/bloc/settings_bloc.dart';
import 'package:wanzo/features/settings/bloc/settings_state.dart';
import 'package:wanzo/features/settings/models/settings.dart';
import 'package:wanzo/constants/spacing.dart';
import 'package:wanzo/constants/border_radius.dart';
import 'package:wanzo/core/enums/currency_enum.dart';
import 'package:wanzo/features/dashboard/models/operation_journal_entry.dart'; // Import for OperationTypeUIIcon

enum _ExpandedView { none, recentSales, operationsJournal }

// Model for KPI data
class KpiData {
  final double salesTodayCdf;
  final double salesTodayUsd;
  final int clientsServed;
  final double receivables;
  final double expenses;

  KpiData({
    required this.salesTodayCdf,
    required this.salesTodayUsd,
    required this.clientsServed,
    required this.receivables,
    required this.expenses,
  });
}

/// Écran principal du tableau de bord
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late OperationJournalBloc _operationJournalBloc;
  late SalesBloc _salesBloc;
  late JournalService _journalService;
  late DashboardBloc _dashboardBloc;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  _ExpandedView _expandedView = _ExpandedView.none;

  String _getDisplayCurrencyCode(Settings settings) {
    final Currency activeAppCurrency = settings.activeCurrency;
    return activeAppCurrency.code;
  }

  @override
  void initState() {
    super.initState();
    _operationJournalBloc = BlocProvider.of<OperationJournalBloc>(context);
    _salesBloc = BlocProvider.of<SalesBloc>(context);
    _dashboardBloc = BlocProvider.of<DashboardBloc>(context);
    _journalService = JournalService();

    final now = DateTime.now();
    _dashboardBloc.add(LoadDashboardData(date: now));
    _operationJournalBloc.add(LoadOperations(
        startDate: DateTime(now.year, now.month, 1),
        endDate: DateTime(now.year, now.month + 1, 0, 23, 59, 59)));
    _salesBloc.add(LoadSalesByDateRange(
        startDate: now.subtract(const Duration(days: 7)),
        endDate: now));
  }

  void _expandRecentSales() {
    setState(() {
      _expandedView = _ExpandedView.recentSales;
    });
  }

  void _expandOperationsJournal() {
    setState(() {
      _expandedView = _ExpandedView.operationsJournal;
    });
  }

  void _collapseView() {
    setState(() {
      _expandedView = _ExpandedView.none;
    });
  }

  Widget _buildExpandedView({
    required String title,
    required Widget content,
    required VoidCallback onCollapse,
    bool isJournal = false,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final settingsState = context.watch<SettingsBloc>().state;
    
    Settings settings;
    if (settingsState is SettingsLoaded) {
      settings = settingsState.settings;
    } else if (settingsState is SettingsUpdated) {
      settings = settingsState.settings;
    } else {
      return Scaffold(appBar: AppBar(title: Text(title)), body: Center(child: Text(l10n.commonLoading)));
    }

    List<Widget> actions = [];
    if (isJournal) {
      actions.addAll([
        PopupMenuButton<String>(
          icon: const Icon(Icons.filter_list),
          tooltip: l10n.dashboardJournalExportSelectDateRangeTitle,
          onSelected: (value) {
            DateTime now = DateTime.now();
            DateTime startDate = now;
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
              _selectDateRangeInternal(context, l10n, (start, end) {
                if (!mounted) return;
                _operationJournalBloc.add(FilterPeriodChanged(newStartDate: start, newEndDate: end));
              });
              return; 
            } else {
              return;
            }
            _operationJournalBloc.add(FilterPeriodChanged(newStartDate: startDate, newEndDate: endDate));
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'today',
              child: Text(l10n.commonToday),
            ),
            PopupMenuItem<String>(
              value: 'this_month',
              child: Text(l10n.commonThisMonth),
            ),
            PopupMenuItem<String>(
              value: 'this_year',
              child: Text(l10n.commonThisYear),
            ),
            const PopupMenuDivider(),
            PopupMenuItem<String>(
              value: 'custom',
              child: Text(l10n.commonCustom),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.picture_as_pdf),
          tooltip: l10n.dashboardJournalExportExportButton,
          onPressed: () {
            _exportOperationsJournalToPdfInternal(context, l10n, settings);
          },
        ),
        // IconButton(
        //   icon: const Icon(Icons.print),
        //   tooltip: l10n.dashboardJournalExportPrintButton, // This key exists
        //   onPressed: () {
        //     // _printOperationsJournalInternal(context, l10n, settings); // Kept commented
        //   },
        // ),
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

  Future<void> _selectDateRangeInternal(BuildContext context, AppLocalizations l10n, Function(DateTime, DateTime) onRangeSelected) async {
    final locale = Localizations.localeOf(context);
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(
        start: _selectedStartDate ?? DateTime.now().subtract(const Duration(days: 7)),
        end: _selectedEndDate ?? DateTime.now(),
      ),
      helpText: l10n.dashboardJournalExportSelectDateRangeTitle,
      cancelText: l10n.commonCancel.toUpperCase(),
      confirmText: l10n.commonConfirm.toUpperCase(),
      locale: locale,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            // Customizations if needed
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final endDate = DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59);
      setState(() {
        _selectedStartDate = picked.start;
        _selectedEndDate = endDate;
      });
      onRangeSelected(picked.start, endDate);
    }
  }
  
  Future<void> _exportOperationsJournalToPdfInternal(BuildContext context, AppLocalizations l10n, Settings settings) async {
    final journalState = _operationJournalBloc.state;

    if (journalState is OperationJournalLoaded) {
      if (_selectedStartDate == null || _selectedEndDate == null) {
        await _selectDateRangeInternal(context, l10n, (start, end) async {
          if (!mounted) return;
          final file = await _journalService.generateJournalPdf(
            journalState.operations,
            start,
            end,
            journalState.openingBalance,
            l10n,
            settings
          );
          if (!mounted) return;
          // Utiliser le context actuel car mounted a été vérifié
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(file != null ? l10n.dashboardJournalExportSuccessMessage : l10n.dashboardJournalExportFailureMessage)),
          );
        });
      } else {
        if (!mounted) return;
        final file = await _journalService.generateJournalPdf(
          journalState.operations,
          _selectedStartDate!,
          _selectedEndDate!,
          journalState.openingBalance,
          l10n,
          settings
        );
        if (!mounted) return;
        // Utiliser le context actuel car mounted a été vérifié
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(file != null ? l10n.dashboardJournalExportSuccessMessage : l10n.dashboardJournalExportFailureMessage)),
        );
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.dashboardJournalExportNoDataForPeriod)),
      );
    }
  }

  // Future<void> _printOperationsJournalInternal(BuildContext context, AppLocalizations l10n, Settings settings) async {
  //   final journalState = _operationJournalBloc.state;
  //   if (journalState is OperationJournalLoaded) {
  //      if (_selectedStartDate == null || _selectedEndDate == null) {
  //       await _selectDateRangeInternal(context, l10n, (start, end) async {
  //         if (!mounted) return; // Check mounted
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text(l10n.dashboardJournalExportPrintingMessage)),
  //         );
  //         // await _journalService.printJournalPdf( // Method does not exist
  //         //   journalState.operations,
  //         //   start,
  //         //   end,
  //         //   journalState.openingBalance,
  //         //   l10n,
  //         //   settings
  //         // );
  //       });
  //     } else {
  //       if (!mounted) return; // Check mounted
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text(l10n.dashboardJournalExportPrintingMessage)),
  //       );
  //       // await _journalService.printJournalPdf( // Method does not exist
  //       //   journalState.operations,
  //       //   _selectedStartDate!,
  //       //   _selectedEndDate!,
  //       //   journalState.openingBalance,
  //       //   l10n,
  //       //   settings
  //       // );
  //     }
  //   } else {
  //     if (!mounted) return; // Check mounted
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text(l10n.dashboardJournalExportNoDataForPeriod)),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsState = context.watch<SettingsBloc>().state;
    
    Settings settings;
    if (settingsState is SettingsLoaded) {
      settings = settingsState.settings;
    } else if (settingsState is SettingsUpdated) {
      settings = settingsState.settings;
    } else {
      return WanzoScaffold(
          currentIndex: 0,
          title: l10n.dashboardScreenTitle, 
          body: Center(child: CircularProgressIndicator(semanticsLabel: l10n.commonLoading)) 
      );
    }
    final String displayCurrencyCode = _getDisplayCurrencyCode(settings);

    if (_expandedView != _ExpandedView.none) {
      String title; 
      Widget content;
      bool isJournal = false;

      if (_expandedView == _ExpandedView.recentSales) {
        title = l10n.dashboardRecentSalesTitle;
        List<Sale> sales = [];
        final salesStateWatch = context.watch<SalesBloc>().state;
        if (salesStateWatch is SalesLoaded) {
          sales = salesStateWatch.sales;
        }
        content = _buildRecentSalesList(context, sales, true, l10n, displayCurrencyCode);
      } else { 
        title = l10n.dashboardOperationsJournalTitle;
        isJournal = true;
        content = _buildOperationsJournal(context, true, l10n, displayCurrencyCode);
      }
      return _buildExpandedView( 
        title: title,
        content: content,
        onCollapse: _collapseView,
        isJournal: isJournal,
      );
    }

    return WanzoScaffold(
      currentIndex: 0,
      title: l10n.dashboardScreenTitle, 
      body: _buildDashboardContent(context, l10n, settings, displayCurrencyCode), 
      floatingActionButton: FloatingActionButton(
        heroTag: 'dashboard_fab', // Added unique heroTag
        onPressed: () {
          _showQuickActionsMenu(context, l10n);
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary),
      ),
    );
  }

  void _showQuickActionsMenu(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bottomSheetContext) { 
        return Container(
          padding: const EdgeInsets.all(WanzoSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.dashboardQuickActionsTitle, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: WanzoSpacing.lg),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: WanzoSpacing.md,
                crossAxisSpacing: WanzoSpacing.md,
                childAspectRatio: 1.0,
                children: [
                  _buildQuickActionInternal(
                    bottomSheetContext,
                    Icons.add_shopping_cart,
                    l10n.dashboardQuickActionsNewInvoice,
                    () {
                      Navigator.pop(bottomSheetContext);
                      context.push('/sales/add');
                    },
                    iconColor: Colors.green,
                  ),
                  _buildQuickActionInternal(
                    bottomSheetContext,
                    Icons.inventory_2,
                    l10n.addProductTitle, // Corrected localization key
                    () {
                      Navigator.pop(bottomSheetContext);
                      context.push('/inventory/add'); // Corrected route
                    },
                    iconColor: Colors.orange,
                  ),
                  _buildQuickActionInternal(
                    bottomSheetContext,
                    Icons.monetization_on,
                    l10n.dashboardQuickActionsNewFinancing,
                    () {
                      Navigator.pop(bottomSheetContext);
                      context.push('/financing/add');
                    },
                    iconColor: Colors.teal,
                  ),
                  _buildQuickActionInternal(
                    bottomSheetContext,
                    Icons.receipt_long,
                    l10n.dashboardQuickActionsNewExpense, 
                    () {
                      Navigator.pop(bottomSheetContext);
                      context.push('/expenses/add'); 
                    },
                    iconColor: Colors.redAccent,
                  ),
                  _buildQuickActionInternal(
                    bottomSheetContext,
                    Icons.person_add_alt_1,
                    l10n.dashboardQuickActionsNewClient, 
                    () {
                      Navigator.pop(bottomSheetContext);
                      context.push('/customers/add'); 
                    },
                    iconColor: Colors.blueAccent,
                  ),
                  _buildQuickActionInternal(
                    bottomSheetContext,
                    Icons.store, 
                    l10n.dashboardQuickActionsNewSupplier, 
                    () {
                      Navigator.pop(bottomSheetContext);
                      context.push('/suppliers/add'); 
                    },
                    iconColor: Colors.purpleAccent,
                  ),
                ],
              ),
              const SizedBox(height: WanzoSpacing.md),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActionInternal(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap, {
    Color iconColor = Colors.grey, // Default color
    double iconSize = 28.0, // Adjusted icon size
    double iconContainerPadding = WanzoSpacing.sm, // e.g. 8.0
    double spacingAfterIcon = WanzoSpacing.xs,    // e.g. 4.0
    TextStyle? labelTextStyle,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(WanzoBorderRadius.md), // e.g. 12.0
      child: Padding(
        padding: const EdgeInsets.all(WanzoSpacing.xs / 2), // Minimal padding for the InkWell area
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, 
          children: [
            Container(
              padding: EdgeInsets.all(iconContainerPadding),              decoration: BoxDecoration(
                color: iconColor.withAlpha(38), // 0.15 * 255 = 38 - Utilisé withAlpha au lieu de withOpacity
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: iconSize,
                color: iconColor, // Icon takes the main color
              ),
            ),
            SizedBox(height: spacingAfterIcon),
            Text(
              label,
              textAlign: TextAlign.center,
              style: labelTextStyle ?? Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11), // Adjusted font size
              maxLines: 2, 
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, AppLocalizations l10n, Settings settings, String displayCurrencyCode) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, dashboardState) {
        final salesState = context.watch<SalesBloc>().state;

        if (dashboardState is DashboardLoading || (salesState is SalesLoading && salesState is! SalesLoaded)) {
          return Center(child: CircularProgressIndicator(semanticsLabel: l10n.commonLoading));
        }

        if (dashboardState is DashboardError) {
          return Center(child: Text('${l10n.commonError}: ${dashboardState.message}'));
        }
        
        if (salesState is SalesError && dashboardState is! DashboardError) { 
          return Center(child: Text('${l10n.commonErrorDataUnavailable}: ${salesState.message}'));
        }        if (dashboardState is DashboardLoaded) {
          final kpiData = KpiData(
            salesTodayCdf: dashboardState.salesTodayCdf,
            salesTodayUsd: dashboardState.salesTodayUsd,
            clientsServed: dashboardState.clientsServedToday,
            receivables: dashboardState.receivables,
            expenses: dashboardState.expenses
          );

          List<Sale> recentSales = [];
          if (salesState is SalesLoaded) {
            recentSales = salesState.sales;
          }

          return RefreshIndicator(
            onRefresh: () async {
              final now = DateTime.now();
              _dashboardBloc.add(LoadDashboardData(date: now));
              _salesBloc.add(LoadSalesByDateRange(
                startDate: now.subtract(const Duration(days: 7)), 
                endDate: now
              ));
              _operationJournalBloc.add(LoadOperations(
                startDate: DateTime(now.year, now.month, 1),
                endDate: DateTime(now.year, now.month + 1, 0, 23, 59, 59)
              ));
            },
            child: ListView(
              padding: const EdgeInsets.all(WanzoSpacing.md),
              children: [
                _buildHeaderStats(context, kpiData, l10n, displayCurrencyCode),
                const SizedBox(height: WanzoSpacing.lg),
                _buildSalesChart(context, recentSales, l10n, displayCurrencyCode),
                const SizedBox(height: WanzoSpacing.lg),
                // _buildRecentSalesAndJournal(context, recentSales, l10n, displayCurrencyCode), // Original Row layout
                _buildTabbedRecentSalesAndJournal(context, recentSales, l10n, displayCurrencyCode), // New Tabbed layout
              ],
            ),
          );
        } 
        // Fallback for any other unhandled state (e.g., initial state or if dashboardState is not DashboardLoaded)
        return Center(child: Text(l10n.commonLoading)); 
      }, 
    ); 
  }  Widget _buildHeaderStats(BuildContext context, KpiData kpiData, AppLocalizations l10n, String displayCurrencyCode) {
    return GridView.count(
      crossAxisCount: 2, 
      crossAxisSpacing: WanzoSpacing.md,
      mainAxisSpacing: WanzoSpacing.md,
      shrinkWrap: true,
      childAspectRatio: 2.2, // Réduit la hauteur des cartes KPI (valeur plus grande = cartes plus plates)
      physics: const NeverScrollableScrollPhysics(),      
      children: [
        _buildStatCard(context, title: '${l10n.dashboardHeaderSalesToday} (CDF)', value: formatCurrency(kpiData.salesTodayCdf, 'CDF'), icon: Icons.monetization_on, color: Colors.green, l10n: l10n),
        _buildStatCard(context, title: '${l10n.dashboardHeaderSalesToday} (USD)', value: formatCurrency(kpiData.salesTodayUsd, 'USD'), icon: Icons.monetization_on, color: Colors.blue, l10n: l10n),
        _buildStatCard(context, title: l10n.dashboardHeaderClientsServed, value: kpiData.clientsServed.toString(), icon: Icons.people, color: Colors.orange, l10n: l10n),
        _buildStatCard(context, title: 'Dépenses', value: formatCurrency(kpiData.expenses, displayCurrencyCode), icon: Icons.money_off, color: Colors.red, l10n: l10n),
      ],
    );
  }
  Widget _buildStatCard(BuildContext context, {required String title, required String value, required IconData icon, required Color color, required AppLocalizations l10n}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(WanzoBorderRadius.md)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: WanzoSpacing.md, vertical: WanzoSpacing.xs), // Réduit le padding vertical
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min, // Minimise la taille de la colonne
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title, 
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 11, // Réduit la taille du titre
                    ), 
                    overflow: TextOverflow.ellipsis
                  )
                ),
                Icon(icon, color: color, size: 16), // Réduits la taille de l'icône
              ],
            ),
            const SizedBox(height: WanzoSpacing.xs / 2), // Réduit l'espace entre le titre et la valeur
            // Utiliser un SingleChildScrollView horizontal pour les grands nombres
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                value, 
                style: value.length > 10
                    ? Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold, 
                        color: color,
                        fontSize: 16, // Réduit la taille pour tous les nombres
                      )
                    : Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold, 
                        color: color,
                        fontSize: 18, // Réduit la taille pour les nombres courts
                      ),
              ),
            ),
            const SizedBox(height: WanzoSpacing.xs / 2), // Réduit l'espace entre la valeur et le lien
            InkWell(
              onTap: () {
                // TODO: Implement actual navigation or details view
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l10n.dashboardCardViewDetails} for $title')));
              },
              child: Text(
                l10n.dashboardCardViewDetails, 
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontSize: 10, // Réduit la taille du texte du lien
                )
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesChart(BuildContext context, List<Sale> salesData, AppLocalizations l10n, String displayCurrencyCode) {
    final chartData = _prepareSalesChartData(salesData); 
    final locale = Localizations.localeOf(context).languageCode;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(WanzoBorderRadius.md)),
      child: Padding(
        padding: const EdgeInsets.all(WanzoSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.dashboardSalesChartTitle, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: WanzoSpacing.lg),
            if (chartData.isEmpty)
              Center(child: Padding(
                padding: const EdgeInsets.symmetric(vertical: WanzoSpacing.lg),
                child: Text(l10n.dashboardSalesChartNoData),
              ))
            else
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData( 
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 60, getTitlesWidget: (value, meta) {
                        return Text(formatCurrency(value < 0 ? 0 : value, displayCurrencyCode), style: const TextStyle(fontSize: 10));
                      })),
                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, interval: 1, getTitlesWidget: (value, meta) {
                        final day = DateTime.now().subtract(Duration(days: 6 - value.toInt()));
                        return Text(DateFormat.E(locale).format(day), style: const TextStyle(fontSize: 10));
                      })),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData( 
                        spots: chartData,
                        isCurved: true,
                        color: Theme.of(context).primaryColor,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(show: true, color: Theme.of(context).primaryColor.withAlpha((0.2 * 255).round())),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (List<LineBarSpot> touchedBarSpots) { 
                          return touchedBarSpots.map((barSpot) {
                            final flSpot = barSpot;                              return LineTooltipItem(
                              formatCurrency(flSpot.y, displayCurrencyCode),
                              TextStyle(
                                color: Theme.of(context).colorScheme.onPrimaryContainer, 
                                fontWeight: FontWeight.bold,
                                fontSize: flSpot.y > 1000000 ? 10 : 12, // Réduire la taille pour les grands nombres
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ), // Closes Column
      ), // Closes Padding
    ); // Closes Card
  }

  List<FlSpot> _prepareSalesChartData(List<Sale> salesData) {
    final Map<int, double> dailySales = {}; 
    final now = DateTime.now();
    final todayAtStartOfDay = DateTime(now.year, now.month, now.day);

    for (int i = 0; i < 7; i++) {
      dailySales[i] = 0.0; 
    }
    
    for (final sale in salesData) {
      // Removed: if (sale.date == null) continue; // sale.date is non-nullable
      final saleDateAtStartOfDay = DateTime(sale.date.year, sale.date.month, sale.date.day);
      final differenceInDays = todayAtStartOfDay.difference(saleDateAtStartOfDay).inDays;

      if (differenceInDays >= 0 && differenceInDays < 7) {
        final dayIndex = 6 - differenceInDays; 
        dailySales[dayIndex] = (dailySales[dayIndex] ?? 0.0) + sale.totalAmountInCdf; 
      }
    }
    return dailySales.entries.map((entry) => FlSpot(entry.key.toDouble(), entry.value)).toList()..sort((a,b)=> a.x.compareTo(b.x));
  }
  Widget _buildTabbedRecentSalesAndJournal(BuildContext context, List<Sale> recentSales, AppLocalizations l10n, String displayCurrencyCode) {
    return DefaultTabController(
      length: 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TabBar(
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withAlpha((0.7 * 255).round()), // Updated to use withAlpha
            indicatorColor: Theme.of(context).colorScheme.primary,
            tabs: [
              Tab(text: l10n.dashboardOperationsJournalTitle), // Moved to first position for priority
              Tab(text: l10n.dashboardRecentSalesTitle),
            ],
          ),          SizedBox(
            // Ajusté après optimisation des cartes KPI
            height: 420, // Revenu à 420px après avoir réduit la taille des cartes KPI
            child: TabBarView(
              children: [
                _buildOperationsJournal(context, false, l10n, displayCurrencyCode), // Moved to first position
                _buildRecentSalesList(context, recentSales, false, l10n, displayCurrencyCode),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSalesList(BuildContext context, List<Sale> sales, bool isExpanded, AppLocalizations l10n, String displayCurrencyCode) {
    final locale = Localizations.localeOf(context).languageCode;
    final DateFormat dateFormat = DateFormat.yMd(locale);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(WanzoBorderRadius.md)),
      child: Padding(
        padding: const EdgeInsets.all(WanzoSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.dashboardRecentSalesTitle, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                if (!isExpanded)
                  TextButton(
                    onPressed: _expandRecentSales,
                    child: Text(l10n.dashboardRecentSalesViewAll),
                  ),
              ],
            ),
            const SizedBox(height: WanzoSpacing.sm),
            if (sales.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: WanzoSpacing.lg),
                child: Center(child: Text(l10n.dashboardRecentSalesNoData)),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: isExpanded ? sales.length : (sales.length > 5 ? 5 : sales.length),
                itemBuilder: (context, index) {
                  final sale = sales[index];
                  final clientName = sale.customerName.isNotEmpty ? sale.customerName : l10n.commonAnonymousClient;
                  final saleDate = dateFormat.format(sale.date);
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      child: Text(clientName.isNotEmpty ? clientName[0].toUpperCase() : l10n.commonAnonymousClientInitial),
                    ),                    title: Text(clientName, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                    subtitle: Text(saleDate, style: Theme.of(context).textTheme.bodySmall),
                    trailing: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 120),
                        child: Text(
                          formatCurrency(sale.totalAmountInCdf, displayCurrencyCode),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold, 
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: sale.totalAmountInCdf > 1000000 ? 12 : 14, // Réduire la taille pour les grands nombres
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                    onTap: () {
                      // if (sale.id != null) context.push(\\'${AppRoutes.saleDetails}/${sale.id}\\'); // AppRoutes missing
                    },
                  );
                },
              ),
          ],
        ), // Closes Column
      ), // Closes Padding
    ); // Closes Card
  }

  Widget _buildOperationsJournal(BuildContext context, bool isExpanded, AppLocalizations l10n, String displayCurrencyCode) {
    final locale = Localizations.localeOf(context).languageCode;
    final DateFormat dateFormat = DateFormat.yMd(locale);
    final DateFormat timeFormat = DateFormat.Hm(locale);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(WanzoBorderRadius.md)),
      child: Padding(
        padding: const EdgeInsets.all(WanzoSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.dashboardOperationsJournalTitle, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                if (!isExpanded)
                  TextButton(
                    onPressed: _expandOperationsJournal,
                    child: Text(l10n.dashboardOperationsJournalViewAll),
                  ),
              ],
            ),
            const SizedBox(height: WanzoSpacing.sm),
            BlocBuilder<OperationJournalBloc, OperationJournalState>(              builder: (context, journalState) {
                if (journalState is OperationJournalLoading) {
                  return Center(child: CircularProgressIndicator(semanticsLabel: l10n.commonLoading));
                } else if (journalState is OperationJournalError) {
                  return Center(child: Text('${l10n.commonError}: ${journalState.message}'));
                } else if (journalState is OperationJournalLoaded) {
                  if (journalState.operations.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: WanzoSpacing.lg),
                      child: Center(child: Text(l10n.dashboardOperationsJournalNoData)),
                    );
                  }
                    // Limiter aux 10 dernières opérations pour la vue en miniature
                  final entriesToShow = isExpanded 
                      ? journalState.operations 
                      : journalState.operations.take(10).toList();
                  
                  final hasMoreEntries = !isExpanded && journalState.operations.length > 10;
                  
                  return isExpanded
                    ? ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: entriesToShow.length,
                        separatorBuilder: (context, index) => const Divider(height: 0, thickness: 1, indent: 72, endIndent: 16),
                        itemBuilder: (context, index) {
                          final entry = entriesToShow[index];
                          final entryCurrencyCode = entry.currencyCode ?? displayCurrencyCode;
                          return _buildJournalEntry(context, entry, entryCurrencyCode, displayCurrencyCode, l10n, dateFormat, timeFormat);
                        },
                      )                    : ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 400), // Adjusted height for better spacing
                        child: Column(
                          mainAxisSize: MainAxisSize.min, // Ensure column takes minimum space
                          children: [ConstrainedBox(                            constraints: const BoxConstraints(
                              maxHeight: 350, // Adjusted to avoid overflow
                              minHeight: 50, // Minimum height for the list
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const AlwaysScrollableScrollPhysics(), // Rendre scrollable
                              itemCount: entriesToShow.length,
                              separatorBuilder: (context, index) => const Divider(height: 0, thickness: 1, indent: 72, endIndent: 16),
                              itemBuilder: (context, index) {
                                final entry = entriesToShow[index];
                                final entryCurrencyCode = entry.currencyCode ?? displayCurrencyCode;
                                return _buildJournalEntry(context, entry, entryCurrencyCode, displayCurrencyCode, l10n, dateFormat, timeFormat);
                              },
                            ),
                          ),                          if (hasMoreEntries)
                            InkWell(
                              onTap: _expandOperationsJournal,
                              child: Container(                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                width: double.infinity,
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min, // This ensures the row takes only the space it needs
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.more_horiz, size: 14, color: Theme.of(context).colorScheme.primary),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Voir plus d\'opérations',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ));
                }
                return Center(child: Text(l10n.commonErrorDataUnavailable)); 
              },
            ),
          ],
        ), // Closes Column
      ), // Closes Padding
    ); // Closes Card
  }

  Widget _buildJournalEntry(
    BuildContext context, 
    OperationJournalEntry entry, 
    String entryCurrencyCode, 
    String displayCurrencyCode, 
    AppLocalizations l10n, 
    DateFormat dateFormat, 
    DateFormat timeFormat
  ) {
    String amountDisplay = "";
    Color amountColor = Theme.of(context).colorScheme.onSurface;

    if (entry.isDebit) {
      amountDisplay = "- ${formatCurrency(entry.amount.abs(), entryCurrencyCode)}";
      amountColor = Colors.redAccent;
    } else if (entry.isCredit) {
      amountDisplay = "+ ${formatCurrency(entry.amount.abs(), entryCurrencyCode)}";
      amountColor = Colors.green;
    } else {
      amountDisplay = formatCurrency(entry.amount, entryCurrencyCode);
    }    return ListTile(
      dense: true, // Rendre le ListTile plus compact
      contentPadding: EdgeInsets.zero,
      visualDensity: const VisualDensity(vertical: -4), // Réduire encore plus l'espacement vertical
      minVerticalPadding: 0, // Minimiser le padding vertical
      leading: Icon(
        entry.type.icon, 
        size: 16, // Réduire la taille de l'icône
        color: entry.isDebit ? Colors.redAccent : Colors.green,
      ),title: Text(
        entry.description, 
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 12, // Réduire la taille pour économiser de l'espace vertical
        ), 
        maxLines: 1, 
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        "${dateFormat.format(entry.date)} ${timeFormat.format(entry.date)}",
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontSize: 10, // Réduire la taille pour économiser de l'espace vertical
        ),
      ),
      trailing: SizedBox(
        width: 120, // Fixed width for the trailing widget
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // Pour réduire la hauteur de la colonne
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(                amountDisplay,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold, 
                  color: amountColor,
                  fontSize: entry.amount > 1000000 ? 11 : 12, // Taille réduite pour tous les montants
                ),
                textAlign: TextAlign.right,
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                '${l10n.dashboardOperationsJournalBalanceLabel}: ${formatCurrency(entry.balanceAfter, displayCurrencyCode)}', 
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: entry.balanceAfter > 1000000 ? 9 : 10, // Taille réduite pour tous les soldes
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        // TODO: Implement details view for operation entry if needed
      },
    );
  }
}
