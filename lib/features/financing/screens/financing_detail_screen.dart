import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:wanzo/core/shared_widgets/wanzo_scaffold.dart';
import 'package:wanzo/features/financing/bloc/financing_bloc.dart';
import 'package:wanzo/features/financing/models/financing_request.dart';

class FinancingDetailScreen extends StatefulWidget {
  final String id;
  final FinancingRequest? financing;

  const FinancingDetailScreen({
    super.key,
    required this.id,
    this.financing,
  });

  @override
  State<FinancingDetailScreen> createState() => _FinancingDetailScreenState();
}

class _FinancingDetailScreenState extends State<FinancingDetailScreen> {
  late FinancingRequest _financing;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.financing != null) {
      _financing = widget.financing!;
      _isInitialized = true;
    } else {
      // Charger depuis le repository si pas passé en paramètre
      _loadFinancing();
    }
  }
  Future<void> _loadFinancing() async {
    final financingBloc = context.read<FinancingBloc>();
    final requests = await financingBloc.financingRepository.getAllRequests();
    final request = requests.firstWhere(
      (req) => req.id == widget.id,
      orElse: () => FinancingRequest(
        id: '',
        amount: 0,
        currency: 'CDF',
        reason: 'Non trouvé',
        type: FinancingType.cashCredit,
        institution: FinancialInstitution.bonneMoisson,
        requestDate: DateTime.now(),
      ),
    );

    if (mounted) {
      setState(() {
        _financing = request;
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return WanzoScaffold(
      title: 'Détails du financement',
      currentIndex: 1, // Operations tab
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(),
            const SizedBox(height: 16),
            _buildDetailsCard(),
            const SizedBox(height: 16),
            if (_financing.status == 'approved' || _financing.status == 'disbursed' || _financing.status == 'repaying')
              _buildScheduleCard(),
            const SizedBox(height: 16),
            _buildActionsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    final Map<String, IconData> statusIcons = {
      'pending': Icons.hourglass_empty,
      'approved': Icons.check_circle,
      'rejected': Icons.cancel,
      'disbursed': Icons.attach_money,
      'repaying': Icons.payment,
      'fully_repaid': Icons.task_alt,
    };

    final Map<String, Color> statusColors = {
      'pending': Colors.orange,
      'approved': Colors.green,
      'rejected': Colors.red,
      'disbursed': Colors.blue,
      'repaying': Colors.purple,
      'fully_repaid': Colors.teal,
    };

    final Map<String, String> statusTexts = {
      'pending': 'En attente',
      'approved': 'Approuvé',
      'rejected': 'Rejeté',
      'disbursed': 'Fonds débloqués',
      'repaying': 'En cours de remboursement',
      'fully_repaid': 'Entièrement remboursé',
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              statusIcons[_financing.status] ?? Icons.help_outline,
              size: 48,
              color: statusColors[_financing.status] ?? Colors.grey,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusTexts[_financing.status] ?? 'Statut inconnu',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: statusColors[_financing.status] ?? Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    _financing.type.displayName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    NumberFormat.currency(
                      locale: 'fr_FR',
                      symbol: _financing.currency,
                    ).format(_financing.amount),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Détails du financement',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            _buildDetailRow('Type', _financing.type.displayName),
            _buildDetailRow('Institution', _financing.institution.displayName),
            _buildDetailRow(
              'Montant',
              NumberFormat.currency(
                locale: 'fr_FR',
                symbol: _financing.currency,
              ).format(_financing.amount),
            ),
            _buildDetailRow(
              'Date de demande',
              DateFormat('dd/MM/yyyy').format(_financing.requestDate),
            ),
            if (_financing.approvalDate != null)
              _buildDetailRow(
                'Date d\'approbation',
                DateFormat('dd/MM/yyyy').format(_financing.approvalDate!),
              ),
            if (_financing.disbursementDate != null)
              _buildDetailRow(
                'Date de décaissement',
                DateFormat('dd/MM/yyyy').format(_financing.disbursementDate!),
              ),
            if (_financing.interestRate != null)
              _buildDetailRow(
                'Taux d\'intérêt',
                '${_financing.interestRate}%',
              ),
            if (_financing.termMonths != null)
              _buildDetailRow(
                'Durée',
                '${_financing.termMonths} mois',
              ),
            if (_financing.financialProduct != null)
              _buildDetailRow(
                'Produit financier',
                _financing.financialProduct!.displayName,
              ),
            if (_financing.type == FinancingType.leasing && _financing.leasingCode != null)
              _buildDetailRow(
                'Code de leasing',
                _financing.leasingCode!,
              ),
            if (_financing.monthlyPayment != null)
              _buildDetailRow(
                'Paiement mensuel',
                NumberFormat.currency(
                  locale: 'fr_FR',
                  symbol: _financing.currency,
                ).format(_financing.monthlyPayment!),
              ),
            _buildDetailRow('Motif', _financing.reason),
            if (_financing.notes != null && _financing.notes!.isNotEmpty)
              _buildDetailRow('Notes', _financing.notes!),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard() {
    final scheduledPayments = _financing.scheduledPayments ?? [];
    final completedPayments = _financing.completedPayments ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Échéancier de remboursement',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            if (scheduledPayments.isEmpty)
              const Text('Aucun échéancier disponible.'),
            for (int i = 0; i < scheduledPayments.length; i++)
              ListTile(
                leading: Icon(
                  completedPayments.any((date) =>
                      date.year == scheduledPayments[i].year &&
                      date.month == scheduledPayments[i].month &&
                      date.day == scheduledPayments[i].day)
                      ? Icons.check_circle
                      : scheduledPayments[i].isBefore(DateTime.now())
                          ? Icons.warning
                          : Icons.schedule,
                  color: completedPayments.any((date) =>
                      date.year == scheduledPayments[i].year &&
                      date.month == scheduledPayments[i].month &&
                      date.day == scheduledPayments[i].day)
                      ? Colors.green
                      : scheduledPayments[i].isBefore(DateTime.now())
                          ? Colors.red
                          : Colors.orange,
                ),
                title: Text(
                  'Échéance ${i + 1}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text(
                  DateFormat('dd/MM/yyyy').format(scheduledPayments[i]),
                ),
                trailing: _financing.monthlyPayment != null
                    ? Text(
                        NumberFormat.currency(
                          locale: 'fr_FR',
                          symbol: _financing.currency,
                        ).format(_financing.monthlyPayment!),
                      )
                    : null,
                onTap: _financing.status == 'disbursed' ||
                        _financing.status == 'repaying'
                    ? () => _showRecordPaymentDialog(i)
                    : null,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            // Action: Validate receipt (Confirm funds received)
            if (_financing.status == 'approved')
              ElevatedButton.icon(
                onPressed: _showDisburseFundsDialog,
                icon: const Icon(Icons.check_circle),
                label: const Text('Confirmer réception des fonds'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            
            // Action: Record repayment
            if (_financing.status == 'disbursed' || _financing.status == 'repaying')
              ElevatedButton.icon(
                onPressed: () => _showRecordPaymentDialog(null),
                icon: const Icon(Icons.payment),
                label: const Text('Enregistrer un remboursement'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
              ),
            
            // Action: Delete request - available for all statuses
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _showDeleteConfirmationDialog,
              icon: const Icon(Icons.delete),
              label: const Text('Supprimer cette demande'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Future<void> _showApproveDialog() async {
    final interestRateController = TextEditingController();
    final termMonthsController = TextEditingController();
    final monthlyPaymentController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Approuver le financement'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: interestRateController,
                    decoration: const InputDecoration(
                      labelText: 'Taux d\'intérêt (%)',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un taux d\'intérêt';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Veuillez entrer un nombre valide';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: termMonthsController,
                    decoration: const InputDecoration(
                      labelText: 'Durée (mois)',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer une durée';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Veuillez entrer un nombre entier';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: monthlyPaymentController,
                    decoration: InputDecoration(
                      labelText: 'Paiement mensuel (${_financing.currency})',
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
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop();
                  
                  final interestRate = double.parse(interestRateController.text);
                  final termMonths = int.parse(termMonthsController.text);
                  final monthlyPayment = double.parse(monthlyPaymentController.text);
                  
                  context.read<FinancingBloc>().add(
                    ApproveFinancingRequest(
                      requestId: _financing.id,
                      approvalDate: DateTime.now(),
                      interestRate: interestRate,
                      termMonths: termMonths,
                      monthlyPayment: monthlyPayment,
                    ),
                  );
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Financement approuvé avec succès'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  
                  // Reload the financing data
                  _loadFinancing();
                }
              },
              child: const Text('Approuver'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showRejectDialog() async {
    final reasonController = TextEditingController();
    
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Rejeter le financement'),
          content: TextFormField(
            controller: reasonController,
            decoration: const InputDecoration(
              labelText: 'Motif du rejet',
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                
                // Mettre à jour le statut du financement
                final updatedFinancing = _financing.copyWith(
                  status: 'rejected',
                  notes: reasonController.text,
                );
                
                context.read<FinancingBloc>().add(
                  UpdateFinancingRequest(updatedFinancing),
                );
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Financement rejeté'),
                    backgroundColor: Colors.red,
                  ),
                );
                
                // Reload the financing data
                _loadFinancing();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Rejeter'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDisburseFundsDialog() async {
    // Create scheduled payments based on term months
    final List<DateTime> scheduledPayments = [];
    if (_financing.termMonths != null) {
      final now = DateTime.now();
      for (int i = 1; i <= _financing.termMonths!; i++) {
        scheduledPayments.add(
          DateTime(now.year, now.month + i, now.day),
        );
      }
    }
    
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Débloquer les fonds'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Êtes-vous sûr de vouloir débloquer ${NumberFormat.currency(locale: 'fr_FR', symbol: _financing.currency).format(_financing.amount)} pour ce financement?',
              ),
              const SizedBox(height: 16),
              Text(
                'Un échéancier de ${_financing.termMonths} mensualités sera automatiquement créé.',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                
                context.read<FinancingBloc>().add(
                  DisburseFunds(
                    requestId: _financing.id,
                    disbursementDate: DateTime.now(),
                    scheduledPayments: scheduledPayments,
                  ),
                );
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fonds débloqués avec succès'),
                    backgroundColor: Colors.blue,
                  ),
                );
                
                // Reload the financing data
                _loadFinancing();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Débloquer'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showRecordPaymentDialog(int? paymentIndex) async {
    final amountController = TextEditingController();
    if (_financing.monthlyPayment != null) {
      amountController.text = _financing.monthlyPayment!.toString();
    }
    
    final formKey = GlobalKey<FormState>();
    
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(paymentIndex != null 
              ? 'Paiement pour l\'échéance ${paymentIndex + 1}' 
              : 'Enregistrer un paiement'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (paymentIndex != null)
                  Text(
                    'Date d\'échéance: ${DateFormat('dd/MM/yyyy').format(_financing.scheduledPayments![paymentIndex])}',
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: 'Montant (${_financing.currency})',
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
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop();
                  
                  final amount = double.parse(amountController.text);
                  
                  context.read<FinancingBloc>().add(
                    RecordPayment(
                      requestId: _financing.id,
                      paymentDate: DateTime.now(),
                      amount: amount,
                    ),
                  );
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Paiement enregistré avec succès'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  
                  // Reload the financing data
                  _loadFinancing();
                }
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Supprimer cette demande'),
          content: const Text(
            'Êtes-vous sûr de vouloir supprimer cette demande de financement? Cette action est irréversible.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                
                // Supprimer la demande
                context.read<FinancingBloc>().add(
                  DeleteFinancingRequest(_financing.id),
                );
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Demande de financement supprimée'),
                    backgroundColor: Colors.red,
                  ),
                );
                
                // Revenir à l'écran précédent
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }
}
