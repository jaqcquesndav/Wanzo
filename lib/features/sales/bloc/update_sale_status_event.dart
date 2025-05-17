// filepath: c:\Users\DevSpace\Flutter\wanzo\lib\features\sales\bloc\update_sale_status_event.dart
part of 'sales_bloc.dart';

/// Événement pour mettre à jour le statut d'une vente
class UpdateSaleStatus extends SalesEvent {
  final String id;
  final SaleStatus status;

  const UpdateSaleStatus(this.id, this.status);

  @override
  List<Object?> get props => [id, status];
}
