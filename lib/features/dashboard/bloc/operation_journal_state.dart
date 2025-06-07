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
  final double openingBalance; // Maintenu pour compatibilité
  final Map<String, double> openingBalancesByCurrency; // Nouveau champ pour les soldes d'ouverture par devise

  const OperationJournalLoaded({
    required this.operations,
    required this.startDate,
    required this.endDate,
    required this.groupedOperations,
    required this.openingBalance,
    required this.openingBalancesByCurrency,
  });

  OperationJournalLoaded copyWith({
    List<OperationJournalEntry>? operations,
    DateTime? startDate,
    DateTime? endDate,
    Map<DateTime, List<OperationJournalEntry>>? groupedOperations,
    double? openingBalance,
    Map<String, double>? openingBalancesByCurrency,
  }) {
    return OperationJournalLoaded(
      operations: operations ?? this.operations,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      groupedOperations: groupedOperations ?? this.groupedOperations,
      openingBalance: openingBalance ?? this.openingBalance,
      openingBalancesByCurrency: openingBalancesByCurrency ?? this.openingBalancesByCurrency,
    );
  }
}

class OperationJournalError extends OperationJournalState {
  final String message;
  const OperationJournalError(this.message);
}
