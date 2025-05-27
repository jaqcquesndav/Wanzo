import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wanzo/core/enums/currency_enum.dart';
import 'package:wanzo/core/services/currency_service.dart';
import 'package:wanzo/features/settings/bloc/settings_bloc.dart';
import 'package:wanzo/features/settings/bloc/settings_state.dart';
import 'package:wanzo/features/subscription/bloc/subscription_bloc.dart';
import 'package:wanzo/features/subscription/models/invoice_model.dart'; // Assuming Invoice class is here
import 'package:wanzo/features/subscription/models/subscription_tier_model.dart'; // Assuming SubscriptionTier class is here
import 'package:wanzo/l10n/generated/app_localizations.dart';
import 'package:wanzo/constants/spacing.dart';

// Placeholder events - these should be defined in subscription_event.dart
class SubmitManualPayment extends SubscriptionEvent {
  final String paymentMethod;
  final String proofPath;
  const SubmitManualPayment(this.paymentMethod, this.proofPath);
  @override List<Object?> get props => [paymentMethod, proofPath];
}

class UpdatePaymentMethod extends SubscriptionEvent {
  final String paymentMethod;
  const UpdatePaymentMethod(this.paymentMethod);
  @override List<Object?> get props => [paymentMethod];
}


class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final ImagePicker _picker = ImagePicker();
  String? _selectedPaymentMethod;
  String? _manualPaymentProofPath; // To store path for manual payment proof

  @override
  void initState() {
    super.initState();
    // Dispatch load event
    context.read<SubscriptionBloc>().add(LoadSubscriptionDetails());
  }

  Future<void> _pickImage(ImageSource source) async {
    final localizations = AppLocalizations.of(context)!;
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxHeight: 1024, // Optional: constrain image size
        maxWidth: 1024,  // Optional: constrain image size
        imageQuality: 85, // Optional: compress image
      );
      if (pickedFile != null) {
        // Validate file type and size (basic example)
        final fileBytes = await pickedFile.readAsBytes();
        final fileSizeInMB = fileBytes.lengthInBytes / (1024 * 1024);
        final fileExtension = pickedFile.path.split('.').last.toLowerCase();

        if (!['jpg', 'jpeg', 'png'].contains(fileExtension)) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(localizations.subscriptionUnsupportedFileType)),
          );
          return;
        }
        if (fileSizeInMB > 5) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(localizations.subscriptionFileTooLarge)),
          );
          return;
        }
        
        // If manual payment is selected, store the path
        if (_selectedPaymentMethod == 'manual_payment') {
          setState(() {
            _manualPaymentProofPath = pickedFile.path;
          });
        }
        if (!mounted) return;
        context.read<SubscriptionBloc>().add(UploadPaymentProof(pickedFile.path));

      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.subscriptionNoImageSelected)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: ${e.toString()}')),
      );
    }
  }

  void _showChangeSubscriptionDialog(BuildContext context, List<SubscriptionTier> tiers, SubscriptionTier? currentTier, Currency activeCurrency) {
    final localizations = AppLocalizations.of(context)!;
    final currencyService = Provider.of<CurrencyService>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(localizations.subscriptionChangeDialogTitle),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: tiers.length,
              itemBuilder: (context, index) {
                final tier = tiers[index];
                String formattedPrice;
                String tierDisplayName = tier.name;

                if (tier.price.toLowerCase() == 'free' || tier.price == localizations.subscriptionTierFree) {
                    formattedPrice = localizations.subscriptionTierFree;
                    if (tier.name.toLowerCase() == 'free') tierDisplayName = localizations.subscriptionTierFree;
                } else {
                    double? priceValue = double.tryParse(tier.price); // Assumes tier.price is numeric string if not "Free"
                    // This part needs robust parsing if tier.price can be "10 USD" etc.
                    // For now, assumes priceValue is in CDF if parsable, else displays raw.
                    formattedPrice = priceValue != null
                        ? currencyService.formatAmount(priceValue, displayCurrency: activeCurrency)
                        : tier.price;
                }
                
                return ListTile(
                  title: Text(tierDisplayName),
                  subtitle: Text(localizations.subscriptionChangeDialogTierSubtitle(formattedPrice, tier.adhaTokens.toString())),
                  selected: tier.type == currentTier?.type,
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
              child: Text(localizations.commonCancel),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showTopUpDialog(BuildContext context, Currency activeCurrency) {
    final localizations = AppLocalizations.of(context)!;
    // Example amounts - replace with actual top-up options
    final List<double> topUpAmounts = [5.0, 10.0, 20.0, 50.0]; 

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(localizations.subscriptionTopUpDialogTitle),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: topUpAmounts.length,
              itemBuilder: (context, index) {
                final amount = topUpAmounts[index];
                // Assuming amounts are in the active currency for simplicity here
                final formattedAmount = NumberFormat.currency(
                    symbol: activeCurrency.symbol, 
                    decimalDigits: 2,
                    // locale: activeCurrency.locale, // You might need a locale for proper formatting
                ).format(amount);

                return ListTile(
                  title: Text(localizations.subscriptionTopUpDialogAmount(formattedAmount, '')), // Passing empty currency code as amount is already formatted
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
              child: Text(localizations.commonCancel),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final settingsState = context.watch<SettingsBloc>().state;
    final Currency activeCurrency = (settingsState is SettingsLoaded) ? settingsState.settings.activeCurrency : Currency.CDF;
    final currencyService = Provider.of<CurrencyService>(context, listen: false);


    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.subscriptionScreenTitle),
      ),
      body: BlocConsumer<SubscriptionBloc, SubscriptionState>(
        listener: (context, state) {
          if (state is SubscriptionUpdateSuccess) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(localizations.subscriptionUpdateSuccessMessage), backgroundColor: Theme.of(context).colorScheme.secondary),
              );
          } else if (state is SubscriptionUpdateFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(localizations.subscriptionUpdateFailureMessage(state.error)), backgroundColor: Theme.of(context).colorScheme.error),
              );
          } else if (state is TokenTopUpSuccess) { // Corrected state name
             ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(localizations.subscriptionTokenTopUpSuccessMessage), backgroundColor: Theme.of(context).colorScheme.secondary),
              );
          } else if (state is TokenTopUpFailure) { // Corrected state name
             ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(localizations.subscriptionTokenTopUpFailureMessage(state.error)), backgroundColor: Theme.of(context).colorScheme.error),
              );
          } else if (state is PaymentProofUploadSuccess) { // Corrected state name
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(localizations.subscriptionPaymentProofUploadSuccessMessage), backgroundColor: Theme.of(context).colorScheme.secondary),
              );
          } else if (state is PaymentProofUploadFailure) { // Corrected state name
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(localizations.subscriptionPaymentProofUploadFailureMessage(state.error)), backgroundColor: Theme.of(context).colorScheme.error),
              );
          }
        },
        builder: (context, state) {
          if (state is SubscriptionLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SubscriptionLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<SubscriptionBloc>().add(LoadSubscriptionDetails());
              },
              child: ListView(
                padding: const EdgeInsets.all(WanzoSpacing.md),
                children: [
                  _buildSectionTitle(context, localizations.subscriptionSectionOurOffers),
                  _buildSubscriptionTiers(context, state.tiers, state.currentTier, activeCurrency), // Used state.tiers
                  const SizedBox(height: WanzoSpacing.lg),

                  _buildSectionTitle(context, localizations.subscriptionSectionCurrentSubscription),
                  _buildCurrentSubscriptionDetails(context, state.currentTier, activeCurrency, currencyService),
                  const SizedBox(height: WanzoSpacing.sm),
                  ElevatedButton(
                        onPressed: () => _showChangeSubscriptionDialog(context, state.tiers, state.currentTier, activeCurrency), // Used state.tiers
                        child: Text(localizations.subscriptionChangeSubscriptionButton), 
                      ),
                  const SizedBox(height: WanzoSpacing.lg),

                  _buildSectionTitle(context, localizations.subscriptionSectionTokenUsage),
                  _buildTokenUsage(context, state, activeCurrency),
                  const SizedBox(height: WanzoSpacing.lg),

                  _buildSectionTitle(context, localizations.subscriptionSectionInvoiceHistory),
                  _buildInvoiceHistory(context, state.invoices, activeCurrency, currencyService),
                  const SizedBox(height: WanzoSpacing.lg),
                  
                  _buildSectionTitle(context, localizations.subscriptionSectionPaymentMethods),
                  _buildPaymentMethods(context, state),
                  const SizedBox(height: WanzoSpacing.xl),
                ],
              ),
            );
          } else if (state is SubscriptionError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: WanzoSpacing.md),
                  ElevatedButton(
                    onPressed: () {
                      context.read<SubscriptionBloc>().add(LoadSubscriptionDetails());
                    },
                    child: Text(localizations.subscriptionRetryButton),
                  ),
                ],
              ),
            );
          }
          return Center(child: Text(localizations.subscriptionUnhandledState));
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: WanzoSpacing.md),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSubscriptionTiers(BuildContext context, List<SubscriptionTier> tiers, SubscriptionTier? currentTier, Currency activeCurrency) {
    // Assuming currentTier can be null if no subscription is active yet.
    // Or ensure currentTier is always one of the tiers or a default "none" tier.
    return SizedBox(
      height: 280, // Adjust height as needed
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tiers.length,
        itemBuilder: (context, index) {
          final tier = tiers[index];
          // Ensure currentTier is not null for comparison or handle nullability
          final bool isCurrent = currentTier != null && tier.type == currentTier.type;
          return Container(
            width: 220, // Adjust width as needed
            margin: const EdgeInsets.only(right: WanzoSpacing.md),
            child: _buildTierCard(context, tier, isCurrent, activeCurrency),
          );
        },
      ),
    );
  }

  Widget _buildTierCard(BuildContext context, SubscriptionTier tier, bool isCurrent, Currency activeCurrency) {
    final localizations = AppLocalizations.of(context)!;
    final currencyService = Provider.of<CurrencyService>(context, listen: false);
    
    String formattedPrice;
    if (tier.price.toLowerCase() == 'free' || tier.price == localizations.subscriptionTierFree) {
        formattedPrice = localizations.subscriptionTierFree;
    } else {
        double? priceValue = double.tryParse(tier.price);
        formattedPrice = priceValue != null
            ? currencyService.formatAmount(priceValue, displayCurrency: activeCurrency) // Assumes priceValue is in CDF
            : tier.price; // Fallback for "10 USD" etc. - needs better parsing
    }

    return Card(
      elevation: isCurrent ? 4.0 : 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(WanzoSpacing.sm),
        side: isCurrent ? BorderSide(color: Theme.of(context).primaryColor, width: 2) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(WanzoSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tier.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: WanzoSpacing.xs),
            Text(formattedPrice, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: WanzoSpacing.sm),
            Text(localizations.subscriptionTierUsers(int.tryParse(tier.users) ?? 0)),
            Text(localizations.subscriptionTierAdhaTokens(int.tryParse(tier.adhaTokens) ?? 0)),
            const SizedBox(height: WanzoSpacing.sm),
            Text(localizations.subscriptionTierFeatures, style: Theme.of(context).textTheme.labelLarge),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true, // Important for ListView inside Column
                itemCount: tier.features.length,
                itemBuilder: (context, idx) => Text('- ${tier.features[idx]}', style: Theme.of(context).textTheme.bodySmall),
              ),
            ),
            const SizedBox(height: WanzoSpacing.sm),
            if (isCurrent) ...[
              const SizedBox(height: WanzoSpacing.sm),
              Chip(
                label: Text(localizations.subscriptionTierCurrentPlanChip),
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                labelStyle: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
              ),
            ] else ...[
              const SizedBox(height: WanzoSpacing.md),
              ElevatedButton(
                onPressed: () {
                  context.read<SubscriptionBloc>().add(ChangeSubscriptionTier(tier.type));
                },
                child: Text(localizations.subscriptionTierChoosePlanButton),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentSubscriptionDetails(BuildContext context, SubscriptionTier? currentTier, Currency activeCurrency, CurrencyService currencyService) {
    final localizations = AppLocalizations.of(context)!;
    if (currentTier == null) {
      return Text(localizations.subscriptionNoActivePlan); // Added localization for no active plan
    }
    String formattedPrice;
    if (currentTier.price.toLowerCase() == 'free' || currentTier.price == localizations.subscriptionTierFree) {
        formattedPrice = localizations.subscriptionTierFree;
    } else {
        double? priceValue = double.tryParse(currentTier.price);
         formattedPrice = priceValue != null
            ? currencyService.formatAmount(priceValue, displayCurrency: activeCurrency) // Assumes priceValue is in CDF
            : currentTier.price; // Fallback
    }

    return Card(
      child: ListTile(
        title: Text(localizations.subscriptionCurrentPlanTitle(currentTier.name)),
        subtitle: Text(localizations.subscriptionCurrentPlanPrice(formattedPrice)),
      ),
    );
  }

  Widget _buildTokenUsage(BuildContext context, SubscriptionLoaded state, Currency activeCurrency) {
    final localizations = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(WanzoSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(localizations.subscriptionAvailableAdhaTokens(state.availableTokens)), // availableTokens is int
            const SizedBox(height: WanzoSpacing.md),
            ElevatedButton(
              onPressed: () => _showTopUpDialog(context, activeCurrency),
              child: Text(localizations.subscriptionTopUpTokensButton),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceHistory(BuildContext context, List<Invoice> invoices, Currency activeCurrency, CurrencyService currencyService) {
    final localizations = AppLocalizations.of(context)!;
    if (invoices.isEmpty) {
      return Center(child: Text(localizations.subscriptionNoInvoices));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: invoices.length,
      itemBuilder: (context, index) {
        final invoice = invoices[index];
        final formattedDate = DateFormat('dd/MM/yyyy').format(invoice.date);
        // Assuming invoice.amount is in CDF
        final formattedAmount = currencyService.formatAmount(invoice.amount, displayCurrency: activeCurrency);
        return Card(
          child: ListTile(
            title: Text(localizations.subscriptionInvoiceListTitle(invoice.id, formattedDate)),
            subtitle: Text(localizations.subscriptionInvoiceListSubtitle(formattedAmount, invoice.status)),
            trailing: IconButton(
              icon: const Icon(Icons.download_for_offline),
              tooltip: localizations.subscriptionDownloadInvoiceTooltip,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(localizations.subscriptionSimulateDownloadInvoice(invoice.id, invoice.downloadUrl ?? '')),
                  ),
                );
              },
            ),
            onTap: () {
               ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(localizations.subscriptionSimulateViewInvoiceDetails(invoice.id)),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPaymentMethods(BuildContext context, SubscriptionLoaded state) {
    final localizations = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(localizations.subscriptionPaymentMethodsNextInvoice, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: WanzoSpacing.md),
        
        Text(localizations.subscriptionPaymentMethodsRegistered, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
        const Text("No registered methods yet (placeholder)."), // Placeholder
        const SizedBox(height: WanzoSpacing.lg),

        Text(localizations.subscriptionPaymentMethodsOtherOptions, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
        RadioListTile<String>(
          title: Text(localizations.subscriptionPaymentMethodNewCard),
          value: 'new_card',
          groupValue: _selectedPaymentMethod,
          onChanged: (String? value) {
            setState(() { _selectedPaymentMethod = value; _manualPaymentProofPath = null; });
          },
        ),
        RadioListTile<String>(
          title: Text(localizations.subscriptionPaymentMethodNewMobileMoney),
          value: 'new_mobile_money',
          groupValue: _selectedPaymentMethod,
          onChanged: (String? value) {
            setState(() { _selectedPaymentMethod = value; _manualPaymentProofPath = null; });
          },
        ),
        RadioListTile<String>(
          title: Text(localizations.subscriptionPaymentMethodManual),
          value: 'manual_payment',
          groupValue: _selectedPaymentMethod,
          onChanged: (String? value) {
            setState(() { _selectedPaymentMethod = value; }); // Keep existing proof path if any
          },
        ),

        if (_selectedPaymentMethod == 'manual_payment')
          Padding(
            padding: const EdgeInsets.symmetric(vertical: WanzoSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(localizations.subscriptionManualPaymentInstructions, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: WanzoSpacing.md),
                if (state.uploadedProofName != null) // Display if a proof was uploaded via BLoC state
                  Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: WanzoSpacing.sm),
                      Expanded(child: Text(localizations.subscriptionProofUploadedLabel(state.uploadedProofName!))),
                    ],
                  )
                // This condition shows the locally picked file path before BLoC confirms upload
                else if (_manualPaymentProofPath != null)
                   Row(
                    children: [
                      const Icon(Icons.hourglass_top, color: Colors.orange),
                      const SizedBox(width: WanzoSpacing.sm),
                      Expanded(child: Text("Proof selected: ${_manualPaymentProofPath!.split(Platform.pathSeparator).last}")),
                    ],
                  ),
                const SizedBox(height: WanzoSpacing.sm),
                OutlinedButton.icon(
                  icon: Icon(state.uploadedProofName == null && _manualPaymentProofPath == null ? Icons.upload_file : Icons.refresh),
                  label: Text(state.uploadedProofName == null && _manualPaymentProofPath == null ? localizations.subscriptionUploadProofButton : localizations.subscriptionReplaceProofButton),
                  onPressed: () => _pickImage(ImageSource.gallery),
                ),
              ],
            ),
          ),
        
        const SizedBox(height: WanzoSpacing.lg),
        ElevatedButton(
          onPressed: _selectedPaymentMethod != null ? () {
            if (_selectedPaymentMethod == 'manual_payment') {
              if (_manualPaymentProofPath != null) {
                 context.read<SubscriptionBloc>().add(SubmitManualPayment(_selectedPaymentMethod!, _manualPaymentProofPath!));
              } else if (state.uploadedProofName != null) {
                // This case is tricky: if BLoC already has a proof, and user confirms, what path to submit?
                // For now, assume if _manualPaymentProofPath is null, but state.uploadedProofName is not,
                // we might need a way to re-submit based on existing proof or require re-upload.
                // Simplest: only allow submit if _manualPaymentProofPath is fresh.
                 ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please upload or re-upload a payment proof.")),
                 );
              } else {
                 ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please upload a payment proof for manual payment.")),
                 );
              }
            } else {
               context.read<SubscriptionBloc>().add(UpdatePaymentMethod(_selectedPaymentMethod!));
            }
             // Generic message, specific success/failure will come from BLoC listeners
             // ScaffoldMessenger.of(context).showSnackBar(
             //    SnackBar(content: Text(localizations.subscriptionSimulatePaymentMethodSelected(_selectedPaymentMethod!))),
             // );
          } : null,
          child: Text(localizations.subscriptionConfirmPaymentMethodButton),
        ),
      ],
    );
  }
}
