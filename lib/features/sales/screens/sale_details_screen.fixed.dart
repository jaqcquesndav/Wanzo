import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../constants/spacing.dart';
import '../bloc/sales_bloc.dart';
import '../models/sale.dart';
import '../../settings/bloc/settings_bloc.dart';
import '../../settings/bloc/settings_state.dart';
import '../../invoice/services/invoice_service.dart';
import '../../../core/utils/currency_formatter.dart'; // Import for formatCurrency
import '../../settings/models/settings.dart'; // Import for CurrencyType and Settings

/// Écran de détails d'une vente
class SaleDetailsScreen extends StatelessWidget {
  final Sale sale;

  const SaleDetailsScreen({
    super.key,
    required this.sale,
  });

  @override
  Widget build(BuildContext context) {
    final settingsBloc = BlocProvider.of<SettingsBloc>(context);
    CurrencyType currencyType = CurrencyType.usd; // Default

    if (settingsBloc.state is SettingsLoaded) {
      currencyType = (settingsBloc.state as SettingsLoaded).settings.currency;
    } else if (settingsBloc.state is SettingsUpdated) {
      currencyType = (settingsBloc.state as SettingsUpdated).settings.currency;
    }
    // Add other state checks if necessary, e.g., for an initial loading state

    Color statusColor;
    String statusText;
    IconData statusIcon;

    // Déterminer la couleur et le texte en fonction du statut
    switch (sale.status) {
      case SaleStatus.pending:
        statusColor = Colors.amber;
        statusText = "En attente";
        statusIcon = Icons.pending;
        break;
      case SaleStatus.completed:
        statusColor = Colors.green;
        statusText = "Terminée";
        statusIcon = Icons.check_circle;
        break;
      case SaleStatus.cancelled:
        statusColor = Colors.red;
        statusText = "Annulée";
        statusIcon = Icons.cancel;
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Détails de la vente"),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == "edit") {
                // TODO: Naviguer vers l'écran d'édition
              } else if (value == "delete") {
                _showDeleteConfirmation(context, sale);
              } else if (value == "print") {
                _printInvoice(context, sale);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: "edit",
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text("Modifier"),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: "print",
                child: Row(
                  children: [
                    Icon(Icons.print),
                    SizedBox(width: 8),
                    Text("Imprimer"),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: "delete",
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text("Supprimer", style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(WanzoSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(WanzoSpacing.base),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Vente #${sale.id.substring(0, 8)}",
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Chip(
                          label: Text(
                            statusText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: statusColor,
                          avatar: Icon(
                            statusIcon,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: WanzoSpacing.sm),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16),
                        const SizedBox(width: WanzoSpacing.xs),
                        Text(
                          DateFormat("dd/MM/yyyy HH:mm").format(sale.date),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: WanzoSpacing.xs),
                    Row(
                      children: [
                        const Icon(Icons.person, size: 16),
                        const SizedBox(width: WanzoSpacing.xs),
                        Text(
                          "Client: ${sale.customerName}",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: WanzoSpacing.sm),
                    Row(
                      children: [
                        const Icon(Icons.payment, size: 16),
                        const SizedBox(width: WanzoSpacing.xs),
                        Text(
                          "Mode de paiement: ${sale.paymentMethod}",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          formatCurrency(sale.totalAmount, currencyType),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: WanzoSpacing.xs),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Payé"),
                        Text(formatCurrency(sale.paidAmount, currencyType)),
                      ],
                    ),
                    const SizedBox(height: WanzoSpacing.xs),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Reste à payer",
                          style: TextStyle(
                            color: sale.totalAmount > sale.paidAmount
                                ? Colors.red
                                : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          formatCurrency(sale.totalAmount - sale.paidAmount, currencyType),
                          style: TextStyle(
                            color: sale.totalAmount > sale.paidAmount
                                ? Colors.red
                                : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: WanzoSpacing.base),
            Text(
              "Articles vendus",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: WanzoSpacing.sm),
            Card(
              margin: EdgeInsets.zero,
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sale.items.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final item = sale.items[index];
                  return ListTile(
                    title: Text(item.productName),
                    subtitle: Text(
                      "${item.quantity} × ${formatCurrency(item.unitPrice, currencyType)}",
                    ),
                    trailing: Text(
                      formatCurrency(item.totalPrice, currencyType),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: WanzoSpacing.base,
            vertical: WanzoSpacing.sm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: () => _printInvoice(context, sale),
                icon: const Icon(Icons.print),
                label: const Text("Imprimer"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
              if (sale.status == SaleStatus.pending)
                ElevatedButton.icon(
                  onPressed: () {
                    context
                        .read<SalesBloc>()
                        .add(UpdateSaleStatus(sale.id, SaleStatus.completed));
                    GoRouter.of(context).pop();
                  },
                  icon: const Icon(Icons.check),
                  label: const Text("Terminer"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext dialogContext, Sale sale) {
    showDialog(
      context: dialogContext,
      builder: (BuildContext alertContext) => AlertDialog(
        title: const Text("Confirmer la suppression"),
        content: const Text(
            "Êtes-vous sûr de vouloir supprimer cette vente ? Cette action est irréversible."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(alertContext),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(alertContext);
              dialogContext.read<SalesBloc>().add(DeleteSale(sale.id));
              GoRouter.of(dialogContext).pop();
            },
            child: const Text(
              "Supprimer",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _printInvoice(BuildContext invContext, Sale sale) async {
    final invoiceService = InvoiceService();
    final settingsBloc = BlocProvider.of<SettingsBloc>(invContext);
    final settingsState = settingsBloc.state;

    Settings currentSettings;

    if (settingsState is SettingsLoaded) {
      currentSettings = settingsState.settings;
    } else if (settingsState is SettingsUpdated) {
      currentSettings = settingsState.settings;
    } else {
      // Fallback or error handling if settings are not loaded
      // For example, use default settings or show an error.
      // This is a simplified fallback. Consider a more robust solution.
      currentSettings = Settings(
        companyName: 'Ma Compagnie', 
        companyAddress: 'Adresse Compagnie', 
        companyPhone: '123456789', 
        companyEmail: 'email@example.com', 
        companyLogo: '', 
        currency: CurrencyType.usd, // Default currency
        dateFormat: 'dd/MM/yyyy', 
        themeMode: AppThemeMode.system, 
        language: 'fr', 
        showTaxes: false, 
        defaultTaxRate: 0.0, 
        invoiceNumberFormat: 'INV-{YYYY}-{SEQ}', 
        invoicePrefix: 'INV', 
        defaultPaymentTerms: 'Net 30', 
        defaultInvoiceNotes: 'Merci pour votre achat.', 
        taxIdentificationNumber: '', 
        defaultProductCategory: '', 
        lowStockAlertDays: 7, 
        backupEnabled: false, 
        backupFrequency: 24, 
        reportEmail: '', 
        rccmNumber: '', 
        idNatNumber: '', 
        pushNotificationsEnabled: true, 
        inAppNotificationsEnabled: true, 
        emailNotificationsEnabled: true, 
        soundNotificationsEnabled: true
        );
      ScaffoldMessenger.of(invContext).showSnackBar(
        const SnackBar(content: Text('Paramètres par défaut utilisés pour la facture.')),
      );
    }
    
    await invoiceService.generateAndShowReceipt(
      sale: sale,
      companyName: currentSettings.companyName,
      companyAddress: currentSettings.companyAddress,
      companyPhone: currentSettings.companyPhone,
      companyEmail: currentSettings.companyEmail,
      footerText: currentSettings.defaultInvoiceNotes,
    );
  }
}
