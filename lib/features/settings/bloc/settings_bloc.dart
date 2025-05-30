import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/settings_repository.dart';
import '../models/settings.dart'; // Added import for Settings model
import 'settings_event.dart';
import 'settings_state.dart';

/// BLoC pour gérer les paramètres de l'application
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  /// Repository pour accéder aux paramètres
  final SettingsRepository settingsRepository;

  SettingsBloc({required this.settingsRepository}) : super(const SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateSettings>(_onUpdateSettings);
    on<UpdateCompanyInfo>(_onUpdateCompanyInfo);
    on<UpdateInvoiceSettings>(_onUpdateInvoiceSettings);
    on<UpdateDisplaySettings>(_onUpdateDisplaySettings);
    on<UpdateInventorySettings>(_onUpdateInventorySettings);
    on<UpdateBackupSettings>(_onUpdateBackupSettings);
    on<UpdateNotificationSettings>(_onUpdateNotificationSettings);
    on<ResetSettings>(_onResetSettings);
  }

  /// Gère le chargement des paramètres
  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());
    
    try {
      final settings = await settingsRepository.getSettings();
      emit(SettingsLoaded(settings));
    } catch (e) {
      emit(SettingsError('Erreur lors du chargement des paramètres: $e'));
    }
  }

  /// Gère la mise à jour complète des paramètres
  Future<void> _onUpdateSettings(
    UpdateSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());
    
    try {
      await settingsRepository.saveSettings(event.settings);
      emit(SettingsUpdated(
        settings: event.settings,
        message: 'Paramètres mis à jour avec succès',
      ));
      emit(SettingsLoaded(event.settings)); // Emit SettingsLoaded
    } catch (e) {
      emit(SettingsError('Erreur lors de la mise à jour des paramètres: $e'));
      if (state is SettingsLoaded) {
        emit(SettingsLoaded((state as SettingsLoaded).settings));
      } else {
        add(const LoadSettings());
      }
    }
  }

  /// Gère la mise à jour des informations de l'entreprise
  Future<void> _onUpdateCompanyInfo(
    UpdateCompanyInfo event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());
    
    try {
      final currentSettings = await settingsRepository.getSettings();
      final updatedSettings = currentSettings.copyWith(
        companyName: event.companyName,
        companyAddress: event.companyAddress,
        companyPhone: event.companyPhone,
        companyEmail: event.companyEmail,
        companyLogo: event.companyLogo,
        taxIdentificationNumber: event.taxIdentificationNumber,
        rccmNumber: event.rccmNumber,
        idNatNumber: event.idNatNumber,
      );
      
      await settingsRepository.saveSettings(updatedSettings);
      emit(SettingsUpdated(
        settings: updatedSettings,
        message: 'Informations de l\'entreprise mises à jour',
      ));
      emit(SettingsLoaded(updatedSettings)); // Emit SettingsLoaded
    } catch (e) {
      emit(SettingsError('Erreur lors de la mise à jour des informations de l\'entreprise: $e'));
      if (state is SettingsLoaded) {
        emit(SettingsLoaded((state as SettingsLoaded).settings));
      } else {
        add(const LoadSettings());
      }
    }
  }

  /// Gère la mise à jour des paramètres de facture
  Future<void> _onUpdateInvoiceSettings(
    UpdateInvoiceSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());
    
    try {
      final currentSettings = await settingsRepository.getSettings();
      final updatedSettings = currentSettings.copyWith(
        invoiceNumberFormat: event.invoiceNumberFormat,
        invoicePrefix: event.invoicePrefix,
        defaultPaymentTerms: event.defaultPaymentTerms,
        defaultInvoiceNotes: event.defaultInvoiceNotes,
        showTaxes: event.showTaxes,
        defaultTaxRate: event.defaultTaxRate,
      );
      
      await settingsRepository.saveSettings(updatedSettings);
      emit(SettingsUpdated(
        settings: updatedSettings,
        message: 'Paramètres de facturation mis à jour',
      ));
      emit(SettingsLoaded(updatedSettings)); // Emit SettingsLoaded
    } catch (e) {
      emit(SettingsError('Erreur lors de la mise à jour des paramètres de facturation: $e'));
      if (state is SettingsLoaded) {
        emit(SettingsLoaded((state as SettingsLoaded).settings));
      } else {
        add(const LoadSettings());
      }
    }
  }

  /// Gère la mise à jour des paramètres d'affichage
  Future<void> _onUpdateDisplaySettings(
    UpdateDisplaySettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());
    
    try {
      final currentSettings = await settingsRepository.getSettings();
      final updatedSettings = currentSettings.copyWith(
        themeMode: event.themeMode,
        language: event.language,
        dateFormat: event.dateFormat,
      );
      
      await settingsRepository.saveSettings(updatedSettings);
      emit(SettingsUpdated(
        settings: updatedSettings,
        message: 'Paramètres d\'affichage mis à jour',
      ));
      emit(SettingsLoaded(updatedSettings)); // Emit SettingsLoaded
    } catch (e) {
      emit(SettingsError('Erreur lors de la mise à jour des paramètres d\'affichage: $e'));
      if (state is SettingsLoaded) {
        emit(SettingsLoaded((state as SettingsLoaded).settings));
      } else {
        add(const LoadSettings());
      }
    }
  }

  /// Gère la mise à jour des paramètres de stock
  Future<void> _onUpdateInventorySettings(
    UpdateInventorySettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());
    
    try {
      final currentSettings = await settingsRepository.getSettings();
      final updatedSettings = currentSettings.copyWith(
        defaultProductCategory: event.defaultProductCategory,
        lowStockAlertDays: event.lowStockAlertDays,
      );
      
      await settingsRepository.saveSettings(updatedSettings);
      emit(SettingsUpdated(
        settings: updatedSettings,
        message: 'Paramètres de stock mis à jour',
      ));
      emit(SettingsLoaded(updatedSettings)); // Emit SettingsLoaded
    } catch (e) {
      emit(SettingsError('Erreur lors de la mise à jour des paramètres de stock: $e'));
      if (state is SettingsLoaded) {
        emit(SettingsLoaded((state as SettingsLoaded).settings));
      } else {
        add(const LoadSettings());
      }
    }
  }

  /// Gère la mise à jour des paramètres de sauvegarde
  Future<void> _onUpdateBackupSettings(
    UpdateBackupSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());
    
    try {
      final currentSettings = await settingsRepository.getSettings();
      final updatedSettings = currentSettings.copyWith(
        backupEnabled: event.backupEnabled,
        backupFrequency: event.backupFrequency,
        reportEmail: event.reportEmail,
      );
      
      await settingsRepository.saveSettings(updatedSettings);
      emit(SettingsUpdated(
        settings: updatedSettings,
        message: 'Paramètres de sauvegarde mis à jour',
      ));
      emit(SettingsLoaded(updatedSettings)); // Emit SettingsLoaded
    } catch (e) {
      emit(SettingsError('Erreur lors de la mise à jour des paramètres de sauvegarde: $e'));
      if (state is SettingsLoaded) {
        emit(SettingsLoaded((state as SettingsLoaded).settings));
      } else {
        add(const LoadSettings());
      }
    }
  }

  /// Gère la mise à jour des paramètres de notification
  Future<void> _onUpdateNotificationSettings(
    UpdateNotificationSettings event,
    Emitter<SettingsState> emit,
  ) async {
    // Get current settings from state if possible, otherwise load them.
    Settings currentSettings;
    if (state is SettingsLoaded) {
      currentSettings = (state as SettingsLoaded).settings;
    } else if (state is SettingsUpdated) { // Also consider SettingsUpdated as a source of current settings
      currentSettings = (state as SettingsUpdated).settings;
    } else {
      // If settings are not loaded, emit loading and fetch them.
      emit(const SettingsLoading());
      try {
        currentSettings = await settingsRepository.getSettings();
        emit(SettingsLoaded(currentSettings));
      } catch (e) {
        emit(SettingsError('Erreur lors du chargement des paramètres avant mise à jour: $e'));
        return;
      }
    }
    
    final updatedSettings = currentSettings.copyWith(
      pushNotificationsEnabled: event.pushNotificationsEnabled,
      inAppNotificationsEnabled: event.inAppNotificationsEnabled,
      emailNotificationsEnabled: event.emailNotificationsEnabled,
      soundNotificationsEnabled: event.soundNotificationsEnabled,
    );
    
    // Emit loading before the save operation for this specific update
    emit(const SettingsLoading()); 
    
    try {
      await settingsRepository.saveSettings(updatedSettings);
      emit(SettingsUpdated(
        settings: updatedSettings,
        message: 'Paramètres de notification mis à jour avec succès',
      ));
      emit(SettingsLoaded(updatedSettings)); // Emit SettingsLoaded
    } catch (e) {
      emit(SettingsError('Erreur lors de la mise à jour des paramètres de notification: $e'));
      // Revert to previously known good settings on error
      emit(SettingsLoaded(currentSettings)); 
    }
  }

  /// Gère la réinitialisation des paramètres
  Future<void> _onResetSettings(
    ResetSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());
    
    try {
      final defaultSettings = await settingsRepository.resetSettings();
      emit(SettingsUpdated(
        settings: defaultSettings,
        message: 'Paramètres réinitialisés aux valeurs par défaut',
      ));
      emit(SettingsLoaded(defaultSettings)); // Emit SettingsLoaded
    } catch (e) {
      emit(SettingsError('Erreur lors de la réinitialisation des paramètres: $e'));
      if (state is SettingsLoaded) {
        emit(SettingsLoaded((state as SettingsLoaded).settings));
      } else {
        add(const LoadSettings());
      }
    }
  }
}
