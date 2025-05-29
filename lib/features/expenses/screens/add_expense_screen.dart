import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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

  void _submitExpense() {
    if (_formKey.currentState!.validate()) {
      final amount = double.tryParse(_amountController.text);
      if (amount == null || amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez entrer un montant valide.')),
        );
        return;
      }

      final newExpense = Expense(
        id: const Uuid().v4(),
        date: _selectedDate,
        motif: _descriptionController.text,
        amount: amount,
        category: _selectedCategory, // Use the ExpenseCategory enum value directly
        paymentMethod: _selectedPaymentMethod ?? 'N/A',
        // attachmentUrls and supplierId are optional and will use defaults if not provided
      );

      context.read<ExpenseBloc>().add(AddExpense(newExpense));
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
            context.pop(); // Go back after success
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
