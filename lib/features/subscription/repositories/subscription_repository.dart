import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:wanzo/core/services/api_service.dart';
import 'package:wanzo/features/expenses/models/expense.dart';
import 'package:wanzo/features/expenses/repositories/expense_repository.dart';
import 'package:wanzo/features/subscription/models/subscription_tier_model.dart';
import 'package:wanzo/features/subscription/models/invoice_model.dart';
import 'package:wanzo/features/subscription/models/payment_method_model.dart';

class SubscriptionRepository {
  final ExpenseRepository _expenseRepository;
  final ApiService _apiService;
  final _uuid = const Uuid();

  SubscriptionRepository({
    required ExpenseRepository expenseRepository,
    required ApiService apiService,
  })  : _expenseRepository = expenseRepository,
        _apiService = apiService;

  Future<List<SubscriptionTier>> getSubscriptionTiers() async {
    try {
      final response = await _apiService.get('subscription/tiers');
      if (response['data'] != null && response['data'] is List) {
        return (response['data'] as List)
            .map((tierData) => SubscriptionTier.fromJson(tierData))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching subscription tiers: $e');
      return _tiers_fallback;
    }
  }

  Future<SubscriptionTier> getCurrentUserSubscription() async {
    try {
      final response = await _apiService.get('subscription/current');
      if (response['data'] != null) {
        return SubscriptionTier.fromJson(response['data']);
      }
      return _currentTier_fallback;
    } catch (e) {
      print('Error fetching current subscription: $e');
      return _currentTier_fallback;
    }
  }

  Future<double> getTokenUsage() async {
    try {
      final response = await _apiService.get('subscription/token-usage');
      if (response['data'] != null && response['data']['usage_percentage'] != null) {
        return (response['data']['usage_percentage'] as num).toDouble();
      }
      return 0.0;
    } catch (e) {
      print('Error fetching token usage: $e');
      return 0.0;
    }
  }

  Future<int> getAvailableTokens() async {
    try {
      final response = await _apiService.get('subscription/available-tokens');
      if (response['data'] != null && response['data']['tokens'] != null) {
        return (response['data']['tokens'] as num).toInt();
      }
      return 0;
    } catch (e) {
      print('Error fetching available tokens: $e');
      return 0;
    }
  }

  Future<List<Invoice>> getInvoices() async {
    try {
      final response = await _apiService.get('subscription/invoices');
      if (response['data'] != null && response['data'] is List) {
        return (response['data'] as List)
            .map((invoiceData) => Invoice.fromJson(invoiceData))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching invoices: $e');
      return _invoices_fallback;
    }
  }

  Future<List<PaymentMethod>> getPaymentMethods() async {
    try {
      final response = await _apiService.get('subscription/payment-methods');
      if (response['data'] != null && response['data'] is List) {
        return (response['data'] as List)
            .map((pmData) => PaymentMethod.fromJson(pmData))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching payment methods: $e');
      return _paymentMethods_fallback;
    }
  }

  double _parsePrice(String priceString) {
    if (priceString.toLowerCase() == 'gratuit') {
      return 0.0;
    }
    final numericPart = priceString.split(' ')[0].replaceAll(',', '').replaceAll('.', '');
    return double.tryParse(numericPart) ?? 0.0;
  }

  Future<void> changeSubscriptionTier(SubscriptionTierType newTierType) async {
    print('SubscriptionRepository: Attempting to change subscription to $newTierType via API');
    try {
      final response = await _apiService.post('subscription/change-tier', body: {'newTierType': newTierType.toString().split('.').last});
      print('SubscriptionRepository: API call to change tier successful. Response: $response');

      final newTierData = _tiers_fallback.firstWhere((t) => t.type == newTierType, orElse: () => _currentTier_fallback);

      final tierPrice = _parsePrice(newTierData.price);
      if (tierPrice > 0) {
        final expense = Expense(
          id: _uuid.v4(),
          date: DateTime.now(),
          description: 'Paiement abonnement ${newTierData.name}',
          amount: tierPrice,
          category: ExpenseCategory.utilities,
          paymentMethod: 'System/Online',
        );
        try {
          await _expenseRepository.addExpense(expense);
          print('SubscriptionRepository: Expense recorded for subscription change to ${newTierData.name}');
        } catch (e) {
          print('SubscriptionRepository: Failed to record expense for subscription change: $e');
        }
      }
    } catch (e) {
      print('Error changing subscription tier via API: $e');
      throw Exception('Failed to change subscription tier: $e');
    }
  }

  Future<void> topUpAdhaTokens(double amount) async {
    print('SubscriptionRepository: Attempting to top up Adha tokens for $amount FCFA via API');
    try {
      final response = await _apiService.post('subscription/topup-tokens', body: {'amount': amount});
      print('SubscriptionRepository: API call to topup tokens successful. Response: $response');

      const double fcfaPerToken = 10.0;
      int tokensToAdd = (amount / fcfaPerToken).round();

      final expense = Expense(
        id: _uuid.v4(),
        date: DateTime.now(),
        description: 'Recharge de $tokensToAdd tokens Adha ($amount FCFA)',
        amount: amount,
        category: ExpenseCategory.other,
        paymentMethod: 'System/Online',
      );
      try {
        await _expenseRepository.addExpense(expense);
        print('SubscriptionRepository: Expense recorded for Adha token top-up of $amount FCFA');
      } catch (e) {
        print('SubscriptionRepository: Failed to record expense for token top-up: $e');
      }
    } catch (e) {
      print('Error topping up Adha tokens via API: $e');
      throw Exception('Failed to top up Adha tokens: $e');
    }
  }

  Future<String> uploadPaymentProof(File imageFile) async {
    print('SubscriptionRepository: Uploading payment proof via API: ${imageFile.path}');
    try {
      // Use postMultipart for file uploads
      final response = await _apiService.postMultipart(
        endpoint: 'subscription/upload-proof',
        file: imageFile,
        fileField: 'proofImage', // Make sure this matches the backend expected field name
      );
      
      if (response['data'] != null && response['data']['proofUrl'] != null) {
        final proofUrl = response['data']['proofUrl'] as String;
        print('SubscriptionRepository: Proof uploaded successfully via API. URL: $proofUrl');
        return proofUrl;
      }
      throw Exception('Payment proof upload failed: Invalid API response structure.');
    } catch (e) {
      print('Error uploading payment proof via API: $e');
      throw Exception('Failed to upload payment proof: $e');
    }
  }

  final List<SubscriptionTier> _tiers_fallback = [
    SubscriptionTier(name: 'Freemium', price: 'Gratuit', users: '1 Utilisateur', features: ['Stock limité', 'Clients limités', 'Ventes basiques'], adhaTokens: '100', type: SubscriptionTierType.freemium),
    SubscriptionTier(name: 'Starter', price: '5,000 FCFA/mois', users: '5 Utilisateurs', features: ['Stock illimité', 'Clients illimités', 'Ventes avancées', 'Support Email'], adhaTokens: '500', type: SubscriptionTierType.starter),
    SubscriptionTier(name: 'Premium', price: '15,000 FCFA/mois', users: 'Utilisateurs Illimités', features: ['Tout de Starter', 'Multi-boutiques', 'Support Prioritaire', 'Analyses Avancées'], adhaTokens: '2000', type: SubscriptionTierType.premium),
  ];

  SubscriptionTier _currentTier_fallback = SubscriptionTier(name: 'Freemium', price: 'Gratuit', users: '1 Utilisateur', features: ['Stock limité', 'Clients limités', 'Ventes basiques'], adhaTokens: '100', type: SubscriptionTierType.freemium, isCurrent: true);

  final List<Invoice> _invoices_fallback = [
    Invoice(id: 'INV-2024-001', date: DateTime.now().subtract(const Duration(days: 35)), amount: 5000, status: 'Payée', downloadUrl: 'https://example.com/invoice/INV-2024-001.pdf'),
    Invoice(id: 'INV-2024-002', date: DateTime.now().subtract(const Duration(days: 5)), amount: 5000, status: 'En attente', downloadUrl: 'https://example.com/invoice/INV-2024-002.pdf'),
  ];

  final List<PaymentMethod> _paymentMethods_fallback = [
    PaymentMethod(id: 'pm_card_123', name: 'Visa **** 1234', type: 'card', details: 'Expire 12/26'),
    PaymentMethod(id: 'pm_momo_456', name: 'Orange Money 77xxxxxx', type: 'mobile_money', details: 'Principal'),
  ];
}

extension SubscriptionTierCopyWith on SubscriptionTier {
  SubscriptionTier copyWith({
    String? name,
    String? price,
    String? users,
    List<String>? features,
    String? adhaTokens,
    SubscriptionTierType? type,
    bool? isCurrent,
  }) {
    return SubscriptionTier(
      name: name ?? this.name,
      price: price ?? this.price,
      users: users ?? this.users,
      features: features ?? this.features,
      adhaTokens: adhaTokens ?? this.adhaTokens,
      type: type ?? this.type,
      isCurrent: isCurrent ?? this.isCurrent,
    );
  }
}
