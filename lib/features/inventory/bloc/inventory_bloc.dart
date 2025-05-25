import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/inventory_repository.dart';
import 'inventory_event.dart';
import 'inventory_state.dart';
import '../../dashboard/models/operation_journal_entry.dart';
import '../../dashboard/bloc/operation_journal_bloc.dart'; // Corrected import
import '../../notifications/services/notification_service.dart'; // Corrected import
import '../../notifications/models/notification_model.dart'; // Added import for NotificationType
import '../models/stock_transaction.dart'; // Added import for StockTransaction and StockTransactionType
import 'package:uuid/uuid.dart';

/// BLoC pour la gestion de l'inventaire
class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final InventoryRepository _inventoryRepository;
  final NotificationService _notificationService;
  final OperationJournalBloc _operationJournalBloc;
  final _uuid = const Uuid();

  InventoryBloc({
    required InventoryRepository inventoryRepository,
    required NotificationService notificationService,
    required OperationJournalBloc operationJournalBloc,
  })  : _inventoryRepository = inventoryRepository,
        _notificationService = notificationService,
        _operationJournalBloc = operationJournalBloc,
        super(const InventoryInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<LoadProductsByCategory>(_onLoadProductsByCategory);
    on<SearchProducts>(_onSearchProducts);
    on<LoadLowStockProducts>(_onLoadLowStockProducts);
    on<LoadProduct>(_onLoadProduct);
    on<AddProduct>(_onAddProduct);
    on<UpdateProduct>(_onUpdateProduct);
    on<DeleteProduct>(_onDeleteProduct);
    on<AddStockTransaction>(_onAddStockTransaction);
    on<ReverseStockTransaction>(_onReverseStockTransaction);
    on<LoadAllTransactions>(_onLoadAllTransactions);
    on<LoadProductTransactions>(_onLoadProductTransactions);
    on<LoadTransactionsByDateRange>(_onLoadTransactionsByDateRange);
  }
  
  /// Charger tous les produits
  Future<void> _onLoadProducts(LoadProducts event, Emitter<InventoryState> emit) async {
    emit(const InventoryLoading());
    try {
      final products = _inventoryRepository.getAllProducts();
      final totalValue = _inventoryRepository.getTotalInventoryValue();
      final totalCount = _inventoryRepository.getTotalProductCount();
      final lowStockProducts = _inventoryRepository.getLowStockProducts();

      // Check for low stock products and send notifications
      for (var product in products) { // Iterate all products to check stock level
        if (product.isLowStock) { 
          await _notificationService.sendNotification(
            title: 'Stock bas: ${product.name}',
            message: 'Le stock pour ${product.name} est bas (${product.stockQuantity} ${product.unit.name}). Pensez à réapprovisionner.',
            type: NotificationType.lowStock,
          );
        }
      }
      
      emit(ProductsLoaded(
        products: products,
        totalInventoryValue: totalValue,
        totalProductCount: totalCount,
        lowStockCount: lowStockProducts.length,
      ));
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }
  
  /// Charger les produits par catégorie
  Future<void> _onLoadProductsByCategory(LoadProductsByCategory event, Emitter<InventoryState> emit) async {
    emit(const InventoryLoading());
    try {
      final products = _inventoryRepository.getProductsByCategory(event.category);
      final totalValue = products.fold(0.0, (total, product) => total + product.stockValue);
      final lowStockProducts = products.where((product) => product.isLowStock).toList();
      
      emit(ProductsLoaded(
        products: products,
        totalInventoryValue: totalValue,
        totalProductCount: products.length,
        lowStockCount: lowStockProducts.length,
      ));
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }
  
  /// Rechercher des produits
  Future<void> _onSearchProducts(SearchProducts event, Emitter<InventoryState> emit) async {
    emit(const InventoryLoading());
    try {
      final products = _inventoryRepository.searchProducts(event.query);
      final totalValue = products.fold(0.0, (total, product) => total + product.stockValue);
      final lowStockProducts = products.where((product) => product.isLowStock).toList();
      
      emit(ProductsLoaded(
        products: products,
        totalInventoryValue: totalValue,
        totalProductCount: products.length,
        lowStockCount: lowStockProducts.length,
      ));
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }
  
  /// Charger les produits avec stock bas
  Future<void> _onLoadLowStockProducts(LoadLowStockProducts event, Emitter<InventoryState> emit) async {
    emit(const InventoryLoading());
    try {
      final products = _inventoryRepository.getLowStockProducts();
      final totalValue = products.fold(0.0, (total, product) => total + product.stockValue);
      
      emit(ProductsLoaded(
        products: products,
        totalInventoryValue: totalValue,
        totalProductCount: products.length,
        lowStockCount: products.length,
      ));
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }
  
  /// Charger un seul produit avec ses transactions
  Future<void> _onLoadProduct(LoadProduct event, Emitter<InventoryState> emit) async {
    emit(const InventoryLoading());
    try {
      final product = _inventoryRepository.getProductById(event.id);
      
      if (product == null) {
        emit(const InventoryError('Produit non trouvé'));
        return;
      }
      
      final transactions = _inventoryRepository.getTransactionsByProduct(event.id);
      
      emit(ProductLoaded(
        product: product,
        transactions: transactions,
      ));
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }
  
  /// Ajouter un nouveau produit
  Future<void> _onAddProduct(AddProduct event, Emitter<InventoryState> emit) async {
    emit(const InventoryLoading());
    try {
      final product = await _inventoryRepository.addProduct(event.product);
      
      // Create journal entry for stock in
      final journalEntry = OperationJournalEntry(
        id: _uuid.v4(),
        date: DateTime.now(),
        type: OperationType.stockIn,
        description: "Ajout initial du produit: ${product.name}",
        amount: product.costPrice * product.stockQuantity, // Value of initial stock
        quantity: product.stockQuantity,
        productId: product.id,
        productName: product.name,
        relatedDocumentId: product.id, // Could be product ID or a purchase order ID if available
      );
      _operationJournalBloc.add(AddOperationJournalEntry(journalEntry)); // Dispatch event
      
      emit(InventoryOperationSuccess('Produit ajouté avec succès et enregistré dans le journal'));
      add(const LoadProducts()); // Reload products list
    } catch (e) {
      emit(InventoryError("Erreur lors de l'ajout du produit: ${e.toString()}"));
    }
  }
  
  /// Mettre à jour un produit existant
  Future<void> _onUpdateProduct(UpdateProduct event, Emitter<InventoryState> emit) async {
    emit(const InventoryLoading());
    try {
      final product = await _inventoryRepository.updateProduct(event.product);
      emit(InventoryOperationSuccess('Produit mis à jour avec succès'));
      add(LoadProduct(product.id));
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }
  
  /// Supprimer un produit
  Future<void> _onDeleteProduct(DeleteProduct event, Emitter<InventoryState> emit) async {
    emit(const InventoryLoading());
    try {
      await _inventoryRepository.deleteProduct(event.id);
      emit(const InventoryOperationSuccess('Produit supprimé avec succès'));
      add(const LoadProducts());
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }
  
  /// Ajouter une transaction de stock
  Future<void> _onAddStockTransaction(AddStockTransaction event, Emitter<InventoryState> emit) async {
    emit(const InventoryLoading());
    try {
      // Retrieve product details to get product name and unit cost if needed for journal
      final product = _inventoryRepository.getProductById(event.transaction.productId);
      if (product == null) {
        emit(InventoryError("Produit associé à la transaction non trouvé."));
        return;
      }

      final transaction = await _inventoryRepository.addStockTransaction(event.transaction);
      
      // Create journal entry
      final String? currentNotes = transaction.notes;
      String journalDescription;
      if (currentNotes != null && currentNotes.isNotEmpty) {
        journalDescription = currentNotes;
      } else {
        journalDescription = "Mouvement de stock: ${product.name}";
      }

      final journalEntry = OperationJournalEntry(
        id: _uuid.v4(),
        date: transaction.date,
        type: transaction.type == StockTransactionType.purchase || transaction.type == StockTransactionType.initialStock || transaction.type == StockTransactionType.returned || transaction.type == StockTransactionType.transferIn
            ? OperationType.stockIn 
            : OperationType.stockOut,
        description: journalDescription,
        amount: (transaction.type == StockTransactionType.purchase || transaction.type == StockTransactionType.initialStock) && product.costPrice > 0
            ? (transaction.quantity * product.costPrice) 
            : 0, // Amount for stock out/adjustments is often 0 or handled differently in journal
        quantity: transaction.quantity,
        productId: transaction.productId,
        productName: product.name, // Use product name from fetched product
        relatedDocumentId: transaction.id,
      );
      _operationJournalBloc.add(AddOperationJournalEntry(journalEntry)); // Dispatch event

      emit(InventoryOperationSuccess('Transaction de stock ajoutée avec succès et enregistrée dans le journal'));
      add(LoadProduct(transaction.productId)); // Reload product details
      add(const LoadProducts()); // Reload all products
    } catch (e) {
      emit(InventoryError("Erreur lors de l'ajout de la transaction de stock: ${e.toString()}"));
    }
  }

  /// Annuler une transaction de stock (et créer une entrée de journal inverse)
  Future<void> _onReverseStockTransaction(ReverseStockTransaction event, Emitter<InventoryState> emit) async {
    emit(const InventoryLoading());
    try {
      // In a real scenario, the repository would handle the logic of reversing a transaction.
      // This might involve creating a new transaction that counters the original.
      // For now, we'll simulate fetching the original transaction to create an inverse journal entry.
      
      // Attempt to find the original transaction - THIS IS A SIMPLIFICATION
      // A robust implementation would have a dedicated method in the repository.
      final originalTransaction = _inventoryRepository.getAllTransactions().firstWhere(
        (t) => t.id == event.transactionId, 
      );

      final product = _inventoryRepository.getProductById(originalTransaction.productId);
      if (product == null) {
        emit(InventoryError("Produit associé à la transaction originale non trouvé."));
        return;
      }

      // Create journal entry for the reversal
      final String? originalNotes = originalTransaction.notes;
      String reversalJournalDescription;
      if (originalNotes != null && originalNotes.isNotEmpty) {
        reversalJournalDescription = "Annulation: $originalNotes";
      } else {
        reversalJournalDescription = "Annulation: Mouvement de stock: ${product.name}";
      }

      final journalEntry = OperationJournalEntry(
        id: _uuid.v4(),
        date: DateTime.now(),
        type: originalTransaction.type == StockTransactionType.purchase || originalTransaction.type == StockTransactionType.initialStock || originalTransaction.type == StockTransactionType.returned || originalTransaction.type == StockTransactionType.transferIn
            ? OperationType.stockOut // Reverse of stockIn is stockOut
            : OperationType.stockIn,  // Reverse of stockOut is stockIn
        description: reversalJournalDescription,
        amount: (originalTransaction.type == StockTransactionType.purchase || originalTransaction.type == StockTransactionType.initialStock) && product.costPrice > 0
            ? -(originalTransaction.quantity * product.costPrice) // Negative amount for reversal
            : 0, 
        quantity: -originalTransaction.quantity, // Negative quantity for reversal
        productId: originalTransaction.productId,
        productName: product.name, // Use product name from fetched product
        relatedDocumentId: originalTransaction.id, // Link to original transaction ID
      );
      _operationJournalBloc.add(AddOperationJournalEntry(journalEntry)); // Dispatch event

      emit(const InventoryOperationSuccess('Transaction de stock annulée et enregistrée dans le journal.'));
      add(LoadProduct(originalTransaction.productId));
      add(const LoadProducts());
    } catch (e) {
      emit(InventoryError("Erreur lors de l'annulation de la transaction: ${e.toString()}"));
    }
  }
  
  /// Charger toutes les transactions de stock
  Future<void> _onLoadAllTransactions(LoadAllTransactions event, Emitter<InventoryState> emit) async {
    emit(const InventoryLoading());
    try {
      final transactions = _inventoryRepository.getAllTransactions();
      emit(TransactionsLoaded(transactions: transactions));
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }
  
  /// Charger les transactions pour un produit spécifique
  Future<void> _onLoadProductTransactions(LoadProductTransactions event, Emitter<InventoryState> emit) async {
    emit(const InventoryLoading());
    try {
      final transactions = _inventoryRepository.getTransactionsByProduct(event.productId);
      emit(TransactionsLoaded(transactions: transactions));
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }
  
  /// Charger les transactions dans une plage de dates
  Future<void> _onLoadTransactionsByDateRange(LoadTransactionsByDateRange event, Emitter<InventoryState> emit) async {
    emit(const InventoryLoading());
    try {
      final transactions = _inventoryRepository.getTransactionsByDateRange(
        event.startDate,
        event.endDate,
      );
      emit(TransactionsLoaded(transactions: transactions));
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }
}
