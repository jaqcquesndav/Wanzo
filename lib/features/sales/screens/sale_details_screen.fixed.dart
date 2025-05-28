import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart'; // Added for Printing.sharePdf
import 'dart:io'; // Added for File
import '../../../constants/spacing.dart';
import '../bloc/sales_bloc.dart';
import '../models/sale.dart';
import '../../settings/bloc/settings_bloc.dart';
import '../../settings/bloc/settings_state.dart';
import '../../invoice/services/invoice_service.dart';
import '../../../core/utils/currency_formatter.dart'; // Import for formatCurrency
import '../../settings/models/settings.dart'; // Import for Settings
import '../../../core/enums/currency_enum.dart'; // Import for Currency

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
    String displayCurrencyCode = sale.transactionCurrencyCode; // Default to sale's transaction currency

    if (settingsBloc.state is SettingsLoaded) {
      displayCurrencyCode = (settingsBloc.state as SettingsLoaded).settings.activeCurrency.code;
    } else if (settingsBloc.state is SettingsUpdated) {
      displayCurrencyCode = (settingsBloc.state as SettingsUpdated).settings.activeCurrency.code;
    }

    Color statusColor;
    String statusText;
    IconData statusIcon;

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
      case SaleStatus.partiallyPaid: // Added missing case
        statusColor = Colors.orange;
        statusText = "Partiellement payée";
        statusIcon = Icons.pie_chart; // Example icon
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
                          "Total (${sale.transactionCurrencyCode})",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          formatCurrency(sale.totalAmountInTransactionCurrency, displayCurrencyCode),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: WanzoSpacing.xs),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Payé (${sale.transactionCurrencyCode})"),
                        Text(formatCurrency(sale.paidAmountInTransactionCurrency, displayCurrencyCode)),
                      ],
                    ),
                    const SizedBox(height: WanzoSpacing.xs),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Reste à payer (${sale.transactionCurrencyCode})",
                          style: TextStyle(
                            color: sale.totalAmountInTransactionCurrency > sale.paidAmountInTransactionCurrency
                                ? Colors.red
                                : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          formatCurrency(sale.totalAmountInTransactionCurrency - sale.paidAmountInTransactionCurrency, displayCurrencyCode),
                          style: TextStyle(
                            color: sale.totalAmountInTransactionCurrency > sale.paidAmountInTransactionCurrency
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
                      "${item.quantity} × ${formatCurrency(item.unitPrice, sale.transactionCurrencyCode)}", // Assuming item.unitPrice is in transaction currency
                    ),
                    trailing: Text(
                      formatCurrency(item.totalPrice, sale.transactionCurrencyCode), // Assuming item.totalPrice is in transaction currency
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
              if (sale.status == SaleStatus.pending || sale.status == SaleStatus.partiallyPaid)
                ElevatedButton.icon(
                  onPressed: () {
                    if (sale.status == SaleStatus.pending) {
                       context
                        .read<SalesBloc>()
                        .add(UpdateSaleStatus(sale.id, SaleStatus.completed));
                        GoRouter.of(context).pop();
                    } else if (sale.status == SaleStatus.partiallyPaid) {
                       ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Logique de paiement partiel à implémenter.')),
                      );
                    }
                  },
                  icon: const Icon(Icons.payment),
                  label: Text(sale.status == SaleStatus.pending ? "Marquer comme Payé" : "Ajouter Paiement"),
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
      currentSettings = const Settings(); // Use default constructor
      ScaffoldMessenger.of(invContext).showSnackBar(
        const SnackBar(content: Text('Paramètres par défaut utilisés pour la facture.')),
      );
    }
    
    try {
      final String filePath = await invoiceService.generateInvoicePdf(sale, currentSettings);
      final pdfFile = File(filePath); // Renamed variable to avoid conflict
      if (await pdfFile.exists()) {
        await Printing.sharePdf(bytes: await pdfFile.readAsBytes(), filename: 'invoice_${sale.id.substring(0,8)}.pdf');
      } else {
         if (invContext.mounted) {
          ScaffoldMessenger.of(invContext).showSnackBar(
            const SnackBar(content: Text('Erreur: Fichier PDF non trouvé après génération.')),
          );
        }
      }
    } catch (e) {
       if (invContext.mounted) {
        ScaffoldMessenger.of(invContext).showSnackBar(
          SnackBar(content: Text('Erreur lors de la génération ou du partage de la facture: $e')),
        );
      }
    }
  }
}
