import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/inventory_repository.dart';
import 'inventory_event.dart';
import 'inventory_state.dart';

/// BLoC pour la gestion de l'inventaire
class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final InventoryRepository _inventoryRepository;
  
  InventoryBloc({required InventoryRepository inventoryRepository}) 
      : _inventoryRepository = inventoryRepository,
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
      emit(InventoryOperationSuccess('Produit ajouté avec succès'));
      add(const LoadProducts());
    } catch (e) {
      emit(InventoryError(e.toString()));
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
      await _inventoryRepository.addStockTransaction(event.transaction);
      emit(const InventoryOperationSuccess('Transaction enregistrée avec succès'));
      add(LoadProduct(event.transaction.productId));
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }
  
  /// Annuler une transaction de stock
  Future<void> _onReverseStockTransaction(ReverseStockTransaction event, Emitter<InventoryState> emit) async {
    emit(const InventoryLoading());
    try {
      await _inventoryRepository.reverseTransaction(event.transactionId);
      emit(const InventoryOperationSuccess('Transaction annulée avec succès'));
      add(const LoadAllTransactions());
    } catch (e) {
      emit(InventoryError(e.toString()));
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
