import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  // Azul eléctrico (color principal)
  static const Color gold           = Color(0xFF3B82F6);
  static const Color goldLight      = Color(0xFF60A5FA);
  static const Color goldDim        = Color(0xFF2563EB);
  static const Color goldGlow       = Color(0x263B82F6);

  // Fondos oscuros
  static const Color dark           = Color(0xFF0F172A);
  static const Color dark2          = Color(0xFF1E293B);
  static const Color dark3          = Color(0xFF263347);
  static const Color dark4          = Color(0xFF334155);
  static const Color dark5          = Color(0xFF475569);

  // Fondos claros
  static const Color cream          = Color(0xFFF1F5F9);
  static const Color cream2         = Color(0xFFE2E8F0);
  static const Color white          = Color(0xFFFFFFFF);

  // Texto
  static const Color textDark       = Color(0xFF0F172A);
  static const Color textMuted      = Color(0xFF64748B);
  static const Color textLight      = Color(0xFFFFFFFF);
  static const Color textMutedLight = Color(0xFF94A3B8);

  // Semánticos
  static const Color green          = Color(0xFF16A34A);
  static const Color greenLight     = Color(0xFF22C55E);
  static const Color greenBg        = Color(0xFFDCFCE7);
  static const Color red            = Color(0xFFDC2626);
  static const Color redLight       = Color(0xFFEF4444);
  static const Color redBg          = Color(0xFFFEE2E2);
  static const Color blue           = Color(0xFF2563EB);
  static const Color blueBg         = Color(0xFFDBEAFE);
  static const Color purple         = Color(0xFF7C3AED);
  static const Color orange         = Color(0xFFF97316);
  static const Color teal           = Color(0xFF0D9488);

  // Bordes
  static const Color borderDark     = Color(0x263B82F6);
  static const Color borderLight    = Color(0xFFCBD5E1);
}


class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    final base = ThemeData.dark();
    final textTheme = GoogleFonts.dmSansTextTheme(base.textTheme).copyWith(
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.textLight,
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textLight,
      ),
      headlineMedium: GoogleFonts.playfairDisplay(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textLight,
      ),
      titleLarge: GoogleFonts.dmSans(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: AppColors.textLight,
      ),
      titleMedium: GoogleFonts.dmSans(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textLight,
      ),
      bodyLarge: GoogleFonts.dmSans(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textLight,
      ),
      bodyMedium: GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textMutedLight,
      ),
      labelSmall: GoogleFonts.dmMono(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textMutedLight,
        letterSpacing: 0.5,
      ),
    );

    return base.copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.dark,
      primaryColor: AppColors.gold,
      textTheme: textTheme,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.gold,
        primaryContainer: AppColors.dark3,
        secondary: AppColors.goldLight,
        surface: AppColors.dark2,
        error: AppColors.redLight,
        onPrimary: AppColors.dark,
        onSurface: AppColors.textLight,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.dark,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textLight),
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textLight,
        ),
        surfaceTintColor: Colors.transparent,
      ),

      // Card
      cardTheme: CardThemeData(
        color: AppColors.dark2,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
        margin: const EdgeInsets.only(bottom: 10),
      ),

      // ElevatedButton (botón dorado principal)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.dark,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.gold,
          side: const BorderSide(color: AppColors.gold, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.gold,
          textStyle: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.dark3,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: AppColors.borderDark, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: AppColors.borderDark, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: AppColors.redLight, width: 1.5),
        ),
        hintStyle: GoogleFonts.dmSans(
          color: AppColors.textMutedLight.withOpacity(0.6),
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.dmSans(
          color: AppColors.goldDim,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
        prefixIconColor: AppColors.goldDim,
        suffixIconColor: AppColors.textMutedLight,
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.dark,
        selectedItemColor: AppColors.goldLight,
        unselectedItemColor: AppColors.dark5,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.borderDark,
        thickness: 1,
        space: 0,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.dark2,
        contentTextStyle:
            GoogleFonts.dmSans(color: AppColors.textLight, fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.dark,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.gold
              : AppColors.dark4,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.goldGlow
              : AppColors.dark3,
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData.light().copyWith(
      scaffoldBackgroundColor: AppColors.cream,
      primaryColor: AppColors.gold,
    );
  }
}

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get moneyLarge => GoogleFonts.dmMono(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.textLight,
      );

  static TextStyle get moneyMedium => GoogleFonts.dmMono(
        fontSize: 17,
        fontWeight: FontWeight.w500,
        color: AppColors.textLight,
      );

  static TextStyle get moneySmall => GoogleFonts.dmMono(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textLight,
      );

  static TextStyle get positive => GoogleFonts.dmMono(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.green,
      );

  static TextStyle get negative => GoogleFonts.dmMono(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.red,
      );

  static TextStyle get golden => GoogleFonts.dmMono(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.goldDim,
      );

  static TextStyle get cardTitle => GoogleFonts.playfairDisplay(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
      );

  static TextStyle get sectionLabel => GoogleFonts.dmSans(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: AppColors.textMuted,
        letterSpacing: 1.5,
      );
}
