import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';

import 'package:wanzo/constants/constants.dart';
import 'package:wanzo/core/shared_widgets/wanzo_scaffold.dart';
import 'package:wanzo/features/financing/bloc/financing_bloc.dart';
import 'package:wanzo/features/financing/models/financing_request.dart';

class AddFinancingScreen extends StatefulWidget {
  const AddFinancingScreen({super.key});

  @override
  State<AddFinancingScreen> createState() => _AddFinancingScreenState();
}

class _AddFinancingScreenState extends State<AddFinancingScreen> {  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _reasonController = TextEditingController();
  final _currencyController = TextEditingController(text: 'CDF');
  final _termMonthsController = TextEditingController(); // Contrôleur pour la durée en mois
  FinancialInstitution _selectedInstitution = FinancialInstitution.bonneMoisson;
  FinancialProduct _selectedProduct = FinancialProduct.cashFlow; // Produit financier sélectionné
  final List<String> _attachmentPaths = []; // Liste des pièces jointes
  final ImagePicker _picker = ImagePicker();
  String? _leasingCode; // Code pour le leasing
  
  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    _currencyController.dispose();
    _termMonthsController.dispose(); // Libérer le contrôleur de durée
    super.dispose();
  }
  
  // Méthode pour sélectionner une pièce jointe
  Future<void> _pickAttachment() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85
      );
      
      // Vérifier si le widget est toujours monté avant d'utiliser setState
      if (!mounted) return;
      
      if (pickedFile != null) {
        setState(() {
          _attachmentPaths.add(pickedFile.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la sélection du fichier: $e')),
      );
    }
  }

  // Méthode pour supprimer une pièce jointe
  void _removeAttachment(int index) {
    setState(() {
      _attachmentPaths.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WanzoScaffold(
      title: 'Nouvelle demande de financement',
      currentIndex: 1, // Operations tab
      body: BlocListener<FinancingBloc, FinancingState>(        listener: (context, state) {
          if (state is FinancingOperationSuccess) {
            // Le journal des opérations est géré dans le bloc de financement

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            
            // Return to the previous screen with a refresh indicator
            context.pop(true);
          } else if (state is FinancingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(              child: Column(                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInstitutionSelection(),
                  const SizedBox(height: 16),
                  _buildFinancialProductSelection(),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Montant',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un montant';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Veuillez entrer un nombre valide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _currencyController,
                    decoration: const InputDecoration(
                      labelText: 'Devise',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer une devise';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _termMonthsController,
                    decoration: const InputDecoration(
                      labelText: 'Durée (en mois)',
                      border: OutlineInputBorder(),
                      hintText: 'Entre 1 et 36 mois',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer une durée';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Veuillez entrer un nombre entier';
                      }
                      
                      final months = int.parse(value);
                      if (months < 1 || months > 36) {
                        return 'La durée doit être entre 1 et 36 mois';
                      }
                      
                      return null;
                    },
                  ),                  const SizedBox(height: 16),
                  
                  // Afficher le code de leasing si le produit est equipment (leasing)
                  if (_selectedProduct == FinancialProduct.equipment)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Code de leasing',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_leasingCode ?? 'Génération automatique lors de la soumission',
                                style: TextStyle(
                                  fontWeight: _leasingCode != null ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 16,
                                ),
                              ),
                              if (_leasingCode != null)
                                const Padding(
                                  padding: EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    'Ce code sera utilisé pour l\'achat d\'équipement chez Wanzo Store',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  
                  TextFormField(
                    controller: _reasonController,
                    decoration: const InputDecoration(
                      labelText: 'Motif',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un motif';
                      }
                      return null;
                    },                  ),
                  const SizedBox(height: 16),
                  
                  // Section des pièces jointes
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pièces justificatives (optionnel)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Bouton d'ajout de pièce jointe
                      ElevatedButton.icon(
                        icon: const Icon(Icons.attach_file),
                        label: const Text('Ajouter une pièce jointe'),
                        onPressed: _pickAttachment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                          foregroundColor: Theme.of(context).colorScheme.onSecondary,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Info text
                      if (_attachmentPaths.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: WanzoSpacing.sm, bottom: WanzoSpacing.sm),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Pièces jointes acceptées: facture, devis, lettre d'intention, projet, etc.",
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      // Liste des pièces jointes
                      if (_attachmentPaths.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _attachmentPaths.length,
                          itemBuilder: (context, index) {
                            final path = _attachmentPaths[index];
                            final fileName = path.split('/').last;
                            
                            return ListTile(
                              leading: const Icon(Icons.insert_drive_file),
                              title: Text(fileName, style: const TextStyle(fontSize: 14)),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                                onPressed: () => _removeAttachment(index),
                                tooltip: 'Supprimer la pièce jointe',
                              ),
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                            );
                          },
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _submitForm,
                      icon: const Icon(Icons.send),
                      label: const Text('Soumettre la demande'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );  }

  Widget _buildInstitutionSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Institution financière',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<FinancialInstitution>(
          value: _selectedInstitution,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          items: FinancialInstitution.values.map((institution) {
            return DropdownMenuItem<FinancialInstitution>(
              value: institution,
              child: Text(institution.displayName),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedInstitution = value;
              });
            }
          },
          validator: (value) {
            if (value == null) {
              return 'Veuillez sélectionner une institution';
            }
            return null;
          },
        ),
      ],
    );
  }
  
  Widget _buildFinancialProductSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Produit financier',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<FinancialProduct>(
          value: _selectedProduct,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          items: FinancialProduct.values.map((product) {
            return DropdownMenuItem<FinancialProduct>(
              value: product,
              child: Text(product.displayName),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {                _selectedProduct = value;
                
                // Si le produit financier est équipement (leasing), générer un code
                if (_selectedProduct == FinancialProduct.equipment) {
                  _generateLeasingCode();
                }
              });
            }
          },
          validator: (value) {
            if (value == null) {
              return 'Veuillez sélectionner un produit financier';
            }
            return null;
          },
        ),
      ],
    );
  }
  
  // Méthode pour générer un code de leasing
  void _generateLeasingCode() {
    final uuid = const Uuid().v4();
    // Prendre les 8 premiers caractères du UUID et les convertir en majuscules
    final code = 'WL-${uuid.substring(0, 8).toUpperCase()}';
    setState(() {
      _leasingCode = code;
    });
  }
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final financingBloc = context.read<FinancingBloc>();
      
      // Vérifier si les pièces jointes existent et sont accessibles
      List<String> validAttachments = [];
      for (String path in _attachmentPaths) {
        final file = File(path);
        if (file.existsSync()) {
          validAttachments.add(path);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('La pièce jointe "$path" n\'est pas accessible.')),
          );
        }
      }      // Déterminer le type de financement en fonction du produit financier
      FinancingType determinedType;
      switch (_selectedProduct) {
        case FinancialProduct.cashFlow:
          determinedType = FinancingType.cashCredit;
          break;
        case FinancialProduct.investment:
          determinedType = FinancingType.investmentCredit;
          break;
        case FinancialProduct.equipment:
          determinedType = FinancingType.leasing;
          break;
        case FinancialProduct.agricultural:
          determinedType = FinancingType.productionInputs;
          break;
        case FinancialProduct.commercialGoods:
          determinedType = FinancingType.merchandise;
          break;
      }
      
      final request = FinancingRequest(
        id: const Uuid().v4(),
        amount: double.parse(_amountController.text),
        currency: _currencyController.text,
        reason: _reasonController.text,
        type: determinedType,
        institution: _selectedInstitution,
        requestDate: DateTime.now(),
        termMonths: int.tryParse(_termMonthsController.text), // Récupérer la durée en mois
        financialProduct: _selectedProduct, // Ajouter le produit financier
        leasingCode: _leasingCode, // Ajouter le code de leasing si disponible
        attachmentPaths: validAttachments.isNotEmpty ? validAttachments : null,
      );
      
      financingBloc.add(AddFinancingRequest(request));
    }
  }
}
