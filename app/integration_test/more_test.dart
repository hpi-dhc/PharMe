import 'package:app/common/module.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.onlyPumps;

  group('test settings page', () {
    testWidgets('right things are getting rendered', (tester) async {
      await initServices();
      MetaData.instance.tutorialDone = true;
      await MetaData.save();
      final appRouter = AppRouter();
      await tester.pumpWidget(MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routeInformationParser: appRouter.defaultRouteParser(),
        routerDelegate: appRouter.delegate(
          deepLinkBuilder: (_) => DeepLink.path('/main/more'),
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
      final BuildContext context = tester.element(find.byType(Scaffold).first);

      expect(
        find.text(context.l10n.more_page_account_settings),
        findsOneWidget,
      );

      // test opening of a dialog
      await tester.tap(find.text(context.l10n.more_page_delete_data));
      await tester.pumpAndSettle();

      expect(
        find.text(context.l10n.more_page_delete_data_text),
        findsOneWidget,
      );

      // close dialog
      await tester.tap(find.text(context.l10n.action_cancel));
      await tester.pumpAndSettle();

      // test onboarding button
      await tester.tap(find.text(context.l10n.more_page_onboarding));
      await tester.pumpAndSettle();

      expect(find.text(context.l10n.onboarding_1_header), findsOneWidget);

      await context.router.root.pop();
      await tester.pumpAndSettle();

      // test about us
      await tester.tap(find.text(context.l10n.more_page_about_us));
      await tester.pumpAndSettle();

      expect(
        find.text(context.l10n.more_page_about_us_text),
        findsOneWidget,
      );

      context.router.back();
      await tester.pumpAndSettle();

      // test privacy policy
      await tester.tap(find.text(context.l10n.more_page_privacy_policy));
      await tester.pumpAndSettle();

      expect(
        find.text(context.l10n.more_page_privacy_policy_text),
        findsOneWidget,
      );

      context.router.back();
      await tester.pumpAndSettle();

      // test terms and conditions
      await tester.tap(
        find.text(context.l10n.more_page_terms_and_conditions),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(context.l10n.more_page_terms_and_conditions_text),
        findsOneWidget,
      );
    });
  });
}
