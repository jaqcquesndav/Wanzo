import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../models/expense.dart';
import '../repositories/expense_repository.dart';
import '../../dashboard/models/operation_journal_entry.dart';
import '../../dashboard/repositories/operation_journal_repository.dart';
import '../../dashboard/bloc/operation_journal_bloc.dart'; // Import OperationJournalBloc

part 'expense_event.dart';
part 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final ExpenseRepository _expenseRepository;
  final OperationJournalRepository _journalRepository;
  final OperationJournalBloc _operationJournalBloc; // Add OperationJournalBloc
  final _uuid = const Uuid();

  ExpenseBloc({
    required ExpenseRepository expenseRepository,
    required OperationJournalRepository journalRepository,
    required OperationJournalBloc operationJournalBloc, // Inject OperationJournalBloc
  })  : _expenseRepository = expenseRepository,
        _journalRepository = journalRepository,
        _operationJournalBloc = operationJournalBloc, // Initialize OperationJournalBloc
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
        description: "Dépense: ${newExpense.description}",
        amount: -newExpense.amount, // Montant négatif pour une sortie
        paymentMethod: newExpense.paymentMethod,
        relatedDocumentId: newExpense.id, // Lier au document de dépense
      );
      await _journalRepository.addOperation(journalEntry); // Changed to addOperation
      _operationJournalBloc.add(const RefreshJournal()); // Dispatch RefreshJournal event

      emit(ExpenseOperationSuccess('Dépense ajoutée avec succès et enregistrée au journal.'));
      add(const LoadExpenses()); // Recharger la liste des dépenses
      // Potentiellement notifier OperationJournalBloc pour rafraîchir
    } catch (e) {
      emit(ExpenseError("Erreur lors de l'ajout de la dépense: ${e.toString()}"));
    }
  }

  Future<void> _onUpdateExpense(UpdateExpense event, Emitter<ExpenseState> emit) async {
    emit(const ExpenseLoading());
    try {
      await _expenseRepository.updateExpense(event.expense);
      // TODO: Mettre à jour l'entrée de journal correspondante si nécessaire. 
      // Cela peut être complexe si le montant ou la date change.
      // Pour l'instant, on ne met à jour que la dépense elle-même.
      emit(const ExpenseOperationSuccess('Dépense mise à jour avec succès.'));
      add(const LoadExpenses());
    } catch (e) {
      emit(ExpenseError("Erreur lors de la mise à jour de la dépense: ${e.toString()}"));
    }
  }

  Future<void> _onDeleteExpense(DeleteExpense event, Emitter<ExpenseState> emit) async {
    emit(const ExpenseLoading());
    try {
      await _expenseRepository.deleteExpense(event.expenseId);
      // TODO: Supprimer ou marquer comme annulée l'entrée de journal correspondante.
      // Pour l'instant, on ne supprime que la dépense elle-même.
      emit(const ExpenseOperationSuccess('Dépense supprimée avec succès.'));
      add(const LoadExpenses());
    } catch (e) {
      emit(ExpenseError("Erreur lors de la suppression de la dépense: ${e.toString()}"));
    }
  }
}
