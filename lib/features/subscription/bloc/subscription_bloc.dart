import 'dart:io'; // Required for File and Platform
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:wanzo/features/subscription/models/subscription_tier_model.dart';
import 'package:wanzo/features/subscription/repositories/subscription_repository.dart';
import 'package:wanzo/features/subscription/models/invoice_model.dart';
import 'package:wanzo/features/subscription/models/payment_method_model.dart';

part 'subscription_event.dart';
part 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final SubscriptionRepository _subscriptionRepository;

  SubscriptionBloc({required SubscriptionRepository subscriptionRepository})
      : _subscriptionRepository = subscriptionRepository,
        super(SubscriptionInitial()) {
    on<LoadSubscriptionDetails>(_onLoadSubscriptionDetails);
    on<ChangeSubscriptionTier>(_onChangeSubscriptionTier);
    on<TopUpAdhaTokens>(_onTopUpAdhaTokens);
    on<UploadPaymentProof>(_onUploadPaymentProof);
    on<SubmitManualPayment>(_onSubmitManualPayment); // Added handler
    on<UpdatePaymentMethod>(_onUpdatePaymentMethod); // Added handler
  }

  Future<void> _onLoadSubscriptionDetails(
    LoadSubscriptionDetails event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());
    try {
      final tiers = await _subscriptionRepository.getSubscriptionTiers();
      final currentTier = await _subscriptionRepository.getCurrentUserSubscription();
      final tokenUsage = await _subscriptionRepository.getTokenUsage();
      final availableTokens = await _subscriptionRepository.getAvailableTokens();
      final invoices = await _subscriptionRepository.getInvoices();
      final paymentMethods = await _subscriptionRepository.getPaymentMethods();
      emit(SubscriptionLoaded(
        tiers: tiers,
        currentTier: currentTier,
        tokenUsage: tokenUsage.toInt(), // Cast to int
        availableTokens: availableTokens,
        invoices: invoices,
        paymentMethods: paymentMethods,
      ));
    } catch (e) {
      emit(SubscriptionError('Failed to load subscription details: ${e.toString()}'));
    }
  }

  Future<void> _onChangeSubscriptionTier(
    ChangeSubscriptionTier event,
    Emitter<SubscriptionState> emit,
  ) async {
    if (state is SubscriptionLoaded) {
      try {
        await _subscriptionRepository.changeSubscriptionTier(event.newTierType);
        emit(const SubscriptionUpdateSuccess('Abonnement changé avec succès!'));
        add(LoadSubscriptionDetails()); // Reload all details to ensure consistency
      } catch (e) {
        emit(SubscriptionUpdateFailure('Erreur lors du changement d\'abonnement: ${e.toString()}'));
      }
    }
  }

  Future<void> _onTopUpAdhaTokens(
    TopUpAdhaTokens event,
    Emitter<SubscriptionState> emit,
  ) async {
    if (state is SubscriptionLoaded) {
      try {
        await _subscriptionRepository.topUpAdhaTokens(event.amount);
        emit(TokenTopUpSuccess('Tokens Adha rechargés: ${event.amount}'));
        add(LoadSubscriptionDetails());
      } catch (e) {
        emit(TokenTopUpFailure('Erreur lors de la recharge de tokens: ${e.toString()}'));
      }
    }
  }

  Future<void> _onUploadPaymentProof(
    UploadPaymentProof event,
    Emitter<SubscriptionState> emit,
  ) async {
    if (state is SubscriptionLoaded) {
      final currentState = state as SubscriptionLoaded;
      emit(currentState.copyWith(isUploadingProof: true, clearUploadedProofName: true));

      try {
        final File imageFile = File(event.imagePath);
        final String proofUrl = await _subscriptionRepository.uploadPaymentProof(imageFile);
        final String fileName = imageFile.path.split(Platform.pathSeparator).last;

        emit(currentState.copyWith(
          isUploadingProof: false,
          uploadedProofName: fileName,
        ));
        emit(PaymentProofUploadSuccess(message: 'Preuve ($fileName) téléchargée. URL: $proofUrl'));
      } catch (e) {
        emit(currentState.copyWith(isUploadingProof: false));
        emit(PaymentProofUploadFailure(error: 'Échec du téléchargement de la preuve: ${e.toString()}'));
      }
    }
  }

  Future<void> _onSubmitManualPayment( // Added method
    SubmitManualPayment event,
    Emitter<SubscriptionState> emit,
  ) async {
    if (state is SubscriptionLoaded) {
      final currentState = state as SubscriptionLoaded;
      emit(currentState.copyWith(isSubmittingManualPayment: true));
      try {
        // Assuming a repository method like this exists:
        // await _subscriptionRepository.submitManualPayment(event.transactionReference, currentState.uploadedProofName);
        // For now, simulate success
        await Future.delayed(const Duration(seconds: 1)); // Simulate network call
        emit(ManualPaymentSubmissionSuccess(message: "Manual payment submitted successfully."));
        emit(currentState.copyWith(isSubmittingManualPayment: false, clearUploadedProofName: true)); // Clear proof name after submission
        add(LoadSubscriptionDetails()); // Reload details
      } catch (e) {
        emit(ManualPaymentSubmissionFailure(error: "Failed to submit manual payment: ${e.toString()}"));
        emit(currentState.copyWith(isSubmittingManualPayment: false));
      }
    }
  }

  Future<void> _onUpdatePaymentMethod( // Added method
    UpdatePaymentMethod event,
    Emitter<SubscriptionState> emit,
  ) async {
    if (state is SubscriptionLoaded) {
      final currentState = state as SubscriptionLoaded;
      emit(currentState.copyWith(isUpdatingPaymentMethod: true));
      try {
        // Assuming a repository method like this exists:
        // await _subscriptionRepository.updatePaymentMethod(event.paymentMethodId);
        // For now, simulate success
        await Future.delayed(const Duration(seconds:1)); // Simulate network call
        emit(PaymentMethodUpdateSuccess(message: "Payment method updated successfully."));
        emit(currentState.copyWith(isUpdatingPaymentMethod: false));
        add(LoadSubscriptionDetails()); // Reload details
      } catch (e) {
        emit(PaymentMethodUpdateFailure(error: "Failed to update payment method: ${e.toString()}"));
        emit(currentState.copyWith(isUpdatingPaymentMethod: false));
      }
    }
  }
}
