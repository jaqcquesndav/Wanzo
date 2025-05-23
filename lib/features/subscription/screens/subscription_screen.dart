import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart'; // Re-added for context.pop() and context.go()
import 'package:intl/intl.dart';

import 'package:wanzo/constants/spacing.dart';
import 'package:wanzo/core/utils/currency_formatter.dart'; // Added import
import 'package:wanzo/features/settings/bloc/settings_bloc.dart'; // Added import
import 'package:wanzo/features/settings/bloc/settings_state.dart'; // Added import
import 'package:wanzo/features/settings/models/settings.dart'; // Added import
import 'package:wanzo/features/subscription/bloc/subscription_bloc.dart';
import 'package:wanzo/features/subscription/models/subscription_tier_model.dart';
import 'package:wanzo/features/subscription/models/invoice_model.dart';
import 'package:wanzo/features/subscription/repositories/subscription_repository.dart';
import 'package:image_picker/image_picker.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SubscriptionBloc(
        subscriptionRepository: RepositoryProvider.of<SubscriptionRepository>(context),
      )..add(LoadSubscriptionDetails()),
      child: const SubscriptionView(),
    );
  }
}

class SubscriptionView extends StatefulWidget {
  const SubscriptionView({super.key});

  @override
  State<SubscriptionView> createState() => _SubscriptionViewState();
}

class _SubscriptionViewState extends State<SubscriptionView> {
  String? _selectedPaymentMethod;
  final DateFormat _invoiceDateFormat = DateFormat('dd/MM/yyyy');
  final ImagePicker _picker = ImagePicker();

  static const int _maxFileSizeInBytes = 5 * 1024 * 1024; // 5MB
  static const List<String> _supportedMimeTypes = ['image/jpeg', 'image/png'];
  static const List<String> _supportedExtensions = ['.jpg', '.jpeg', '.png'];

  Future<void> _pickImageAndUpload(BuildContext context) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (!mounted) return;

