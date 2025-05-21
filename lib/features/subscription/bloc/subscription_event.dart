part of 'subscription_bloc.dart';

abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all subscription-related details
class LoadSubscriptionDetails extends SubscriptionEvent {}

/// Event to change the user's subscription tier
class ChangeSubscriptionTier extends SubscriptionEvent {
  final SubscriptionTierType newTierType;

  const ChangeSubscriptionTier(this.newTierType);

  @override
  List<Object?> get props => [newTierType];
}

/// Event to top-up Adha tokens
class TopUpAdhaTokens extends SubscriptionEvent {
  final double amount; // Or a specific token package ID

  const TopUpAdhaTokens(this.amount);

  @override
  List<Object?> get props => [amount];
}

/// Event to upload payment proof for manual payments
class UploadPaymentProof extends SubscriptionEvent {
  final String imagePath; // Path to the uploaded file

  const UploadPaymentProof(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}
