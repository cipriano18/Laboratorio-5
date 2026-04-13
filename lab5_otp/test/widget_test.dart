import 'package:flutter_test/flutter_test.dart';
import 'package:lab5_otp/app/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    expect(find.text('Verificar identidad'), findsOneWidget);
  });
}
