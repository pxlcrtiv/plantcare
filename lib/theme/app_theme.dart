import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A class that contains all theme configurations for the plant care application.
class AppTheme {
  AppTheme._();

  // Living Palette - Earth-toned foundation with vibrant accents
  static const Color primaryLight = Color(0xFF2D5A3D); // Deep forest green
  static const Color primaryVariantLight = Color(0xFF1A3D28);
  static const Color secondaryLight = Color(0xFF7FB069); // Fresh sage
  static const Color secondaryVariantLight = Color(0xFF6A9B56);
  static const Color accentLight = Color(0xFFF4A261); // Warm terracotta
  static const Color backgroundLight = Color(0xFFFEFEFE); // Pure white
  static const Color surfaceLight = Color(0xFFF8F9FA); // Subtle warm gray
  static const Color successLight = Color(0xFF52B788); // Vibrant green
  static const Color warningLight = Color(0xFFF9C74F); // Gentle yellow
  static const Color errorLight = Color(0xFFF8961E); // Soft orange
  static const Color textPrimaryLight = Color(0xFF1A1A1A); // Near-black
  static const Color textSecondaryLight = Color(0xFF6B7280); // Medium gray
  static const Color onPrimaryLight = Color(0xFFFFFFFF);
  static const Color onSecondaryLight = Color(0xFF000000);
  static const Color onBackgroundLight = Color(0xFF1A1A1A);
  static const Color onSurfaceLight = Color(0xFF1A1A1A);
  static const Color onErrorLight = Color(0xFFFFFFFF);

  // Dark theme colors - adapted for low light plant care environments
  static const Color primaryDark =
      Color(0xFF7FB069); // Fresh sage as primary in dark
  static const Color primaryVariantDark = Color(0xFF6A9B56);
  static const Color secondaryDark =
      Color(0xFF2D5A3D); // Deep forest as secondary
  static const Color secondaryVariantDark = Color(0xFF1A3D28);
  static const Color accentDark = Color(0xFFF4A261); // Warm terracotta
  static const Color backgroundDark = Color(0xFF0F1419); // Deep natural dark
  static const Color surfaceDark = Color(0xFF1A1F24); // Subtle dark surface
  static const Color successDark = Color(0xFF52B788); // Vibrant green
  static const Color warningDark = Color(0xFFF9C74F); // Gentle yellow
  static const Color errorDark = Color(0xFFF8961E); // Soft orange
  static const Color textPrimaryDark = Color(0xFFFEFEFE); // Pure white
  static const Color textSecondaryDark = Color(0xFFB0B8C1); // Light gray
  static const Color onPrimaryDark = Color(0xFF000000);
  static const Color onSecondaryDark = Color(0xFFFFFFFF);
  static const Color onBackgroundDark = Color(0xFFFEFEFE);
  static const Color onSurfaceDark = Color(0xFFFEFEFE);
  static const Color onErrorDark = Color(0xFF000000);

  // Card and dialog colors
  static const Color cardLight = Color(0xFFF8F9FA);
  static const Color cardDark = Color(0xFF1A1F24);
  static const Color dialogLight = Color(0xFFFEFEFE);
  static const Color dialogDark = Color(0xFF1A1F24);

  // Shadow colors - using primary color at 8% opacity for organic feel
  static const Color shadowLight = Color(0x142D5A3D);
  static const Color shadowDark = Color(0x147FB069);

  // Divider colors
  static const Color dividerLight = Color(0x1F6B7280);
  static const Color dividerDark = Color(0x1FB0B8C1);

