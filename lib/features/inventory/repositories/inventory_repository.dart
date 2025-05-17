import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/product.dart';

/// Repository pour gérer l'inventaire et les transactions de stock
class InventoryRepository {
  static const _productsBoxName = 'products';
  static const _transactionsBoxName = 'stock_transactions';
  
  late final Box<Product> _productsBox;
  late final Box<StockTransaction> _transactionsBox;
  final _uuid = const Uuid();
  
  /// Initialiser les boxes Hive
  Future<void> init() async {
    _productsBox = await Hive.openBox<Product>(_productsBoxName);
    _transactionsBox = await Hive.openBox<StockTransaction>(_transactionsBoxName);
  }
  
  /// Fermer les boxes Hive
  Future<void> close() async {
    await _productsBox.close();
    await _transactionsBox.close();
  }
  
  /// Obtenir tous les produits
  List<Product> getAllProducts() {
    return _productsBox.values.toList();
  }
  
  /// Obtenir un produit par son ID
  Product? getProductById(String id) {
    try {
      return _productsBox.values.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }
  
  /// Rechercher des produits
  List<Product> searchProducts(String query) {
    final normalizedQuery = query.toLowerCase().trim();
    
    if (normalizedQuery.isEmpty) {
      return getAllProducts();
    }
    
    return _productsBox.values.where((product) {
      return product.name.toLowerCase().contains(normalizedQuery) ||
             product.description.toLowerCase().contains(normalizedQuery) ||
             product.barcode.toLowerCase().contains(normalizedQuery);
    }).toList();
  }
  
  /// Filtrer les produits par catégorie
  List<Product> getProductsByCategory(ProductCategory category) {
    return _productsBox.values.where((product) => product.category == category).toList();
  }
  
  /// Obtenir les produits avec stock bas
  List<Product> getLowStockProducts() {
    return _productsBox.values.where((product) => product.isLowStock).toList();
  }
  
  /// Ajouter un nouveau produit
  Future<Product> addProduct(Product product) async {
    final newProduct = Product(
      id: _uuid.v4(),
      name: product.name,
      description: product.description,
      barcode: product.barcode,
      category: product.category,
      costPrice: product.costPrice,
      sellingPrice: product.sellingPrice,
      stockQuantity: product.stockQuantity,
      unit: product.unit,
      alertThreshold: product.alertThreshold,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    await _productsBox.put(newProduct.id, newProduct);
    
    // Enregistrer une transaction initiale si la quantité est > 0
    if (product.stockQuantity > 0) {
      await addStockTransaction(StockTransaction(
        id: _uuid.v4(),
        productId: newProduct.id,
        type: StockTransactionType.purchase,
        quantity: product.stockQuantity,
        date: DateTime.now(),
        notes: 'Stock initial lors de la création du produit',
      ));
    }
    
    return newProduct;
  }
  
  /// Mettre à jour un produit existant
  Future<Product> updateProduct(Product product) async {
    final existingProduct = getProductById(product.id);
    
    if (existingProduct == null) {
      throw Exception('Produit non trouvé');
    }
    
    final updatedProduct = product.copyWith(
      updatedAt: DateTime.now(),
    );
    
    await _productsBox.put(product.id, updatedProduct);
    
    // Si la quantité a changé, enregistrer un ajustement
    if (existingProduct.stockQuantity != product.stockQuantity) {
      final adjustmentQuantity = product.stockQuantity - existingProduct.stockQuantity;
      
      await addStockTransaction(StockTransaction(
        id: _uuid.v4(),
        productId: product.id,
        type: StockTransactionType.adjustment,
        quantity: adjustmentQuantity,
        date: DateTime.now(),
        notes: 'Ajustement manuel du stock',
      ));
    }
    
    return updatedProduct;
  }
  
  /// Supprimer un produit
  Future<void> deleteProduct(String id) async {
    await _productsBox.delete(id);
    
    // Supprimer également toutes les transactions associées
    final transactions = _transactionsBox.values.where((t) => t.productId == id).toList();
    for (final transaction in transactions) {
      await _transactionsBox.delete(transaction.id);
    }
  }
  
  /// Ajouter une nouvelle transaction de stock
  Future<StockTransaction> addStockTransaction(StockTransaction transaction) async {
    final product = getProductById(transaction.productId);
    
    if (product == null) {
      throw Exception('Produit non trouvé');
    }
    
    final newTransaction = StockTransaction(
      id: transaction.id.isEmpty ? _uuid.v4() : transaction.id,
      productId: transaction.productId,
      type: transaction.type,
      quantity: transaction.quantity,
      date: transaction.date,
      referenceId: transaction.referenceId,
      notes: transaction.notes,
    );
    
    await _transactionsBox.put(newTransaction.id, newTransaction);
    
    // Mettre à jour la quantité en stock du produit
    final newQuantity = product.stockQuantity + transaction.quantity;
    if (newQuantity < 0) {
      throw Exception('Stock insuffisant');
    }
    
    final updatedProduct = product.copyWith(
      stockQuantity: newQuantity,
      updatedAt: DateTime.now(),
    );
    
    await _productsBox.put(product.id, updatedProduct);
    
    return newTransaction;
  }
  
  /// Obtenir toutes les transactions
  List<StockTransaction> getAllTransactions() {
    return _transactionsBox.values.toList();
  }
  
  /// Obtenir les transactions pour un produit spécifique
  List<StockTransaction> getTransactionsByProduct(String productId) {
    return _transactionsBox.values
        .where((transaction) => transaction.productId == productId)
        .toList();
  }
  
  /// Obtenir les transactions entre deux dates
  List<StockTransaction> getTransactionsByDateRange(DateTime startDate, DateTime endDate) {
    return _transactionsBox.values
        .where((transaction) => 
            transaction.date.isAfter(startDate) && 
            transaction.date.isBefore(endDate.add(const Duration(days: 1))))
        .toList();
  }
  
  /// Annuler une transaction
  Future<void> reverseTransaction(String transactionId) async {
    final transaction = _transactionsBox.values
        .firstWhere((t) => t.id == transactionId);
    
    // Créer une transaction inverse
    final reverseTransaction = StockTransaction(
      id: _uuid.v4(),
      productId: transaction.productId,
      type: transaction.type,
      quantity: -transaction.quantity, // Quantité négative pour annuler
      date: DateTime.now(),
      referenceId: transaction.referenceId,
      notes: 'Annulation de la transaction ${transaction.id}',
    );
    
    await addStockTransaction(reverseTransaction);
  }
  
  /// Obtenir la valeur totale de l'inventaire
  double getTotalInventoryValue() {
    return _productsBox.values.fold(0, (total, product) => total + product.stockValue);
  }
  
  /// Obtenir le nombre total de produits
  int getTotalProductCount() {
    return _productsBox.length;
  }
}
