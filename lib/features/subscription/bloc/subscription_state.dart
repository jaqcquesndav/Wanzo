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
  final SubscriptionTier? currentTier;
  final int tokenUsage;
  final int availableTokens;
  final List<Invoice> invoices;
  final List<PaymentMethod> paymentMethods;
  final bool isUploadingProof;
  final String? uploadedProofName; // To show the name of the uploaded file
  final bool isSubmittingManualPayment; // Added
  final bool isUpdatingPaymentMethod; // Added

  const SubscriptionLoaded({
    required this.tiers,
    this.currentTier,
    required this.tokenUsage,
    required this.availableTokens,
    required this.invoices,
    required this.paymentMethods,
    this.isUploadingProof = false,
    this.uploadedProofName,
    this.isSubmittingManualPayment = false, // Added
    this.isUpdatingPaymentMethod = false, // Added
  });

  SubscriptionLoaded copyWith({
    List<SubscriptionTier>? tiers,
    SubscriptionTier? currentTier,
    int? tokenUsage,
    int? availableTokens,
    List<Invoice>? invoices,
    List<PaymentMethod>? paymentMethods,
    bool? isUploadingProof,
    String? uploadedProofName,
    bool? clearUploadedProofName, // Special flag to nullify the name
    bool? isSubmittingManualPayment, // Added
    bool? isUpdatingPaymentMethod, // Added
  }) {
    return SubscriptionLoaded(
      tiers: tiers ?? this.tiers,
      currentTier: currentTier ?? this.currentTier,
      tokenUsage: tokenUsage ?? this.tokenUsage,
      availableTokens: availableTokens ?? this.availableTokens,
      invoices: invoices ?? this.invoices,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      isUploadingProof: isUploadingProof ?? this.isUploadingProof,
      uploadedProofName: clearUploadedProofName == true ? null : uploadedProofName ?? this.uploadedProofName,
      isSubmittingManualPayment: isSubmittingManualPayment ?? this.isSubmittingManualPayment, // Added
      isUpdatingPaymentMethod: isUpdatingPaymentMethod ?? this.isUpdatingPaymentMethod, // Added
    );
  }

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
        isSubmittingManualPayment, // Added
        isUpdatingPaymentMethod, // Added
      ];
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

// States for Manual Payment Submission
class ManualPaymentSubmissionSuccess extends SubscriptionState {
  final String message;
  const ManualPaymentSubmissionSuccess({required this.message});
  @override List<Object> get props => [message];
}

class ManualPaymentSubmissionFailure extends SubscriptionState {
  final String error;
  const ManualPaymentSubmissionFailure({required this.error});
  @override List<Object> get props => [error];
}

// States for Payment Method Update
class PaymentMethodUpdateSuccess extends SubscriptionState {
  final String message;
  const PaymentMethodUpdateSuccess({required this.message});
  @override List<Object> get props => [message];
}

class PaymentMethodUpdateFailure extends SubscriptionState {
  final String error;
  const PaymentMethodUpdateFailure({required this.error});
  @override List<Object> get props => [error];
}

class SubscriptionError extends SubscriptionState {
  final String message;
  const SubscriptionError(this.message);
  @override
  List<Object> get props => [message];
}
