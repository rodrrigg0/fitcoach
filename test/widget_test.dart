import 'package:flutter_test/flutter_test.dart';
import 'package:fitcoach/main.dart';

void main() {
  testWidgets('FitCoach app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FitCoachApp());
    await tester.pump();
  });
}
