import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_ai/app/app.dart';
import 'package:pixel_ai/app/routing/app_routing.dart';
import 'package:pixel_ai/app/routing/route_names.dart';
import 'package:pixel_ai/features/ai_tools/presentation/ai_tools_screen.dart';
import 'package:pixel_ai/features/editor/presentation/editor_screen.dart';
import 'package:pixel_ai/features/gallery/presentation/gallery_screen.dart';
import 'package:pixel_ai/features/home/presentation/home_screen.dart';
import 'package:pixel_ai/features/home/widgets/photo_edit_model_card.dart';
import 'package:pixel_ai/features/onboarding/presentation/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pumpApp(
  WidgetTester tester, {
  bool onboardingCompleted = true,
}) async {
  SharedPreferences.setMockInitialValues({
    'onboarding_completed': onboardingCompleted,
  });
  // O GoRouter é estático e mantém a localização entre testes: repõe o ponto
  // de partida e deixa o redirect levar ao ecrã correto.
  AppRouter.router.go(RouteNames.home);
  await tester.pumpWidget(const ProviderScope(child: PixelAIApp()));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Onboarding pendente é apresentado e conclui para a Home',
      (WidgetTester tester) async {
    await _pumpApp(tester, onboardingCompleted: false);

    expect(find.byType(OnboardingScreen), findsOneWidget);

    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(OnboardingScreen), findsNothing);
  });

  testWidgets('Onboarding concluído encaminha diretamente para a Home',
      (WidgetTester tester) async {
    await _pumpApp(tester, onboardingCompleted: true);

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Pixel AI'), findsOneWidget);
  });

  testWidgets('Cartão da Home abre o Editor com a configuração do modelo',
      (WidgetTester tester) async {
    await _pumpApp(tester);

    expect(find.byType(PhotoEditModelCard), findsWidgets);

    await tester.tap(find.byType(PhotoEditModelCard).first);
    await tester.pumpAndSettle();

    expect(find.byType(EditorScreen), findsOneWidget);
    expect(find.text('Edição de paisagem'), findsWidgets);

    // Voltar do Editor regressa à Home.
    await tester.tap(find.byTooltip('Cancelar'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(EditorScreen), findsNothing);

    // Todos os modelos continuam disponíveis na grelha.
    await tester.scrollUntilVisible(
      find.text('Estilo editorial'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Estilo editorial'), findsOneWidget);
  });

  testWidgets('AI Tools apresenta as ferramentas e abre o Editor',
      (WidgetTester tester) async {
    await _pumpApp(tester);

    await tester.tap(find.byIcon(Icons.more_horiz));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ferramentas de IA'));
    await tester.pumpAndSettle();

    expect(find.byType(AiToolsScreen), findsOneWidget);
    expect(find.text('Background Remover'), findsOneWidget);
    expect(find.text('AI Enhance'), findsOneWidget);
    expect(find.text('AI Portrait'), findsOneWidget);
    expect(find.text('Object Remover'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Photo Restoration'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Background Generator'), findsOneWidget);
    expect(find.text('AI Colorize'), findsOneWidget);
    expect(find.text('Photo Restoration'), findsOneWidget);
    expect(find.text('AI Upscaler'), findsOneWidget);

    await tester.tap(find.text('Photo Restoration'));
    await tester.pumpAndSettle();

    expect(find.byType(EditorScreen), findsOneWidget);
    expect(find.text('Photo Restoration'), findsWidgets);
  });

  testWidgets('Editor executa o fluxo aplicar e apresenta os estados',
      (WidgetTester tester) async {
    await _pumpApp(tester);

    await tester.tap(find.byType(PhotoEditModelCard).first);
    await tester.pumpAndSettle();

    // Estado inicial de edição: controlos da ferramenta de máscara.
    expect(find.text('Brush'), findsOneWidget);
    expect(find.text('Tamanho'), findsWidgets);

    await tester.tap(find.byTooltip('Aplicar'));
    await tester.pump();

    expect(find.textContaining('A processar'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));

    expect(find.text('Resultado ainda indisponível'), findsOneWidget);
    expect(find.text('Voltar a editar'), findsOneWidget);
    expect(find.text('Guardar na galeria'), findsOneWidget);

    // Voltar a editar repõe o estado de edição.
    await tester.tap(find.text('Voltar a editar'));
    await tester.pumpAndSettle();

    expect(find.text('Brush'), findsOneWidget);
    expect(find.text('Resultado ainda indisponível'), findsNothing);
  });

  testWidgets('Selecionar outra ferramenta atualiza os controlos',
      (WidgetTester tester) async {
    await _pumpApp(tester);

    await tester.tap(find.byType(PhotoEditModelCard).first);
    await tester.pumpAndSettle();

    expect(find.text('Tamanho'), findsWidgets);
    expect(find.text('Dureza'), findsWidgets);

    await tester.tap(find.text('Lasso'));
    await tester.pumpAndSettle();

    expect(find.text('Suavização'), findsWidgets);
    expect(find.text('Tamanho'), findsNothing);
    expect(find.text('Dureza'), findsNothing);

    await tester.tap(find.text('Restore'));
    await tester.pumpAndSettle();

    expect(find.text('Intensidade'), findsWidgets);
    expect(find.text('Tamanho'), findsWidgets);
  });

  testWidgets('Gallery apresenta estado vazio e permite abrir o Editor',
      (WidgetTester tester) async {
    await _pumpApp(tester);

    await tester.tap(find.byIcon(Icons.more_horiz));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Galeria'));
    await tester.pumpAndSettle();

    expect(find.byType(GalleryScreen), findsOneWidget);
    expect(find.text('Ainda não tem fotografias'), findsOneWidget);

    await tester.tap(find.text('Abrir o Editor'));
    await tester.pumpAndSettle();

    expect(find.byType(EditorScreen), findsOneWidget);
  });

  testWidgets('Guardar na galeria apresenta o item e permite voltar a editar',
      (WidgetTester tester) async {
    await _pumpApp(tester);

    await tester.tap(find.byType(PhotoEditModelCard).first);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Aplicar'));
    await tester.pump(const Duration(seconds: 2));

    await tester.tap(find.text('Guardar na galeria'));
    await tester.pumpAndSettle();

    // Deixa o SnackBar terminar antes de continuar.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Cancelar'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_horiz));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Galeria'));
    await tester.pumpAndSettle();

    expect(find.byType(GalleryScreen), findsOneWidget);
    expect(find.text('Ainda não tem fotografias'), findsNothing);
    expect(find.text('Edição de paisagem'), findsWidgets);

    await tester.tap(find.text('Edição de paisagem').first);
    await tester.pumpAndSettle();

    // O conteúdo do painel pode precisar de deslizar em ecrãs baixos.
    await tester.ensureVisible(find.text('Editar'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();

    expect(find.byType(EditorScreen), findsOneWidget);
    expect(find.text('Edição de paisagem'), findsWidgets);
  });
}
