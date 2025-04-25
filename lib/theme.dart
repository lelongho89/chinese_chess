import 'package:flutter/material.dart';

class AppTheme extends ThemeExtension<AppTheme> {
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color surfaceColor;

  AppTheme({
    this.primaryColor = const Color(0xFF1976D2),
    this.secondaryColor = const Color(0xFF03A9F4),
    this.backgroundColor = const Color(0xFFF5F5F5),
    this.surfaceColor = const Color(0xFFFFFFFF),
  });

  AppTheme.dark({
    this.primaryColor = const Color(0xFF2196F3),
    this.secondaryColor = const Color(0xFF64B5F6),
    this.backgroundColor = const Color(0xFF121212),
    this.surfaceColor = const Color(0xFF1E1E1E),
  });

  static ThemeData createTheme({
    bool isDark = false,
    bool isHighContrast = false,
  }) {
    // Define primary color for the app
    const primaryColor = Color(0xFF1976D2); // Blue

    // Create a color scheme from the primary color
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: isDark ? Brightness.dark : Brightness.light,
    );

    // Create the base theme
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: isDark ? Brightness.dark : Brightness.light,

      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
      ),

      // Card theme
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // Segmented button theme
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),

      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return colorScheme.primary;
          }
          return null;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return colorScheme.primary.withOpacity(0.5);
          }
          return null;
        }),
      ),

      // Slider theme
      sliderTheme: SliderThemeData(
        activeTrackColor: colorScheme.primary,
        thumbColor: colorScheme.primary,
        overlayColor: colorScheme.primary.withOpacity(0.2),
      ),

      // List tile theme
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // Extensions
      extensions: [
        isDark ? AppTheme.dark() : AppTheme(),
      ],
    );
  }

  @override
  ThemeExtension<AppTheme> copyWith({
    Color? primaryColor,
    Color? secondaryColor,
    Color? backgroundColor,
    Color? surfaceColor,
  }) {
    return AppTheme(
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
    );
  }

  @override
  ThemeExtension<AppTheme> lerp(ThemeExtension<AppTheme>? other, double t) {
    if (other is! AppTheme) {
      return this;
    }

    return AppTheme(
      primaryColor: Color.lerp(primaryColor, other.primaryColor, t)!,
      secondaryColor: Color.lerp(secondaryColor, other.secondaryColor, t)!,
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      surfaceColor: Color.lerp(surfaceColor, other.surfaceColor, t)!,
    );
  }
}
