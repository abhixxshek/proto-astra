import 'package:flutter_test/flutter_test.dart';
import 'package:agrosmart_mobile/main.dart';

void main() {
  testWidgets('App loads splash screen test', (WidgetTester tester) async {
    await tester.pumpWidget(const AgroSmartApp());
    expect(find.text('AgroSmart'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}
