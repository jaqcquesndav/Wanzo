part of 'subscription_bloc.dart';

// No imports here, they are in subscription_bloc.dart

abstract class SubscriptionState extends Equatable {
  const SubscriptionState();
  @override
  List<Object?> get props => [];
}

class SubscriptionInitial extends SubscriptionState {}
class SubscriptionLoading extends SubscriptionState {}

class SubscriptionLoaded extends SubscriptionState {
  final List<SubscriptionTier> tiers;
  final SubscriptionTier currentTier;
  final double tokenUsage; // e.g., 0.75 for 75%
  final int availableTokens;
  final List<Invoice> invoices; // Defined in invoice_model.dart
  final List<PaymentMethod> paymentMethods; // Defined in payment_method_model.dart
  final bool isUploadingProof;
  final String? uploadedProofName;

  const SubscriptionLoaded({
    required this.tiers,
    required this.currentTier,
    required this.tokenUsage,
    required this.availableTokens,
    required this.invoices,
    required this.paymentMethods,
    this.isUploadingProof = false,
    this.uploadedProofName,
  });

  @override
  List<Object?> get props => [
        tiers,
        currentTier,
        tokenUsage,
        availableTokens,
        invoices,
        paymentMethods,
        isUploadingProof,
        uploadedProofName,
      ];

  SubscriptionLoaded copyWith({
    List<SubscriptionTier>? tiers,
    SubscriptionTier? currentTier,
    double? tokenUsage,
    int? availableTokens,
    List<Invoice>? invoices,
    List<PaymentMethod>? paymentMethods,
    bool? isUploadingProof,
    String? uploadedProofName,
    bool clearUploadedProofName = false,
  }) {
    return SubscriptionLoaded(
      tiers: tiers ?? this.tiers,
      currentTier: currentTier ?? this.currentTier,
      tokenUsage: tokenUsage ?? this.tokenUsage,
      availableTokens: availableTokens ?? this.availableTokens,
      invoices: invoices ?? this.invoices,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      isUploadingProof: isUploadingProof ?? this.isUploadingProof,
      uploadedProofName: clearUploadedProofName
          ? null
          : (uploadedProofName ?? this.uploadedProofName),
    );
  }
}

class SubscriptionUpdateSuccess extends SubscriptionState {
  final String message;
  const SubscriptionUpdateSuccess(this.message);
  @override List<Object> get props => [message];
}
class SubscriptionUpdateFailure extends SubscriptionState {
  final String error;
  const SubscriptionUpdateFailure(this.error);
  @override List<Object> get props => [error];
}

class TokenTopUpSuccess extends SubscriptionState {
  final String message;
  const TokenTopUpSuccess(this.message);
  @override List<Object> get props => [message];
}
class TokenTopUpFailure extends SubscriptionState {
  final String error;
  const TokenTopUpFailure(this.error);
  @override List<Object> get props => [error];
}

class PaymentProofUploadSuccess extends SubscriptionState {
  final String message;
  const PaymentProofUploadSuccess({required this.message});
  @override List<Object> get props => [message];
}

class PaymentProofUploadFailure extends SubscriptionState {
  final String error;
  const PaymentProofUploadFailure({required this.error});
  @override List<Object> get props => [error];
}

class SubscriptionError extends SubscriptionState {
  final String message;
  const SubscriptionError(this.message);
  @override
  List<Object> get props => [message];
}
