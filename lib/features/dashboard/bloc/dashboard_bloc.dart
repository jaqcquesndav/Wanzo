import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart'; // Required for @immutable
import '../../sales/repositories/sales_repository.dart';
import '../../customer/repositories/customer_repository.dart';
import '../../transactions/repositories/transaction_repository.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final SalesRepository _salesRepository;
  final CustomerRepository _customerRepository; 
  final TransactionRepository _transactionRepository;

  DashboardBloc({
    required SalesRepository salesRepository,
    required CustomerRepository customerRepository,
    required TransactionRepository transactionRepository,
  }) : _salesRepository = salesRepository,
       _customerRepository = customerRepository,
       _transactionRepository = transactionRepository,
       super(DashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
  }

  Future<void> _onLoadDashboardData(LoadDashboardData event, Emitter<DashboardState> emit) async {
    emit(DashboardLoading());
    try {
      // Fetch data for KPIs
      // Note: These are simplified examples. Actual implementation will depend on repository methods and data models.

      // Sales Today
      final todayStart = DateTime(event.date.year, event.date.month, event.date.day);
      final todayEnd = DateTime(event.date.year, event.date.month, event.date.day, 23, 59, 59);
      final sales = await _salesRepository.getSalesByDateRange(todayStart, todayEnd);
      final double salesToday = sales.fold(0.0, (sum, sale) => sum + sale.totalAmount);

      // Clients Served Today - This is a placeholder. 
      // You'll need a way to count unique customers from today's sales or a separate metric.
      // final int clientsServedToday = sales.map((s) => s.customerId).toSet().length; // Example if customerId is available and represents unique clients
      // For now, using a placeholder. This needs to be refined based on actual data and logic.
      final int clientsServedToday = await _customerRepository.getUniqueCustomersCountForDateRange(todayStart, todayEnd);


      // Receivables - This is a placeholder. 
      // You'll need a method in SalesRepository or a dedicated receivables repository.
      final double receivables = await _salesRepository.getTotalReceivables();

      // Transactions Today - This is a placeholder.
      // You might count sales, expenses, etc., or have a dedicated transaction log.
      // final int transactionsToday = await _transactionRepository.getTransactionCountForDate(event.date);
      final int transactionsToday = await _transactionRepository.getTransactionCountForDate(event.date); // Using TransactionRepository

      emit(DashboardLoaded(
        salesToday: salesToday,
        clientsServedToday: clientsServedToday,
        receivables: receivables,
        transactionsToday: transactionsToday,
      ));
    } catch (e) {
      emit(DashboardError("Erreur de chargement des données du tableau de bord: ${e.toString()}"));
    }
  }
}