  /// Light theme optimized for bright windowsill conditions
  static ThemeData lightTheme = ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: primaryLight,
          onPrimary: onPrimaryLight,
          primaryContainer: primaryVariantLight,
          onPrimaryContainer: onPrimaryLight,
          secondary: secondaryLight,
          onSecondary: onSecondaryLight,
          secondaryContainer: secondaryVariantLight,
          onSecondaryContainer: onSecondaryLight,
          tertiary: accentLight,
          onTertiary: Color(0xFF000000),
          tertiaryContainer: accentLight.withValues(alpha: 0.2),
          onTertiaryContainer: Color(0xFF000000),
          error: errorLight,
          onError: onErrorLight,
          surface: surfaceLight,
          onSurface: onSurfaceLight,
          onSurfaceVariant: textSecondaryLight,
          outline: dividerLight,
          outlineVariant: dividerLight.withValues(alpha: 0.5),
          shadow: shadowLight,
          scrim: shadowLight,
          inverseSurface: surfaceDark,
          onInverseSurface: onSurfaceDark,
          inversePrimary: primaryDark),
      scaffoldBackgroundColor: backgroundLight,
      cardColor: cardLight,
      dividerColor: dividerLight,
      appBarTheme: AppBarTheme(
          backgroundColor: backgroundLight,
          foregroundColor: textPrimaryLight,
          elevation: 0,
          shadowColor: shadowLight,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: textPrimaryLight,
              letterSpacing: -0.5)),
      cardTheme: CardTheme(
          color: cardLight,
          elevation: 2.0,
          shadowColor: shadowLight,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: surfaceLight,
          selectedItemColor: primaryLight,
          unselectedItemColor: textSecondaryLight,
          elevation: 4,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle:
              GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
          unselectedLabelStyle:
              GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400)),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: accentLight,
          foregroundColor: Color(0xFF000000),
          elevation: 4,
          focusElevation: 6,
          hoverElevation: 6,
          highlightElevation: 8,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0))),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              foregroundColor: onPrimaryLight,
              backgroundColor: primaryLight,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              elevation: 2,
              shadowColor: shadowLight,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              textStyle: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5))),
      outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
              foregroundColor: primaryLight,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              side: BorderSide(color: primaryLight, width: 1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              textStyle: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5))),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
              foregroundColor: primaryLight,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              textStyle: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5))),
      textTheme: _buildTextTheme(isLight: true),
      inputDecorationTheme: InputDecorationTheme(
          fillColor: surfaceLight,
          filled: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: surfaceLight)),
          enabledBorder:
              OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: surfaceLight)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: primaryLight, width: 2)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: errorLight, width: 1)),
          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: errorLight, width: 2)),
          labelStyle: GoogleFonts.inter(color: textSecondaryLight, fontSize: 16, fontWeight: FontWeight.w400),
          hintStyle: GoogleFonts.inter(color: textSecondaryLight.withValues(alpha: 0.7), fontSize: 16, fontWeight: FontWeight.w400),
          prefixIconColor: textSecondaryLight,
          suffixIconColor: textSecondaryLight),
      switchTheme: SwitchThemeData(thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryLight;
        }
        return textSecondaryLight;
      }), trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryLight.withValues(alpha: 0.3);
        }
        return textSecondaryLight.withValues(alpha: 0.2);
      })),
      checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return successLight;
            }
            return Colors.transparent;
          }),
          checkColor: WidgetStateProperty.all(onPrimaryLight),
          side: BorderSide(color: textSecondaryLight, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
      radioTheme: RadioThemeData(fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryLight;
        }
        return textSecondaryLight;
      })),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: primaryLight, linearTrackColor: primaryLight.withValues(alpha: 0.2), circularTrackColor: primaryLight.withValues(alpha: 0.2)),
      sliderTheme: SliderThemeData(activeTrackColor: primaryLight, thumbColor: primaryLight, overlayColor: primaryLight.withValues(alpha: 0.2), inactiveTrackColor: primaryLight.withValues(alpha: 0.3), trackHeight: 4, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8)),
      tabBarTheme: TabBarTheme(labelColor: primaryLight, unselectedLabelColor: textSecondaryLight, indicatorColor: primaryLight, indicatorSize: TabBarIndicatorSize.label, labelStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500), unselectedLabelStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400)),
      tooltipTheme: TooltipThemeData(decoration: BoxDecoration(color: textPrimaryLight.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(8)), textStyle: GoogleFonts.inter(color: backgroundLight, fontSize: 14, fontWeight: FontWeight.w400), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
      snackBarTheme: SnackBarThemeData(backgroundColor: textPrimaryLight, contentTextStyle: GoogleFonts.inter(color: backgroundLight, fontSize: 16, fontWeight: FontWeight.w400), actionTextColor: accentLight, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0))),
      bottomSheetTheme: BottomSheetThemeData(backgroundColor: backgroundLight, shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), elevation: 8, modalBackgroundColor: backgroundLight), dialogTheme: DialogThemeData(backgroundColor: dialogLight));

  /// Dark theme optimized for dimmer indoor plant care environments
  static ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme(
          brightness: Brightness.dark,
          primary: primaryDark,
          onPrimary: onPrimaryDark,
          primaryContainer: primaryVariantDark,
          onPrimaryContainer: onPrimaryDark,
          secondary: secondaryDark,
          onSecondary: onSecondaryDark,
          secondaryContainer: secondaryVariantDark,
          onSecondaryContainer: onSecondaryDark,
          tertiary: accentDark,
          onTertiary: Color(0xFF000000),
          tertiaryContainer: accentDark.withValues(alpha: 0.2),
          onTertiaryContainer: Color(0xFFFFFFFF),
          error: errorDark,
          onError: onErrorDark,
          surface: surfaceDark,
          onSurface: onSurfaceDark,
          onSurfaceVariant: textSecondaryDark,
          outline: dividerDark,
          outlineVariant: dividerDark.withValues(alpha: 0.5),
          shadow: shadowDark,
          scrim: shadowDark,
          inverseSurface: surfaceLight,
          onInverseSurface: onSurfaceLight,
          inversePrimary: primaryLight),
      scaffoldBackgroundColor: backgroundDark,
      cardColor: cardDark,
      dividerColor: dividerDark,
      appBarTheme: AppBarTheme(
          backgroundColor: backgroundDark,
          foregroundColor: textPrimaryDark,
          elevation: 0,
          shadowColor: shadowDark,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: textPrimaryDark,
              letterSpacing: -0.5)),
      cardTheme: CardTheme(
          color: cardDark,
          elevation: 2.0,
          shadowColor: shadowDark,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: surfaceDark,
          selectedItemColor: primaryDark,
          unselectedItemColor: textSecondaryDark,
          elevation: 4,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle:
              GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
          unselectedLabelStyle:
              GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400)),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: accentDark,
          foregroundColor: Color(0xFF000000),
          elevation: 4,
          focusElevation: 6,
          hoverElevation: 6,
          highlightElevation: 8,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0))),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              foregroundColor: onPrimaryDark,
              backgroundColor: primaryDark,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              elevation: 2,
              shadowColor: shadowDark,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              textStyle: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5))),
      outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
              foregroundColor: primaryDark,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              side: BorderSide(color: primaryDark, width: 1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              textStyle: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5))),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
              foregroundColor: primaryDark,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              textStyle: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5))),
      textTheme: _buildTextTheme(isLight: false),
      inputDecorationTheme: InputDecorationTheme(
          fillColor: surfaceDark,
          filled: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: surfaceDark)),
          enabledBorder:
              OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: surfaceDark)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: primaryDark, width: 2)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: errorDark, width: 1)),
          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: errorDark, width: 2)),
          labelStyle: GoogleFonts.inter(color: textSecondaryDark, fontSize: 16, fontWeight: FontWeight.w400),
          hintStyle: GoogleFonts.inter(color: textSecondaryDark.withValues(alpha: 0.7), fontSize: 16, fontWeight: FontWeight.w400),
          prefixIconColor: textSecondaryDark,
          suffixIconColor: textSecondaryDark),
      switchTheme: SwitchThemeData(thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryDark;
        }
        return textSecondaryDark;
      }), trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryDark.withValues(alpha: 0.3);
        }
        return textSecondaryDark.withValues(alpha: 0.2);
      })),
      checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return successDark;
            }
            return Colors.transparent;
          }),
          checkColor: WidgetStateProperty.all(onPrimaryDark),
          side: BorderSide(color: textSecondaryDark, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
      radioTheme: RadioThemeData(fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryDark;
        }
        return textSecondaryDark;
      })),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: primaryDark, linearTrackColor: primaryDark.withValues(alpha: 0.2), circularTrackColor: primaryDark.withValues(alpha: 0.2)),
      sliderTheme: SliderThemeData(activeTrackColor: primaryDark, thumbColor: primaryDark, overlayColor: primaryDark.withValues(alpha: 0.2), inactiveTrackColor: primaryDark.withValues(alpha: 0.3), trackHeight: 4, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8)),
      tabBarTheme: TabBarTheme(labelColor: primaryDark, unselectedLabelColor: textSecondaryDark, indicatorColor: primaryDark, indicatorSize: TabBarIndicatorSize.label, labelStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500), unselectedLabelStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400)),
      tooltipTheme: TooltipThemeData(decoration: BoxDecoration(color: textPrimaryDark.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(8)), textStyle: GoogleFonts.inter(color: backgroundDark, fontSize: 14, fontWeight: FontWeight.w400), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
      snackBarTheme: SnackBarThemeData(backgroundColor: textPrimaryDark, contentTextStyle: GoogleFonts.inter(color: backgroundDark, fontSize: 16, fontWeight: FontWeight.w400), actionTextColor: accentDark, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0))),
      bottomSheetTheme: BottomSheetThemeData(backgroundColor: backgroundDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), elevation: 8, modalBackgroundColor: backgroundDark), dialogTheme: DialogThemeData(backgroundColor: dialogDark));

  /// Helper method to build text theme with Inter and JetBrains Mono fonts
  static TextTheme _buildTextTheme({required bool isLight}) {
    final Color textHighEmphasis = isLight ? textPrimaryLight : textPrimaryDark;
    final Color textMediumEmphasis =
        isLight ? textSecondaryLight : textSecondaryDark;
    final Color textDisabled = isLight
        ? textSecondaryLight.withValues(alpha: 0.6)
        : textSecondaryDark.withValues(alpha: 0.6);

    return TextTheme(
        // Display styles - Inter with geometric clarity
        displayLarge: GoogleFonts.inter(
            fontSize: 57,
            fontWeight: FontWeight.w700,
            color: textHighEmphasis,
            letterSpacing: -0.25,
            height: 1.12),
        displayMedium: GoogleFonts.inter(
            fontSize: 45,
            fontWeight: FontWeight.w700,
            color: textHighEmphasis,
            letterSpacing: 0,
            height: 1.16),
        displaySmall: GoogleFonts.inter(
            fontSize: 36,
            fontWeight: FontWeight.w600,
            color: textHighEmphasis,
            letterSpacing: 0,
            height: 1.22),

        // Headline styles - Inter for clear hierarchy
        headlineLarge: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            color: textHighEmphasis,
            letterSpacing: 0,
            height: 1.25),
        headlineMedium: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: textHighEmphasis,
            letterSpacing: 0,
            height: 1.29),
        headlineSmall: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: textHighEmphasis,
            letterSpacing: 0,
            height: 1.33),

        // Title styles - Inter for navigation and cards
        titleLarge: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: textHighEmphasis,
            letterSpacing: 0,
            height: 1.27),
        titleMedium: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: textHighEmphasis,
            letterSpacing: 0.15,
            height: 1.5),
        titleSmall: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textHighEmphasis,
            letterSpacing: 0.1,
            height: 1.43),

        // Body styles - Inter for comfortable reading
        bodyLarge: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: textHighEmphasis,
            letterSpacing: 0.5,
            height: 1.5),
        bodyMedium: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textHighEmphasis,
            letterSpacing: 0.25,
            height: 1.43),
        bodySmall: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: textMediumEmphasis,
            letterSpacing: 0.4,
            height: 1.33),

        // Label styles - Inter for UI elements and captions
        labelLarge: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textHighEmphasis,
            letterSpacing: 0.1,
            height: 1.43),
        labelMedium: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textMediumEmphasis,
            letterSpacing: 0.5,
            height: 1.33),
        labelSmall: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: textDisabled,
            letterSpacing: 0.5,
            height: 1.45));
  }

  /// Helper method to get JetBrains Mono for data display
  static TextStyle getDataTextStyle({
    required bool isLight,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    final Color textColor = isLight ? textPrimaryLight : textPrimaryDark;
    return GoogleFonts.jetBrainsMono(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: textColor,
        letterSpacing: 0,
        height: 1.4);
  }

  /// Helper method to get success color based on theme
  static Color getSuccessColor(bool isLight) {
    return isLight ? successLight : successDark;
  }

  /// Helper method to get warning color based on theme
  static Color getWarningColor(bool isLight) {
    return isLight ? warningLight : warningDark;
  }

  /// Helper method to get accent color based on theme
  static Color getAccentColor(bool isLight) {
    return isLight ? accentLight : accentDark;
  }
}
