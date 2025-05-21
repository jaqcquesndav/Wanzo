import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../models/operation_journal_entry.dart';
import '../repositories/operation_journal_repository.dart';
import 'package:collection/collection.dart'; // For groupBy

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
  }

  Future<void> _onLoadOperations(
    LoadOperations event,
    Emitter<OperationJournalState> emit,
  ) async {
    emit(const OperationJournalLoading());
    try {
      final operations = await _repository.getOperations(event.startDate, event.endDate);
      final openingBalance = await _repository.getOpeningBalance(event.startDate);
      final grouped = _groupOperationsByDay(operations);
      emit(OperationJournalLoaded(
        operations: operations,
        startDate: event.startDate,
        endDate: event.endDate,
        groupedOperations: grouped,
        openingBalance: openingBalance, // Pass opening balance to state
      ));
    } catch (e) {
      emit(OperationJournalError('Erreur de chargement des opérations: $e'));
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
      if (state is! OperationJournalError) { // Avoid overwriting existing error if not relevant
         // emit(OperationJournalError('Erreur lors de l\'ajout de l\'entrée: $e'));
      }
    }
  }

  Map<DateTime, List<OperationJournalEntry>> _groupOperationsByDay(
      List<OperationJournalEntry> operations) {
    return groupBy(operations, (OperationJournalEntry op) {
      return DateTime(op.date.year, op.date.month, op.date.day);
    });
  }
}
