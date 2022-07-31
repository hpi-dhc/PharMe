import 'package:app/common/module.dart';
import 'package:app/faq/constants.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.onlyPumps;

  group('integration test for the faq page', () {
    final appRouter = AppRouter();
    final faqWidget = MaterialApp.router(
      routeInformationParser: appRouter.defaultRouteParser(),
      routerDelegate: appRouter.delegate(
        initialDeepLink: 'main/faq',
      ),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale('en', '')],
    );

    testWidgets('All questions are loaded and expansion tiles can be open',
        (tester) async {
      await tester.pumpWidget(faqWidget);
      await tester.pumpAndSettle();

      expect(
        find
            .descendant(
              of: find.byKey(ValueKey('questionsColumn')),
              matching: find.byType(ExpansionTile),
            )
            .evaluate()
            .length,
        faqList.length,
      );

      expect(find.text(faqList[0].question), findsOneWidget);
      expect(find.text(faqList[0].answer), findsNothing);

      await tester.tap(find.byType(ExpansionTile).first);
      await tester.pumpAndSettle();

      expect(find.text(faqList[0].answer), findsOneWidget);
    });
  });
}