    if (image != null) {
      final String? mimeType = image.mimeType;
      final String fileName = image.name.toLowerCase();
      bool isSupported = false;

      if (mimeType != null) {
        if (_supportedMimeTypes.contains(mimeType.toLowerCase())) {
          isSupported = true;
        }
      } else {
        for (String ext in _supportedExtensions) {
          if (fileName.endsWith(ext)) {
            isSupported = true;
            break;
          }
        }
      }

      if (!isSupported) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Type de fichier non supporté. Veuillez choisir un fichier JPG ou PNG.')),
        );
        return;
      }

      final int fileSize = await image.length();
      if (!mounted) return;

      if (fileSize > _maxFileSizeInBytes) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fichier trop volumineux. La taille maximale est de 5MB.')),
        );
        return;
      }
      if (!mounted) return; // Added this line for robustness
      context.read<SubscriptionBloc>().add(UploadPaymentProof(image.path));
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucune image sélectionnée.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsState = context.watch<SettingsBloc>().state;
    CurrencyType currencyType;
    if (settingsState is SettingsLoaded) {
      currencyType = settingsState.settings.currency;
    } else if (settingsState is SettingsUpdated) {
      currencyType = settingsState.settings.currency;
    } else {
      currencyType = CurrencyType.cdf; // Default currency
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Abonnements'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
        ),
      ),
      body: BlocConsumer<SubscriptionBloc, SubscriptionState>(
        listener: (context, state) {
          if (state is SubscriptionUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Theme.of(context).colorScheme.secondary),
            );
          } else if (state is SubscriptionUpdateFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Theme.of(context).colorScheme.error),
            );
          } else if (state is TokenTopUpSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Theme.of(context).colorScheme.secondary),
            );
          } else if (state is TokenTopUpFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Theme.of(context).colorScheme.error),
            );
          } else if (state is PaymentProofUploadSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Theme.of(context).colorScheme.secondary),
            );
          } else if (state is PaymentProofUploadFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Theme.of(context).colorScheme.error),
            );
          }
        },
        builder: (context, state) {
          if (state is SubscriptionLoading || state is SubscriptionInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SubscriptionLoaded) {
            return _buildLoadedState(context, state, currencyType); // Pass currencyType
          } else if (state is SubscriptionError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 48),
                  const SizedBox(height: WanzoSpacing.md),
                  Text(state.message, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  const SizedBox(height: WanzoSpacing.md),
                  ElevatedButton(
                    onPressed: () => context.read<SubscriptionBloc>().add(LoadSubscriptionDetails()),
                    child: const Text('Réessayer'),
                  )
                ],
              ),
            );
          }
          return const Center(child: Text('État non géré ou initialisation...'));
        },
      ),
    );
  }

  Widget _buildLoadedState(BuildContext context, SubscriptionLoaded state, CurrencyType currencyType) { // Added currencyType parameter
    if (_selectedPaymentMethod == null && state.paymentMethods.isNotEmpty) {
      if (state.paymentMethods.any((pm) => pm.type == 'card')) {
        _selectedPaymentMethod = 'card';
      } else if (state.paymentMethods.any((pm) => pm.type == 'mobile_money')) {
        _selectedPaymentMethod = 'mobile_money';
      } else {
        _selectedPaymentMethod = state.paymentMethods.first.id; // Use id for groupValue
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(WanzoSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Nos Offres d\'Abonnement'),
          _buildSubscriptionTiers(context, state.tiers, state.currentTier, currencyType), // Pass currencyType
          const SizedBox(height: WanzoSpacing.lg),
          _buildSectionTitle('Votre Abonnement Actuel'),
          _buildCurrentSubscriptionStatus(context, state.currentTier, currencyType), // Pass currencyType
          const SizedBox(height: WanzoSpacing.lg),
          _buildSectionTitle('Utilisation des Tokens Adha'),
          _buildTokenUsage(context, state.tokenUsage, state.availableTokens),
          const SizedBox(height: WanzoSpacing.lg),
          _buildSectionTitle('Historique des Factures'),
          _buildInvoiceList(context, state.invoices, currencyType), // Pass currencyType
          const SizedBox(height: WanzoSpacing.lg),
          _buildSectionTitle('Méthodes de Paiement'),
          _buildPaymentMethods(context, state),
          const SizedBox(height: WanzoSpacing.xl),
          if (state.currentTier.type != SubscriptionTierType.premium)
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _showChangeSubscriptionDialog(context, state.tiers, state.currentTier);
                },
                child: const Text('Changer d\'abonnement'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: WanzoSpacing.sm),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSubscriptionTiers(BuildContext context, List<SubscriptionTier> tiers, SubscriptionTier currentTier, CurrencyType currencyType) { // Added currencyType
    return SizedBox(
      height: 290,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tiers.length,
        itemBuilder: (context, index) {
          final tier = tiers[index];
          final bool isCurrent = tier.type == currentTier.type;
          return _buildTierCard(context, tier, isCurrent, currencyType); // Pass currencyType
        },
      ),
    );
  }

  Widget _buildTierCard(BuildContext context, SubscriptionTier tier, bool isCurrent, CurrencyType currencyType) { // Added currencyType
    final double priceAmount = double.tryParse(tier.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;

    return Card(
      elevation: isCurrent ? 6 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isCurrent ? Theme.of(context).colorScheme.primary : Colors.grey.shade300, width: isCurrent ? 2 : 1),
      ),
      margin: const EdgeInsets.only(right: WanzoSpacing.md, bottom: WanzoSpacing.sm, top: WanzoSpacing.sm),
      child: Container(
        width: 230,
        padding: const EdgeInsets.all(WanzoSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tier.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
            const SizedBox(height: WanzoSpacing.xs),
            Text(tier.price.toLowerCase() == "gratuit" ? "Gratuit" : formatCurrency(priceAmount, currencyType), style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: WanzoSpacing.sm),
            Text('Utilisateurs: ${tier.users}'),
            Text('Tokens Adha: ${tier.adhaTokens}'),
            const SizedBox(height: WanzoSpacing.sm),
            Text('Fonctionnalités:', style: Theme.of(context).textTheme.labelLarge),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: tier.features.map((feature) => Text('• $feature', style: Theme.of(context).textTheme.bodySmall)).toList(),
                ),
              ),
            ),
            const SizedBox(height: WanzoSpacing.sm),
            if (isCurrent)
              Chip(
                label: const Text('Plan Actuel'),
                backgroundColor: Theme.of(context).colorScheme.secondaryContainer, // Adjusted to use theme color
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<SubscriptionBloc>().add(ChangeSubscriptionTier(tier.type));
                  },
                  child: const Text('Choisir ce plan'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentSubscriptionStatus(BuildContext context, SubscriptionTier currentTier, CurrencyType currencyType) { // Added currencyType
    final double priceAmount = double.tryParse(currentTier.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;

    return Card(
      child: ListTile(
        title: Text('Plan actuel: ${currentTier.name}'),
        subtitle: Text('Prix: ${currentTier.price.toLowerCase() == "gratuit" ? "Gratuit" : formatCurrency(priceAmount, currencyType)}'),
      ),
    );
  }

  Widget _buildTokenUsage(BuildContext context, double tokenUsage, int availableTokens) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(WanzoSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tokens Adha disponibles: $availableTokens'),
            const SizedBox(height: WanzoSpacing.sm),
            LinearProgressIndicator(
              value: tokenUsage,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
              minHeight: 10,
            ),
            const SizedBox(height: WanzoSpacing.md),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  _showTokenTopUpDialog(context);
                },
                child: const Text('Recharger des Tokens'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceList(BuildContext context, List<Invoice> invoices, CurrencyType currencyType) { // Added currencyType parameter
    if (invoices.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: WanzoSpacing.md),
          child: Text('Aucune facture disponible pour le moment.'),
        ),
      );
    }
    return Card(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: invoices.length,
        itemBuilder: (context, index) {
          final invoice = invoices[index];
          return ListTile(
            title: Text('Facture ${invoice.id} - ${_invoiceDateFormat.format(invoice.date)}'),
            subtitle: Text('Montant: ${formatCurrency(invoice.amount, currencyType)} - Statut: ${invoice.status}'),
            trailing: IconButton(
              icon: const Icon(Icons.download_for_offline_outlined),
              tooltip: 'Télécharger la facture',
              onPressed: invoice.downloadUrl != null && invoice.downloadUrl!.isNotEmpty
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Simulation: Téléchargement de ${invoice.id} depuis ${invoice.downloadUrl}')),
                      );
                    }
                  : null,
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Simulation: Voir détails de la facture ${invoice.id}')),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPaymentMethods(BuildContext context, SubscriptionLoaded loadedState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(WanzoSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Méthodes de paiement pour la prochaine facture:', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: WanzoSpacing.sm),
            if (loadedState.paymentMethods.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Méthodes enregistrées:", style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
                  ...loadedState.paymentMethods.map((pm) => RadioListTile<String>(
                        title: Text(pm.name),
                        subtitle: Text(pm.details ?? ''),
                        value: pm.id,
                        groupValue: _selectedPaymentMethod,
                        onChanged: (value) => setState(() => _selectedPaymentMethod = value),
                        secondary: Icon(pm.type == 'card' ? Icons.credit_card : Icons.phone_android),
                      )),
                  const Divider(),
                ],
              ),
            Text("Autres options de paiement:", style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
            RadioListTile<String>(
              title: const Text('Nouvelle Carte Bancaire'),
              value: 'new_card',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) => setState(() => _selectedPaymentMethod = value),
              secondary: const Icon(Icons.add_card),
            ),
            RadioListTile<String>(
              title: const Text('Nouveau Mobile Money'),
              value: 'new_mobile_money',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) => setState(() => _selectedPaymentMethod = value),
              secondary: const Icon(Icons.add_call),
            ),
            RadioListTile<String>(
              title: const Text('Paiement Manuel (Transfert/Dépôt)'),
              value: 'manual_payment',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) => setState(() => _selectedPaymentMethod = value),
              secondary: const Icon(Icons.receipt_long),
            ),
            if (_selectedPaymentMethod == 'manual_payment')
              Padding(
                padding: const EdgeInsets.only(top: WanzoSpacing.sm, left: WanzoSpacing.md, right: WanzoSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Veuillez effectuer le transfert/dépôt aux coordonnées qui seront fournies et télécharger une preuve de paiement.'),
                    const SizedBox(height: WanzoSpacing.sm),
                    if (loadedState.isUploadingProof)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else ...[
                      if (loadedState.uploadedProofName != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: WanzoSpacing.sm),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: Theme.of(context).colorScheme.secondary),
                              const SizedBox(width: WanzoSpacing.xs),
                              Expanded(child: Text('Preuve: ${loadedState.uploadedProofName}', overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                        ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.upload_file),
                        label: Text(loadedState.uploadedProofName == null ? 'Télécharger la preuve' : 'Remplacer la preuve'),
                        onPressed: () {
                          _pickImageAndUpload(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: loadedState.uploadedProofName == null ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.tertiary, // Adjusted to use theme colors
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            const SizedBox(height: WanzoSpacing.md),
            Center(
              child: ElevatedButton(
                onPressed: _selectedPaymentMethod != null
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Méthode de paiement sélectionnée: $_selectedPaymentMethod (Simulation)')),
                        );
                      }
                    : null,
                child: const Text('Confirmer la méthode de paiement'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangeSubscriptionDialog(BuildContext context, List<SubscriptionTier> tiers, SubscriptionTier currentTier) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Changer d\'abonnement'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: tiers.length,
              itemBuilder: (ctx, index) {
                final tier = tiers[index];
                if (tier.type == currentTier.type) return const SizedBox.shrink();
                return ListTile(
                  title: Text(tier.name),
                  subtitle: Text('${tier.price} - Tokens: ${tier.adhaTokens}'),
                  onTap: () {
                    context.read<SubscriptionBloc>().add(ChangeSubscriptionTier(tier.type));
                    Navigator.of(dialogContext).pop();
                  },
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showTokenTopUpDialog(BuildContext context) {
    final List<double> topUpAmounts = [500, 1000, 2000, 5000, 10000];
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Recharger des Tokens Adha'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: topUpAmounts.length,
              itemBuilder: (ctx, index) {
                final amount = topUpAmounts[index];
                return ListTile(
                  title: Text('${NumberFormat("#,##0", "fr_FR").format(amount)} FCFA'),
                  onTap: () {
                    context.read<SubscriptionBloc>().add(TopUpAdhaTokens(amount));
                    Navigator.of(dialogContext).pop();
                  },
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
