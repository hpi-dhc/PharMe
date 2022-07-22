import 'package:app/common/module.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.onlyPumps;

  group('integration tests for the onboarding', () {
    testWidgets('Test that pages are changing', (tester) async {
      final appRouter = AppRouter();
      await tester.pumpWidget(MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routeInformationParser: appRouter.defaultRouteParser(),
        routerDelegate: appRouter.delegate(
          initialDeepLink: 'onboarding',
        ),
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('en', '')],
      ));

      await tester.pumpAndSettle();
      expect(find.text('Welcome to PharMe'), findsOneWidget);

      // change page
      await tester.tap(find.byKey(ValueKey('next_button')));
      await tester.pumpAndSettle();
      expect(find.text('One size does not fit all'), findsOneWidget);
      // change page
      await tester.tap(find.byKey(ValueKey('next_button')));
      await tester.pumpAndSettle();
      expect(find.text('Genome power unlocked to improve human health'),
          findsOneWidget);

      await tester.tap(find.byKey(ValueKey('next_button')));
      await tester.pumpAndSettle();
      expect(find.text('Tailored to your genome'), findsOneWidget);

      await tester.tap(find.byKey(ValueKey('next_button')));
      await tester.pumpAndSettle();
      expect(find.text('We care about your data protection'), findsOneWidget);
    });
  });
}
