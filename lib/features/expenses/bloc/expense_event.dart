part of 'expense_bloc.dart';

abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();

  @override
  List<Object?> get props => [];
}

class LoadExpenses extends ExpenseEvent {
  const LoadExpenses();
}

class LoadExpensesByDateRange extends ExpenseEvent {
  final DateTime startDate;
  final DateTime endDate;

  const LoadExpensesByDateRange(this.startDate, this.endDate);

  @override
  List<Object> get props => [startDate, endDate];
}

class LoadExpensesByCategory extends ExpenseEvent {
  final ExpenseCategory category;

  const LoadExpensesByCategory(this.category);

  @override
  List<Object> get props => [category];
}

class AddExpense extends ExpenseEvent {
  final Expense expense;
  final List<File>? imageFiles; // Added imageFiles

  const AddExpense(this.expense, {this.imageFiles}); // Added imageFiles

  @override
  List<Object?> get props => [expense, imageFiles]; // Added imageFiles to props
}

class UpdateExpense extends ExpenseEvent {
  final Expense expense;

  const UpdateExpense(this.expense);

  @override
  List<Object> get props => [expense];
}

class DeleteExpense extends ExpenseEvent {
  final String expenseId;

  const DeleteExpense(this.expenseId);

  @override
  List<Object> get props => [expenseId];
}

class LoadExpenseById extends ExpenseEvent {
  final String expenseId;

  const LoadExpenseById(this.expenseId);

  @override
  List<Object> get props => [expenseId];
}
