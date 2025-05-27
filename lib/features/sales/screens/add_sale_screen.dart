import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wanzo/core/enums/currency_enum.dart'; // Corrected: Currency is the enum name
import 'package:wanzo/core/models/currency_settings_model.dart';
import 'package:wanzo/core/utils/currency_formatter.dart';
import 'package:wanzo/features/customer/bloc/customer_bloc.dart';
import 'package:wanzo/features/customer/bloc/customer_event.dart';
import 'package:wanzo/features/customer/bloc/customer_state.dart';
import 'package:wanzo/features/customer/models/customer.dart';
import 'package:wanzo/features/inventory/bloc/inventory_bloc.dart';
import 'package:wanzo/features/inventory/bloc/inventory_event.dart';
import 'package:wanzo/features/inventory/bloc/inventory_state.dart';
import 'package:wanzo/features/inventory/models/product.dart';
import 'package:wanzo/features/invoice/services/invoice_service.dart';
import 'package:wanzo/features/settings/bloc/settings_bloc.dart' as old_settings_bloc;
import 'package:wanzo/features/settings/bloc/settings_event.dart' as old_settings_event;
import 'package:wanzo/features/settings/bloc/settings_state.dart' as old_settings_state;
import 'package:wanzo/features/settings/models/settings.dart' as old_settings_model;
import 'package:wanzo/features/settings/presentation/cubit/currency_settings_cubit.dart';
import '../../../constants/spacing.dart';
import '../bloc/sales_bloc.dart';
import '../models/sale.dart';
import '../models/sale_item.dart';

/// Écran d'ajout d'une nouvelle vente
class AddSaleScreen extends StatefulWidget {
  const AddSaleScreen({super.key});

  @override
  State<AddSaleScreen> createState() => _AddSaleScreenState();
}

