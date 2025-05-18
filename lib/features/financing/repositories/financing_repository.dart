import '../models/financing_request.dart';
import 'package:uuid/uuid.dart';

// Mock repository for now
class FinancingRepository {
  final List<FinancingRequest> _requests = [];
  final _uuid = const Uuid();

  Future<void> init() async {
    // Initialize any necessary Hive boxes or other storage if not mock
  }

  Future<List<FinancingRequest>> getAllRequests() async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate async
    return List.from(_requests);
  }

  Future<FinancingRequest> addRequest(FinancingRequest request) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate async
    final newRequest = request.copyWith(id: _uuid.v4());
    _requests.add(newRequest);
    return newRequest;
  }

  Future<void> updateRequest(FinancingRequest request) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate async
    final index = _requests.indexWhere((r) => r.id == request.id);
    if (index != -1) {
      _requests[index] = request;
    } else {
      throw Exception('Financing request not found');
    }
  }

  Future<void> deleteRequest(String id) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate async
    _requests.removeWhere((r) => r.id == id);
  }
}
