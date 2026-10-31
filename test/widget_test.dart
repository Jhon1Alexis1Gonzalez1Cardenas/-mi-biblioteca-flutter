import 'package:flutter_test/flutter_test.dart';
import 'package:mi_biblioteca/main.dart';

void main() {
  testWidgets('App initialization smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the home screen is displayed.
    expect(find.text('Mi Biblioteca'), findsWidgets);
  });
}
