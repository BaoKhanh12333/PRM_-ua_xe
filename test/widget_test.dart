import 'package:flutter_test/flutter_test.dart';
import 'package:dua_xe/main.dart';

void main() {
  testWidgets('Racing Game App basic test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(RacingGameApp());

    // Verify that the title is present on the AuthScreen.
    expect(find.text('SIÊU CẤP ĐUA XE'), findsOneWidget);
  });
}
