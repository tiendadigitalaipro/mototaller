import 'package:flutter/material.dart';

/// Identidad "taller de motos / racing": rojo carrera con acento cromado
/// (plateado, look de repuestos/motor) — distinta de BarberFlow (dorado),
/// ZYNC (cian), Mercado Logic Pro (terracota), Nail Studio Pro (fucsia),
/// Frutería Pro (naranja/verde), Bodega Pro (índigo/lima), FarmaCaja
/// (teal/coral), FerroStock (acero/ámbar) y DentalFlow (violeta/menta).
class AppColors {
  static const racing = Color(0xFFE11D2E);
  static const racingDim = Color(0xFFAF1522);
  static const chrome = Color(0xFFC4CDD8);
  static const chromeDim = Color(0xFF98A2AF);
  static const background = Color(0xFF0E0E11);
  static const surface = Color(0xFF16161A);
  static const surfaceLight = Color(0xFF201F26);
}

class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.racing,
        secondary: AppColors.chrome,
        surface: AppColors.surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.racing,
        elevation: 0,
        centerTitle: false,
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.surface,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.racing,
        foregroundColor: Colors.white,
      ),
      fontFamily: 'Roboto',
    );
  }
}
