import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:wanzo/core/enums/currency_enum.dart';
import 'package:wanzo/core/utils/currency_formatter.dart';
import 'package:wanzo/core/services/currency_service.dart';
import '../../../constants/colors.dart';
import '../../../constants/spacing.dart';
import '../../../core/shared_widgets/wanzo_scaffold.dart';
import '../../../features/settings/presentation/cubit/currency_settings_cubit.dart';
import '../bloc/sales_bloc.dart';
import '../models/sale.dart';
import 'package:wanzo/l10n/generated/app_localizations.dart'; 

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
    context.read<SalesBloc>().add(const LoadSales());
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencySettingsState = context.watch<CurrencySettingsCubit>().state;
    final String appActiveCurrencyCode = currencySettingsState.settings.activeCurrency.code;
    final AppLocalizations l10n = AppLocalizations.of(context)!; 

    return WanzoScaffold(
      currentIndex: 1, 
      title: l10n.salesScreenTitle, 
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
              tabs: [
                Tab(text: l10n.salesTabAll), 
                Tab(text: l10n.salesTabPending), 
                Tab(text: l10n.salesTabCompleted), 
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
                      _buildSalesSummary(state, appActiveCurrencyCode),
                      
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
                                    Text(
                                      l10n.salesNoSalesFound, 
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    const SizedBox(height: WanzoSpacing.lg),
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.add),
                                      label: Text(l10n.salesAddSaleButton), 
                                      onPressed: () => _navigateToAddSale(context),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: state.sales.length,
                                itemBuilder: (context, index) {
                                  final sale = state.sales[index];
                                  return _buildSaleItem(context, sale, appActiveCurrencyCode);
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
                          l10n.salesErrorPrefix + ': ${state.message}', // Ensure concatenation is correct
                          style: const TextStyle(color: WanzoColors.error),
                        ),
                        const SizedBox(height: WanzoSpacing.lg),
                        ElevatedButton(
                          onPressed: () => context.read<SalesBloc>().add(const LoadSales()),
                          child: Text(l10n.salesRetryButton), 
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
        final AppLocalizations l10n = AppLocalizations.of(context)!; 
        
        return AlertDialog(
          title: Text(l10n.salesFilterDialogTitle), 
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Champ de date de début
              ListTile(
                title: Text(l10n.salesFilterDialogStartDate), 
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
                title: Text(l10n.salesFilterDialogEndDate), 
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
              child: Text(l10n.salesFilterDialogCancel), 
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
              child: Text(l10n.salesFilterDialogApply), 
            ),
          ],
        );
      },
    );
  }

  /// Construire le résumé des ventes
  Widget _buildSalesSummary(SalesLoaded state, String appActiveCurrencyCode) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final currencyService = context.read<CurrencyService>();
    // Convert appActiveCurrencyCode (String) to Currency enum
    final Currency activeCurrencyEnum = Currency.values.firstWhere((c) => c.code == appActiveCurrencyCode, orElse: () => Currency.CDF); // Provide a default or handle error

    final double totalInActiveCurrency = currencyService.convertFromCdf(state.totalAmountInCdf, activeCurrencyEnum);
    
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
                    l10n.salesSummaryTotal,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    formatCurrency(totalInActiveCurrency, appActiveCurrencyCode), // Display with the string code
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
                    l10n.salesSummaryCount, 
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
  Widget _buildSaleItem(BuildContext context, Sale sale, String appActiveCurrencyCode) {
    Color statusColor;
    String statusText;
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final currencyService = context.read<CurrencyService>();
    // Convert appActiveCurrencyCode (String) to Currency enum
    final Currency activeCurrencyEnum = Currency.values.firstWhere((c) => c.code == appActiveCurrencyCode, orElse: () => Currency.CDF); // Provide a default or handle error

    // Déterminer la couleur et le texte en fonction du statut
    switch (sale.status) {
      case SaleStatus.pending:
        statusColor = Colors.orange;
        statusText = l10n.salesStatusPending; 
        break;
      case SaleStatus.completed:
        statusColor = Colors.green;
        statusText = l10n.salesStatusCompleted; 
        break;
      case SaleStatus.partiallyPaid: 
        statusColor = Colors.blue; 
        statusText = l10n.salesStatusPartiallyPaid; 
        break;
      case SaleStatus.cancelled:
        statusColor = Colors.red;
        statusText = l10n.salesStatusCancelled; 
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
                        l10n.salesListItemSaleIdPrefix + sale.id.substring(0, 8),
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
                    l10n.salesListItemArticles(sale.items.length), 
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
                    l10n.salesListItemTotal, 
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  RichText(
                    textAlign: TextAlign.end,
                    text: TextSpan(
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                      children: <TextSpan>[
                        TextSpan(
                          text: formatCurrency(sale.totalAmountInTransactionCurrency, sale.transactionCurrencyCode),
                        ),
                        if (sale.transactionCurrencyCode != appActiveCurrencyCode)
                          TextSpan(
                            text: '\n(${formatCurrency(currencyService.convertFromCdf(sale.totalAmountInCdf, activeCurrencyEnum), appActiveCurrencyCode)})',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).primaryColor.withOpacity(0.8),
                                  fontStyle: FontStyle.italic,
                                ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              
              // Statut de paiement
              // Use isFullyPaid which should be based on transaction currency amounts
              if ((sale.totalAmountInTransactionCurrency - sale.paidAmountInTransactionCurrency).abs() > 0.001 && sale.paidAmountInTransactionCurrency < sale.totalAmountInTransactionCurrency) ...[
                const SizedBox(height: WanzoSpacing.xs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.salesListItemRemainingToPay, 
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.red,
                      ),
                    ),
                    RichText(
                      textAlign: TextAlign.end,
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                        children: <TextSpan>[
                          TextSpan(
                            text: formatCurrency(
                              sale.totalAmountInTransactionCurrency - sale.paidAmountInTransactionCurrency,
                              sale.transactionCurrencyCode
                            ),
                          ),
                          if (sale.transactionCurrencyCode != appActiveCurrencyCode)
                            TextSpan(
                              text: '\n(${formatCurrency(currencyService.convertFromCdf(sale.totalAmountInCdf - sale.paidAmountInCdf, activeCurrencyEnum), appActiveCurrencyCode)})',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.red.withOpacity(0.8),
                                    fontStyle: FontStyle.italic,
                                  ),
                            ),
                        ],
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
