import 'package:flutter_test/flutter_test.dart';
import 'package:fitcoach/core/providers/locale_provider.dart';
import 'package:fitcoach/main.dart';

void main() {
  testWidgets('FitCoach app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(FitCoachApp(localeProvider: LocaleProvider()));
    await tester.pump();
  });
}
