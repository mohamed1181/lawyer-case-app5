import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// هوية بصرية احترافية مخصصة للمحامين:
/// Deep Navy Blue (خلفيات) + Charcoal (بطاقات) + Gold/Bronze (تمييز وإجراءات رئيسية)
class AppColors {
  static const Color navy = Color(0xFF0B1320);
  static const Color navyLight = Color(0xFF152238);
  static const Color charcoal = Color(0xFF1E2530);
  static const Color gold = Color(0xFFC9A24B);
  static const Color goldLight = Color(0xFFE3C77D);
  static const Color textPrimary = Color(0xFFF3F1EA);
  static const Color textSecondary = Color(0xFFA9B1BE);
  static const Color danger = Color(0xFFD9534F);
  static const Color success = Color(0xFF4CAF7D);
  static const Color warning = Color(0xFFE0A85E);
}

class AppTheme {
  static ThemeData get dark {
    final base = ThemeData.dark();
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.navy,
      primaryColor: AppColors.gold,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.gold,
        secondary: AppColors.goldLight,
        surface: AppColors.charcoal,
        background: AppColors.navy,
      ),
      textTheme: GoogleFonts.cairoTextTheme(base.textTheme).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.navy,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: AppColors.gold),
      ),
      cardTheme: CardThemeData(
        color: AppColors.charcoal,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.navyLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: AppColors.textSecondary),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.navy,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.navy,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.navyLight,
        selectedItemColor: AppColors.gold,
        unselectedItemColor: AppColors.textSecondary,
      ),
    );
  }
}
