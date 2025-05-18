part of 'financing_bloc.dart';

abstract class FinancingEvent extends Equatable {
  const FinancingEvent();

  @override
  List<Object> get props => [];
}

class AddFinancingRequest extends FinancingEvent {
  final FinancingRequest request;

  const AddFinancingRequest(this.request);

  @override
  List<Object> get props => [request];
}

// Add other events like LoadFinancingRequests, UpdateFinancingRequest, DeleteFinancingRequest if needed
