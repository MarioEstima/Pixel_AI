// Router principal da aplicação PixelAI: gere a navegação entre Onboarding, Home, AI Tools, Editor e Gallery.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_ai/features/home/presentation/home_screen.dart';
import 'package:pixel_ai/features/onboarding/presentation/onboarding_screen.dart';
import 'package:pixel_ai/features/ai_tools/presentation/ai_tools_screen.dart';
import 'package:pixel_ai/features/editor/presentation/editor_screen.dart';
import 'package:pixel_ai/features/gallery/presentation/gallery_screen.dart';
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
      GoRoute(
        path: RouteNames.aiTools,
        builder: (context, state) => const AiToolsScreen(),
      ),
      GoRoute(
        path: RouteNames.editor,
        // `state.extra` pode ser um EditorConfig, um simples texto ou nulo:
        // EditorConfig.fromExtra garante sempre uma configuração válida.
        builder: (context, state) => EditorScreen(
          config: EditorConfig.fromExtra(state.extra),
        ),
      ),
      GoRoute(
        path: RouteNames.gallery,
        builder: (context, state) => const GalleryScreen(),
      ),
    ],
  );
}
