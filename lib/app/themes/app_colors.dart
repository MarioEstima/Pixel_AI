import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color pinkVibrant = Color(0xFFF9B8DC);
  static const Color pinkLight = Color(0xFFFCD6EA);
  static const Color lavender = Color(0xFFE3CFF8);
  static const Color lilacDeep = Color(0xFFD9B8F5);

  // Interface escura
  static const Color background = Color(0xFF14101C);
  static const Color surface = Color(0xFF1F1829);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA9A3B8);

  // Acentos
  static const Color accentCoral = Color(0xFFF4A58A);
  static const Color accentSky = Color(0xFF6FA8DC);
  static const Color accentSakura = Color(0xFFF2B8C6);
  static const Color accentRed = Color(0xFFD8402E);

  // Efeito vidro (branco com ~14% de opacidade)
  static const Color glass = Color(0x24FFFFFF);
  static const Color glassBorder = Color(0x2EFFFFFF);

  // Gradiente de fundo
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [pinkVibrant, lavender, lilacDeep],
    stops: [0.0, 0.6, 1.0],
  );
}
