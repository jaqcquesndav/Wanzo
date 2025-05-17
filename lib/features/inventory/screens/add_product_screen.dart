import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../constants/spacing.dart';
import '../../../constants/typography.dart';
import '../../../constants/colors.dart';
import '../../../core/shared_widgets/wanzo_scaffold.dart';
import '../bloc/inventory_bloc.dart';
import '../bloc/inventory_event.dart';
import '../bloc/inventory_state.dart';
import '../models/product.dart';

/// Écran d'ajout de produit
class AddProductScreen extends StatefulWidget {
  /// Produit à modifier (null pour un nouveau produit)
  final Product? product;

  const AddProductScreen({super.key, this.product});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _barcodeController;
  late final TextEditingController _costPriceController;
  late final TextEditingController _sellingPriceController;
  late final TextEditingController _stockQuantityController;
  late final TextEditingController _alertThresholdController;
  
  late ProductCategory _selectedCategory;
  late ProductUnit _selectedUnit;
  
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    
    _isEditing = widget.product != null;
    
    // Initialiser les contrôleurs
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descriptionController = TextEditingController(text: widget.product?.description ?? '');
    _barcodeController = TextEditingController(text: widget.product?.barcode ?? '');
    _costPriceController = TextEditingController(
      text: widget.product?.costPrice.toString() ?? '',
    );
    _sellingPriceController = TextEditingController(
      text: widget.product?.sellingPrice.toString() ?? '',
    );
    _stockQuantityController = TextEditingController(
      text: widget.product?.stockQuantity.toString() ?? '',
    );
    _alertThresholdController = TextEditingController(
      text: widget.product?.alertThreshold.toString() ?? '5',
    );
    
