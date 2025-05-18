import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
// import 'package:intl/intl.dart'; // Not used in this version
import 'package:uuid/uuid.dart';
import '../../../constants/constants.dart';
import '../../../core/shared_widgets/wanzo_scaffold.dart';
import '../bloc/financing_bloc.dart';
import '../models/financing_request.dart';

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
  String _selectedCurrency = 'USD'; // Default currency
  FinancingType _selectedFinancingType = FinancingType.cashCredit;
  FinancialInstitution _selectedInstitution = FinancialInstitution.bonneMoisson;
  int _creditScore = 75; // Example credit score, fetch from a relevant source

  final List<String> _currencies = ['USD', 'CDF'];

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

  void _submitRequest() {
    if (_formKey.currentState!.validate()) {
      final amount = double.tryParse(_amountController.text);
      if (amount == null || amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez entrer un montant valide.')),
        );
        return;
      }

      final newRequest = FinancingRequest(
        id: const Uuid().v4(),
        amount: amount,
        currency: _selectedCurrency,
        reason: _reasonController.text,
        type: _selectedFinancingType,
        institution: _selectedInstitution,
        requestDate: DateTime.now(),
      );

      context.read<FinancingBloc>().add(AddFinancingRequest(newRequest));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WanzoScaffold(
      title: 'Nouvelle Demande de Financement',
      currentIndex: 0, // Or appropriate index if part of main navigation
      body: BlocListener<FinancingBloc, FinancingState>(
        listener: (context, state) {
          if (state is FinancingOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            context.pop(); // Go back after success
          } else if (state is FinancingError) {
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
                // Credit Score Header
                Card(
                  color: WanzoColors.primary.withOpacity(0.1),
                  elevation: 0,
                  child: ListTile(
                    leading: Icon(Icons.shield_outlined, color: WanzoColors.primary, size: 30),
                    title: Text(
                      'Votre Cote de Crédit: $_creditScore / 100',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: WanzoColors.primary),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.info_outline, color: WanzoColors.primary),
                      onPressed: _showCreditScoreInfo,
                    ),
                  ),
                ),
                const SizedBox(height: WanzoSpacing.lg),

                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(labelText: 'Montant demandé'),
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
                DropdownButtonFormField<String>(
                  value: _selectedCurrency,
                  decoration: const InputDecoration(labelText: 'Devise'),
                  items: _currencies.map((String currency) {
                    return DropdownMenuItem<String>(
                      value: currency,
                      child: Text(currency),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCurrency = newValue!;
                    });
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
                ),
                const SizedBox(height: WanzoSpacing.xl),
                ElevatedButton(
                  onPressed: _submitRequest,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: WanzoColors.primary),
                  child: BlocBuilder<FinancingBloc, FinancingState>(
                    builder: (context, state) {
                      if (state is FinancingLoading) {
                        return const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                        );
                      }
                      return const Text('Soumettre la Demande',
                          style: TextStyle(color: Colors.white));
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
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }
}
