import 'package:flutter/material.dart';
import 'core/app_routing.dart';

class AppColors {
  static const Color background = Color(0xFFF6F2EA); // Krem hangat
  static const Color surface = Color(0xFFFFFDF9); // Putih gading lembut
  static const Color cardAlt = Color(0xFFEDE6DA); // Beige lembut
  static const Color primary = Color(0xFFD95D39); // Terakota hangat
  static const Color secondary = Color(0xFF2E6F5E); // Hijau sage
  static const Color textDark = Color(0xFF23201E); // Arang hangat
  static const Color textMuted = Color(0xFF6E665F); // Abu kecokelatan
  static const Color border = Color(0xFFE0D7C8);
}

void main() {
  runApp(const ReadLaterApp());
}

class ReadLaterApp extends StatelessWidget {
  const ReadLaterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReadLater Blog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          onSurface: AppColors.textDark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textDark,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            color: AppColors.textDark,
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          labelStyle: const TextStyle(color: AppColors.textMuted),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.cardAlt,
          labelStyle: const TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w500,
          ),
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      initialRoute: AppRouting.splash,
      onGenerateRoute: AppRouting.generateRoute,
    );
  }
}