    _selectedCategory = widget.product?.category ?? ProductCategory.other;
    _selectedUnit = widget.product?.unit ?? ProductUnit.piece;
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _barcodeController.dispose();
    _costPriceController.dispose();
    _sellingPriceController.dispose();
    _stockQuantityController.dispose();
    _alertThresholdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InventoryBloc, InventoryState>(      listener: (context, state) {
        if (state is InventoryOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          context.pop();
        } else if (state is InventoryError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: WanzoScaffold(
        currentIndex: 2, // Stock a l'index 2
        title: _isEditing ? 'Modifier le produit' : 'Ajouter un produit',
        onBackPressed: () => context.pop(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(WanzoSpacing.md),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Informations générales
                _buildSectionTitle(context, 'Informations générales'),
                const SizedBox(height: WanzoSpacing.md),
                
                // Nom du produit
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom du produit',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.inventory),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un nom de produit';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: WanzoSpacing.md),
                
                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optionnel)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: WanzoSpacing.md),
                
                // Code-barres
                TextFormField(
                  controller: _barcodeController,
                  decoration: InputDecoration(
                    labelText: 'Code-barres / Référence (optionnel)',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.qr_code),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.camera_alt),
                      onPressed: () {
                        // TODO: Ajouter la fonctionnalité de scan de code-barres
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cette fonctionnalité sera bientôt disponible'),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: WanzoSpacing.md),
                
                // Catégorie
                DropdownButtonFormField<ProductCategory>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Catégorie',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: ProductCategory.values.map((category) {
                    return DropdownMenuItem<ProductCategory>(
                      value: category,
                      child: Text(_getCategoryName(category)),
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
                const SizedBox(height: WanzoSpacing.lg),
                
                // Prix
                _buildSectionTitle(context, 'Prix'),
                const SizedBox(height: WanzoSpacing.md),
                
                // Prix d'achat
                TextFormField(
                  controller: _costPriceController,
                  decoration: const InputDecoration(
                    labelText: 'Prix d\'achat (FC)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.store),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un prix d\'achat';
                    }
                    try {
                      final price = double.parse(value);
                      if (price < 0) {
                        return 'Le prix ne peut pas être négatif';
                      }
                    } catch (e) {
                      return 'Veuillez entrer un nombre valide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: WanzoSpacing.md),
                
                // Prix de vente
                TextFormField(
                  controller: _sellingPriceController,
                  decoration: const InputDecoration(
                    labelText: 'Prix de vente (FC)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.sell),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un prix de vente';
                    }
                    try {
                      final price = double.parse(value);
                      if (price < 0) {
                        return 'Le prix ne peut pas être négatif';
                      }
                    } catch (e) {
                      return 'Veuillez entrer un nombre valide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: WanzoSpacing.lg),
                
                // Stock
                _buildSectionTitle(context, 'Gestion du stock'),
                const SizedBox(height: WanzoSpacing.md),
                
                // Quantité en stock
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quantité
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _stockQuantityController,
                        decoration: const InputDecoration(
                          labelText: 'Quantité en stock',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.inventory_2),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        validator: (value) {
                          if (_isEditing) {
                            return null; // Skip validation when editing
                          }
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer une quantité';
                          }
                          try {
                            final quantity = double.parse(value);
                            if (quantity < 0) {
                              return 'La quantité ne peut pas être négative';
                            }
                          } catch (e) {
                            return 'Veuillez entrer un nombre valide';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: WanzoSpacing.md),
                    
                    // Unité
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<ProductUnit>(
                        value: _selectedUnit,
                        decoration: const InputDecoration(
                          labelText: 'Unité',
                          border: OutlineInputBorder(),
                        ),
                        items: ProductUnit.values.map((unit) {
                          return DropdownMenuItem<ProductUnit>(
                            value: unit,
                            child: Text(_getUnitName(unit)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedUnit = value;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: WanzoSpacing.md),
                
                // Seuil d'alerte
                TextFormField(
                  controller: _alertThresholdController,
                  decoration: const InputDecoration(
                    labelText: 'Seuil d\'alerte de stock bas',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.warning),
                    helperText: 'Vous recevrez une alerte lorsque le stock sera inférieur à cette valeur',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un seuil d\'alerte';
                    }
                    try {
                      final threshold = double.parse(value);
                      if (threshold < 0) {
                        return 'Le seuil ne peut pas être négatif';
                      }
                    } catch (e) {
                      return 'Veuillez entrer un nombre valide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: WanzoSpacing.xl),
                
                // Bouton de soumission
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(WanzoSpacing.md),
                  ),
                  child: Text(
                    _isEditing ? 'Mettre à jour le produit' : 'Ajouter le produit',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                
                if (_isEditing) ...[
                  const SizedBox(height: WanzoSpacing.md),
                  // Bouton de suppression
                  OutlinedButton.icon(
                    onPressed: _confirmDelete,
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text(
                      'Supprimer ce produit',
                      style: TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(WanzoSpacing.md),
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  /// Construire un titre de section
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: WanzoSpacing.sm),
        const Expanded(
          child: Divider(),
        ),
      ],
    );
  }
  
  /// Soumettre le formulaire
  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final costPrice = double.tryParse(_costPriceController.text) ?? 0;
      final sellingPrice = double.tryParse(_sellingPriceController.text) ?? 0;
      final stockQuantity = double.tryParse(_stockQuantityController.text) ?? 0;
      final alertThreshold = double.tryParse(_alertThresholdController.text) ?? 5;
      
      if (_isEditing) {
        // Mettre à jour le produit existant
        final updatedProduct = widget.product!.copyWith(
          name: _nameController.text,
          description: _descriptionController.text,
          barcode: _barcodeController.text,
          category: _selectedCategory,
          costPrice: costPrice,
          sellingPrice: sellingPrice,
          stockQuantity: stockQuantity,
          unit: _selectedUnit,
          alertThreshold: alertThreshold,
          updatedAt: DateTime.now(),
        );
        
        context.read<InventoryBloc>().add(UpdateProduct(updatedProduct));
      } else {
        // Créer un nouveau produit
        final newProduct = Product(
          id: const Uuid().v4(), // ID temporaire, sera remplacé par le repository
          name: _nameController.text,
          description: _descriptionController.text,
          barcode: _barcodeController.text,
          category: _selectedCategory,
          costPrice: costPrice,
          sellingPrice: sellingPrice,
          stockQuantity: stockQuantity,
          unit: _selectedUnit,
          alertThreshold: alertThreshold,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        context.read<InventoryBloc>().add(AddProduct(newProduct));
      }
    }
  }
  
  /// Confirmer la suppression
  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer le produit'),
          content: const Text(
            'Êtes-vous sûr de vouloir supprimer ce produit ? Cette action est irréversible.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<InventoryBloc>().add(DeleteProduct(widget.product!.id));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }
  
  /// Obtenir le nom d'une catégorie
  String _getCategoryName(ProductCategory category) {
    switch (category) {
      case ProductCategory.food:
        return 'Alimentation';
      case ProductCategory.drink:
        return 'Boissons';
      case ProductCategory.electronics:
        return 'Électronique';
      case ProductCategory.clothing:
        return 'Vêtements';
      case ProductCategory.household:
        return 'Articles ménagers';
      case ProductCategory.hygiene:
        return 'Hygiène et beauté';
      case ProductCategory.office:
        return 'Fournitures de bureau';
      case ProductCategory.other:
        return 'Autres';
    }
  }
  
  /// Obtenir le nom d'une unité
  String _getUnitName(ProductUnit unit) {
    switch (unit) {
      case ProductUnit.piece:
        return 'Pièce(s)';
      case ProductUnit.kg:
        return 'Kilogramme(s)';
      case ProductUnit.g:
        return 'Gramme(s)';
      case ProductUnit.l:
        return 'Litre(s)';
      case ProductUnit.ml:
        return 'Millilitre(s)';
      case ProductUnit.package:
        return 'Paquet(s)';
      case ProductUnit.box:
        return 'Boîte(s)';
      case ProductUnit.other:
        return 'Autre';
    }
  }
}
