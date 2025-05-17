import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";
import "package:intl/intl.dart";
import "../../../constants/spacing.dart";
import "../bloc/sales_bloc.dart";
import "../models/sale.dart";
import '../../settings/bloc/settings_bloc.dart';
import '../../settings/bloc/settings_state.dart';
import '../../invoice/services/invoice_service.dart';

/// Écran de détails d'une vente
class SaleDetailsScreen extends StatelessWidget {
  final Sale sale;

  const SaleDetailsScreen({
    super.key,
    required this.sale,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: "FC",
      decimalDigits: 0,
    );

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
          // Menu d'options
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == "edit") {
                // TODO: Naviguer vers l'écran d'édition
              } else if (value == "delete") {
                _showDeleteConfirmation(context);
              } else if (value == "print") {
                _printInvoice(context);
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
            // En-tête avec information générale
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(WanzoSpacing.base),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status de la vente
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
                            style: TextStyle(
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
                    // Information sur la date et le client
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
                    // Information sur le paiement
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
                    // Résumé des montants
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          currencyFormat.format(sale.totalAmount),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: WanzoSpacing.xs),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Payé"),
                        Text(currencyFormat.format(sale.paidAmount)),
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
                          currencyFormat.format(
                              sale.totalAmount - sale.paidAmount),
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
            // Liste des articles vendus
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
                      "${item.quantity} × ${currencyFormat.format(item.unitPrice)}",
                    ),
                    trailing: Text(
                      currencyFormat.format(item.totalPrice),
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
                onPressed: () => _printInvoice(context),
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
                    // Marquer la vente comme terminée
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

  /// Affiche une boîte de dialogue de confirmation pour supprimer la vente
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmer la suppression"),
        content: const Text(
            "Êtes-vous sûr de vouloir supprimer cette vente ? Cette action est irréversible."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<SalesBloc>().add(DeleteSale(sale.id));
              GoRouter.of(context).pop();
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

  /// Imprime la facture
  void _printInvoice(BuildContext context) async {
    final invoiceService = InvoiceService();
    final settingsBloc = context.read<SettingsBloc>();
    final settingsState = settingsBloc.state;
    
    String companyName = '';
    String companyAddress = '';
    String companyPhone = '';
    String companyEmail = '';
    String footerText = '';
      if (settingsState is SettingsLoaded) {
      companyName = settingsState.settings.companyName;
      companyAddress = settingsState.settings.companyAddress;
      companyPhone = settingsState.settings.companyPhone;
      companyEmail = settingsState.settings.companyEmail;
      footerText = settingsState.settings.defaultInvoiceNotes;
    }
    
    await invoiceService.generateAndShowReceipt(
      sale: sale,
      companyName: companyName,
      companyAddress: companyAddress,
      companyPhone: companyPhone,
      companyEmail: companyEmail,
      footerText: footerText,
      context: context,
    );
  }
}
