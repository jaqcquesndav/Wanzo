import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wanzo/features/customer/bloc/customer_bloc.dart';
import 'package:wanzo/features/customer/bloc/customer_event.dart';
import 'package:wanzo/features/customer/bloc/customer_state.dart';
import 'package:wanzo/features/customer/models/customer.dart';
import 'package:wanzo/features/inventory/bloc/inventory_bloc.dart';
import 'package:wanzo/features/inventory/bloc/inventory_event.dart';
import 'package:wanzo/features/inventory/bloc/inventory_state.dart';
import 'package:wanzo/features/inventory/models/product.dart';
import 'package:wanzo/features/invoice/services/invoice_service.dart';
import 'package:wanzo/features/settings/bloc/settings_bloc.dart';
import 'package:wanzo/features/settings/bloc/settings_event.dart';
import 'package:wanzo/features/settings/bloc/settings_state.dart';
import 'package:wanzo/features/settings/models/settings.dart';
import '../../../constants/spacing.dart';
import '../bloc/sales_bloc.dart';
import '../models/sale.dart'; // Added missing import

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

  @override
  void initState() {
    super.initState();
    context.read<SettingsBloc>().add(const LoadSettings());
    context.read<InventoryBloc>().add(const LoadProducts());
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
    return Scaffold(
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
                          _buildItemsList(),
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
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Montant total'),
                            Text(
                              _formatCurrency(_calculateTotal()),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: WanzoSpacing.md),
                        
                        TextFormField(
                          initialValue: _paidAmount.toStringAsFixed(0),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Montant payé',
                            border: OutlineInputBorder(),
                            prefixText: 'FC ',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer le montant payé';
                            }
                            final amount = double.tryParse(value);
                            if (amount == null) {
                              return 'Montant invalide';
                            }
                            if (amount < 0) {
                               return 'Le montant ne peut pas être négatif';
                            }
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
                          decoration: const InputDecoration(
                            labelText: 'Méthode de paiement',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Espèces',
                              child: Text('Espèces'),
                            ),
                            DropdownMenuItem(
                              value: 'Mobile Money',
                              child: Text('Mobile Money'),
                            ),
                            DropdownMenuItem(
                              value: 'Carte bancaire',
                              child: Text('Carte bancaire'),
                            ),
                            DropdownMenuItem(
                              value: 'Virement bancaire',
                              child: Text('Virement bancaire'),
                            ),
                            DropdownMenuItem(
                              value: 'Crédit',
                              child: Text('Crédit'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _paymentMethod = value!;
                              if (_paymentMethod != 'Crédit') {
                                _paidAmount = _calculateTotal();
                              } 
                            });
                          },
                        ),
                        
                        const SizedBox(height: WanzoSpacing.md),
                        
                        if (_items.isNotEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: WanzoSpacing.sm,
                              horizontal: WanzoSpacing.md,
                            ),
                            decoration: BoxDecoration(
                              color: _getPaymentStatusColor().withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _getPaymentStatusColor(),
                              ),
                            ),
                            child: Text(
                              _getPaymentStatusText(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _getPaymentStatusColor(),
                                fontWeight: FontWeight.bold,
                              ),
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
                onPressed: (_items.isEmpty || isLoading) ? null : _saveSale,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: WanzoSpacing.md),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        'Enregistrer la vente',
                        style: TextStyle(fontSize: 16),
                      ),
              );
            },
          ),
        ),
      ),
    );
  }

  Color _getPaymentStatusColor() {
    final total = _calculateTotal();
    if (_paymentMethod == 'Crédit') {
      if (_paidAmount == 0) {
        return Colors.orange;
      } else if (_paidAmount < total) {
        return Colors.blue;
      } else {
        return Colors.green;
      }
    } else {
      if (_isPaidFully()) {
        return Colors.green;
      } else {
        return Colors.red;
      }
    }
  }

  String _getPaymentStatusText() {
    final total = _calculateTotal();
    if (_paymentMethod == 'Crédit') {
      if (_paidAmount == 0) {
        return 'Vente à crédit (aucun acompte)';
      } else if (_paidAmount < total) {
        return 'Acompte: ${_formatCurrency(_paidAmount)}, Reste: ${_formatCurrency(total - _paidAmount)}';
      } else {
        return 'Payé (crédit soldé)';
      }
    } else { 
      if (_isPaidFully()) {
        return 'Entièrement payé';
      } else {
        return 'Reste à payer: ${_formatCurrency(total - _paidAmount)}';
      }
    }
  }

  Future<void> _handleSaleSuccess(String saleId) async {
    final settingsState = context.read<SettingsBloc>().state;
    if (settingsState is! SettingsLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur: Paramètres non chargés pour la génération du document.')),
      );
      if (mounted) Navigator.of(context).pop(); 
      return;
    }

    final savedSale = Sale(
      id: saleId, 
      date: DateTime.now(), 
      customerId: _linkedCustomerId ?? 'new_cust_ph_${_customerPhoneController.text.isNotEmpty ? _customerPhoneController.text.replaceAll(RegExp(r'[^0-9]'),'') : DateTime.now().millisecondsSinceEpoch}', 
      customerName: _customerNameController.text,
      items: List<SaleItem>.from(_items), 
      totalAmount: _calculateTotal(),
      paidAmount: _paidAmount,
      paymentMethod: _paymentMethod,
      status: _isPaidFully() ? SaleStatus.completed : SaleStatus.pending,
      notes: _notesController.text
    );

    final invoiceService = InvoiceService();
    final settings = settingsState.settings;
    String? pdfPath;
    String documentType;

    if (_paymentMethod == 'Crédit' && !_isPaidFully()) {
      documentType = 'Facture';
      pdfPath = await invoiceService.generateInvoicePdf(savedSale, settings);
    } else { 
      documentType = 'Reçu';
      pdfPath = await invoiceService.generateReceiptPdf(savedSale, settings);
    }

    // ignore: unnecessary_null_comparison 
    if (pdfPath != null && pdfPath.isNotEmpty) {
      _showDocumentOptions(pdfPath, documentType, savedSale, settings); // Pass settings
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible de générer le $documentType. Chemin non valide.')),
      );
      if (mounted) Navigator.of(context).pop(); 
    }
  }

  void _showDocumentOptions(String pdfPath, String documentType, Sale sale, Settings settings) { // Add Settings parameter
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
                  await invoiceService.shareInvoice(
                    sale, 
                    settings, 
                    customerPhoneNumber: _customerPhoneController.text, 
                  );
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
    final settingsState = context.watch<SettingsBloc>().state;
    String currencySymbol = 'FC ';
    if (settingsState is SettingsLoaded) {
      currencySymbol = '${settingsState.settings.currency} ';
    }
    final currencyFormat = NumberFormat.currency(
      symbol: currencySymbol,
      decimalDigits: 0,
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: WanzoSpacing.sm),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  'Produit',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'Qté',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Prix',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(width: WanzoSpacing.md),
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
                Expanded(
                  flex: 3,
                  child: Text(item.productName),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    '${item.quantity.toInt()}',
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    currencyFormat.format(item.totalPrice),
                    textAlign: TextAlign.right,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () => _removeItem(index),
                ),
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
              Text(
                'Total',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                currencyFormat.format(_calculateTotal()),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
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

    final settingsState = context.read<SettingsBloc>().state;
    String currencySymbolDialog = 'FC ';
    if (settingsState is SettingsLoaded) {
      currencySymbolDialog = '${settingsState.settings.currency} ';
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final quantity = int.tryParse(quantityController.text) ?? 0;
            final unitPrice = double.tryParse(unitPriceController.text) ?? 0;
            final totalPrice = quantity * unitPrice;

            return AlertDialog(
              title: const Text('Ajouter un article'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BlocBuilder<InventoryBloc, InventoryState>(
                      builder: (context, state) {
                        List<Product> productSuggestions = [];
                        if (state is ProductsLoaded) {
                          productSuggestions = state.products;
                        }

                        return Autocomplete<Product>(
                          displayStringForOption: (Product option) => option.name,
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return productSuggestions;
                            }
                            return productSuggestions.where((Product product) {
                              return product.name.toLowerCase().contains(textEditingValue.text.toLowerCase());
                            });
                          },
                          onSelected: (Product selection) {
                            setStateDialog(() {
                              selectedProductForDialog = selection;
                              productNameController.text = selection.name;
                              productIdController.text = selection.id;
                              unitPriceController.text = selection.sellingPrice.toString();
                              if (quantityController.text.isEmpty || quantityController.text == '0') {
                                quantityController.text = '1';
                              }
                            });
                          },
                          fieldViewBuilder: (BuildContext context, 
                                              TextEditingController fieldTextEditingController, 
                                              FocusNode fieldFocusNode, 
                                              VoidCallback onFieldSubmitted) {
                            return TextFormField(
                              controller: productNameController,
                              focusNode: fieldFocusNode,
                              decoration: const InputDecoration(
                                labelText: 'Nom du produit',
                                border: OutlineInputBorder(),
                                hintText: 'Commencez à taper pour rechercher...',
                              ),
                              onChanged: (value) {
                                setStateDialog(() {
                                   if (selectedProductForDialog != null && selectedProductForDialog!.name != value) {
                                      selectedProductForDialog = null;
                                      productIdController.clear();
                                    }
                                });
                              },
                            );
                          },
                          optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<Product> onSelected, Iterable<Product> options) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 4.0,
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxHeight: 200),
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    itemCount: options.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      final Product option = options.elementAt(index);
                                      return InkWell(
                                        onTap: () {
                                          onSelected(option);
                                        },
                                        child: ListTile(
                                          title: Text(option.name),
                                          subtitle: Text('Stock: ${option.stockQuantity}, Prix: ${_formatCurrency(option.sellingPrice)}'),
                                        ),
                                      );
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
                      keyboardType: const TextInputType.numberWithOptions(decimal: false),
                      inputFormatters: [ FilteringTextInputFormatter.digitsOnly ],
                      decoration: const InputDecoration(
                        labelText: 'Quantité',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Quantité requise';
                        final q = int.tryParse(value);
                        if (q == null || q <= 0) return 'Quantité invalide';
                        if (selectedProductForDialog != null && q > selectedProductForDialog!.stockQuantity) {
                          return 'Stock insuffisant (${selectedProductForDialog!.stockQuantity} disp.)';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setStateDialog(() {}); 
                      },
                    ),
                    
                    const SizedBox(height: WanzoSpacing.md),
                    
                    TextFormField(
                      controller: unitPriceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [ FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')) ],
                      decoration: InputDecoration(
                        labelText: 'Prix unitaire',
                        border: const OutlineInputBorder(),
                        prefixText: currencySymbolDialog,
                      ),
                       validator: (value) {
                        if (value == null || value.isEmpty) return 'Prix requis';
                        final p = double.tryParse(value);
                        if (p == null || p <= 0) return 'Prix invalide';
                        return null;
                      },
                      onChanged: (value) {
                        setStateDialog(() {}); 
                      },
                    ),
                    
                    const SizedBox(height: WanzoSpacing.md),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Prix total:'),
                        Text(
                          _formatCurrency(totalPrice),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final String productName = productNameController.text;
                    final String quantityStr = quantityController.text;
                    final String unitPriceStr = unitPriceController.text;

                    if (productName.isEmpty || quantityStr.isEmpty || unitPriceStr.isEmpty) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar( content: Text('Veuillez remplir nom, quantité et prix unitaire.'), backgroundColor: Colors.red, ),
                      );
                      return;
                    }

                    final currentQuantity = int.tryParse(quantityStr);
                    final currentUnitPrice = double.tryParse(unitPriceStr);

                    if (currentQuantity == null || currentQuantity <= 0) {
                       ScaffoldMessenger.of(dialogContext).showSnackBar( const SnackBar(content: Text('Quantité invalide.')), );
                      return;
                    }
                    if (currentUnitPrice == null || currentUnitPrice <= 0) {
                       ScaffoldMessenger.of(dialogContext).showSnackBar( const SnackBar(content: Text('Prix unitaire invalide.')), );
                      return;
                    }
                    if (selectedProductForDialog != null && currentQuantity > selectedProductForDialog!.stockQuantity) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(content: Text('Stock insuffisant. Disponible: ${selectedProductForDialog!.stockQuantity}')),
                      );
                      return;
                    }
                    
                    final String resolvedProductId = selectedProductForDialog?.id ?? 
                                                 (productIdController.text.isNotEmpty 
                                                    ? productIdController.text 
                                                    : 'manual-${DateTime.now().millisecondsSinceEpoch}');
                    
                    final currentTotalPrice = currentQuantity * currentUnitPrice; 
                    
                    setState(() {
                      _addItem(
                        SaleItem(
                          productId: resolvedProductId,
                          productName: productName,
                          quantity: currentQuantity.toDouble(),
                          unitPrice: currentUnitPrice,
                          totalPrice: currentTotalPrice,
                        ),
                      );
                    });
                    
                    Navigator.pop(dialogContext);
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
      if (_paymentMethod != 'Crédit') {
        _paidAmount = _calculateTotal();
      }
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
      if (_paymentMethod != 'Crédit') {
        _paidAmount = _calculateTotal();
      }
    });
  }

  double _calculateTotal() {
    return _items.fold(0, (total, item) => total + item.totalPrice);
  }

  bool _isPaidFully() {
    return _paidAmount >= (_calculateTotal() - 0.001);
  }

  String _formatCurrency(double amount) {
    final settingsState = context.watch<SettingsBloc>().state;
    String currencySymbol = 'FC '; 
    if (settingsState is SettingsLoaded) {
      currencySymbol = '${settingsState.settings.currency} ';
    }
    final currencyFormat = NumberFormat.currency(
      symbol: currencySymbol,
      decimalDigits: 0, 
    );
    return currencyFormat.format(amount);
  }

  void _saveSale() {
    if (_formKey.currentState!.validate()) {
      if (_items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar( content: Text('Veuillez ajouter au moins un article à la vente.'), backgroundColor: Colors.red, ),
        );
        return;
      }

      if (_paymentMethod != 'Crédit' && !_isPaidFully()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar( content: Text('Pour les paiements autres que crédit, le montant payé doit couvrir le total.'), backgroundColor: Colors.red, ),
        );
        return;
      }
      if (_paymentMethod == 'Crédit' && _paidAmount > _calculateTotal()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar( content: Text('Pour les ventes à crédit, le montant payé ne peut excéder le total.'), backgroundColor: Colors.red, ),
        );
        return;
      }

      final String customerIdToSave;
      if (_linkedCustomerId != null) {
        customerIdToSave = _linkedCustomerId!;
      } else {
        final sanePhone = _customerPhoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
        customerIdToSave = _customerPhoneController.text.isNotEmpty
            ? 'new_customer_phone_$sanePhone'
            : 'new_customer_ts_${DateTime.now().millisecondsSinceEpoch}';
      }
      
      final sale = Sale(
        id: '', 
        date: DateTime.now(),
        customerId: customerIdToSave, 
        customerName: _customerNameController.text, 
        items: List<SaleItem>.from(_items),
        totalAmount: _calculateTotal(),
        paidAmount: _paidAmount,
        paymentMethod: _paymentMethod,
        status: _isPaidFully() ? SaleStatus.completed : SaleStatus.pending,
        notes: _notesController.text,
      );
      
      context.read<SalesBloc>().add(AddSale(sale));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar( content: Text('Veuillez corriger les erreurs dans le formulaire.'), backgroundColor: Colors.red, ),
      );
    }
  }
}
