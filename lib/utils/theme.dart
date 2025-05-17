import 'package:flutter/material.dart';

/// Classe utilitaire contenant les couleurs et styles du thème Wanzo
class WanzoTheme {
  // Empêche l'instanciation
  WanzoTheme._();

  // Couleurs primaires
  static const Color primary = Color(0xFF197CA8);
  static const Color primaryLight = Color(0xFF2089B7);
  static const Color primaryDark = Color(0xFF156D93);

  // Couleurs interactives
  static const Color interactive = Color(0xFF1E90C3);
  static const Color interactiveLight = Color(0xFF2F9FCF);
  static const Color interactiveDark = Color(0xFF1B81AF);

  // Couleurs de succès
  static const Color success = Color(0xFF015730);
  static const Color successLight = Color(0xFF026B3A);
  static const Color successDark = Color(0xFF014426);

  // Couleurs d'avertissement
  static const Color warning = Color(0xFFEE872B);
  static const Color warningLight = Color(0xFFF09642);
  static const Color warningDark = Color(0xFFE67816);

  // Couleurs d'erreur
  static const Color error = Color(0xFFDC2626);
  static const Color danger = Color(0xFFDC2626); // Alias pour error

  // Couleurs d'information
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);
  static const Color infoDark = Color(0xFF2563EB);

  // Espacement (similaire aux classes Tailwind)
  static const double spacingXxs = 2;
  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 12;
  static const double spacingBase = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;
  static const double spacingXxl = 48;
  static const double spacingXxxl = 64;

  // Rayons de bordure
  static const double borderRadiusXs = 2;
  static const double borderRadiusSm = 4;
  static const double borderRadiusMd = 6;
  static const double borderRadiusLg = 8;
  static const double borderRadiusXl = 12;
  static const double borderRadiusXxl = 16;
  static const double borderRadiusFull = 9999;

  // Typographie - Tailles de police
  static const double fontSizeXs = 12;
  static const double fontSizeSm = 14;
  static const double fontSizeBase = 16;
  static const double fontSizeMd = 18;
  static const double fontSizeLg = 20;
  static const double fontSizeXl = 24;
  static const double fontSizeXxl = 32;

  // Typographie - Poids de police
  static const FontWeight fontWeightLight = FontWeight.w300;
  static const FontWeight fontWeightNormal = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;

  /// Génère le thème clair
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: Colors.white,
        secondary: interactive,
        onSecondary: Colors.white,
        error: error,
        onError: Colors.white,
        surface: Colors.white,
        onSurface: const Color(0xFF111827),
        tertiary: info,
        onTertiary: Colors.white,
        surfaceTint: Colors.transparent,
      ),
      scaffoldBackgroundColor: Colors.white,
      cardColor: Colors.white,
      dividerColor: const Color(0xFFE5E7EB),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: Color(0xFF111827)),
        displayMedium: TextStyle(color: Color(0xFF111827)),
        displaySmall: TextStyle(color: Color(0xFF111827)),
        headlineLarge: TextStyle(color: Color(0xFF111827)),
        headlineMedium: TextStyle(color: Color(0xFF111827)),
        headlineSmall: TextStyle(color: Color(0xFF111827)),
        titleLarge: TextStyle(color: Color(0xFF111827)),
        titleMedium: TextStyle(color: Color(0xFF111827)),
        titleSmall: TextStyle(color: Color(0xFF111827)),
        bodyLarge: TextStyle(color: Color(0xFF111827)),
        bodyMedium: TextStyle(color: Color(0xFF111827)),
        bodySmall: TextStyle(color: Color(0xFF4B5563)),
        labelLarge: TextStyle(color: Color(0xFF111827)),
        labelMedium: TextStyle(color: Color(0xFF4B5563)),
        labelSmall: TextStyle(color: Color(0xFF9CA3AF)),
      ),
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMd),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMd),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMd),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMd),
          ),
        ),
      ),
      iconTheme: const IconThemeData(
        color: Color(0xFF4B5563),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMd),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF2C2E33),
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMd),
        ),
      ),
    );
  }

  /// Génère le thème sombre
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: primaryLight,
        onPrimary: Colors.white,
        secondary: interactiveLight,
        onSecondary: Colors.white,
        error: error,
        onError: Colors.white,
        surface: const Color(0xFF2C2E33),
        onSurface: const Color(0xFFF3F4F6),
        tertiary: infoLight,
        onTertiary: Colors.white,
        surfaceTint: Colors.transparent,
      ),
      scaffoldBackgroundColor: const Color(0xFF1A1B1E),
      cardColor: const Color(0xFF2C2E33),
      dividerColor: const Color(0xFF3B3D42),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: Color(0xFFF3F4F6)),
        displayMedium: TextStyle(color: Color(0xFFF3F4F6)),
        displaySmall: TextStyle(color: Color(0xFFF3F4F6)),
        headlineLarge: TextStyle(color: Color(0xFFF3F4F6)),
        headlineMedium: TextStyle(color: Color(0xFFF3F4F6)),
        headlineSmall: TextStyle(color: Color(0xFFF3F4F6)),
        titleLarge: TextStyle(color: Color(0xFFF3F4F6)),
        titleMedium: TextStyle(color: Color(0xFFF3F4F6)),
        titleSmall: TextStyle(color: Color(0xFFF3F4F6)),
        bodyLarge: TextStyle(color: Color(0xFFF3F4F6)),
        bodyMedium: TextStyle(color: Color(0xFFF3F4F6)),
        bodySmall: TextStyle(color: Color(0xFFD1D5DB)),
        labelLarge: TextStyle(color: Color(0xFFF3F4F6)),
        labelMedium: TextStyle(color: Color(0xFFD1D5DB)),
        labelSmall: TextStyle(color: Color(0xFF9CA3AF)),
      ),
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMd),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: primaryLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMd),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryLight,
          side: const BorderSide(color: primaryLight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMd),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMd),
          ),
        ),
      ),
      iconTheme: const IconThemeData(
        color: Color(0xFFD1D5DB),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryLight,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        color: const Color(0xFF2C2E33),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMd),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF3B3D42),
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMd),
        ),
      ),
    );
  }
}
