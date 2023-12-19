import 'package:app/common/module.dart';
import 'package:app/onboarding/module.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.onlyPumps;

  group('integration tests for the onboarding', () {
    testWidgets('Test that pages are changing', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: OnboardingPage(),
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('en', '')],
      ));

      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(Scaffold).first);
      expect(find.text(context.l10n.onboarding_1_header), findsOneWidget);

      await tester.tap(find.byKey(ValueKey('nextButton')));
      await tester.pumpAndSettle();
      expect(find.text(context.l10n.onboarding_2_header), findsOneWidget);

      await tester.tap(find.byKey(ValueKey('nextButton')));
      await tester.pumpAndSettle();
      expect(find.text(context.l10n.onboarding_3_header), findsOneWidget);

      await tester.tap(find.byKey(ValueKey('nextButton')));
      await tester.pumpAndSettle();
      expect(find.text(context.l10n.onboarding_4_header), findsOneWidget);

      await tester.tap(find.byKey(ValueKey('nextButton')));
      await tester.pumpAndSettle();
      expect(find.text(context.l10n.onboarding_5_header), findsOneWidget);
    });
  });
}
