import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../dashboard/bloc/operation_journal_bloc.dart'; // Correct import for BLoC and its events
import '../../dashboard/models/operation_journal_entry.dart';
import '../models/financing_request.dart';
import '../repositories/financing_repository.dart';

part 'financing_event.dart';
part 'financing_state.dart';

class FinancingBloc extends Bloc<FinancingEvent, FinancingState> {
  final FinancingRepository _financingRepository;
  final OperationJournalBloc _operationJournalBloc;

  FinancingBloc({
    required FinancingRepository financingRepository,
    required OperationJournalBloc operationJournalBloc,
  })  : _financingRepository = financingRepository,
        _operationJournalBloc = operationJournalBloc,
        super(FinancingInitial()) {
    on<AddFinancingRequest>(_onAddFinancingRequest);
  }

  Future<void> _onAddFinancingRequest(
    AddFinancingRequest event,
    Emitter<FinancingState> emit,
  ) async {
    emit(FinancingLoading());
    try {
      final requestWithId = event.request.id.isEmpty 
          ? event.request.copyWith(id: const Uuid().v4()) 
          : event.request;

      await _financingRepository.addRequest(requestWithId);
      
      final journalEntry = OperationJournalEntry(
        id: const Uuid().v4(),
        date: requestWithId.requestDate,
        description: 'Demande de financement: ${requestWithId.type.displayName} - ${requestWithId.institution.displayName}',
        type: OperationType.financingRequest,
        amount: requestWithId.amount, 
        relatedDocumentId: requestWithId.id,
        paymentMethod: requestWithId.currency, 
      );
      _operationJournalBloc.add(AddOperationJournalEntry(journalEntry));

      emit(const FinancingOperationSuccess('Demande de financement soumise avec succès.'));
    } catch (e) {
      emit(FinancingError('Erreur lors de la soumission: ${e.toString()}'));
    }
  }
}
