import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/customer.dart';
import '../../sales/repositories/sales_repository.dart';

/// Repository pour la gestion des clients
class CustomerRepository {
  static const _customersBoxName = 'customers';
  late Box<Customer> _customersBox;
  final _uuid = const Uuid();

  /// Initialise le repository
  Future<void> init() async {
    // Enregistrement des adaptateurs Hive
    // Adapters are now registered in hive_setup.dart
    
    _customersBox = await Hive.openBox<Customer>(_customersBoxName);
    
    // En mode développement, ajoutons quelques clients de test si la boîte est vide
    if (_customersBox.isEmpty) {
      await _addTestCustomers();
    }
  }

  /// Ajoute des clients de test en mode développement
  Future<void> _addTestCustomers() async {
    final testCustomers = [
      Customer(
        id: _uuid.v4(),
        name: 'Jean Dupont',
        phoneNumber: '+243 999 123 456',
        email: 'jean.dupont@email.com',
        address: 'Avenue des Étoiles, Kinshasa',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        notes: 'Client régulier',
        totalPurchases: 850000,
        lastPurchaseDate: DateTime.now().subtract(const Duration(days: 5)),
        category: CustomerCategory.vip,
      ),
      Customer(
        id: _uuid.v4(),
        name: 'Marie Kabongo',
        phoneNumber: '+243 998 765 432',
        email: 'marie.kabongo@email.com',
        address: 'Boulevard du 30 Juin, Kinshasa',
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        notes: 'Préfère être contactée par WhatsApp',
        totalPurchases: 350000,
        lastPurchaseDate: DateTime.now().subtract(const Duration(days: 12)),
        category: CustomerCategory.regular,
      ),
      Customer(
        id: _uuid.v4(),
        name: 'Entreprise ABC',
        phoneNumber: '+243 991 234 567',
        email: 'contact@entrepriseabc.com',
        address: 'Zone Industrielle, Lubumbashi',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        notes: 'Client entreprise, commandes régulières',
        totalPurchases: 2500000,
        lastPurchaseDate: DateTime.now().subtract(const Duration(days: 3)),
        category: CustomerCategory.business,
      ),
      Customer(
        id: _uuid.v4(),
        name: 'Pierre Mutombo',
        phoneNumber: '+243 997 654 321',
        email: 'pierre.mutombo@email.com',
        address: 'Quartier Bon Marché, Kinshasa',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        totalPurchases: 75000,
        lastPurchaseDate: DateTime.now().subtract(const Duration(days: 8)),
        category: CustomerCategory.new_customer,
      ),
    ];
    
    for (final customer in testCustomers) {
      await _customersBox.put(customer.id, customer);
    }
  }

  /// Récupère tous les clients
  Future<List<Customer>> getCustomers() async {
    return _customersBox.values.toList();
  }

  /// Récupère un client spécifique
  Future<Customer?> getCustomer(String id) async {
    return _customersBox.get(id);
  }

  /// Ajoute un nouveau client
  Future<Customer> addCustomer(Customer customer) async {
    final newCustomer = customer.copyWith(
      id: _uuid.v4(),
      createdAt: DateTime.now(),
    );
    
    await _customersBox.put(newCustomer.id, newCustomer);
    return newCustomer;
  }

  /// Met à jour un client existant
  Future<Customer> updateCustomer(Customer customer) async {
    await _customersBox.put(customer.id, customer);
    return customer;
  }

  /// Supprime un client
  Future<void> deleteCustomer(String id) async {
    await _customersBox.delete(id);
  }

  /// Recherche des clients par nom, email ou numéro de téléphone
  Future<List<Customer>> searchCustomers(String searchTerm) async {
    final lowerCaseSearchTerm = searchTerm.toLowerCase();
    return _customersBox.values
        .where((customer) =>
            customer.name.toLowerCase().contains(lowerCaseSearchTerm) ||
            (customer.email?.toLowerCase().contains(lowerCaseSearchTerm) ?? false) ||
            customer.phoneNumber.toLowerCase().contains(lowerCaseSearchTerm))
        .toList();
  }

  /// Récupère les meilleurs clients (ceux avec le total d'achats le plus élevé)
  Future<List<Customer>> getTopCustomers({int limit = 5}) async {
    final customers = _customersBox.values.toList();
    customers.sort((a, b) => b.totalPurchases.compareTo(a.totalPurchases));
    return customers.take(limit).toList();
  }

  /// Récupère les clients les plus récents (ceux avec la date d'achat la plus récente)
  Future<List<Customer>> getRecentCustomers({int limit = 5}) async {
    final customers = _customersBox.values.toList();
    customers.sort((a, b) {
      if (a.lastPurchaseDate == null && b.lastPurchaseDate == null) return 0;
      if (a.lastPurchaseDate == null) return 1; // b comes first
      if (b.lastPurchaseDate == null) return -1; // a comes first
      return b.lastPurchaseDate!.compareTo(a.lastPurchaseDate!);
    });
    return customers.take(limit).toList();
  }

  /// Met à jour le total des achats d'un client
  Future<Customer> updateCustomerPurchaseTotal(String customerId, double amount) async {
    final customer = await getCustomer(customerId);
    if (customer == null) {
      throw Exception('Client non trouvé pour la mise à jour du total des achats');
    }
    final updatedCustomer = customer.copyWith(
      totalPurchases: customer.totalPurchases + amount,
      lastPurchaseDate: DateTime.now(),
    );
    await _customersBox.put(customerId, updatedCustomer);
    return updatedCustomer;
  }  /// Récupère le nombre de clients uniques pour une période donnée
  Future<int> getUniqueCustomersCountForDateRange(DateTime startDate, DateTime endDate) async {
    // Dépendance sur SalesRepository pour récupérer les ventes de la période
    try {
      // Récupérer les ventes de la période via le SalesRepository
      final salesRepo = await _getSalesRepository();
      if (salesRepo != null) {
        final sales = await salesRepo.getSalesByDateRange(startDate, endDate);
        
        // Extraire les IDs clients uniques des ventes
        final uniqueCustomerIds = <String>{};
        for (final sale in sales) {
          if (sale.customerId != null && sale.customerId!.isNotEmpty) {
            uniqueCustomerIds.add(sale.customerId!);
          }
        }
        
        return uniqueCustomerIds.length;
      }
      
      // Fallback: Si pas d'accès au SalesRepository, utiliser lastPurchaseDate des clients
      return _customersBox.values
        .where((customer) => customer.lastPurchaseDate != null && 
          customer.lastPurchaseDate!.isAfter(startDate) && 
          customer.lastPurchaseDate!.isBefore(endDate.add(const Duration(days: 1))))
        .length;
    } catch (e) {
      print('Erreur lors du calcul des clients uniques: $e');
      // Fallback en cas d'erreur: retourner 0 plutôt qu'une valeur incorrecte
      return 0;
    }
  }
  
  // Méthode helper pour obtenir une instance de SalesRepository
  Future<SalesRepository?> _getSalesRepository() async {
    try {
      // Créer et initialiser une instance du SalesRepository
      final salesRepo = SalesRepository();
      await salesRepo.init();
      return salesRepo;
    } catch (e) {
      print('Erreur lors de l\'obtention du SalesRepository: $e');
      return null;
    }
  }
}
