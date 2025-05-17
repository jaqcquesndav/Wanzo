// filepath: c:\Users\DevSpace\Flutter\wanzo\lib\features\sales\repositories\sales_repository.dart
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/sale.dart';

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
    final newSale = Sale(
      id: _uuid.v4(),
      date: sale.date,
      customerId: sale.customerId,
      customerName: sale.customerName,
      items: sale.items,
      totalAmount: sale.totalAmount,
      paidAmount: sale.paidAmount,
      paymentMethod: sale.paymentMethod,
      status: sale.status,
      notes: sale.notes,
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
    return sales.fold<double>(0, (total, sale) => total + sale.totalAmount);
  }

  /// Récupérer le nombre de ventes
  Future<int> getSalesCount() async {
    return _salesBox.length;
  }
}
