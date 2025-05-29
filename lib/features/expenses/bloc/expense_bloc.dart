import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../models/expense.dart';
import '../repositories/expense_repository.dart';
import '../../dashboard/models/operation_journal_entry.dart';
import '../../dashboard/bloc/operation_journal_bloc.dart';

part 'expense_event.dart';
part 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final ExpenseRepository _expenseRepository;
  final OperationJournalBloc _operationJournalBloc;
  final _uuid = const Uuid();

  ExpenseBloc({
    required ExpenseRepository expenseRepository,
    required OperationJournalBloc operationJournalBloc,
  })  : _expenseRepository = expenseRepository,
        _operationJournalBloc = operationJournalBloc,
        super(const ExpenseInitial()) {
    on<LoadExpenses>(_onLoadExpenses);
    on<LoadExpensesByDateRange>(_onLoadExpensesByDateRange);
    on<LoadExpensesByCategory>(_onLoadExpensesByCategory);
    on<AddExpense>(_onAddExpense);
    on<UpdateExpense>(_onUpdateExpense);
    on<DeleteExpense>(_onDeleteExpense);
  }

  Future<void> _onLoadExpenses(LoadExpenses event, Emitter<ExpenseState> emit) async {
    emit(const ExpenseLoading());
    try {
      final expenses = await _expenseRepository.getAllExpenses();
      final total = expenses.fold(0.0, (sum, item) => sum + item.amount);
      emit(ExpensesLoaded(expenses: expenses, totalExpenses: total));
    } catch (e) {
      emit(ExpenseError("Erreur de chargement des dépenses: ${e.toString()}"));
    }
  }

  Future<void> _onLoadExpensesByDateRange(LoadExpensesByDateRange event, Emitter<ExpenseState> emit) async {
    emit(const ExpenseLoading());
    try {
      final expenses = await _expenseRepository.getExpensesByDateRange(event.startDate, event.endDate);
      final total = expenses.fold(0.0, (sum, item) => sum + item.amount);
      emit(ExpensesLoaded(expenses: expenses, totalExpenses: total));
    } catch (e) {
      emit(ExpenseError("Erreur de chargement des dépenses par période: ${e.toString()}"));
    }
  }

  Future<void> _onLoadExpensesByCategory(LoadExpensesByCategory event, Emitter<ExpenseState> emit) async {
    emit(const ExpenseLoading());
    try {
      final expenses = await _expenseRepository.getExpensesByCategory(event.category);
      final total = expenses.fold(0.0, (sum, item) => sum + item.amount);
      emit(ExpensesLoaded(expenses: expenses, totalExpenses: total));
    } catch (e) {
      emit(ExpenseError("Erreur de chargement des dépenses par catégorie: ${e.toString()}"));
    }
  }

  Future<void> _onAddExpense(AddExpense event, Emitter<ExpenseState> emit) async {
    emit(const ExpenseLoading());
    try {
      final newExpense = await _expenseRepository.addExpense(event.expense);

      final journalEntry = OperationJournalEntry(
        id: _uuid.v4(),
        date: newExpense.date,
        type: OperationType.cashOut, // Dépense est une sortie d'argent
        description: "Dépense: ${newExpense.motif}", // Changed from description to motif
        amount: -newExpense.amount.abs(), // Assurer que le montant est négatif pour cashOut
        paymentMethod: newExpense.paymentMethod,
        relatedDocumentId: newExpense.id, // Lier au document de dépense
        isDebit: true, // Expenses are debits to the business
        isCredit: false,
        balanceAfter: 0, // This will be calculated by the journal service/bloc normally
      );
      _operationJournalBloc.add(AddOperationJournalEntry(journalEntry)); // Dispatch event

      emit(ExpenseOperationSuccess('Dépense ajoutée avec succès et enregistrée au journal.'));
      add(const LoadExpenses()); // Recharger la liste des dépenses
    } catch (e) {
      emit(ExpenseError("Erreur lors de l'ajout de la dépense: ${e.toString()}"));
    }
  }

  Future<void> _onUpdateExpense(UpdateExpense event, Emitter<ExpenseState> emit) async {
    emit(const ExpenseLoading());
    try {
      // Fetch the original expense to compare changes
      final originalExpense = await _expenseRepository.getExpenseById(event.expense.id);

      if (originalExpense == null) {
        emit(ExpenseError("Dépense originale non trouvée pour la mise à jour du journal."));
        add(const LoadExpenses()); // Reload to reflect current state
        return;
      }
      
      await _expenseRepository.updateExpense(event.expense);
      final updatedExpense = event.expense; // Alias for clarity

      // 1. Create a reversing journal entry for the original expense
      final reversalJournalEntry = OperationJournalEntry(
        id: _uuid.v4(),
        date: DateTime.now(), // Or originalExpense.date - using now for reversal event time
        type: OperationType.cashIn, // Reversing a cashOut
        description: "Annulation (MàJ) Dépense: ${originalExpense.motif}", // Changed from description to motif
        amount: originalExpense.amount.abs(), // Positive amount for cashIn
        paymentMethod: originalExpense.paymentMethod,
        relatedDocumentId: originalExpense.id,
        isDebit: false, // Reversal of an expense is a credit
        isCredit: true,
        balanceAfter: 0, // Placeholder, to be calculated by journal logic
      );
      _operationJournalBloc.add(AddOperationJournalEntry(reversalJournalEntry));

      // 2. Create a new journal entry for the updated expense
      final newJournalEntry = OperationJournalEntry(
        id: _uuid.v4(),
        date: updatedExpense.date,
        type: OperationType.cashOut,
        description: "Dépense (MàJ): ${updatedExpense.motif}", // Changed from description to motif
        amount: -updatedExpense.amount.abs(), // Negative amount for cashOut
        paymentMethod: updatedExpense.paymentMethod,
        relatedDocumentId: updatedExpense.id,
        isDebit: true, // Updated expense is a debit
        isCredit: false,
        balanceAfter: 0, // Placeholder, to be calculated by journal logic
      );
      _operationJournalBloc.add(AddOperationJournalEntry(newJournalEntry));

      emit(const ExpenseOperationSuccess('Dépense mise à jour et journal ajusté avec succès.'));
      add(const LoadExpenses());
    } catch (e) {
      emit(ExpenseError("Erreur lors de la mise à jour de la dépense: ${e.toString()}"));
    }
  }

  Future<void> _onDeleteExpense(DeleteExpense event, Emitter<ExpenseState> emit) async {
    emit(const ExpenseLoading());
    try {
      // Fetch the expense before deleting to get its details for the journal entry
      final expenseToDelete = await _expenseRepository.getExpenseById(event.expenseId);

      if (expenseToDelete == null) {
        emit(ExpenseError("Dépense non trouvée pour l'annulation du journal."));
        return;
      }

      await _expenseRepository.deleteExpense(event.expenseId);

      // Create a reversing journal entry
      final journalEntry = OperationJournalEntry(
        id: _uuid.v4(),
        date: DateTime.now(), // Or expenseToDelete.date - decide on consistent date for reversal
        type: OperationType.cashIn, // Reversing a cashOut
        description: "Annulation Dépense: ${expenseToDelete.motif}", // Changed from description to motif
        amount: expenseToDelete.amount.abs(), // Positive amount for cashIn
        paymentMethod: expenseToDelete.paymentMethod,
        relatedDocumentId: expenseToDelete.id,
        isDebit: false, // Reversal of an expense is a credit
        isCredit: true,
        balanceAfter: 0, // Placeholder, to be calculated by journal logic
      );
      _operationJournalBloc.add(AddOperationJournalEntry(journalEntry));

      emit(const ExpenseOperationSuccess('Dépense supprimée et annulation enregistrée au journal.'));
      add(const LoadExpenses());
    } catch (e) {
      emit(ExpenseError("Erreur lors de la suppression de la dépense: ${e.toString()}"));
    }
  }
}
