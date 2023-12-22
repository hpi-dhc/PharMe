import 'package:app/common/module.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.onlyPumps;

  UserData.instance.lookups = {};

  CachedDrugs.instance.version = 1;
  CachedDrugs.instance.drugs = List.empty();

  group('test the main page', () {
    testWidgets('test that tabs change pages', (tester) async {
      await initServices();
      final appRouter = AppRouter();
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => ActiveDrugs(),
          child: MaterialApp.router(
            routeInformationParser: appRouter.defaultRouteParser(),
            routerDelegate: appRouter.delegate(
              deepLinkBuilder: (_) => DeepLink.path('/main'),
            ),
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('en', '')],
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.summarize_rounded), findsOneWidget);
      expect(find.byIcon(Icons.medication_rounded), findsOneWidget);
      expect(find.byIcon(Icons.lightbulb_rounded), findsOneWidget);
      expect(find.byIcon(Icons.more_horiz_rounded), findsOneWidget);

      // ignore: omit_local_variable_types
      BottomNavigationBar bar = tester.widget(find.byType(BottomNavigationBar));

      expect(bar.currentIndex, 0);

      await tester.tap(find.byIcon(Icons.lightbulb_rounded));
      await tester.pumpAndSettle();

      bar = tester.widget(find.byType(BottomNavigationBar));
      expect(bar.currentIndex, 2);
    });
  });
}
