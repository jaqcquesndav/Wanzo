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
  final double salesTodayCdf;
  final double salesTodayUsd;
  final int clientsServedToday;
  final double receivables;
  final double expenses;
  // Add other KPI fields as needed

  const DashboardLoaded({
    required this.salesTodayCdf,
    required this.salesTodayUsd,
    required this.clientsServedToday,
    required this.receivables,
    required this.expenses,
  });

  @override
  List<Object> get props => [salesTodayCdf, salesTodayUsd, clientsServedToday, receivables, expenses];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object> get props => [message];
}
