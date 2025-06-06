import '../models/transaction.dart';
import '../../expenses/repositories/expense_repository.dart';
import '../../expenses/models/expense.dart';

// Placeholder for TransactionRepository. Implement with actual data source (Hive, API, etc.)
class TransactionRepository {
  // Example: In-memory list for demonstration
  final List<Transaction> _transactions = [];
  final ExpenseRepository? _expenseRepository; // Optional dependency

  TransactionRepository({ExpenseRepository? expenseRepository})
      : _expenseRepository = expenseRepository;

  Future<void> init() async {
    // Initialize data source if needed (e.g., open Hive box)
  }

  Future<List<Transaction>> getTransactionsForDate(DateTime date) async {
    // Filter transactions for the given date
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    return _transactions
        .where((t) => t.date.isAfter(startOfDay) && t.date.isBefore(endOfDay))
        .toList();
  }

  Future<int> getTransactionCountForDate(DateTime date) async {
    final transactionsOnDate = await getTransactionsForDate(date);
    return transactionsOnDate.length;
  }

  Future<void> addTransaction(Transaction transaction) async {
    _transactions.add(transaction);
    // Persist to data source
  }

  // Get all transactions between two dates
  Future<List<Transaction>> getTransactionsByDateRange(
      DateTime startDate, DateTime endDate) async {
    return _transactions
        .where((t) =>
            t.date.isAfter(startDate) &&
            t.date.isBefore(endDate.add(const Duration(days: 1))))
        .toList();
  }

  // Get total expenses for a date range
  Future<double> getTotalExpensesForDateRange(
      DateTime startDate, DateTime endDate) async {
    // If expense repository is provided, use it directly for more accurate data
    if (_expenseRepository != null) {
      final expenses =
          await _expenseRepository!.getExpensesByDateRange(startDate, endDate);
      double total = 0.0;
      for (final expense in expenses) {
        total += expense.amount;
      }
      return total;
    }

    // Fallback to using transactions if expense repository is not available
    final transactions = await getTransactionsByDateRange(startDate, endDate);
    double total = 0.0;
    for (final transaction in transactions) {
      if (transaction.type == 'expense') {
        total += transaction.amount;
      }
    }
    return total;
  }

  // Add other methods as needed (e.g., getTransactionById, updateTransaction, deleteTransaction)
}
