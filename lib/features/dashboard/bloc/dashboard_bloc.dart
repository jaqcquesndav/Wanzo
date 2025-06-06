import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart'; // Required for @immutable
import '../../sales/repositories/sales_repository.dart';
import '../../customer/repositories/customer_repository.dart';
import '../../transactions/repositories/transaction_repository.dart';
import '../../expenses/repositories/expense_repository.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final SalesRepository _salesRepository;
  final CustomerRepository _customerRepository; 
  final TransactionRepository _transactionRepository;
  final ExpenseRepository? _expenseRepository;

  DashboardBloc({
    required SalesRepository salesRepository,
    required CustomerRepository customerRepository,
    required TransactionRepository transactionRepository,
    ExpenseRepository? expenseRepository,
  }) : _salesRepository = salesRepository,
       _customerRepository = customerRepository,
       _transactionRepository = transactionRepository,
       _expenseRepository = expenseRepository,
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
      
      // Separate sales in CDF and USD
      double salesTodayCdf = 0.0;
      double salesTodayUsd = 0.0;
        for (final sale in sales) {
        // Add to CDF sales only if the transaction was in CDF
        if (sale.transactionCurrencyCode == 'CDF' || sale.transactionCurrencyCode == null) {
          salesTodayCdf += sale.totalAmountInCdf;
        }
        
        // Add to USD sales if transaction was in USD
        if (sale.transactionCurrencyCode == 'USD') {
          salesTodayUsd += sale.totalAmountInTransactionCurrency ?? 0.0;
        } else if (sale.totalAmountInUsd != null && sale.transactionCurrencyCode == 'USD') {
          // Use totalAmountInUsd if available as a fallback, but only for USD transactions
          salesTodayUsd += sale.totalAmountInUsd!;
        }
      }

      // Clients Served Today
      final int clientsServedToday = await _customerRepository.getUniqueCustomersCountForDateRange(todayStart, todayEnd);

      // Receivables - Montants à recevoir
      final double receivables = await _salesRepository.getTotalReceivables();

      // Expenses - Dépenses
      double expenses = 0.0;
      try {
        // Try to get expenses from expense repository first if available
        if (_expenseRepository != null) {
          final todayExpenses = await _expenseRepository.getExpensesByDateRange(todayStart, todayEnd);
          for (final expense in todayExpenses) {
            expenses += expense.amount;
          }
        } else {
          // Fallback to transaction repository
          expenses = await _transactionRepository.getTotalExpensesForDateRange(todayStart, todayEnd);
        }
      } catch (e) {
        // Fallback if the specific method is not available
        try {
          final transactions = await _transactionRepository.getTransactionsByDateRange(todayStart, todayEnd);
          for (final transaction in transactions) {
            if (transaction.isExpense) {
              expenses += transaction.amount.abs();
            }
          }
        } catch (innerE) {
          // If all else fails, just set expenses to 0
          expenses = 0.0;
        }
      }

      emit(DashboardLoaded(
        salesTodayCdf: salesTodayCdf,
        salesTodayUsd: salesTodayUsd,
        clientsServedToday: clientsServedToday,
        receivables: receivables,
        expenses: expenses,
      ));
    } catch (e) {
      emit(DashboardError("Erreur de chargement des données du tableau de bord: ${e.toString()}"));
    }
  }
}
