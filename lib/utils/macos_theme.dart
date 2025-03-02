import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MacOSTheme {
  // Colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF333333);
  static const Color accentColor = Color(0xFF007AFF); // macOS blue
  
  // Status colors - Made slightly brighter
  static const Color runningColor = Color(0xFF007AFF); // Blue
  static const Color pendingColor = Color(0xFFFF9500); // Orange
  static const Color completedColor = Color(0xFF34C759); // Green
  static const Color failedColor = Color(0xFFFF3B30); // Red
  
  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    primaryColor: accentColor,
    colorScheme: ColorScheme.light(
      primary: accentColor,
      secondary: accentColor,
      background: background,
      surface: Colors.white.withOpacity(0.8), // More transparent
    ),
    scaffoldBackgroundColor: background,
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), // Slightly more rounded
      ),
      color: Colors.white.withOpacity(0.7), // More transparent cards
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white.withOpacity(0.7), // More transparent
      foregroundColor: Colors.black,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    ),
    textTheme: GoogleFonts.interTextTheme(
      ThemeData.light().textTheme,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        foregroundColor: Colors.white,
        backgroundColor: accentColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: accentColor,
        side: const BorderSide(color: accentColor, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accentColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.9),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    primaryColor: accentColor,
    colorScheme: ColorScheme.dark(
      primary: accentColor,
      secondary: accentColor,
      background: backgroundDark,
      surface: const Color(0xFF222222).withOpacity(0.7), // More transparent
    ),
    scaffoldBackgroundColor: backgroundDark,
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), // Slightly more rounded
      ),
      color: const Color(0xFF444444).withOpacity(0.6), // Lighter, more transparent cards
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: Colors.black.withOpacity(0.7), // Semi-transparent drawer
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF333333).withOpacity(0.7), // Semi-transparent
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    textTheme: GoogleFonts.interTextTheme(
      ThemeData.dark().textTheme,
    ).apply(
      bodyColor: Colors.white, // Ensure good contrast with transparent backgrounds
      displayColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        foregroundColor: Colors.white,
        backgroundColor: accentColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: accentColor,
        side: const BorderSide(color: accentColor, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accentColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: const Color(0xFF222222).withOpacity(0.9),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  );

  // Get color for job status with increased opacity for stronger colors
  static Color getStatusColor(String status) {
    if (status == 'RUNNING') return runningColor;
    if (status == 'PENDING') return pendingColor;
    if (status == 'COMPLETED' || status == 'COMPLETING') return completedColor;
    if (['FAILED', 'TIMEOUT', 'CANCELLED'].contains(status)) return failedColor;
    return pendingColor; // Default
  }
} 