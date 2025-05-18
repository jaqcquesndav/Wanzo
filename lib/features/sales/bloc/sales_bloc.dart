// filepath: c:\Users\DevSpace\Flutter\wanzo\lib\features\sales\bloc\sales_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/sale.dart';
import '../repositories/sales_repository.dart';
import '../../dashboard/models/operation_journal_entry.dart';
import '../../dashboard/repositories/operation_journal_repository.dart';
import '../../dashboard/bloc/operation_journal_bloc.dart'; // Import OperationJournalBloc
import 'package:uuid/uuid.dart';

part 'sales_event.dart';
part 'sales_state.dart';

/// Bloc gérant l'état des ventes
class SalesBloc extends Bloc<SalesEvent, SalesState> {
  final SalesRepository _salesRepository;
  final OperationJournalRepository _journalRepository; // Ajout du repository du journal
  final OperationJournalBloc _operationJournalBloc; // Add OperationJournalBloc
  final _uuid = const Uuid(); // Pour générer des IDs pour les entrées de journal

  SalesBloc({
    required SalesRepository salesRepository,
    required OperationJournalRepository journalRepository, // Injection de dépendance
    required OperationJournalBloc operationJournalBloc, // Inject OperationJournalBloc
  })  : _salesRepository = salesRepository,
        _journalRepository = journalRepository, // Initialisation
        _operationJournalBloc = operationJournalBloc, // Initialize OperationJournalBloc
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
    try {
      await _salesRepository.addSale(event.sale);
      emit(const SalesOperationSuccess('Vente ajoutée avec succès'));

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
        amount: event.sale.totalAmount,
        relatedDocumentId: event.sale.id,
      ));

      // Si un paiement partiel ou total est effectué au moment de la vente (non crédit pur)
      if (event.sale.paidAmount > 0 && saleType != OperationType.saleCredit) {
        journalEntries.add(OperationJournalEntry(
          id: _uuid.v4(),
          date: event.sale.date,
          description: 'Paiement initial - Vente #${event.sale.id.substring(0, 6)}',
          type: OperationType.cashIn,
          amount: event.sale.paidAmount,
          relatedDocumentId: event.sale.id,
        ));
      }

      // Enregistrer les sorties de stock pour chaque article vendu
      for (var item in event.sale.items) {
        journalEntries.add(OperationJournalEntry(
          id: _uuid.v4(),
          date: event.sale.date,
          description: 'Sortie stock: ${item.quantity} x ${item.productName} (Vente #${event.sale.id.substring(0, 6)})',
          type: OperationType.stockOut,
          amount: 0,
          relatedDocumentId: event.sale.id,
        ));
      }

      await _journalRepository.addOperationEntries(journalEntries);
      _operationJournalBloc.add(const RefreshJournal()); // Dispatch RefreshJournal event

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