class _AddSaleScreenState extends State<AddSaleScreen> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs pour les champs du formulaire
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _notesController = TextEditingController();

  String? _linkedCustomerId;
  Customer? _foundCustomer; // Pour stocker le client trouvé par numéro

  // Valeurs par défaut
  String _paymentMethod = 'Espèces';
  final List<SaleItem> _items = [];
  double _paidAmount = 0.0;

  // Currency related state
  Currency _defaultCurrency = Currency.CDF; // App default
  Currency? _selectedTransactionCurrency;
  double _transactionExchangeRate = 1.0; // Rate of _selectedTransactionCurrency to _defaultCurrency (CDF)
  Map<Currency, double> _exchangeRates = {}; // Stores rate_to_CDF for each currency
  List<Currency> _availableCurrencies = Currency.values;


  @override
  void initState() {
    super.initState();
    context.read<old_settings_bloc.SettingsBloc>().add(const old_settings_event.LoadSettings());
    context.read<InventoryBloc>().add(const LoadProducts());
    context.read<CustomerBloc>(); 
    
    final currencySettingsCubit = context.read<CurrencySettingsCubit>();
    // Access state directly after cubit is obtained
    final currentCurrencyState = currencySettingsCubit.state;
    if (currentCurrencyState.status == CurrencySettingsStatus.loaded) {
      _initializeCurrencySettings(currentCurrencyState.settings);
    } else {
       currencySettingsCubit.loadSettings(); // Trigger load if not already loaded
    }
  }

  void _initializeCurrencySettings(CurrencySettingsModel settings) {
    setState(() {
      _defaultCurrency = settings.defaultCurrency;
      _selectedTransactionCurrency = settings.defaultCurrency; 
      _exchangeRates = settings.exchangeRates;
      // Ensure _exchangeRates has a non-null entry for defaultCurrency for safety
      _transactionExchangeRate = settings.exchangeRates[settings.defaultCurrency] ?? 1.0;
      
      _availableCurrencies = settings.exchangeRates.keys
          .where((k) => settings.exchangeRates[k] != null && settings.exchangeRates[k]! > 0)
          .toList();
      
      // Ensure default currency is always available if it has a rate
      if (!_availableCurrencies.contains(settings.defaultCurrency) && 
          (settings.exchangeRates[settings.defaultCurrency] ?? 0) > 0) {
          _availableCurrencies.add(settings.defaultCurrency);
      }
      // If no currencies are available (e.g. all rates are 0 or null), add default as a fallback
      if (_availableCurrencies.isEmpty) {
          _availableCurrencies.add(settings.defaultCurrency);
      }

      if (_selectedTransactionCurrency == null || !_availableCurrencies.contains(_selectedTransactionCurrency)){
          _selectedTransactionCurrency = _availableCurrencies.isNotEmpty ? _availableCurrencies.first : settings.defaultCurrency;
      }
      _transactionExchangeRate = _exchangeRates[_selectedTransactionCurrency!] ?? 1.0;
    });
  }
  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _searchCustomerByPhone(String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      setState(() {
        _foundCustomer = null;
        _linkedCustomerId = null;
        _customerNameController.clear();
      });
      return;
    }
    context.read<CustomerBloc>().add(SearchCustomers(phoneNumber));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CurrencySettingsCubit, CurrencySettingsState>(
      listener: (context, state) {
        if (state.status == CurrencySettingsStatus.loaded) {
          _initializeCurrencySettings(state.settings);
        } else if (state.status == CurrencySettingsStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erreur chargement devises: ${state.errorMessage}')),
            );
        }
      },
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle vente'),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<SalesBloc, SalesState>(
            listener: (context, state) {
              if (state is SalesOperationSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                  ),
                );
                if (state.saleId != null) {
                  _handleSaleSuccess(state.saleId!);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ID de vente manquant, impossible de générer le document.')),
                  );
                  if (mounted) Navigator.of(context).pop();
                }
              } else if (state is SalesError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          BlocListener<CustomerBloc, CustomerState>(
            listener: (context, state) {
              if (state is CustomerSearchResults) {
                if (state.customers.isNotEmpty && state.customers.any((c) => c.phoneNumber == _customerPhoneController.text)) {
                  final matchedCustomer = state.customers.firstWhere((c) => c.phoneNumber == _customerPhoneController.text);
                  setState(() {
                    _foundCustomer = matchedCustomer;
                    _linkedCustomerId = matchedCustomer.id;
                    _customerNameController.text = matchedCustomer.name;
                  });
                } else {
                  setState(() {
                    _foundCustomer = null;
                    _linkedCustomerId = null;
                  });
                }
              } else if (state is CustomerError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Erreur recherche client: ${state.message}"),
                    backgroundColor: Colors.orange,
                  ),
                );
                setState(() {
                  _foundCustomer = null;
                  _linkedCustomerId = null;
                });
              }
            },
          ),
        ],
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(WanzoSpacing.md),
            children: [
              // Section client
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(WanzoSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person),
                          const SizedBox(width: WanzoSpacing.sm),
                          Text(
                            'Informations client',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: WanzoSpacing.sm),
                      TextFormField(
                        controller: _customerPhoneController,
                        decoration: InputDecoration(
                          labelText: 'Contact téléphonique du client *',
                          border: const OutlineInputBorder(),
                          hintText: 'Ex: 0812345678',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () {
                              _searchCustomerByPhone(_customerPhoneController.text);
                              FocusScope.of(context).unfocus();
                            },
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer le contact téléphonique';
                          }
                          if (!RegExp(r'^[0-9]{7,15}$').hasMatch(value)) {
                            return 'Numéro de téléphone invalide';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          if (_foundCustomer != null && _foundCustomer!.phoneNumber != value) {
                            setState(() {
                              _foundCustomer = null;
                              _linkedCustomerId = null;
                              _customerNameController.clear();
                            });
                          }
                        },
                      ),
                      const SizedBox(height: WanzoSpacing.md),
                      TextFormField(
                        controller: _customerNameController,
                        decoration: InputDecoration(
                          labelText: 'Nom du client *',
                          border: const OutlineInputBorder(),
                          filled: _foundCustomer != null,
                          fillColor: _foundCustomer != null ? Colors.green.withOpacity(0.05) : null,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer le nom du client';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: WanzoSpacing.md),
              // Section articles
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(WanzoSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.shopping_bag),
                              const SizedBox(width: WanzoSpacing.sm),
                              Text(
                                'Articles (${_items.length})',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('Ajouter'),
                            onPressed: _showAddItemDialog,
                          ),
                        ],
                      ),
                      const Divider(),
                      if (_items.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: WanzoSpacing.md),
                          child: Center(
                            child: Text(
                              'Aucun article ajouté',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        )
                      else
                        _buildItemsList(), // Updated to use transaction currency
                    ],
                  ),
                ),
              ),
              const SizedBox(height: WanzoSpacing.md),
              // Section paiement
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(WanzoSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.payment),
                          const SizedBox(width: WanzoSpacing.sm),
                          Text(
                            'Informations de paiement',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: WanzoSpacing.sm),

                      // Currency Selector
                      if (_availableCurrencies.length > 1) ...[
                        DropdownButtonFormField<Currency>(
                          value: _selectedTransactionCurrency,
                          decoration: const InputDecoration(
                            labelText: 'Devise de la transaction',
                            border: OutlineInputBorder(),
                          ),
                          items: _availableCurrencies.map((Currency currency) {
                            return DropdownMenuItem<Currency>(
                              value: currency,
                              child: Text(currency.displayName(context)), // Use context for potential localization
                            );
                          }).toList(),
                          onChanged: (Currency? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedTransactionCurrency = newValue;
                                _transactionExchangeRate = _exchangeRates[newValue] ?? 1.0;
                                if (_paymentMethod != 'Crédit') {
                                   _paidAmount = _calculateTotalInTransactionCurrency();
                                }
                              });
                            }
                          },
                           validator: (value) => value == null ? 'Sélectionnez une devise' : null,
                        ),
                        const SizedBox(height: WanzoSpacing.md),
                        if (_selectedTransactionCurrency != null && _selectedTransactionCurrency != _defaultCurrency)
                          Padding(
                            padding: const EdgeInsets.only(bottom: WanzoSpacing.sm),
                            child: Text(
                              'Taux: 1 ${_selectedTransactionCurrency?.code} = ${formatNumber(_transactionExchangeRate)} ${_defaultCurrency.code}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                      ],

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Montant total'),
                          Text(
                            formatCurrency(_calculateTotalInTransactionCurrency(), _selectedTransactionCurrency?.code ?? _defaultCurrency.code),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: WanzoSpacing.md),
                      TextFormField(
                        key: ValueKey(_selectedTransactionCurrency), 
                        initialValue: _paidAmount.toStringAsFixed(2),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Montant payé',
                          border: const OutlineInputBorder(),
                          prefixText: '${_selectedTransactionCurrency?.symbol ?? _defaultCurrency.symbol} ',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Veuillez entrer le montant payé';
                          final amount = double.tryParse(value);
                          if (amount == null) return 'Montant invalide';
                          if (amount < 0) return 'Le montant ne peut pas être négatif';
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _paidAmount = double.tryParse(value) ?? 0.0;
                          });
                        },
                      ),
                      const SizedBox(height: WanzoSpacing.md),
                      DropdownButtonFormField<String>(
                        value: _paymentMethod,
                        decoration: const InputDecoration(labelText: 'Méthode de paiement', border: OutlineInputBorder()),
                        items: const [
                          DropdownMenuItem(value: 'Espèces', child: Text('Espèces')),
                          DropdownMenuItem(value: 'Mobile Money', child: Text('Mobile Money')),
                          DropdownMenuItem(value: 'Carte bancaire', child: Text('Carte bancaire')),
                          DropdownMenuItem(value: 'Virement bancaire', child: Text('Virement bancaire')),
                          DropdownMenuItem(value: 'Crédit', child: Text('Crédit')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _paymentMethod = value!;
                            if (_paymentMethod != 'Crédit') {
                              _paidAmount = _calculateTotalInTransactionCurrency();
                            } 
                          });
                        },
                      ),
                      const SizedBox(height: WanzoSpacing.md),
                      if (_items.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: WanzoSpacing.sm, horizontal: WanzoSpacing.md),
                          decoration: BoxDecoration(
                            color: _getPaymentStatusColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _getPaymentStatusColor()),
                          ),
                          child: Text(
                            _getPaymentStatusText(),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: _getPaymentStatusColor(), fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: WanzoSpacing.md),
              // Section notes
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(WanzoSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.note),
                          const SizedBox(width: WanzoSpacing.sm),
                          Text(
                            'Notes (optionnel)',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: WanzoSpacing.sm),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Ajouter des notes ou commentaires...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: WanzoSpacing.lg),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(WanzoSpacing.md),
          child: BlocBuilder<SalesBloc, SalesState>(
            builder: (context, state) {
              bool isLoading = state is SalesLoading;
              return ElevatedButton(
                onPressed: (_items.isEmpty || isLoading || _selectedTransactionCurrency == null) ? null : _saveSale,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: WanzoSpacing.md),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Enregistrer la vente', style: TextStyle(fontSize: 16)),
              );
            },
          ),
        ),
      ),
    ));
  }

  Color _getPaymentStatusColor() {
    final total = _calculateTotalInTransactionCurrency();
    if (_paymentMethod == 'Crédit') {
      if (_paidAmount == 0) return Colors.orange;
      if (_paidAmount < total) return Colors.blue;
      return Colors.green;
    }
    return _isPaidFully() ? Colors.green : Colors.red;
  }

  String _getPaymentStatusText() {
    final total = _calculateTotalInTransactionCurrency();
    final currencyCode = _selectedTransactionCurrency?.code ?? _defaultCurrency.code;
    if (_paymentMethod == 'Crédit') {
      if (_paidAmount == 0) return 'Vente à crédit (aucun acompte)';
      if (_paidAmount < total) {
        return 'Acompte: ${formatCurrency(_paidAmount, currencyCode)}, Reste: ${formatCurrency(total - _paidAmount, currencyCode)}';
      }
      return 'Payé (crédit soldé)';
    }
    if (_isPaidFully()) return 'Entièrement payé';
    return 'Reste à payer: ${formatCurrency(total - _paidAmount, currencyCode)}';
  }

  Future<void> _handleSaleSuccess(String saleId) async {
    final oldSettingsBlocState = context.read<old_settings_bloc.SettingsBloc>().state;
    old_settings_model.Settings? currentLegacySettings;
    if (oldSettingsBlocState is old_settings_state.SettingsLoaded) {
      currentLegacySettings = oldSettingsBlocState.settings;
    } else if (oldSettingsBlocState is old_settings_state.SettingsUpdated) {
      currentLegacySettings = oldSettingsBlocState.settings;
    }

    if (currentLegacySettings == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur: Paramètres (anciens) non chargés pour la génération du document.')),
      );
      if (mounted) Navigator.of(context).pop();
      return;
    }

    final totalInTransactionCurrency = _calculateTotalInTransactionCurrency();
    final currentRate = _exchangeRates[_selectedTransactionCurrency!] ?? 1.0;
    final totalInCdf = totalInTransactionCurrency * currentRate;
    final paidInCdf = _paidAmount * currentRate;

    final saleForPdf = Sale(
      id: saleId, 
      date: DateTime.now(), 
      customerId: _linkedCustomerId ?? 'new_cust_ph_${_customerPhoneController.text.isNotEmpty ? _customerPhoneController.text.replaceAll(RegExp(r'[^0-9]'), '') : DateTime.now().millisecondsSinceEpoch}',
      customerName: _customerNameController.text,
      items: List<SaleItem>.from(_items), 
      totalAmountInCdf: totalInCdf,
      paidAmountInCdf: paidInCdf,
      transactionCurrencyCode: _selectedTransactionCurrency!.code,
      transactionExchangeRate: currentRate,
      totalAmountInTransactionCurrency: totalInTransactionCurrency,
      paidAmountInTransactionCurrency: _paidAmount,
      paymentMethod: _paymentMethod,
      status: _isPaidFully() ? SaleStatus.completed : SaleStatus.pending,
      notes: _notesController.text,
    );

    final invoiceService = InvoiceService();
    String? pdfPath;
    String documentType = '';

    if (_paymentMethod == 'Crédit' && !_isPaidFully()) {
      documentType = 'Facture';
      pdfPath = await invoiceService.generateInvoicePdf(saleForPdf, currentLegacySettings);
    } else {
      documentType = 'Reçu';
      pdfPath = await invoiceService.generateReceiptPdf(saleForPdf, currentLegacySettings);
    }

    if (pdfPath.isNotEmpty) { // Simplified from: pdfPath != null && pdfPath.isNotEmpty
      _showDocumentOptions(pdfPath, documentType, saleForPdf, currentLegacySettings);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible de générer le $documentType. Chemin non valide.')),
      );
      if (mounted) Navigator.of(context).pop();
    }
  }

  void _showDocumentOptions(String pdfPath, String documentType, Sale sale, old_settings_model.Settings settings) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        final invoiceService = InvoiceService();
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.visibility),
                title: Text('Prévisualiser $documentType'),
                onTap: () async {
                  Navigator.pop(bc);
                  await invoiceService.previewDocument(pdfPath);
                  if (mounted) Navigator.of(context).pop(); 
                },
              ),
              ListTile(
                leading: const Icon(Icons.print),
                title: Text('Imprimer $documentType'),
                onTap: () async {
                  Navigator.pop(bc);
                  await invoiceService.printDocument(pdfPath);
                   if (mounted) Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: Text('Partager $documentType'),
                onTap: () async {
                  Navigator.pop(bc);
                  await invoiceService.shareInvoice(sale, settings, customerPhoneNumber: _customerPhoneController.text);
                   if (mounted) Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Fermer et continuer'),
                onTap: () {
                  Navigator.pop(bc);
                  if (mounted) Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItemsList() {
    final currencyCode = _selectedTransactionCurrency?.code ?? _defaultCurrency.code;
    final currencySymbol = _selectedTransactionCurrency?.symbol ?? _defaultCurrency.symbol;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: WanzoSpacing.sm),
          child: Row(
            children: [
              Expanded(flex: 3, child: Text('Produit', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold))),
              Expanded(flex: 1, child: Text('Qté', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
              Expanded(flex: 2, child: Text('Prix U. ($currencySymbol)', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
              const SizedBox(width: WanzoSpacing.md), // For delete icon
            ],
          ),
        ),
        const Divider(),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _items.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final item = _items[index];
            return Row(
              children: [
                Expanded(flex: 3, child: Text(item.productName)),
                Expanded(flex: 1, child: Text('${item.quantity.toInt()}', textAlign: TextAlign.center)),
                Expanded(flex: 2, child: Text(formatCurrency(item.unitPrice, item.currencyCode), textAlign: TextAlign.right)),
                IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), onPressed: () => _removeItem(index)),
              ],
            );
          },
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: WanzoSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              Text(
                formatCurrency(_calculateTotalInTransactionCurrency(), currencyCode),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddItemDialog() {
    final productNameController = TextEditingController();
    final productIdController = TextEditingController();
    final quantityController = TextEditingController(text: '1');
    final unitPriceController = TextEditingController();
    Product? selectedProductForDialog;
    final GlobalKey<FormState> addItemFormKey = GlobalKey<FormState>();

    final dialogCurrency = _selectedTransactionCurrency;
    if (dialogCurrency == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez d\'abord sélectionner une devise pour la transaction.'), backgroundColor: Colors.red),
      );
      return;
    }
    final dialogCurrencyCode = dialogCurrency.code;
    final dialogCurrencySymbol = dialogCurrency.symbol;
    final currentTransactionExchangeRateToCdf = _exchangeRates[dialogCurrency] ?? 1.0;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            double calculatedTotalPrice = 0;
            final qty = int.tryParse(quantityController.text);
            final price = double.tryParse(unitPriceController.text);
            if (qty != null && price != null) calculatedTotalPrice = qty * price;

            return AlertDialog(
              title: const Text('Ajouter un article'),
              content: Form(
                key: addItemFormKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BlocBuilder<InventoryBloc, InventoryState>(
                        builder: (context, state) {
                          List<Product> productSuggestions = state is ProductsLoaded ? state.products : [];
                          return Autocomplete<Product>(
                            displayStringForOption: (Product option) => option.name,
                            optionsBuilder: (TextEditingValue textEditingValue) {
                              if (textEditingValue.text.isEmpty) return const Iterable<Product>.empty();
                              return productSuggestions.where((Product p) => p.name.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                            },
                            onSelected: (Product selection) {
                              setStateDialog(() {
                                selectedProductForDialog = selection;
                                productNameController.text = selection.name;
                                productIdController.text = selection.id;
                                if (currentTransactionExchangeRateToCdf > 0) {
                                   unitPriceController.text = (selection.sellingPrice / currentTransactionExchangeRateToCdf).toStringAsFixed(2);
                                } else {
                                   unitPriceController.text = selection.sellingPrice.toStringAsFixed(2);
                                }
                                if (quantityController.text.isEmpty || quantityController.text == '0') quantityController.text = '1';
                              });
                            },
                            fieldViewBuilder: (ctx, controller, focusNode, onSubmitted) {
                              return TextFormField(
                                controller: productNameController,
                                focusNode: focusNode,
                                decoration: const InputDecoration(labelText: 'Nom du produit', border: OutlineInputBorder(), hintText: 'Rechercher...'),
                                onChanged: (value) {
                                  if (selectedProductForDialog != null && selectedProductForDialog!.name != value) {
                                      setStateDialog((){
                                        selectedProductForDialog = null;
                                        productIdController.clear(); 
                                      });
                                  }
                                },
                                validator: (v) => v == null || v.isEmpty ? 'Nom requis' : null,
                              );
                            },
                            optionsViewBuilder: (ctx, onSelected, options) {
                              return Align(
                                alignment: Alignment.topLeft,
                                child: Material(
                                  elevation: 4.0,
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(maxHeight: 200),
                                    child: ListView.builder(
                                      padding: EdgeInsets.zero, shrinkWrap: true, itemCount: options.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        final Product option = options.elementAt(index);
                                        String displayPrice;
                                        if (currentTransactionExchangeRateToCdf > 0) {
                                            displayPrice = formatCurrency(option.sellingPrice / currentTransactionExchangeRateToCdf, dialogCurrencyCode);
                                        } else {
                                            displayPrice = formatCurrency(option.sellingPrice, _defaultCurrency.code) + " (CDF)";
                                        }
                                        return InkWell(onTap: () => onSelected(option), child: ListTile(title: Text(option.name), subtitle: Text('Stock: ${option.stockQuantity}, Prix: $displayPrice')));
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: WanzoSpacing.md),
                      TextFormField(
                        controller: quantityController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(labelText: 'Quantité', border: OutlineInputBorder()),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Quantité requise';
                          final q = int.tryParse(v);
                          if (q == null || q <= 0) return 'Quantité invalide';
                          if (selectedProductForDialog != null && q > selectedProductForDialog!.stockQuantity) return 'Stock insuffisant (${selectedProductForDialog!.stockQuantity})';
                          return null;
                        },
                        onChanged: (_) => setStateDialog(() {}),
                      ),
                      const SizedBox(height: WanzoSpacing.md),
                      TextFormField(
                        controller: unitPriceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                        decoration: InputDecoration(labelText: 'Prix unitaire', border: const OutlineInputBorder(), prefixText: '$dialogCurrencySymbol '),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Prix requis';
                          final p = double.tryParse(v);
                          if (p == null || p <= 0) return 'Prix invalide';
                          return null;
                        },
                        onChanged: (_) => setStateDialog(() {}),
                      ),
                      const SizedBox(height: WanzoSpacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Prix total:'),
                          Text(formatCurrency(calculatedTotalPrice, dialogCurrencyCode), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Annuler')),
                ElevatedButton(
                  onPressed: () {
                    if (addItemFormKey.currentState!.validate()) {
                      final String productName = productNameController.text;
                      final int currentQuantity = int.parse(quantityController.text);
                      final double unitPriceInSelectedCurrency = double.parse(unitPriceController.text);
                      final String resolvedProductId = selectedProductForDialog?.id ?? productIdController.text.takeIf((it) => it.isNotEmpty) ?? 'manual-${DateTime.now().millisecondsSinceEpoch}';
                      final totalPriceInSelectedCurrency = currentQuantity * unitPriceInSelectedCurrency;
                      final unitPriceInCdf = unitPriceInSelectedCurrency * currentTransactionExchangeRateToCdf;
                      final totalPriceInCdf = totalPriceInSelectedCurrency * currentTransactionExchangeRateToCdf;

                      _addItem(
                        SaleItem(
                          productId: resolvedProductId,
                          productName: productName,
                          quantity: currentQuantity,
                          unitPrice: unitPriceInSelectedCurrency,
                          totalPrice: totalPriceInSelectedCurrency,
                          currencyCode: dialogCurrency.code,
                          exchangeRate: currentTransactionExchangeRateToCdf,
                          unitPriceInCdf: unitPriceInCdf,
                          totalPriceInCdf: totalPriceInCdf,
                        ),
                      );
                      Navigator.pop(dialogContext);
                    }
                  },
                  child: const Text('Ajouter'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addItem(SaleItem item) {
    setState(() {
      _items.add(item);
      if (_paymentMethod != 'Crédit') _paidAmount = _calculateTotalInTransactionCurrency();
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
      if (_paymentMethod != 'Crédit') _paidAmount = _calculateTotalInTransactionCurrency();
    });
  }

  double _calculateTotalInTransactionCurrency() {
    return _items.fold(0.0, (total, item) => total + item.totalPrice);
  }

  bool _isPaidFully() {
    final total = _calculateTotalInTransactionCurrency();
    return (_paidAmount - total).abs() < 0.001 || _paidAmount >= total;
  }
  
  void _saveSale() {
    if (_formKey.currentState!.validate() && _items.isNotEmpty) {
      if (_selectedTransactionCurrency == null) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez sélectionner une devise.'), backgroundColor: Colors.red));
        return;
      }

      final totalInTransactionCurrency = _calculateTotalInTransactionCurrency();
      final currentRate = _exchangeRates[_selectedTransactionCurrency!] ?? 1.0;
      final totalInCdf = totalInTransactionCurrency * currentRate;
      final paidInCdf = _paidAmount * currentRate;

      final sale = Sale(
        id: '', 
        date: DateTime.now(),
        customerId: _linkedCustomerId ?? 'new_cust_ph_${_customerPhoneController.text.isNotEmpty ? _customerPhoneController.text.replaceAll(RegExp(r'[^0-9]'), '') : DateTime.now().millisecondsSinceEpoch}',
        customerName: _customerNameController.text,
        items: List<SaleItem>.from(_items), 
        totalAmountInCdf: totalInCdf,
        paidAmountInCdf: paidInCdf,
        transactionCurrencyCode: _selectedTransactionCurrency!.code,
        transactionExchangeRate: currentRate,
        totalAmountInTransactionCurrency: totalInTransactionCurrency,
        paidAmountInTransactionCurrency: _paidAmount,
        paymentMethod: _paymentMethod,
        status: _isPaidFully() ? SaleStatus.completed : SaleStatus.pending,
        notes: _notesController.text,
      );
      context.read<SalesBloc>().add(AddSale(sale));
    } else if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez ajouter au moins un article.')));
    }
  }

  String formatNumber(double number, {int decimalDigits = 2}) => number.toStringAsFixed(decimalDigits);
}

// Extension for String.isNotEmpty
extension StringExtension on String {
  String? takeIf(bool Function(String) predicate) {
    return predicate(this) ? this : null;
  }
}

// TODO: Update currency_formatter.dart to use CurrencyEnum instead of old CurrencyType.
// For now, formatCurrency(double amount, String currencyCodeOrSymbol) is assumed to work.
