// filepath: c:\Users\DevSpace\Flutter\wanzo\lib\core\enums\currency_enum.dart
import 'package:flutter/widgets.dart';
import 'package:wanzo/l10n/generated/app_localizations.dart'; // Updated import

enum Currency {
  CDF, // Congolese Franc
  USD, // US Dollar
  FCFA // Central African CFA franc
}

extension CurrencyExtension on Currency {
  String get code {
    switch (this) {
      case Currency.CDF:
        return 'CDF';
      case Currency.USD:
        return 'USD';
      case Currency.FCFA:
        return 'FCFA';
    }
  }

  String get symbol {
    switch (this) {
      case Currency.CDF:
        return 'FC'; // Or CDF
      case Currency.USD:
        return '\$';
      case Currency.FCFA:
        return 'FCFA'; // Or XAF
    }
  }

  String displayName(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case Currency.CDF:
        return l10n.currencyCDF;
      case Currency.USD:
        return l10n.currencyUSD;
      case Currency.FCFA:
        return l10n.currencyFCFA;
    }
  }
}
