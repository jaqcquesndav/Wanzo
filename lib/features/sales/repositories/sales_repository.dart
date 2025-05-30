// filepath: c:\Users\DevSpace\Flutter\wanzo\lib\features\sales\repositories\sales_repository.dart
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/sale.dart';
import '../models/sale_item.dart'; // Import SaleItem and SaleItemType

/// Repository pour la gestion des ventes
class SalesRepository {
  static const _salesBoxName = 'sales';
  late final Box<Sale> _salesBox;
  final _uuid = const Uuid();

  /// Initialisation du repository
  Future<void> init() async {
    _salesBox = await Hive.openBox<Sale>(_salesBoxName);
  }

  /// Récupérer toutes les ventes
  Future<List<Sale>> getAllSales() async {
    return _salesBox.values.toList();
  }

  /// Récupérer les ventes filtrées par statut
  Future<List<Sale>> getSalesByStatus(SaleStatus status) async {
    return _salesBox.values.where((sale) => sale.status == status).toList();
  }

  /// Récupérer une vente par son ID
  Future<Sale?> getSaleById(String id) async {
    return _salesBox.values.firstWhere((sale) => sale.id == id);
  }

  /// Récupérer les ventes d'un client
  Future<List<Sale>> getSalesByCustomer(String customerId) async {
    return _salesBox.values.where((sale) => sale.customerId == customerId).toList();
  }

  /// Récupérer les ventes d'une période donnée
  Future<List<Sale>> getSalesByDateRange(DateTime start, DateTime end) async {
    return _salesBox.values.where((sale) => 
      sale.date.isAfter(start) && sale.date.isBefore(end.add(const Duration(days: 1)))
    ).toList();
  }

  /// Ajouter une nouvelle vente
  Future<Sale> addSale(Sale sale) async {
    final newSaleId = _uuid.v4();
    final newSale = Sale(
      id: newSaleId, // Use the generated ID
      date: sale.date,
      customerId: sale.customerId,
      customerName: sale.customerName,
      items: sale.items.map((item) {
        // TODO: [ITEM_TYPE_INTEGRATION] Ensure stock is only updated for products
        if (item.itemType == SaleItemType.product) {
          // Here, you would typically interact with an InventoryRepository or similar
          // to update the stock quantity for item.productId by item.quantity.
          // For now, we'll just log it as a placeholder for the actual stock update logic.
          print('Stock update needed for product ${item.productId}: reduce by ${item.quantity}');
        }
        return item; // Return the item, possibly after stock update
      }).toList(),
      totalAmountInCdf: sale.totalAmountInCdf,
      paidAmountInCdf: sale.paidAmountInCdf,
      paymentMethod: sale.paymentMethod,
      status: sale.status,
      notes: sale.notes,
      transactionCurrencyCode: sale.transactionCurrencyCode,
      transactionExchangeRate: sale.transactionExchangeRate,
      totalAmountInTransactionCurrency: sale.totalAmountInTransactionCurrency,
      paidAmountInTransactionCurrency: sale.paidAmountInTransactionCurrency,
    );
    
    await _salesBox.put(newSale.id, newSale);
    return newSale;
  }

  /// Mettre à jour une vente existante
  Future<void> updateSale(Sale sale) async {
    await _salesBox.put(sale.id, sale);
  }

  /// Supprimer une vente
  Future<void> deleteSale(String id) async {
    await _salesBox.delete(id);
  }
  /// Calculer le total des ventes d'une période
  Future<double> calculateTotalSales(DateTime start, DateTime end) async {
    final sales = await getSalesByDateRange(start, end);
    return sales.fold<double>(0, (total, sale) => total + sale.totalAmountInCdf); // Use CDF field
  }

  /// Récupérer le nombre de ventes
  Future<int> getSalesCount() async {
    return _salesBox.length;
  }

  /// Calculer le total des montants à recevoir (ventes non entièrement payées)
  Future<double> getTotalReceivables() async {
    final sales = _salesBox.values.where((sale) => 
      sale.status == SaleStatus.pending || 
      (sale.status == SaleStatus.partiallyPaid && sale.paidAmountInCdf < sale.totalAmountInCdf) // Use CDF fields
    );
    return sales.fold<double>(0, (total, sale) => total + (sale.totalAmountInCdf - sale.paidAmountInCdf)); // Use CDF fields
  }
}
