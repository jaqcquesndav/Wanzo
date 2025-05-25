part of 'dashboard_bloc.dart';

@immutable
abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final double salesToday;
  final int clientsServedToday;
  final double receivables;
  final int transactionsToday;
  // Add other KPI fields as needed

  const DashboardLoaded({
    required this.salesToday,
    required this.clientsServedToday,
    required this.receivables,
    required this.transactionsToday,
  });

  @override
  List<Object> get props => [salesToday, clientsServedToday, receivables, transactionsToday];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object> get props => [message];
}
