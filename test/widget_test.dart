import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_2048/main.dart';

void main() {
  testWidgets('App renders 2048 title, score boxes and buttons', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('2048'), findsOneWidget);
    expect(find.text('SCORE'), findsOneWidget);
    expect(find.text('BEST'), findsOneWidget);
    expect(find.text('New'), findsOneWidget);
    expect(find.text('AI Bot'), findsOneWidget);

    // Tap theme toggle button
    final themeButton = find.byTooltip('Toggle Theme');
    expect(themeButton, findsOneWidget);
    await tester.tap(themeButton);
    await tester.pumpAndSettle();

    // Tap New Game button
    final newGameButton = find.text('New');
    await tester.tap(newGameButton);
    await tester.pumpAndSettle();
  });
}
