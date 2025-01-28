import 'package:app/common/module.dart';
import 'package:app/faq/pages/content.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.onlyPumps;

  group('integration test for the faq page', () {

    late MaterialApp faqWidget;

    setUpAll(() async {
      await initServices();
      MetaData.instance.tutorialDone = true;
      await MetaData.save();
      final appRouter = AppRouter();
      faqWidget = MaterialApp.router(
        routeInformationParser: appRouter.defaultRouteParser(),
        routerDelegate: appRouter.delegate(
          deepLinkBuilder: (_) => DeepLink.path('/main/faq'),
        ),
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('en', '')],
      );
    });

    testWidgets(
      'All questions are loaded and expansion tiles can be open',
      (tester) async {
        await tester.pumpWidget(faqWidget);
        await tester.pumpAndSettle();

        final faqContent = getFaqContent();

        final expectedNumberOfQuestions = faqContent.fold<int>(
          0, (number, topic) => number + topic.questions.length
        );

        expect(
          find
              .descendant(
                of: find.byKey(ValueKey('questionsColumn')),
                matching: find.byType(ExpansionTile),
              )
              .evaluate()
              .length,
          expectedNumberOfQuestions,
        );

        final BuildContext context =
          tester.element(find.byType(Scaffold).first);
        final firstQuestion = faqContent.first.questions.first(context);
        expect(find.text(firstQuestion.question), findsOneWidget);
        expect(find.text(firstQuestion.answer), findsNothing);

        await tester.tap(find.byType(ExpansionTile).first);
        await tester.pumpAndSettle();

        expect(find.text(firstQuestion.answer), findsOneWidget);
      },
    );
  });
}
