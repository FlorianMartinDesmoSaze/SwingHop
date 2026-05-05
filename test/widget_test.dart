import 'package:flutter_test/flutter_test.dart';
import 'package:swing_hop/main.dart';

void main() {
  testWidgets('Clean test', (WidgetTester tester) async {
    // Ce test vide permet de supprimer l'erreur rouge "MyApp not found"
    await tester.pumpWidget(const SwingHopApp(cameras: []));
  });
}