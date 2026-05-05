import 'package:flutter_test/flutter_test.dart';
import 'package:swing_hop/app.dart';

void main() {
  testWidgets('SwingHopApp se lance sans caméra', (WidgetTester tester) async {
    await tester.pumpWidget(const SwingHopApp(cameras: []));
    expect(find.byType(SwingHopApp), findsOneWidget);
  });
}