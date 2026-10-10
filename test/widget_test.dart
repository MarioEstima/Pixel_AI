import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_ai/app/app.dart';

void main() {
  testWidgets('PixelAI inicia corretamente', (WidgetTester tester) async {
    await tester.pumpWidget(const PixelAIApp());

    await tester.pumpAndSettle();

    expect(find.byType(PixelAIApp), findsOneWidget);
  });
}
