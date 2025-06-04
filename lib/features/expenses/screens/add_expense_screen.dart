import 'dart:io'; // Import for File

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../constants/constants.dart';
import '../../../core/shared_widgets/wanzo_scaffold.dart';
import '../bloc/expense_bloc.dart';
import '../models/expense.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  ExpenseCategory _selectedCategory = ExpenseCategory.other;
  String? _selectedPaymentMethod;
  final List<File> _imageFiles = []; // To store selected image files
  final ImagePicker _picker = ImagePicker(); // ImagePicker instance

  final List<String> _paymentMethods = ['Espèce', 'Mobile Money', 'Carte Bancaire', 'Chèque', 'Virement'];

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFiles.add(File(pickedFile.path));
        });
      }
    } catch (e) {
      // Handle exceptions, e.g., permission denied
      debugPrint('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la sélection de l\'image: $e')),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imageFiles.removeAt(index);
    });
  }

  void _submitExpense() {
    if (_formKey.currentState!.validate()) {
      final amount = double.tryParse(_amountController.text);
      if (amount == null || amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez entrer un montant valide.')),
        );
        return;
      }

      // The TODO below is now handled by the ExpenseBloc/ExpenseRepository/ExpenseApiService flow.
      // Images are passed as File objects to the bloc, and the service layer handles uploads.
      final newExpense = Expense(
        id: const Uuid().v4(), // Client-side ID generation for initial object, API might override or use its own.
        date: _selectedDate,
        motif: _descriptionController.text,
        amount: amount,
        category: _selectedCategory,
        paymentMethod: _selectedPaymentMethod ?? 'N/A',
        attachmentUrls: [], // Placeholder: Will be updated after image upload
        // supplierId is optional
      );

      // Pass _imageFiles to the bloc event if it's designed to handle uploads
      context.read<ExpenseBloc>().add(AddExpense(newExpense, imageFiles: _imageFiles));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WanzoScaffold(
      title: 'Nouvelle Dépense',
      currentIndex: 0, // Added currentIndex, assuming 0 for Dashboard context
      body: BlocListener<ExpenseBloc, ExpenseState>(
        listener: (context, state) {
          if (state is ExpenseOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            context.pop(true); // MODIFIED: Pop with true
          } else if (state is ExpenseError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erreur: ${state.message}')),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(WanzoSpacing.md),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Motif'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un motif.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: WanzoSpacing.md),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(labelText: 'Montant (FC)', prefixText: 'FC '),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un montant.';
                    }
                    if (double.tryParse(value) == null || double.parse(value) <= 0) {
                      return 'Veuillez entrer un montant valide.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: WanzoSpacing.md),
                DropdownButtonFormField<ExpenseCategory>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Catégorie'),
                  items: ExpenseCategory.values.map((ExpenseCategory category) {
                    return DropdownMenuItem<ExpenseCategory>(
                      value: category,
                      child: Text(category.displayName),
                    );
                  }).toList(),
                  onChanged: (ExpenseCategory? newValue) {
                    setState(() {
                      _selectedCategory = newValue!;
                    });
                  },
                ),
                const SizedBox(height: WanzoSpacing.md),
                ListTile(
                  title: Text("Date: ${DateFormat('dd/MM/yyyy', 'fr_FR').format(_selectedDate)}"),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _pickDate(context),
                ),
                const SizedBox(height: WanzoSpacing.md),
                DropdownButtonFormField<String>(
                  value: _selectedPaymentMethod,
                  decoration: const InputDecoration(labelText: 'Méthode de Paiement (Optionnel)'),
                  hint: const Text('Sélectionner une méthode'),
                  items: _paymentMethods.map((String method) {
                    return DropdownMenuItem<String>(
                      value: method,
                      child: Text(method),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedPaymentMethod = newValue;
                    });
                  },
                ),
                const SizedBox(height: WanzoSpacing.md),
                // Image picking section
                Text('Pièces justificatives (Optionnel)', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: WanzoSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Galerie'),
                      onPressed: () => _pickImage(ImageSource.gallery),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade200, foregroundColor: Colors.black87),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Caméra'),
                      onPressed: () => _pickImage(ImageSource.camera),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade200, foregroundColor: Colors.black87),
                    ),
                  ],
                ),
                const SizedBox(height: WanzoSpacing.md),
                if (_imageFiles.isNotEmpty)
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _imageFiles.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: WanzoSpacing.sm),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(WanzoRadius.md),
                                child: Image.file(
                                  _imageFiles[index],
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: InkWell(
                                  onTap: () => _removeImage(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.8),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close, color: Colors.white, size: 18),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: WanzoSpacing.xl),
                ElevatedButton(
                  onPressed: _submitExpense,
                  style: ElevatedButton.styleFrom(backgroundColor: WanzoColors.primary),
                  child: BlocBuilder<ExpenseBloc, ExpenseState>(
                    builder: (context, state) {
                      if (state is ExpenseLoading) {
                        return const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                        );
                      }
                      return const Text('Enregistrer la Dépense', style: TextStyle(color: Colors.white));
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}
