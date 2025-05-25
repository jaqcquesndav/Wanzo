// Enum for the type of interaction
enum AdhaInteractionType {
  genericCardAnalysis,
  directInitiation,
  followUp,
}

extension AdhaInteractionTypeExtension on AdhaInteractionType {
  String get value {
    switch (this) {
      case AdhaInteractionType.genericCardAnalysis:
        return 'generic_card_analysis';
      case AdhaInteractionType.directInitiation:
        return 'direct_initiation';
      case AdhaInteractionType.followUp:
        return 'follow_up';
      default:
        return '';
    }
  }

  static AdhaInteractionType fromString(String? value) {
    switch (value) {
      case 'generic_card_analysis':
        return AdhaInteractionType.genericCardAnalysis;
      case 'direct_initiation':
        return AdhaInteractionType.directInitiation;
      case 'follow_up':
        return AdhaInteractionType.followUp;
      default:
        // Consider throwing an error or returning a default
        throw ArgumentError('Invalid AdhaInteractionType string: \$value');
    }
  }
}

// Represents the base context (always present)
class AdhaBaseContext {
  final Map<String, dynamic> operationJournalSummary; // Structure to be defined with backend
  final Map<String, dynamic> businessProfile;         // Structure from User Profile API

  AdhaBaseContext({
    required this.operationJournalSummary,
    required this.businessProfile,
  });

  Map<String, dynamic> toJson() {
    return {
      'operationJournalSummary': operationJournalSummary,
      'businessProfile': businessProfile,
    };
  }

  factory AdhaBaseContext.fromJson(Map<String, dynamic> json) {
    return AdhaBaseContext(
      operationJournalSummary: json['operationJournalSummary'] as Map<String, dynamic>,
      businessProfile: json['businessProfile'] as Map<String, dynamic>,
    );
  }
}

// Represents the interaction-specific context
class AdhaInteractionContext {
  final AdhaInteractionType interactionType;
  final String? sourceIdentifier; // e.g., 'sales_analysis_card', 'user_direct_input'
  final Map<String, dynamic>? interactionData; // Optional data specific to the interaction

  AdhaInteractionContext({
    required this.interactionType,
    this.sourceIdentifier,
    this.interactionData,
  });

  Map<String, dynamic> toJson() {
    return {
      'interactionType': interactionType.value,
      if (sourceIdentifier != null) 'sourceIdentifier': sourceIdentifier,
      if (interactionData != null) 'interactionData': interactionData,
    };
  }

  factory AdhaInteractionContext.fromJson(Map<String, dynamic> json) {
    return AdhaInteractionContext(
      interactionType: AdhaInteractionTypeExtension.fromString(json['interactionType'] as String?),
      sourceIdentifier: json['sourceIdentifier'] as String?,
      interactionData: json['interactionData'] as Map<String, dynamic>?,
    );
  }
}

// Main context info class sent with each message
class AdhaContextInfo {
  final AdhaBaseContext baseContext;
  final AdhaInteractionContext interactionContext;

  AdhaContextInfo({
    required this.baseContext,
    required this.interactionContext,
  });

  Map<String, dynamic> toJson() {
    return {
      'baseContext': baseContext.toJson(),
      'interactionContext': interactionContext.toJson(),
    };
  }

  factory AdhaContextInfo.fromJson(Map<String, dynamic> json) {
    return AdhaContextInfo(
      baseContext: AdhaBaseContext.fromJson(json['baseContext'] as Map<String, dynamic>),
      interactionContext: AdhaInteractionContext.fromJson(json['interactionContext'] as Map<String, dynamic>),
    );
  }
}
