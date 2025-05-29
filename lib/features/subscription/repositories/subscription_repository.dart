import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:wanzo/core/services/api_client.dart';
import 'package:wanzo/features/expenses/models/expense.dart';
import 'package:wanzo/features/expenses/repositories/expense_repository.dart';
import 'package:wanzo/features/subscription/models/subscription_tier_model.dart';
import 'package:wanzo/features/subscription/models/invoice_model.dart';
import 'package:wanzo/features/subscription/models/payment_method_model.dart';

class SubscriptionRepository {
  final ExpenseRepository _expenseRepository;
  final ApiClient _apiService;
  final _uuid = const Uuid();

  SubscriptionRepository({
    required ExpenseRepository expenseRepository,
    required ApiClient apiService,
  })  : _expenseRepository = expenseRepository,
        _apiService = apiService;

  Future<List<SubscriptionTier>> getSubscriptionTiers() async {
    try {
      final responseData = await _apiService.get('subscription/tiers', requiresAuth: true);
      if (responseData != null && responseData['data'] != null && responseData['data'] is List) {
        return (responseData['data'] as List)
            .map((tierData) => SubscriptionTier.fromJson(tierData))
            .toList();
      }
      debugPrint('Error fetching subscription tiers: Invalid responseData structure: $responseData');
      return _fallbackTiers;
    } catch (e) {
      debugPrint('Error fetching subscription tiers: $e');
      return _fallbackTiers;
    }
  }

  Future<SubscriptionTier> getCurrentUserSubscription() async {
    try {
      final responseData = await _apiService.get('subscription/current', requiresAuth: true);
      if (responseData != null && responseData['data'] != null) {
        return SubscriptionTier.fromJson(responseData['data']);
      }
      debugPrint('Error fetching current subscription: Invalid responseData structure: $responseData');
      return _fallbackCurrentTier;
    } catch (e) {
      debugPrint('Error fetching current subscription: $e');
      return _fallbackCurrentTier;
    }
  }

  Future<double> getTokenUsage() async {
    try {
      final responseData = await _apiService.get('subscription/token-usage', requiresAuth: true);
      if (responseData != null && responseData['data'] != null && responseData['data']['usage_percentage'] != null) {
        return (responseData['data']['usage_percentage'] as num).toDouble();
      }
      debugPrint('Error fetching token usage: Invalid responseData structure: $responseData');
      return 0.0;
    } catch (e) {
      debugPrint('Error fetching token usage: $e');
      return 0.0;
    }
  }

  Future<int> getAvailableTokens() async {
    try {
      final responseData = await _apiService.get('subscription/available-tokens', requiresAuth: true);
      if (responseData != null && responseData['data'] != null && responseData['data']['tokens'] != null) {
        return (responseData['data']['tokens'] as num).toInt();
      }
      debugPrint('Error fetching available tokens: Invalid responseData structure: $responseData');
      return 0;
    } catch (e) {
      debugPrint('Error fetching available tokens: $e');
      return 0;
    }
  }

  Future<List<Invoice>> getInvoices() async {
    try {
      final responseData = await _apiService.get('subscription/invoices', requiresAuth: true);
      if (responseData != null && responseData['data'] != null && responseData['data'] is List) {
        return (responseData['data'] as List)
            .map((invoiceData) => Invoice.fromJson(invoiceData))
            .toList();
      }
      debugPrint('Error fetching invoices: Invalid responseData structure: $responseData');
      return _fallbackInvoices;
    } catch (e) {
      debugPrint('Error fetching invoices: $e');
      return _fallbackInvoices;
    }
  }

