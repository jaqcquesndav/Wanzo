import '../models/operation_journal_entry.dart';
import 'package:flutter/foundation.dart';

// Mock data for now
final List<OperationJournalEntry> _mockData = [
  OperationJournalEntry(
    id: '1',
    date: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
    description: 'Vente de 2 pains au cash',
    type: OperationType.saleCash,
    amount: 500,
    relatedDocumentId: 'SALE001',
  ),
  OperationJournalEntry(
    id: '2',
    date: DateTime.now().subtract(const Duration(days: 1, hours: 1)),
    description: 'Dépense: Achat de carburant',
    type: OperationType.cashOut,
    amount: -15000,
  ),
  OperationJournalEntry(
    id: '3',
    date: DateTime.now().subtract(const Duration(hours: 5)),
    description: 'Vente à crédit - Client Fidèle',
    type: OperationType.saleCredit,
    amount: 12000,
    relatedDocumentId: 'SALE002',
  ),
  OperationJournalEntry(
    id: '4',
    date: DateTime.now().subtract(const Duration(hours: 3)),
    description: 'Entrée stock - 10 sacs de riz (Fournisseur A)',
    type: OperationType.stockIn,
    amount: 0, // Pas un mouvement financier direct pour le journal, mais une opération de stock
    relatedDocumentId: 'PURCH001',
  ),
  OperationJournalEntry(
    id: '5',
    date: DateTime.now().subtract(const Duration(hours: 1)),
    description: 'Vente de 5 cahiers (Espèce)',
    type: OperationType.saleCash,
    amount: 2500,
    relatedDocumentId: 'SALE003',
  ),
  OperationJournalEntry(
    id: '6',
    date: DateTime.now().subtract(const Duration(days: 2, hours: 4)),
    description: 'Paiement reçu du Client Fidèle (Vente SALE002)',
    type: OperationType.customerPayment,
    amount: 10000, // Entrée d'espèce
    relatedDocumentId: 'SALE002',
  ),
  OperationJournalEntry(
    id: '7',
    date: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
    description: 'Paiement Fournisseur A (Achat PURCH001)',
    type: OperationType.supplierPayment,
    amount: -50000, // Sortie d'espèce
    relatedDocumentId: 'PURCH001',
  ),
  OperationJournalEntry(
    id: '8',
    date: DateTime.now().subtract(const Duration(hours: 10)),
    description: 'Sortie stock - Ajustement inventaire (1 sac de riz périmé)',
    type: OperationType.stockOut,
    amount: 0, // Pas un mouvement financier direct, mais une opération de stock
    relatedDocumentId: 'ADJUST001',
  ),
];

class OperationJournalRepository {
  Future<void> init() async {
    // In a real scenario, this could initialize a database connection
    // or fetch initial data from an API.
    // For mock data, this can be empty or pre-populate.
    debugPrint("OperationJournalRepository initialized.");
  }

  Future<List<OperationJournalEntry>> getOperations(
      DateTime startDate, DateTime endDate) async {
    // TODO: Remplacer par une vraie implémentation (API, base de données locale)
    await Future.delayed(const Duration(milliseconds: 500)); // Simule un appel réseau
    return _mockData
        .where((op) =>
            op.date.isAfter(startDate.subtract(const Duration(microseconds: 1))) &&
            op.date.isBefore(endDate.add(const Duration(microseconds: 1))))
        .toList()..sort((a,b) => b.date.compareTo(a.date)); // Tri par date décroissante
  }

  Future<void> addOperation(OperationJournalEntry entry) async {
    await Future.delayed(const Duration(milliseconds: 100)); // Simule une écriture
    _mockData.add(entry);
    // Trier à nouveau si nécessaire, ou s'assurer que l'ordre est maintenu à l'ajout
    _mockData.sort((a, b) => b.date.compareTo(a.date));

    // Optionnel: Notifier le bloc du journal pour qu'il se mette à jour.
    // Si le bloc est accessible directement (ce qui crée un couplage):
    // journalBloc?.add(LoadOperations(startDate: journalBloc.state.startDate, endDate: journalBloc.state.endDate));
    // Une meilleure approche serait un stream d'événements auquel le bloc souscrit.
  }

  // Méthode pour enregistrer plusieurs opérations (ex: vente + sortie de stock)
  Future<void> addOperationEntries(List<OperationJournalEntry> entries) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _mockData.addAll(entries);
    _mockData.sort((a, b) => b.date.compareTo(a.date));
    // Potentiellement notifier le bloc ici aussi
  }

  // TODO: Ajouter des méthodes pour récupérer les opérations de vente, caisse, stock
  // et les transformer en OperationJournalEntry
}
