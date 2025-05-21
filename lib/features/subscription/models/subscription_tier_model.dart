enum SubscriptionTierType { freemium, starter, premium }

class SubscriptionTier {
  final String name;
  final String price;
  final String users;
  final List<String> features;
  final String adhaTokens;
  final SubscriptionTierType type;
  final bool isCurrent; // To highlight the current tier

  SubscriptionTier({
    required this.name,
    required this.price,
    required this.users,
    required this.features,
    required this.adhaTokens,
    required this.type,
    this.isCurrent = false,
  });

  factory SubscriptionTier.fromJson(Map<String, dynamic> json) {
    return SubscriptionTier(
      name: json['name'] as String,
      price: json['price'] as String,
      users: json['users'] as String,
      features: List<String>.from(json['features'] as List<dynamic>),
      adhaTokens: json['adhaTokens'] as String,
      type: SubscriptionTierType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => SubscriptionTierType.freemium, // Default if type is unknown
      ),
      isCurrent: json['isCurrent'] as bool? ?? false,
    );
  }
}
