// Router principal da aplicação PixelAI: gere a navegação entre Onboarding e Home.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_ai/features/home/presentation/home_screen.dart';
import 'package:pixel_ai/features/onboarding/presentation/onboarding_screen.dart';
import 'package:pixel_ai/core/storage/local_storage.dart';

import 'route_names.dart';

class AppRouter {
  AppRouter._();

  static final LocalStorage _localStorage = LocalStorage();

  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.onboarding,
    redirect: (context, state) async {
      final completed = await _localStorage.isOnboardingCompleted();
      final isOnboarding = state.matchedLocation == RouteNames.onboarding;

      if (!completed && !isOnboarding) {
        return RouteNames.onboarding;
      }

      if (completed && isOnboarding) {
        return RouteNames.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.onboarding,
        builder: (context, state) => OnboardingScreen(
          onCompleted: () {
            debugPrint('Callback iniciado');

            _localStorage
                .completeOnboarding()
                .then((_) {
                  debugPrint('Onboarding guardado');

                  if (context.mounted) {
                    debugPrint('A navegar para ${RouteNames.home}');
                    context.go(RouteNames.home);
                  }
                })
                .catchError((error) {
                  debugPrint('Erro ao guardar onboarding: $error');
                });
          },
        ),
      ),
      GoRoute(
        path: RouteNames.home,
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
}
