import 'package:app/common/module.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.onlyPumps;

  group('test the main page', () {
    testWidgets('test that tabs change pages', (tester) async {
      final appRouter = AppRouter();
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: appRouter.defaultRouteParser(),
          routerDelegate: appRouter.delegate(
            initialDeepLink: 'main',
          ),
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en', '')],
        ),
      );

      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(Scaffold).first);

      expect(find.text(context.l10n.general_appName), findsOneWidget);

      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.assessment), findsOneWidget);
      expect(find.byIcon(Icons.lightbulb), findsOneWidget);
      expect(find.byIcon(Icons.more_horiz), findsOneWidget);

      // ignore: omit_local_variable_types
      BottomNavigationBar bar = tester.widget(find.byType(BottomNavigationBar));

      expect(bar.currentIndex, 0);

      await tester.tap(find.byIcon(Icons.lightbulb));
      await tester.pumpAndSettle();

      bar = tester.widget(find.byType(BottomNavigationBar));
      expect(bar.currentIndex, 2);
    });
  });
}
