part of 'operation_journal_bloc.dart';

@immutable
abstract class OperationJournalState {
  const OperationJournalState();
}

class OperationJournalInitial extends OperationJournalState {
  const OperationJournalInitial();
}

class OperationJournalLoading extends OperationJournalState {
  const OperationJournalLoading();
}

class OperationJournalLoaded extends OperationJournalState {
  final List<OperationJournalEntry> operations;
  final DateTime startDate;
  final DateTime endDate;
  final Map<DateTime, List<OperationJournalEntry>> groupedOperations;

  const OperationJournalLoaded({
    required this.operations,
    required this.startDate,
    required this.endDate,
    required this.groupedOperations,
  });

  OperationJournalLoaded copyWith({
    List<OperationJournalEntry>? operations,
    DateTime? startDate,
    DateTime? endDate,
    Map<DateTime, List<OperationJournalEntry>>? groupedOperations,
  }) {
    return OperationJournalLoaded(
      operations: operations ?? this.operations,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      groupedOperations: groupedOperations ?? this.groupedOperations,
    );
  }
}

class OperationJournalError extends OperationJournalState {
  final String message;
  const OperationJournalError(this.message);
}
