// filepath: c:\Users\DevSpace\Flutter\wanzo\lib\features\sales\bloc\sales_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/sale.dart';
import '../repositories/sales_repository.dart';

part 'sales_event.dart';
part 'sales_state.dart';

/// Bloc gérant l'état des ventes
class SalesBloc extends Bloc<SalesEvent, SalesState> {
  final SalesRepository _salesRepository;
  SalesBloc({required SalesRepository salesRepository})
      : _salesRepository = salesRepository,
        super(const SalesInitial()) {
    on<LoadSales>(_onLoadSales);
    on<LoadSalesByStatus>(_onLoadSalesByStatus);
    on<LoadSalesByCustomer>(_onLoadSalesByCustomer);
    on<LoadSalesByDateRange>(_onLoadSalesByDateRange);
    on<AddSale>(_onAddSale);
    on<UpdateSale>(_onUpdateSale);
    on<UpdateSaleStatus>(_onUpdateSaleStatus);
    on<DeleteSale>(_onDeleteSale);
  }

  /// Charger toutes les ventes
  Future<void> _onLoadSales(
    LoadSales event,
    Emitter<SalesState> emit,
  ) async {
    emit(const SalesLoading());
    try {
      final sales = await _salesRepository.getAllSales();
      final totalAmount = sales.fold(0.0, (total, sale) => total + sale.totalAmount);
      emit(SalesLoaded(sales: sales, totalAmount: totalAmount));
    } catch (e) {
      emit(SalesError(e.toString()));
    }
  }

  /// Charger les ventes par statut
  Future<void> _onLoadSalesByStatus(
    LoadSalesByStatus event,
    Emitter<SalesState> emit,
  ) async {
    emit(const SalesLoading());
    try {
      final sales = await _salesRepository.getSalesByStatus(event.status);
      final totalAmount = sales.fold(0.0, (total, sale) => total + sale.totalAmount);
      emit(SalesLoaded(sales: sales, totalAmount: totalAmount));
    } catch (e) {
      emit(SalesError(e.toString()));
    }
  }

  /// Charger les ventes d'un client
  Future<void> _onLoadSalesByCustomer(
    LoadSalesByCustomer event,
    Emitter<SalesState> emit,
  ) async {
    emit(const SalesLoading());
    try {
      final sales = await _salesRepository.getSalesByCustomer(event.customerId);
      final totalAmount = sales.fold(0.0, (total, sale) => total + sale.totalAmount);
      emit(SalesLoaded(sales: sales, totalAmount: totalAmount));
    } catch (e) {
      emit(SalesError(e.toString()));
    }
  }

  /// Charger les ventes par période
  Future<void> _onLoadSalesByDateRange(
    LoadSalesByDateRange event,
    Emitter<SalesState> emit,
  ) async {
    emit(const SalesLoading());
    try {
      final sales = await _salesRepository.getSalesByDateRange(
        event.startDate,
        event.endDate,
      );
      final totalAmount = sales.fold(0.0, (total, sale) => total + sale.totalAmount);
      emit(SalesLoaded(sales: sales, totalAmount: totalAmount));
    } catch (e) {
      emit(SalesError(e.toString()));
    }
  }

  /// Ajouter une nouvelle vente
  Future<void> _onAddSale(
    AddSale event,
    Emitter<SalesState> emit,
  ) async {
    emit(const SalesLoading());
    try {
      await _salesRepository.addSale(event.sale);
      emit(const SalesOperationSuccess('Vente ajoutée avec succès'));
      add(const LoadSales());
    } catch (e) {
      emit(SalesError(e.toString()));
    }
  }

  /// Mettre à jour une vente
  Future<void> _onUpdateSale(
    UpdateSale event,
    Emitter<SalesState> emit,
  ) async {
    emit(const SalesLoading());
    try {
      await _salesRepository.updateSale(event.sale);
      emit(const SalesOperationSuccess('Vente mise à jour avec succès'));
      add(const LoadSales());
    } catch (e) {
      emit(SalesError(e.toString()));
    }
  }
  /// Supprimer une vente
  Future<void> _onDeleteSale(
    DeleteSale event,
    Emitter<SalesState> emit,
  ) async {
    emit(const SalesLoading());
    try {
      await _salesRepository.deleteSale(event.id);
      emit(const SalesOperationSuccess('Vente supprimée avec succès'));
      add(const LoadSales());
    } catch (e) {
      emit(SalesError(e.toString()));
    }
  }
  
  /// Mettre à jour le statut d'une vente
  Future<void> _onUpdateSaleStatus(
    UpdateSaleStatus event,
    Emitter<SalesState> emit,
  ) async {
    emit(const SalesLoading());
    try {
      // Récupérer la vente existante
      final sale = await _salesRepository.getSaleById(event.id);
      if (sale != null) {
        // Créer une nouvelle instance avec le statut mis à jour
        final updatedSale = Sale(
          id: sale.id,
          date: sale.date,
          customerId: sale.customerId,
          customerName: sale.customerName,
          items: sale.items,
          totalAmount: sale.totalAmount,
          paidAmount: sale.paidAmount,
          paymentMethod: sale.paymentMethod,
          status: event.status,
          notes: sale.notes,
        );
        
        // Mettre à jour la vente
        await _salesRepository.updateSale(updatedSale);
        emit(const SalesOperationSuccess('Statut de la vente mis à jour avec succès'));
        add(const LoadSales());
      } else {
        emit(const SalesError('Vente introuvable'));
      }
    } catch (e) {
      emit(SalesError(e.toString()));
    }
  }
}