  Future<List<PaymentMethod>> getPaymentMethods() async {
    try {
      final responseData = await _apiService.get('subscription/payment-methods', requiresAuth: true);
      if (responseData != null && responseData['data'] != null && responseData['data'] is List) {
        return (responseData['data'] as List)
            .map((pmData) => PaymentMethod.fromJson(pmData))
            .toList();
      }
      debugPrint('Error fetching payment methods: Invalid responseData structure: $responseData');
      return _fallbackPaymentMethods;
    } catch (e) {
      debugPrint('Error fetching payment methods: $e');
      return _fallbackPaymentMethods;
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
    debugPrint('SubscriptionRepository: Attempting to change subscription to $newTierType via API');
    try {
      await _apiService.post('subscription/change-tier', 
        body: {'newTierType': newTierType.toString().split('.').last},
        requiresAuth: true
      );
      debugPrint('SubscriptionRepository: API call to change tier successful.');

      final newTierData = _fallbackTiers.firstWhere((t) => t.type == newTierType, orElse: () => _fallbackCurrentTier);
      final tierPrice = _parsePrice(newTierData.price);
      if (tierPrice > 0) {
        final expense = Expense(
          id: _uuid.v4(),
          date: DateTime.now(),
          motif: 'Paiement abonnement ${newTierData.name}',
          amount: tierPrice,
          category: ExpenseCategory.other, // Assuming a general category, adjust if specific one exists
          paymentMethod: 'System/Online',
          // attachmentUrls and supplierId are optional and can be omitted
        );
        try {
          await _expenseRepository.addExpense(expense);
          debugPrint('SubscriptionRepository: Expense recorded for subscription change to ${newTierData.name}');
        } catch (e) {
          debugPrint('SubscriptionRepository: Failed to record expense for subscription change: $e');
        }
      }
    } catch (e) {
      debugPrint('Error changing subscription tier via API: $e');
      throw Exception('Failed to change subscription tier: $e');
    }
  }

  Future<void> topUpAdhaTokens(double amount) async {
    debugPrint('SubscriptionRepository: Attempting to top up Adha tokens for $amount FCFA via API');
    try {
      await _apiService.post('subscription/topup-tokens', 
        body: {'amount': amount.toString()},
        requiresAuth: true
      );
      debugPrint('SubscriptionRepository: API call to topup tokens successful.');

      const double fcfaPerToken = 10.0; 
      int tokensToAdd = (amount / fcfaPerToken).round();

      final expense = Expense(
        id: _uuid.v4(),
        date: DateTime.now(),
        motif: 'Recharge de $tokensToAdd tokens Adha ($amount FCFA)',
        amount: amount,
        category: ExpenseCategory.other, // Assuming a general category, adjust if specific one exists for Adha tokens
        paymentMethod: 'System/Online',
        // attachmentUrls and supplierId are optional and can be omitted
      );
      try {
        await _expenseRepository.addExpense(expense);
        debugPrint('SubscriptionRepository: Expense recorded for Adha token top-up of $amount FCFA');
      } catch (e) {
        debugPrint('SubscriptionRepository: Failed to record expense for token top-up: $e');
      }
    } catch (e) {
      debugPrint('Error topping up Adha tokens via API: $e');
      throw Exception('Failed to top up Adha tokens: $e');
    }
  }

  Future<String> uploadPaymentProof(File imageFile) async {
    debugPrint('SubscriptionRepository: Uploading payment proof via API: ${imageFile.path}');
    try {
      final response = await _apiService.postMultipart(
        'subscription/upload-proof',
        file: imageFile,
        fileField: 'proofImage',
        requiresAuth: true
      );
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = jsonDecode(response.body);
        if (responseData['data'] != null && responseData['data']['proofUrl'] != null) {
          final proofUrl = responseData['data']['proofUrl'] as String;
          debugPrint('SubscriptionRepository: Proof uploaded successfully via API. URL: $proofUrl');
          return proofUrl;
        }
        debugPrint('Error uploading payment proof: Invalid responseData structure in 2xx response: ${response.body}');
        throw Exception('Payment proof upload failed: Invalid API response structure.');
      } else {
        debugPrint('Error uploading payment proof: Status ${response.statusCode}, Body: ${response.body}');
        throw Exception('Payment proof upload failed: Status code ${response.statusCode}.');
      }
    } catch (e) {
      debugPrint('Error uploading payment proof via API: $e');
      throw Exception('Failed to upload payment proof: $e');
    }
  }

  final List<SubscriptionTier> _fallbackTiers = [
    SubscriptionTier(name: 'Freemium', price: 'Gratuit', users: '1 Utilisateur', features: ['Stock limité', 'Clients limités', 'Ventes basiques'], adhaTokens: '100', type: SubscriptionTierType.freemium),
    SubscriptionTier(name: 'Starter', price: '5,000 FCFA/mois', users: '5 Utilisateurs', features: ['Stock illimité', 'Clients illimités', 'Ventes avancées', 'Support Email'], adhaTokens: '500', type: SubscriptionTierType.starter),
    SubscriptionTier(name: 'Premium', price: '15,000 FCFA/mois', users: 'Utilisateurs Illimités', features: ['Tout de Starter', 'Multi-boutiques', 'Support Prioritaire', 'Analyses Avancées'], adhaTokens: '2000', type: SubscriptionTierType.premium),
  ];

  final SubscriptionTier _fallbackCurrentTier = SubscriptionTier(name: 'Freemium', price: 'Gratuit', users: '1 Utilisateur', features: ['Stock limité', 'Clients limités', 'Ventes basiques'], adhaTokens: '100', type: SubscriptionTierType.freemium, isCurrent: true);

  final List<Invoice> _fallbackInvoices = [];
  final List<PaymentMethod> _fallbackPaymentMethods = [];
}
