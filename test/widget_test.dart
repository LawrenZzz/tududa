import 'package:flutter_test/flutter_test.dart';
import 'package:tududa/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: TududiApp()),
    );
    // App should build without errors
    expect(find.byType(TududiApp), findsOneWidget);
  });
}
