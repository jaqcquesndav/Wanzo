import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';
import '../models/settings.dart';

/// Écran des paramètres de facturation
class InvoiceSettingsScreen extends StatefulWidget {
  /// Paramètres actuels
  final Settings settings;

  const InvoiceSettingsScreen({super.key, required this.settings});

  @override
  State<InvoiceSettingsScreen> createState() => _InvoiceSettingsScreenState();
}

class _InvoiceSettingsScreenState extends State<InvoiceSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _currencyController;
  late final TextEditingController _invoiceNumberFormatController;
  late final TextEditingController _invoicePrefixController;
  late final TextEditingController _paymentTermsController;
  late final TextEditingController _invoiceNotesController;
  late final TextEditingController _taxRateController;
  
  bool _showTaxes = true;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    
    // Initialise les contrôleurs avec les valeurs actuelles
    _currencyController = TextEditingController(text: widget.settings.currency);
    _invoiceNumberFormatController = TextEditingController(text: widget.settings.invoiceNumberFormat);
    _invoicePrefixController = TextEditingController(text: widget.settings.invoicePrefix);
    _paymentTermsController = TextEditingController(text: widget.settings.defaultPaymentTerms);
    _invoiceNotesController = TextEditingController(text: widget.settings.defaultInvoiceNotes);
    _taxRateController = TextEditingController(
      text: widget.settings.defaultTaxRate.toString(),
    );
    
    _showTaxes = widget.settings.showTaxes;
    
    // Écouteurs pour détecter les changements
    _currencyController.addListener(_onFieldChanged);
    _invoiceNumberFormatController.addListener(_onFieldChanged);
    _invoicePrefixController.addListener(_onFieldChanged);
    _paymentTermsController.addListener(_onFieldChanged);
    _invoiceNotesController.addListener(_onFieldChanged);
    _taxRateController.addListener(_onFieldChanged);
  }
  
  @override
  void dispose() {
    _currencyController.dispose();
    _invoiceNumberFormatController.dispose();
    _invoicePrefixController.dispose();
    _paymentTermsController.dispose();
    _invoiceNotesController.dispose();
    _taxRateController.dispose();
    super.dispose();
  }
  
  /// Détecte les changements dans les champs
  void _onFieldChanged() {
    final hasChanges = 
        _currencyController.text != widget.settings.currency ||
        _invoiceNumberFormatController.text != widget.settings.invoiceNumberFormat ||
        _invoicePrefixController.text != widget.settings.invoicePrefix ||
        _paymentTermsController.text != widget.settings.defaultPaymentTerms ||
        _invoiceNotesController.text != widget.settings.defaultInvoiceNotes ||
        _taxRateController.text != widget.settings.defaultTaxRate.toString() ||
        _showTaxes != widget.settings.showTaxes;
    
    if (hasChanges != _hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
  }

  /// Retourne le provider d'image approprié selon le chemin
  ImageProvider _getImageProvider(String imagePath) {
    if (imagePath.startsWith('assets/')) {
      return AssetImage(imagePath);
    } else {
      return FileImage(File(imagePath));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres de facturation'),
        actions: [
          if (_hasChanges)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveSettings,
              tooltip: 'Enregistrer',
            ),
        ],
      ),
      body: BlocListener<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state is SettingsUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            setState(() {
              _hasChanges = false;
            });
          } else if (state is SettingsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Paramètres généraux',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Devise
                TextFormField(
                  controller: _currencyController,
                  decoration: const InputDecoration(
                    labelText: 'Devise',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                    hintText: 'FC, \$, €, ...',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La devise est obligatoire';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                const Divider(),
                const SizedBox(height: 16),
                
                const Text(
                  'Format des factures',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Utilisez {YEAR} pour l\'année, {MONTH} pour le mois, {SEQ} pour le numéro de séquence.',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Aperçu de l'en-tête de facture
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Aperçu de l\'en-tête de facture',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                              image: widget.settings.companyLogo != null && widget.settings.companyLogo!.isNotEmpty
                                  ? DecorationImage(
                                      image: _getImageProvider(widget.settings.companyLogo!),
                                      fit: BoxFit.contain,
                                    )
                                  : null,
                            ),
                            child: widget.settings.companyLogo == null || widget.settings.companyLogo!.isEmpty
                                ? const Icon(
                                    Icons.business,
                                    size: 30,
                                    color: Colors.grey,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.settings.companyName.isEmpty ? 'Votre Entreprise' : widget.settings.companyName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                if (widget.settings.companyAddress.isNotEmpty)
                                  Text(
                                    widget.settings.companyAddress,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                Row(
                                  children: [
                                    if (widget.settings.companyPhone.isNotEmpty)
                                      Text(
                                        widget.settings.companyPhone,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    if (widget.settings.companyPhone.isNotEmpty && widget.settings.companyEmail.isNotEmpty)
                                      Text(
                                        ' | ',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    if (widget.settings.companyEmail.isNotEmpty)
                                      Text(
                                        widget.settings.companyEmail,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Format de numéro de facture
                TextFormField(
                  controller: _invoiceNumberFormatController,
                  decoration: const InputDecoration(
                    labelText: 'Format de numéro de facture',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.format_list_numbered),
                    hintText: 'Ex: INV-{YEAR}-{SEQ}',
                  ),
                ),
                const SizedBox(height: 16),
                
                // Préfixe de facture
                TextFormField(
                  controller: _invoicePrefixController,
                  decoration: const InputDecoration(
                    labelText: 'Préfixe de facture',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.library_books),
                    hintText: 'Ex: INV, FACT, ...',
                  ),
                ),
                const SizedBox(height: 16),
                
                const Divider(),
                const SizedBox(height: 16),
                
                const Text(
                  'Taxes et conditions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Afficher les taxes
                SwitchListTile(
                  title: const Text('Afficher les taxes sur les factures'),
                  value: _showTaxes,
                  onChanged: (value) {
                    setState(() {
                      _showTaxes = value;
                      _hasChanges = true;
                    });
                  },
                ),
                const SizedBox(height: 8),
                
                // Taux de taxe par défaut
                TextFormField(
                  controller: _taxRateController,
                  decoration: const InputDecoration(
                    labelText: 'Taux de taxe par défaut (%)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.percent),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (_showTaxes && (value == null || value.isEmpty)) {
                      return 'Le taux de taxe est obligatoire';
                    }
                    try {
                      if (value != null && value.isNotEmpty) {
                        final rate = double.parse(value);
                        if (rate < 0 || rate > 100) {
                          return 'Le taux doit être entre 0 et 100';
                        }
                      }
                    } catch (_) {
                      return 'Veuillez entrer un nombre valide';
                    }
                    return null;
                  },
                  enabled: _showTaxes,
                ),
                const SizedBox(height: 16),
                
                // Conditions de paiement
                TextFormField(
                  controller: _paymentTermsController,
                  decoration: const InputDecoration(
                    labelText: 'Conditions de paiement par défaut',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.payment),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                
                // Notes de facture
                TextFormField(
                  controller: _invoiceNotesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes par défaut sur les factures',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.note),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                
                // Bouton d'enregistrement
                if (_hasChanges)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveSettings,
                      child: const Text('Enregistrer les modifications'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Enregistre les modifications
  void _saveSettings() {
    if (_formKey.currentState?.validate() ?? false) {
      double taxRate;
      try {
        taxRate = double.parse(_taxRateController.text);
      } catch (_) {
        taxRate = widget.settings.defaultTaxRate;
      }
      
      context.read<SettingsBloc>().add(UpdateInvoiceSettings(
        currency: _currencyController.text.trim(),
        invoiceNumberFormat: _invoiceNumberFormatController.text.trim(),
        invoicePrefix: _invoicePrefixController.text.trim(),
        defaultPaymentTerms: _paymentTermsController.text.trim(),
        defaultInvoiceNotes: _invoiceNotesController.text.trim(),
        showTaxes: _showTaxes,
        defaultTaxRate: taxRate,
      ));
    }
  }
}
