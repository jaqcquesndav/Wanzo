import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../models/operation_journal_entry.dart';
import '../repositories/operation_journal_repository.dart';
import 'package:collection/collection.dart'; // For sortBy and groupBy

part 'operation_journal_event.dart';
part 'operation_journal_state.dart';

class OperationJournalBloc
    extends Bloc<OperationJournalEvent, OperationJournalState> {
  final OperationJournalRepository _repository;

  OperationJournalBloc({required OperationJournalRepository repository})
      : _repository = repository,
        super(const OperationJournalInitial()) {
    on<LoadOperations>(_onLoadOperations);
    on<FilterPeriodChanged>(_onFilterPeriodChanged);
    on<RefreshJournal>(_onRefreshJournal);
    on<AddOperationJournalEntry>(_onAddOperationJournalEntry); // Added handler
    on<AddMultipleOperationJournalEntries>(_onAddMultipleOperationJournalEntries); // Added handler
  }
  Future<void> _onLoadOperations(
    LoadOperations event,
    Emitter<OperationJournalState> emit,
  ) async {
    emit(const OperationJournalLoading());
    try {
      // 1. Fetch raw operations and opening balances
      final rawOperations = await _repository.getOperations(event.startDate, event.endDate);
      final openingBalancesByCurrency = await _repository.getOpeningBalances(event.startDate);
      final openingBalance = openingBalancesByCurrency.values.fold(0.0, (prev, curr) => prev + curr);

      // 2. Sort operations by date
      final sortedOperations = List<OperationJournalEntry>.from(rawOperations);
      sortedOperations.sort((a, b) => a.date.compareTo(b.date));

      // 3. Calculate isDebit, isCredit, and running balances by currency
      final processedOperations = <OperationJournalEntry>[];
      double currentBalance = openingBalance;
      Map<String, double> currentBalancesByCurrency = Map<String, double>.from(openingBalancesByCurrency);

      for (final op in sortedOperations) {
        final bool calculatedIsDebit = op.amount < 0;
        final bool calculatedIsCredit = op.amount > 0;
        
        // Mettre à jour le solde total pour compatibilité
        currentBalance += op.amount;
        
        // Mettre à jour le solde de la devise spécifique
        String currencyCode = op.currencyCode ?? 'CDF';
        currentBalancesByCurrency[currencyCode] = (currentBalancesByCurrency[currencyCode] ?? 0.0) + op.amount;
        
        // Vérifier que les devises principales sont toujours présentes
        if (!currentBalancesByCurrency.containsKey('USD')) currentBalancesByCurrency['USD'] = 0.0;
        if (!currentBalancesByCurrency.containsKey('CDF')) currentBalancesByCurrency['CDF'] = 0.0;
        
        processedOperations.add(op.copyWith(
          isDebit: calculatedIsDebit,
          isCredit: calculatedIsCredit,
          balanceAfter: currentBalance,
          balancesByCurrency: Map<String, double>.from(currentBalancesByCurrency),
        ));
      }

      // 4. Group processed operations by day
      final grouped = _groupOperationsByDay(processedOperations);

      // 5. Emit the loaded state with processed data
      emit(OperationJournalLoaded(
        operations: processedOperations,
        startDate: event.startDate,
        endDate: event.endDate,
        groupedOperations: grouped,
        openingBalance: openingBalance,
        openingBalancesByCurrency: openingBalancesByCurrency,
      ));
    } catch (e) {
      emit(OperationJournalError('Erreur de chargement des opérations: ${e.toString()}'));
    }
  }

  void _onFilterPeriodChanged(
    FilterPeriodChanged event,
    Emitter<OperationJournalState> emit,
  ) {
    if (state is OperationJournalLoaded) {
      final currentState = state as OperationJournalLoaded;
      final newStartDate = event.newStartDate ?? currentState.startDate;
      final newEndDate = event.newEndDate ?? currentState.endDate;
      add(LoadOperations(startDate: newStartDate, endDate: newEndDate));
    }
  }

  Future<void> _onRefreshJournal(
    RefreshJournal event,
    Emitter<OperationJournalState> emit,
  ) async {
    if (state is OperationJournalLoaded) {
      final currentState = state as OperationJournalLoaded;
      add(LoadOperations(startDate: currentState.startDate, endDate: currentState.endDate));
    } else {
      final now = DateTime.now();
      add(LoadOperations(startDate: DateTime(now.year, now.month, 1), endDate: now));
    }
  }

  // Handler for adding a new journal entry
  Future<void> _onAddOperationJournalEntry(
    AddOperationJournalEntry event,
    Emitter<OperationJournalState> emit,
  ) async {
    try {
      await _repository.addOperation(event.entry);
      // After adding, refresh the journal to show the new entry
      // We need to ensure the current state has date range, or use a default
      if (state is OperationJournalLoaded) {
        final currentState = state as OperationJournalLoaded;
        add(LoadOperations(startDate: currentState.startDate, endDate: currentState.endDate));
      } else {
        // If journal wasn't loaded, load it with a default range
        final now = DateTime.now();
        add(LoadOperations(startDate: DateTime(now.year, now.month, 1), endDate: now));
      }
    } catch (e) {
      // Optionally, emit an error state or log the error
      // For now, we'll just print it, as journal update is a background task
      if (kDebugMode) {
        print('Erreur lors de l\'ajout à l\'operation journal: $e');
      }
      // To prevent UI freeze if this bloc is listened to for errors, 
      // ensure we emit a state if an error occurs during add.
      // However, typically adding to journal might not need specific UI error feedback
      // unless it's critical for the user flow.
      // If the current state is an error, we might want to preserve it or update it.
      // if (state is! OperationJournalError) { // Avoid overwriting existing error if not relevant
      //    emit(OperationJournalError('Erreur lors de l\'ajout de l\'entrée: ${e.toString()}'));
      // }
      emit(OperationJournalError('Erreur lors de l\'ajout de l\'entrée au journal: ${e.toString()}'));
    }
  }

  // Handler for adding multiple journal entries
  Future<void> _onAddMultipleOperationJournalEntries(
    AddMultipleOperationJournalEntries event,
    Emitter<OperationJournalState> emit,
  ) async {
    if (event.entries.isEmpty) {
      // If there are no entries, no need to do anything or refresh.
      // Optionally, log this situation if it's unexpected.
      if (kDebugMode) {
        print("No entries provided to _onAddMultipleOperationJournalEntries.");
      }
      return;
    }
    try {
      await _repository.addOperationEntries(event.entries);
      // After adding, refresh the journal to show the new entries
      if (state is OperationJournalLoaded) {
        final currentState = state as OperationJournalLoaded;
        add(LoadOperations(startDate: currentState.startDate, endDate: currentState.endDate));
      } else {
        final now = DateTime.now();
        add(LoadOperations(startDate: DateTime(now.year, now.month, 1), endDate: now));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de l\'ajout de plusieurs entrées à l\'operation journal: $e');
      }
      // Optionally emit an error state
      emit(OperationJournalError('Erreur lors de l\'ajout des entrées au journal: ${e.toString()}'));
    }
  }

  Map<DateTime, List<OperationJournalEntry>> _groupOperationsByDay(
      List<OperationJournalEntry> operations) {
    // Group by the date part only (year, month, day)
    return groupBy(operations, (OperationJournalEntry op) {
      return DateTime(op.date.year, op.date.month, op.date.day);
    });
  }
}
