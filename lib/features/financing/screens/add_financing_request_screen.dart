import 'dart:io'; // Import for File
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'package:uuid/uuid.dart';
import '../../../constants/constants.dart';
import '../../../core/shared_widgets/wanzo_scaffold.dart';
import '../../settings/bloc/settings_bloc.dart';
import '../../settings/bloc/settings_state.dart';
import '../bloc/financing_bloc.dart';
import '../models/financing_request.dart';
import '../../../core/enums/currency_enum.dart';

class AddFinancingRequestScreen extends StatefulWidget {
  const AddFinancingRequestScreen({super.key});

  @override
  State<AddFinancingRequestScreen> createState() =>
      _AddFinancingRequestScreenState();
}

class _AddFinancingRequestScreenState extends State<AddFinancingRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _reasonController = TextEditingController();
  FinancingType _selectedFinancingType = FinancingType.cashCredit;
  FinancialInstitution _selectedInstitution = FinancialInstitution.bonneMoisson;  String? _attachmentPath; // Added for attachment path
  final int _creditScore = 75;
  final ImagePicker _picker = ImagePicker(); // ImagePicker instance

  void _showCreditScoreInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Votre Cote de Crédit'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Votre cote actuelle: $_creditScore / 100\n'),
              const Text(
                'Avantages par intervalle:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: WanzoSpacing.sm),
              const Text('0-30: Accès limité, taux élevés.'),
              const Text('31-50: Accès modéré, conditions standards.'),
              const Text('51-70: Bon accès, conditions favorables.'),
              const Text('71-85: Très bon accès, conditions très avantageuses.'),
              const Text('86-100: Excellent accès, meilleures conditions du marché.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _submitRequest(Currency currency) { // Changed CurrencyType to Currency
    if (_formKey.currentState!.validate()) {
      final amount = double.tryParse(_amountController.text);
      if (amount == null || amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez entrer un montant valide.')),
        );
        return;
      }      
      
      // Vérifier si la pièce jointe existe et est accessible
      if (_attachmentPath != null) {
        final file = File(_attachmentPath!);
        if (!file.existsSync()) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('La pièce jointe sélectionnée n\'est pas accessible.')),
          );
          // Continuer quand même car la pièce jointe est optionnelle
        }
      }
        final newRequest = FinancingRequest(
        id: const Uuid().v4(),
        amount: amount,
        currency: currency.code, // Used currency.code instead of currency.name
        reason: _reasonController.text,
        type: _selectedFinancingType,
        institution: _selectedInstitution,
        requestDate: DateTime.now(),
        attachmentPaths: _attachmentPath != null ? [_attachmentPath!] : null, // Updated to use attachmentPaths
      );

      context.read<FinancingBloc>().add(AddFinancingRequest(newRequest));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) {
        Currency currentCurrency = Currency.USD; // Changed CurrencyType to Currency and default value
        String currencySymbol = currentCurrency.symbol; // Used .symbol getter

        if (settingsState is SettingsLoaded) {
          currentCurrency = settingsState.settings.activeCurrency; // Changed to activeCurrency
          currencySymbol = currentCurrency.symbol; // Used .symbol getter
        } else if (settingsState is SettingsUpdated) {
          currentCurrency = settingsState.settings.activeCurrency; // Changed to activeCurrency
          currencySymbol = currentCurrency.symbol; // Used .symbol getter
        }

        return WanzoScaffold(
          title: 'Nouvelle Demande de Financement',
          currentIndex: 0,
          body: BlocListener<FinancingBloc, FinancingState>(
            listener: (context, financingBlocState) {
              if (financingBlocState is FinancingOperationSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(financingBlocState.message)),
                );
                if (context.canPop()) {
                  context.pop();
                }
              } else if (financingBlocState is FinancingError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erreur: ${financingBlocState.message}')),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(WanzoSpacing.md),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    Card(
                      color: Theme.of(context).colorScheme.primary.withAlpha((255 * 0.1).round()),
                      elevation: 0,
                      child: ListTile(
                        leading: Icon(Icons.shield_outlined, color: Theme.of(context).colorScheme.primary, size: 30),
                        title: Text(
                          'Votre Cote de Crédit: $_creditScore / 100',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                          onPressed: _showCreditScoreInfo,
                        ),
                      ),
                    ),
                    const SizedBox(height: WanzoSpacing.lg),

                    TextFormField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        labelText: 'Montant demandé',
                        prefixText: '$currencySymbol ',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un montant.';
                        }
                        if (double.tryParse(value) == null ||
                            double.parse(value) <= 0) {
                          return 'Veuillez entrer un montant valide.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: WanzoSpacing.md),
                    TextFormField(
                      controller: _reasonController,
                      decoration: const InputDecoration(labelText: 'Motif de la demande'),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le motif.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: WanzoSpacing.md),
                    DropdownButtonFormField<FinancingType>(
                      value: _selectedFinancingType,
                      decoration: const InputDecoration(labelText: 'Type de financement'),
                      items: FinancingType.values.map((FinancingType type) {
                        return DropdownMenuItem<FinancingType>(
                          value: type,
                          child: Text(type.displayName),
                        );
                      }).toList(),
                      onChanged: (FinancingType? newValue) {
                        setState(() {
                          _selectedFinancingType = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: WanzoSpacing.md),
                    DropdownButtonFormField<FinancialInstitution>(
                      value: _selectedInstitution,
                      decoration: const InputDecoration(labelText: 'Institution Financière'),
                      items: FinancialInstitution.values
                          .map((FinancialInstitution institution) {
                        return DropdownMenuItem<FinancialInstitution>(
                          value: institution,
                          child: Text(institution.displayName),
                        );
                      }).toList(),
                      onChanged: (FinancialInstitution? newValue) {
                        setState(() {
                          _selectedInstitution = newValue!;
                        });
                      },
                    ),                    const SizedBox(height: WanzoSpacing.md),
                    // Attachment Picker Button
                    ElevatedButton.icon(
                      icon: const Icon(Icons.attach_file),
                      label: Text(_attachmentPath == null 
                          ? 'Ajouter une pièce jointe (Optionnel)' 
                          : 'Pièce jointe: ${_attachmentPath!.split('/').last}'),
                      onPressed: _pickAttachment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        foregroundColor: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                    if (_attachmentPath != null)
                      Padding(
                        padding: const EdgeInsets.only(top: WanzoSpacing.sm),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Pièce jointe acceptée: facture, devis, lettre d'intention, projet, etc.",
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                              onPressed: () {
                                setState(() {
                                  _attachmentPath = null;
                                });
                              },
                              tooltip: 'Supprimer la pièce jointe',
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: WanzoSpacing.xl),
                    ElevatedButton(
                      onPressed: () => _submitRequest(currentCurrency),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary),
                      child: BlocBuilder<FinancingBloc, FinancingState>(
                        builder: (context, financingBlocState) {
                          if (financingBlocState is FinancingLoading) {
                            return SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.onPrimary)
                            );
                          }
                          return Text('Soumettre la Demande',
                              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary));
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }  Future<void> _pickAttachment() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85
      );
      
      // Check if the widget is still mounted before using setState
      if (!mounted) return;
      
      if (pickedFile != null) {
        setState(() {
          _attachmentPath = pickedFile.path;
        });
      }
    } catch (e) {
      // Check if the widget is still mounted before using context
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la sélection du fichier: $e')),
      );
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }
}
