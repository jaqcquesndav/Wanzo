import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/supplier.dart';

/// Repository pour la gestion des fournisseurs
class SupplierRepository {
  static const _suppliersBoxName = 'suppliers';
  late Box<Supplier> _suppliersBox;
  final _uuid = const Uuid();

  /// Initialise le repository
  Future<void> init() async {
    _suppliersBox = await Hive.openBox<Supplier>(_suppliersBoxName);
    
    // En mode développement, ajoutons quelques fournisseurs de test si la boîte est vide
    if (_suppliersBox.isEmpty) {
      await _addTestSuppliers();
    }
  }

  /// Ajoute des fournisseurs de test en mode développement
  Future<void> _addTestSuppliers() async {
    final testSuppliers = [
      Supplier(
        id: _uuid.v4(),
        name: 'Grossiste Central',
        phoneNumber: '+243 998 100 200',
        email: 'contact@grossistecentral.com',
        address: 'Boulevard du Commerce, Kinshasa',
        contactPerson: 'Jean Mbala',
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        notes: 'Notre principal fournisseur de produits alimentaires',
        totalPurchases: 5000000,
        lastPurchaseDate: DateTime.now().subtract(const Duration(days: 7)),
        category: SupplierCategory.strategic,
        deliveryTimeInDays: 3,
        paymentTerms: 'Net 30',
      ),
      Supplier(
        id: _uuid.v4(),
        name: 'Tech Import',
        phoneNumber: '+243 991 234 567',
        email: 'sales@techimport.cd',
        address: 'Avenue du Marché, Lubumbashi',
        contactPerson: 'Sarah Mwamba',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        notes: 'Fournisseur d\'équipements électroniques',
        totalPurchases: 2300000,
        lastPurchaseDate: DateTime.now().subtract(const Duration(days: 15)),
        category: SupplierCategory.regular,
        deliveryTimeInDays: 5,
        paymentTerms: 'Paiement comptant',
      ),
      Supplier(
        id: _uuid.v4(),
        name: 'Global Trading Ltd',
        phoneNumber: '+254 700 123 456',
        email: 'info@globaltrading.com',
        address: 'Nairobi, Kenya',
        contactPerson: 'Daniel Kimathi',
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        notes: 'Fournisseur international basé au Kenya',
        totalPurchases: 3500000,
        lastPurchaseDate: DateTime.now().subtract(const Duration(days: 30)),
        category: SupplierCategory.international,
        deliveryTimeInDays: 14,
        paymentTerms: 'Paiement anticipé 50%',
      ),
      Supplier(
        id: _uuid.v4(),
        name: 'Artisans Locaux SARL',
        phoneNumber: '+243 995 678 901',
        email: 'artisans@local.cd',
        address: 'Quartier Artisanal, Kinshasa',
        contactPerson: 'Marie Lutete',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),        notes: 'Coopérative d\'artisans locaux',
        totalPurchases: 850000,
        lastPurchaseDate: DateTime.now().subtract(const Duration(days: 12)),
        category: SupplierCategory.newSupplier,
        deliveryTimeInDays: 2,
        paymentTerms: 'Net 15',
      ),
    ];
    
    for (final supplier in testSuppliers) {
      await _suppliersBox.put(supplier.id, supplier);
    }
  }

  /// Récupère tous les fournisseurs
  Future<List<Supplier>> getSuppliers() async {
    return _suppliersBox.values.toList();
  }

  /// Récupère un fournisseur spécifique
  Future<Supplier?> getSupplier(String id) async {
    return _suppliersBox.get(id);
  }

  /// Ajoute un nouveau fournisseur
  Future<Supplier> addSupplier(Supplier supplier) async {
    final newSupplier = supplier.copyWith(
      id: _uuid.v4(),
      createdAt: DateTime.now(),
    );
    
    await _suppliersBox.put(newSupplier.id, newSupplier);
    return newSupplier;
  }

  /// Met à jour un fournisseur existant
  Future<Supplier> updateSupplier(Supplier supplier) async {
    final updatedSupplier = supplier.copyWith();
    await _suppliersBox.put(updatedSupplier.id, updatedSupplier);
    return updatedSupplier;
  }

  /// Supprime un fournisseur
  Future<void> deleteSupplier(String id) async {
    await _suppliersBox.delete(id);
  }

  /// Met à jour le total des achats auprès d'un fournisseur
  Future<Supplier> updateSupplierPurchaseTotal(
    String supplierId,
    double amount,
  ) async {
    final supplier = await getSupplier(supplierId);
    if (supplier == null) {
      throw Exception('Fournisseur non trouvé');
    }
    
    final updatedSupplier = supplier.copyWith(
      totalPurchases: supplier.totalPurchases + amount,
      lastPurchaseDate: DateTime.now(),
    );
    
    await _suppliersBox.put(supplierId, updatedSupplier);
    return updatedSupplier;
  }

  /// Recherche des fournisseurs par nom ou numéro de téléphone
  Future<List<Supplier>> searchSuppliers(String query) async {
    final lowercaseQuery = query.toLowerCase();
    
    return _suppliersBox.values.where((supplier) {
      return supplier.name.toLowerCase().contains(lowercaseQuery) ||
          supplier.phoneNumber.contains(query) ||
          supplier.contactPerson.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  /// Récupère les principaux fournisseurs (par montant d'achat)
  Future<List<Supplier>> getTopSuppliers({int limit = 5}) async {
    final suppliers = _suppliersBox.values.toList()
      ..sort((a, b) => b.totalPurchases.compareTo(a.totalPurchases));
    
    return suppliers.take(limit).toList();
  }

  /// Récupère les fournisseurs récemment ajoutés
  Future<List<Supplier>> getRecentSuppliers({int limit = 5}) async {
    final suppliers = _suppliersBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return suppliers.take(limit).toList();
  }
}
