// filepath: c:\Users\DevSpace\Flutter\wanzo\lib\features\sales\bloc\sales_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/sale.dart';
import '../repositories/sales_repository.dart';
import '../../dashboard/models/operation_journal_entry.dart';
import '../../dashboard/bloc/operation_journal_bloc.dart'; // Imports events too
import 'package:uuid/uuid.dart';

part 'sales_event.dart';
part 'sales_state.dart';

/// Bloc gérant l'état des ventes
class SalesBloc extends Bloc<SalesEvent, SalesState> {
  final SalesRepository _salesRepository;
  final OperationJournalBloc _operationJournalBloc;
  final _uuid = const Uuid(); // Pour générer des IDs pour les entrées de journal

  SalesBloc({
    required SalesRepository salesRepository,
    required OperationJournalBloc operationJournalBloc,
  })  : _salesRepository = salesRepository,
        _operationJournalBloc = operationJournalBloc,
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
      final totalAmountInCdf = sales.fold(0.0, (total, sale) => total + sale.totalAmountInCdf);
      emit(SalesLoaded(sales: sales, totalAmountInCdf: totalAmountInCdf));
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
      final totalAmountInCdf = sales.fold(0.0, (total, sale) => total + sale.totalAmountInCdf);
      emit(SalesLoaded(sales: sales, totalAmountInCdf: totalAmountInCdf));
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
      final totalAmountInCdf = sales.fold(0.0, (total, sale) => total + sale.totalAmountInCdf);
      emit(SalesLoaded(sales: sales, totalAmountInCdf: totalAmountInCdf));
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
      final totalAmountInCdf = sales.fold(0.0, (total, sale) => total + sale.totalAmountInCdf);
      emit(SalesLoaded(sales: sales, totalAmountInCdf: totalAmountInCdf));
    } catch (e) {
      emit(SalesError(e.toString()));
    }
  }

  /// Ajouter une nouvelle vente
  Future<void> _onAddSale(
    AddSale event,
    Emitter<SalesState> emit,
  ) async {
    try {
      await _salesRepository.addSale(event.sale);
      emit(SalesOperationSuccess('Vente ajoutée avec succès', saleId: event.sale.id)); // Pass saleId

      // Enregistrer les opérations dans le journal
      final List<OperationJournalEntry> journalEntries = [];
      String saleDescription = 'Vente #${event.sale.id.substring(0, 6)} - ${event.sale.customerName}';

      // Déterminer le type d'opération de vente
      OperationType saleType;
      if (event.sale.paymentMethod.toLowerCase().contains('crédit')) {
        saleType = OperationType.saleCredit;
      } else if (event.sale.paymentMethod.toLowerCase().contains('échelonné')) {
        saleType = OperationType.saleInstallment;
      } else {
        saleType = OperationType.saleCash;
      }

      journalEntries.add(OperationJournalEntry(
        id: _uuid.v4(),
        date: event.sale.date,
        description: saleDescription,
        type: saleType,
        amount: event.sale.totalAmountInCdf, // Use totalAmountInCdf
        relatedDocumentId: event.sale.id,
        isDebit: false, // Sales are typically credits to revenue
        isCredit: true,
        balanceAfter: 0, // Placeholder
      ));

      // Si un paiement partiel ou total est effectué au moment de la vente (non crédit pur)
      if (event.sale.paidAmountInCdf > 0 && saleType != OperationType.saleCredit) { // Use paidAmountInCdf
        journalEntries.add(OperationJournalEntry(
          id: _uuid.v4(),
          date: event.sale.date,
          description: 'Paiement initial - Vente #${event.sale.id.substring(0, 6)}',
          type: OperationType.cashIn,
          amount: event.sale.paidAmountInCdf, // Use paidAmountInCdf
          relatedDocumentId: event.sale.id,
          isDebit: true, // CashIn is a debit to cash asset
          isCredit: false,
          balanceAfter: 0, // Placeholder
        ));
      }

      // Enregistrer les sorties de stock pour chaque article vendu
      for (var item in event.sale.items) {
        journalEntries.add(OperationJournalEntry(
          id: _uuid.v4(),
          date: event.sale.date,
          description: 'Sortie stock: ${item.quantity} x ${item.productName} (Vente #${event.sale.id.substring(0, 6)})',
          type: OperationType.stockOut,
          amount: 0, // Cost of goods sold would be calculated and used here in a full system
          relatedDocumentId: event.sale.id,
          isDebit: true, // COGS is a debit (expense), Inventory is credited
          isCredit: false, // This entry reflects the COGS/Inventory reduction part
          balanceAfter: 0, // Placeholder
        ));
      }

      // await _journalRepository.addOperationEntries(journalEntries); // Removed direct repository call
      _operationJournalBloc.add(AddMultipleOperationJournalEntries(journalEntries)); // Dispatch event

      add(const LoadSales());
    } catch (e) {
      emit(SalesError('Erreur lors de l\'ajout de la vente: ${e.toString()}'));
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
      final sale = await _salesRepository.getSaleById(event.id);
      if (sale != null) {
        final updatedSale = sale.copyWith(status: event.status);

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
