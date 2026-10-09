import 'package:flutter/material.dart';
import 'package:pixel_ai/app/routing/app_routing.dart';
import 'package:pixel_ai/app/themes/app_colors.dart';

void main() {
  runApp(const PixelAIApp());
}

class PixelAIApp extends StatelessWidget {
  const PixelAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PixelAI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          foregroundColor: AppColors.textPrimary,
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        colorScheme: const ColorScheme.dark(
          primary: AppColors.pinkVibrant,
          onPrimary: AppColors.background,
          secondary: AppColors.lilacDeep,
          onSecondary: AppColors.background,
          tertiary: AppColors.accentCoral,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
          error: AppColors.accentRed,
        ),
      ),
      routerConfig: AppRouter.router,
    );
  }
}