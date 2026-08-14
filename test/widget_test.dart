import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scandigitize/main.dart';

void main() {
  testWidgets('App renders login screen initially', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: ScanDigitizeApp()));
    expect(find.text('ScanDigitize'), findsOneWidget);
    expect(find.text('SIGN IN TO WORKSTATION'), findsOneWidget);
  });
}
