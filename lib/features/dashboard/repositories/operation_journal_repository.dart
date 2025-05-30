// Required for jsonDecode if API returns string

import '../models/operation_journal_entry.dart';
import 'package:flutter/foundation.dart';
import '../../../core/services/api_service.dart'; // Import ApiService

// Mock data for now - Will be removed or commented out after API integration
/*
final List<OperationJournalEntry> _mockData = [
  // ... existing mock data ...
];
*/

class OperationJournalRepository {
  final ApiService _apiService;

  // Constructor with ApiService injection
  OperationJournalRepository({ApiService? apiService}) 
    : _apiService = apiService ?? ApiService();

  Future<void> init() async {
    // In a real scenario, this could initialize a database connection
    // or fetch initial data from an API.
    // For mock data, this can be empty or pre-populate.
    debugPrint("OperationJournalRepository initialized.");
  }

  Future<List<OperationJournalEntry>> getOperations(
      DateTime startDate, DateTime endDate) async {
    // TODO: Remplacer par une vraie implémentation (API, base de données locale)
    // This method will also need to be updated to use ApiService
    // For now, let's assume it might call an endpoint like /journal/operations?start_date=...&end_date=...
    try {
      final response = await _apiService.get('journal/operations', queryParams: {
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
      });
      if (response['data'] != null && response['data'] is List) {
        return (response['data'] as List)
            .map((item) => OperationJournalEntry.fromJson(item as Map<String, dynamic>)) // Assuming a fromJson constructor
            .toList()..sort((a,b) => b.date.compareTo(a.date));
      }
      return [];
    } catch (e) {
      debugPrint("Error fetching operations: $e");
      // Fallback to empty list or handle error as appropriate
      return []; 
    }
  }

  Future<double> getOpeningBalance(DateTime forDate) async {
    // This method will also need to be updated to use ApiService
    // For now, let's assume it might call an endpoint like /journal/opening-balance?date=...
    try {
      final response = await _apiService.get('journal/opening-balance', queryParams: {
        'date': forDate.toIso8601String(),
      });
      if (response['balance'] != null) {
        return (response['balance'] as num).toDouble();
      }
      return 0.0;
    } catch (e) {
      debugPrint("Error fetching opening balance: $e");
      return 0.0; // Fallback or error handling
    }
  }

  Future<void> addOperation(OperationJournalEntry entry) async {
    // This method will also need to be updated to use ApiService
    // For now, let's assume it might call an endpoint like /journal/operations
    try {
      await _apiService.post('journal/operations', body: entry.toJson()); // Assuming a toJson method
    } catch (e) {
      debugPrint("Error adding operation: $e");
      // Handle error as appropriate, potentially rethrow or use offline queue
      throw Exception('Failed to add operation to journal: $e');
    }
  }

  Future<void> addOperationEntries(List<OperationJournalEntry> entries) async {
    if (entries.isEmpty) {
      debugPrint("No operation entries to add.");
      return;
    }
    try {
      // Example: Send as a list of operations. Backend needs to support this.
      await _apiService.post('journal/batch-operations', body: {
        'operations': entries.map((e) => e.toJson()).toList()
      });
      debugPrint("Successfully added batch operations to journal.");
    } catch (e) {
      debugPrint("Error adding batch operations: $e");
      // Handle error
      throw Exception('Failed to add batch operations to journal: $e');
    }
  }

  // TODO: Ajouter des méthodes pour récupérer les opérations de vente, caisse, stock
  // et les transformer en OperationJournalEntry

  // Updated for AdhaBloc integration - uses ApiService
  Future<List<Map<String, dynamic>>> getRecentEntries({int limit = 5}) async {
    try {
      final response = await _apiService.get('journal/recent-entries', queryParams: {'limit': limit});
      
      // Assuming the API returns a list of objects that match/can be converted to OperationJournalEntry
      // And then to the context map format.
      if (response['data'] != null && response['data'] is List) {
        final entries = (response['data'] as List)
            .map((item) {
              // We need to ensure the item from API can be turned into an OperationJournalEntry
              // or directly into the map structure Adha expects.
              // If API returns data directly usable for toContextMap:
              if (item is Map<String, dynamic> && item.containsKey('id') && item.containsKey('date') && item.containsKey('description') && item.containsKey('type') && item.containsKey('amount')) {
                 // Minimal check, ideally use a fromJson for robust parsing
                return OperationJournalEntry.fromJson(item).toContextMap();
              }
              // If API returns something else, transformation is needed.
              // For now, let's assume it's compatible with OperationJournalEntry.fromJson
              // Ensure item is Map<String, dynamic> before calling fromJson
              if (item is Map<String, dynamic>) {
                return OperationJournalEntry.fromJson(item).toContextMap();
              } else {
                // Handle cases where item is not a Map, perhaps log or throw error
                debugPrint("Skipping non-map item in recent journal entries: $item");
                return <String, dynamic>{}; // Return empty map or handle as error
              }
            })
            .where((map) => map.isNotEmpty) // Filter out empty maps from non-map items
            .toList();
        return entries;
      }
      return [];
    } catch (e) {
      debugPrint("Error fetching recent journal entries from API: $e");
      // Fallback to empty list or rethrow, or use mock data if critical for UI
      return []; 
    }
  }

  // Updated for AdhaBloc integration - uses ApiService
  Future<Map<String, dynamic>> getSummaryMetrics() async {
    try {
      final response = await _apiService.get('journal/summary-metrics');
      
      // Assuming the API returns a map directly usable or with a 'data' key
      if (response['data'] != null && response['data'] is Map<String, dynamic>) {
        // Ensure the API response matches the expected structure
        final metrics = response['data'] as Map<String, dynamic>;
        return {
          'totalRevenue': (metrics['totalRevenue'] as num?)?.toDouble() ?? 0.0,
          'totalExpenses': (metrics['totalExpenses'] as num?)?.toDouble() ?? 0.0,
          'netFlow': (metrics['netFlow'] as num?)?.toDouble() ?? 0.0,
          'numberOfTransactions': (metrics['numberOfTransactions'] as int?) ?? 0,
          'summaryPeriod': metrics['summaryPeriod'] as String? ?? 'api_data', 
        };
      } else if (response.containsKey('totalRevenue')) {
        // If response is the metrics map directly
         return {
          'totalRevenue': (response['totalRevenue'] as num?)?.toDouble() ?? 0.0,
          'totalExpenses': (response['totalExpenses'] as num?)?.toDouble() ?? 0.0,
          'netFlow': (response['netFlow'] as num?)?.toDouble() ?? 0.0,
          'numberOfTransactions': (response['numberOfTransactions'] as int?) ?? 0,
          'summaryPeriod': response['summaryPeriod'] as String? ?? 'api_data',
        };
      }
      return { // Default empty metrics on unexpected response
        'totalRevenue': 0.0,
        'totalExpenses': 0.0,
        'netFlow': 0.0,
        'numberOfTransactions': 0,
        'summaryPeriod': 'error_fetching_data',
      };
    } catch (e) {
      debugPrint("Error fetching summary metrics from API: $e");
      // Fallback to default/empty metrics or rethrow
      return {
        'totalRevenue': 0.0,
        'totalExpenses': 0.0,
        'netFlow': 0.0,
        'numberOfTransactions': 0,
        'summaryPeriod': 'error_fetching_data',
      };
    }
  }
}

// It's good practice to have fromJson/toJson in the model itself.
// Let's assume OperationJournalEntry needs these for the above code to work.
// If OperationJournalEntry.fromJson and toJson are not complete or do not exist,
// they would need to be added/updated in 'operation_journal_entry.dart'.
