import 'dart:io'; // Added for File support
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart'; // Added image_picker
import 'package:path_provider/path_provider.dart'; // Added path_provider
import 'package:path/path.dart' as path; // Added path
import '../../../constants/spacing.dart';
import '../../../core/shared_widgets/wanzo_scaffold.dart';
import '../bloc/inventory_bloc.dart';
import '../bloc/inventory_event.dart';
import '../bloc/inventory_state.dart';
import '../models/product.dart';
import 'package:wanzo/core/utils/currency_formatter.dart'; // Added
import 'package:wanzo/features/settings/models/settings.dart'; // Added
import 'package:wanzo/features/settings/bloc/settings_bloc.dart'; // Added
import 'package:wanzo/features/settings/bloc/settings_state.dart'; // Added

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
  
  File? _selectedImageFile; // To store the selected image file
  String? _currentImagePath; // To store the path of an existing or newly saved image

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    
    _isEditing = widget.product != null;
    _currentImagePath = widget.product?.imagePath;
    
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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        // Optionally, save the image to the app's directory and store the path
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String fileName = path.basename(imageFile.path);
        final String savedImagePath = path.join(appDir.path, fileName);
        
        // Check if the file already exists at the destination, if so, generate a unique name
        String uniqueSavedImagePath = savedImagePath;
        int counter = 1;
        while (await File(uniqueSavedImagePath).exists()) {
          String newFileName = '${path.basenameWithoutExtension(savedImagePath)}_$counter${path.extension(savedImagePath)}';
          uniqueSavedImagePath = path.join(appDir.path, newFileName);
          counter++;
        }

        await imageFile.copy(uniqueSavedImagePath);

        setState(() {
          _selectedImageFile = imageFile; // Keep for display before saving form
          _currentImagePath = uniqueSavedImagePath; // Store the path to be saved with the product
        });
      }
    } catch (e) {
      // Handle exceptions, e.g., permission denied
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la sélection de l\'image: $e')),
      );
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galerie'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Appareil photo'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
              if (_selectedImageFile != null || (_currentImagePath != null && _currentImagePath!.isNotEmpty))
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Supprimer l\'image', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    setState(() {
                      _selectedImageFile = null;
                      _currentImagePath = null;
                    });
                    Navigator.of(context).pop();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsState = context.watch<SettingsBloc>().state;
    CurrencyType currency = CurrencyType.usd; // Default currency
    String currencySymbol = getCurrencyString(currency); // Default symbol

    if (settingsState is SettingsLoaded) {
      currency = settingsState.settings.currency;
      currencySymbol = getCurrencyString(currency);
    } else if (settingsState is SettingsUpdated) {
      currency = settingsState.settings.currency;
      currencySymbol = getCurrencyString(currency);
    }

    return BlocListener<InventoryBloc, InventoryState>(
      listener: (context, state) {
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
                // Image Picker Section
                _buildSectionTitle(context, 'Image du produit'),
                const SizedBox(height: WanzoSpacing.md),
                GestureDetector(
                  onTap: () => _showImageSourceActionSheet(context),
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(WanzoSpacing.sm),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_selectedImageFile != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(WanzoSpacing.sm),
                            child: Image.file(
                              _selectedImageFile!,
                              width: double.infinity,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          )
                        else if (_currentImagePath != null && _currentImagePath!.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(WanzoSpacing.sm),
                            child: Image.file(
                              File(_currentImagePath!), // Display existing image
                              width: double.infinity,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          )
                        else
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, size: 40, color: Colors.grey[600]),
                              const SizedBox(height: WanzoSpacing.sm),
                              Text('Ajouter une image', style: TextStyle(color: Colors.grey[700])),
                            ],
                          ),
                        if (_selectedImageFile != null || (_currentImagePath != null && _currentImagePath!.isNotEmpty))
                          Positioned(
                            top: 8,
                            right: 8,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedImageFile = null;
                                  _currentImagePath = null;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, color: Colors.white, size: 18),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: WanzoSpacing.lg),

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
                  decoration: InputDecoration(
                    labelText: 'Prix d\'achat ($currencySymbol)',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.store),
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
                  decoration: InputDecoration(
                    labelText: 'Prix de vente ($currencySymbol)',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.sell),
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
                        isExpanded: true, // Add this to allow the dropdown to fill the Expanded width
                        value: _selectedUnit,
                        decoration: const InputDecoration(
                          labelText: 'Unité',
                          border: OutlineInputBorder(),
                        ),
                        items: ProductUnit.values.map((unit) {
                          return DropdownMenuItem<ProductUnit>(
                            value: unit,
                            child: Text(_getUnitName(unit), overflow: TextOverflow.ellipsis), // Add ellipsis for long text
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
          imagePath: _currentImagePath, // Pass the image path
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
          imagePath: _currentImagePath, // Pass the image path
        );
        
        context.read<InventoryBloc>().add(AddProduct(newProduct));
      }
    }
  }
  
  /// Confirmer la suppression
  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Supprimer le produit'),
          content: const Text(
            'Êtes-vous sûr de vouloir supprimer ce produit ? Cette action est irréversible.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
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
        return 'Autre';
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
      case ProductUnit.package: // Corrected from pack to package
        return 'Paquet(s)';
      case ProductUnit.box:
        return 'Boîte(s)';
      case ProductUnit.other: // Added case for other
        return 'Autre';
    }
  }
}
