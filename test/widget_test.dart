import 'package:flutter_test/flutter_test.dart';
import 'package:swing_hop/app.dart';
import 'package:swing_hop/services/locale_service.dart';

void main() {
  testWidgets('SwingHopApp se lance sans caméra', (WidgetTester tester) async {
    await tester.pumpWidget(SwingHopApp(cameras: [], localeProvider: LocaleProvider()));
    expect(find.byType(SwingHopApp), findsOneWidget);
  });
}