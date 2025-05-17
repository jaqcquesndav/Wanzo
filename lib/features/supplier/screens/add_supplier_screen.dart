import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/supplier_bloc.dart';
import '../bloc/supplier_event.dart';
import '../bloc/supplier_state.dart';
import '../models/supplier.dart';

/// Écran pour ajouter ou modifier un fournisseur
class AddSupplierScreen extends StatefulWidget {
  /// Fournisseur à modifier (null pour un nouveau fournisseur)
  final Supplier? supplier;

  const AddSupplierScreen({super.key, this.supplier});

  @override
  State<AddSupplierScreen> createState() => _AddSupplierScreenState();
}

class _AddSupplierScreenState extends State<AddSupplierScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;
  late final TextEditingController _contactPersonController;
  late final TextEditingController _notesController;
  late final TextEditingController _deliveryTimeController;
  late final TextEditingController _paymentTermsController;
  
  late SupplierCategory _selectedCategory;
  
  bool get _isEditing => widget.supplier != null;

  @override
  void initState() {
    super.initState();
    
    // Initialise les contrôleurs avec les valeurs du fournisseur si on est en mode édition
    _nameController = TextEditingController(text: widget.supplier?.name ?? '');
    _phoneController = TextEditingController(text: widget.supplier?.phoneNumber ?? '');
    _emailController = TextEditingController(text: widget.supplier?.email ?? '');
    _addressController = TextEditingController(text: widget.supplier?.address ?? '');
    _contactPersonController = TextEditingController(text: widget.supplier?.contactPerson ?? '');
    _notesController = TextEditingController(text: widget.supplier?.notes ?? '');
    _deliveryTimeController = TextEditingController(
      text: widget.supplier?.deliveryTimeInDays.toString() ?? '0'
    );
    _paymentTermsController = TextEditingController(text: widget.supplier?.paymentTerms ?? '');
    
    _selectedCategory = widget.supplier?.category ?? SupplierCategory.regular;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _contactPersonController.dispose();
    _notesController.dispose();
    _deliveryTimeController.dispose();
    _paymentTermsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier le fournisseur' : 'Ajouter un fournisseur'),
      ),
      body: BlocListener<SupplierBloc, SupplierState>(
        listener: (context, state) {
          if (state is SupplierOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            Navigator.pop(context);
          } else if (state is SupplierError) {
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
                // Informations principales
                const Text(
                  'Informations du fournisseur',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Nom du fournisseur
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom du fournisseur *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.business),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le nom est obligatoire';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Numéro de téléphone
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Numéro de téléphone *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                    hintText: '+243 999 123 456',
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s-]')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le numéro de téléphone est obligatoire';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(value)) {
                        return 'Veuillez entrer un email valide';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Personne à contacter
                TextFormField(
                  controller: _contactPersonController,
                  decoration: const InputDecoration(
                    labelText: 'Personne à contacter',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Adresse
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Adresse',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                
                // Informations commerciales
                const Text(
                  'Informations commerciales',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Délai de livraison
                TextFormField(
                  controller: _deliveryTimeController,
                  decoration: const InputDecoration(
                    labelText: 'Délai de livraison (jours)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.timer),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
                const SizedBox(height: 16),
                
                // Conditions de paiement
                TextFormField(
                  controller: _paymentTermsController,
                  decoration: const InputDecoration(
                    labelText: 'Conditions de paiement',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.payment),
                    hintText: 'Ex: Net 30, 50% d\'avance, etc.',
                  ),
                ),
                const SizedBox(height: 16),
                
                // Catégorie de fournisseur
                const Text(
                  'Catégorie de fournisseur',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<SupplierCategory>(
                      isExpanded: true,
                      value: _selectedCategory,
                      items: SupplierCategory.values.map((category) {
                        return DropdownMenuItem<SupplierCategory>(
                          value: category,
                          child: Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(category),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(_getCategoryName(category)),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Notes
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.note),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                
                // Bouton de sauvegarde
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saveSupplier,
                    child: Text(_isEditing ? 'Mettre à jour' : 'Ajouter'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Sauvegarde le fournisseur (ajout ou mise à jour)
  void _saveSupplier() {
    if (_formKey.currentState?.validate() ?? false) {
      final supplier = Supplier(
        id: widget.supplier?.id ?? '',
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        address: _addressController.text.trim(),
        contactPerson: _contactPersonController.text.trim(),
        createdAt: widget.supplier?.createdAt ?? DateTime.now(),
        notes: _notesController.text.trim(),
        totalPurchases: widget.supplier?.totalPurchases ?? 0.0,
        lastPurchaseDate: widget.supplier?.lastPurchaseDate,
        category: _selectedCategory,
        deliveryTimeInDays: int.tryParse(_deliveryTimeController.text) ?? 0,
        paymentTerms: _paymentTermsController.text.trim(),
      );
      
      if (_isEditing) {
        context.read<SupplierBloc>().add(UpdateSupplier(supplier));
      } else {
        context.read<SupplierBloc>().add(AddSupplier(supplier));
      }
    }
  }

  /// Retourne la couleur associée à une catégorie de fournisseur
  Color _getCategoryColor(SupplierCategory category) {
    switch (category) {      case SupplierCategory.strategic:
        return Colors.indigo;
      case SupplierCategory.regular:
        return Colors.blue;
      case SupplierCategory.newSupplier:
        return Colors.green;
      case SupplierCategory.occasional:
        return Colors.orange;
      case SupplierCategory.international:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  /// Retourne le nom d'une catégorie de fournisseur
  String _getCategoryName(SupplierCategory category) {
    switch (category) {      case SupplierCategory.strategic:
        return 'Stratégique';
      case SupplierCategory.regular:
        return 'Régulier';
      case SupplierCategory.newSupplier:
        return 'Nouveau';
      case SupplierCategory.occasional:
        return 'Occasionnel';
      case SupplierCategory.international:
        return 'International';
      default:
        return 'Inconnu';
    }
  }
}
