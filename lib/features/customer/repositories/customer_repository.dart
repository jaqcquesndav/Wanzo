import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/customer.dart';

/// Repository pour la gestion des clients
class CustomerRepository {
  static const _customersBoxName = 'customers';
  late Box<Customer> _customersBox;
  final _uuid = const Uuid();

  /// Initialise le repository
  Future<void> init() async {
    // Enregistrement des adaptateurs Hive
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(CustomerAdapter());
    }
    
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(CustomerCategoryAdapter());
    }
    
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
    final updatedCustomer = customer.copyWith();
    await _customersBox.put(updatedCustomer.id, updatedCustomer);
    return updatedCustomer;
  }

  /// Supprime un client
  Future<void> deleteCustomer(String id) async {
    await _customersBox.delete(id);
  }

  /// Met à jour le total des achats d'un client
  Future<Customer> updateCustomerPurchaseTotal(
    String customerId,
    double amount,
  ) async {
    final customer = await getCustomer(customerId);
    if (customer == null) {
      throw Exception('Client non trouvé');
    }
    
    final updatedCustomer = customer.copyWith(
      totalPurchases: customer.totalPurchases + amount,
      lastPurchaseDate: DateTime.now(),
    );
    
    await _customersBox.put(customerId, updatedCustomer);
    return updatedCustomer;
  }

  /// Recherche des clients par nom ou numéro de téléphone
  Future<List<Customer>> searchCustomers(String query) async {
    final lowercaseQuery = query.toLowerCase();
    
    return _customersBox.values.where((customer) {
      return customer.name.toLowerCase().contains(lowercaseQuery) ||
          customer.phoneNumber.contains(query);
    }).toList();
  }

  /// Récupère les meilleurs clients (par montant d'achat)
  Future<List<Customer>> getTopCustomers({int limit = 5}) async {
    final customers = _customersBox.values.toList()
      ..sort((a, b) => b.totalPurchases.compareTo(a.totalPurchases));
    
    return customers.take(limit).toList();
  }

  /// Récupère les clients récemment ajoutés
  Future<List<Customer>> getRecentCustomers({int limit = 5}) async {
    final customers = _customersBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return customers.take(limit).toList();
  }
}

/// Adaptateur Hive pour Customer
class CustomerAdapter extends TypeAdapter<Customer> {
  @override
  final int typeId = 3;

  @override
  Customer read(BinaryReader reader) {
    final id = reader.readString();
    final name = reader.readString();
    final phoneNumber = reader.readString();
    final email = reader.readString();
    final address = reader.readString();
    final createdAt = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final notes = reader.readString();
    final totalPurchases = reader.readDouble();
    
    final hasLastPurchaseDate = reader.readBool();
    final lastPurchaseDate = hasLastPurchaseDate
        ? DateTime.fromMillisecondsSinceEpoch(reader.readInt())
        : null;
    
    final categoryIndex = reader.readInt();
    
    return Customer(
      id: id,
      name: name,
      phoneNumber: phoneNumber,
      email: email,
      address: address,
      createdAt: createdAt,
      notes: notes,
      totalPurchases: totalPurchases,
      lastPurchaseDate: lastPurchaseDate,
      category: CustomerCategory.values[categoryIndex],
    );
  }

  @override
  void write(BinaryWriter writer, Customer obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeString(obj.phoneNumber);
    writer.writeString(obj.email);
    writer.writeString(obj.address);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
    writer.writeString(obj.notes);
    writer.writeDouble(obj.totalPurchases);
    
    writer.writeBool(obj.lastPurchaseDate != null);
    if (obj.lastPurchaseDate != null) {
      writer.writeInt(obj.lastPurchaseDate!.millisecondsSinceEpoch);
    }
    
    writer.writeInt(obj.category.index);
  }
}

/// Adaptateur Hive pour CustomerCategory
class CustomerCategoryAdapter extends TypeAdapter<CustomerCategory> {
  @override
  final int typeId = 4;

  @override
  CustomerCategory read(BinaryReader reader) {
    return CustomerCategory.values[reader.readInt()];
  }

  @override
  void write(BinaryWriter writer, CustomerCategory obj) {
    writer.writeInt(obj.index);
  }
}
