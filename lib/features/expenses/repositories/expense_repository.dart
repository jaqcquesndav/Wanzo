import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/expense.dart';

class ExpenseRepository {
  final List<Expense> _mockExpenses = [];
  final _uuid = const Uuid();

  Future<void> init() async {
    // Initialize with some mock data if needed
    // _mockExpenses.addAll([
    //   Expense(
    //     id: _uuid.v4(),
    //     date: DateTime.now().subtract(const Duration(days: 1)),
    //     description: 'Fournitures de bureau',
    //     amount: 25000,
    //     category: ExpenseCategory.supplies,
    //     paymentMethod: 'Cash',
    //   ),
    //   Expense(
    //     id: _uuid.v4(),
    //     date: DateTime.now().subtract(const Duration(hours: 5)),
    //     description: 'Paiement facture internet',
    //     amount: 35000,
    //     category: ExpenseCategory.utilities,
    //     paymentMethod: 'Mobile Money',
    //   ),
    // ]);
    debugPrint("ExpenseRepository initialized.");
  }

  Future<List<Expense>> getAllExpenses() async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay
    return List.unmodifiable(_mockExpenses);
  }

  Future<Expense?> getExpenseById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _mockExpenses.firstWhere((expense) => expense.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<Expense> addExpense(Expense expense) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newExpense = expense.copyWith(id: _uuid.v4());
    _mockExpenses.add(newExpense);
    debugPrint("Expense added: ${newExpense.motif} - ${_mockExpenses.length} total expenses");
    return newExpense;
  }

  Future<Expense> updateExpense(Expense expense) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _mockExpenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _mockExpenses[index] = expense;
      return expense;
    }
    throw Exception('Expense not found for update');
  }

  Future<void> deleteExpense(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockExpenses.removeWhere((expense) => expense.id == id);
  }

  Future<List<Expense>> getExpensesByDateRange(DateTime startDate, DateTime endDate) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockExpenses
        .where((expense) => 
            expense.date.isAfter(startDate.subtract(const Duration(microseconds: 1))) && 
            expense.date.isBefore(endDate.add(const Duration(microseconds: 1))))
        .toList();
  }

   Future<List<Expense>> getExpensesByCategory(ExpenseCategory category) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockExpenses.where((expense) => expense.category == category).toList();
  }
}
