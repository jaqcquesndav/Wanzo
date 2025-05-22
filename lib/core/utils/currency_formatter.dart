import 'package:intl/intl.dart';
import 'package:wanzo/features/settings/models/settings.dart'; // Assuming this is the correct path to CurrencyType

String formatCurrency(double amount, CurrencyType currencyType) {
  String currencyCode;
  String symbol;

  switch (currencyType) {
    case CurrencyType.usd:
      currencyCode = 'USD';
      symbol = '\$';
      break;
    case CurrencyType.cdf:
      currencyCode = 'CDF';
      symbol = 'FC'; // Or CDF, adjust as needed
      break;
    case CurrencyType.fc:
      currencyCode = 'FC'; // Assuming this is a distinct currency, e.g., Franc Congolais
      symbol = 'FC';
      break;
    // No default needed here as CurrencyType enum covers all cases.
    // However, if CurrencyType could be null or have unhandled cases,
    // a default or error handling would be wise.
  }

  // Using intl package for basic number formatting.
  final NumberFormat formatter = NumberFormat.currency(
    locale: 'en_US', // Adjust locale as needed, e.g., 'fr_CD' for CDF
    symbol: symbol,
    decimalDigits: 2,
  );

  // Specific formatting for FC and CDF to place symbol after the amount with a space.
  if (currencyType == CurrencyType.cdf || currencyType == CurrencyType.fc) {
    // Example: "1,234.56 FC"
    // Using a non-breaking space \\u00A0 to ensure symbol stays with the number.
    return '${NumberFormat("#,##0.00", "en_US").format(amount)}\\u00A0$symbol';
  }
  
  // Default formatting for USD (symbol before amount, no space after symbol by default with en_US locale)
  return formatter.format(amount);
}

// Helper to get just the currency string (code)
String getCurrencyString(CurrencyType currencyType) {
  switch (currencyType) {
    case CurrencyType.usd:
      return 'USD';
    case CurrencyType.cdf:
      return 'CDF';
    case CurrencyType.fc:
      return 'FC';
    // No default needed here as CurrencyType enum covers all cases.
  }
}
