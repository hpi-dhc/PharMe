// ignore_for_file: cast_nullable_to_non_nullable

import 'package:app/common/module.dart';
import 'package:app/common/pages/drugs/widgets/module.dart';
import 'package:app/search/module.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDrugsCubit extends MockCubit<DrugsState> implements DrugsCubit {}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final mockDrugsCubit = MockDrugsCubit();

  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.onlyPumps;

  final testDrug = DrugWithGuidelines(
    id: 1,
    name: 'Codeine',
    drugclass: 'Pain killer',
    indication: 'Codeine is used to treat pain and coughing.',
    guidelines: [
      Guideline(
        id: 1,
        warningLevel: WarningLevel.red,
        recommendation: 'Dont take too much from this drug',
        implication:
            'Because of your gene, you cannot digest this drug so well',
        cpicGuidelineUrl: 'some url',
        cpicClassification: 'strong',
        phenotype: Phenotype(
          id: 1,
          geneResult: GeneResult(id: 1, name: 'CYP2C9'),
          geneSymbol: GeneSymbol(id: 1, name: 'Normal Metabolizer'),
        ),
      )
    ],
  );
  final testDrugWithoutGuidelines =
      DrugWithGuidelines(id: 2, name: 'Acetaminophen', guidelines: []);
  UserData.instance.starredMediationIds = [2];

  group('integration test for the drugs page', () {
    testWidgets('test loading', (tester) async {
      when(() => mockDrugsCubit.state).thenReturn(DrugsState.loading());

      await tester.pumpWidget(
        MaterialApp(
          home: DrugPage(testDrug.id, testDrug.name, cubit: mockDrugsCubit),
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en', '')],
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('test error state', (tester) async {
      when(() => mockDrugsCubit.state).thenReturn(
        DrugsState.error(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return DrugPage(testDrug.id, testDrug.name,
                    cubit: mockDrugsCubit);
              },
            ),
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

      final BuildContext context = tester.element(find.byType(Scaffold).first);

      expect(find.text(context.l10n.err_generic), findsOneWidget);
    });

    testWidgets('test loaded page', (tester) async {
      when(() => mockDrugsCubit.state)
          .thenReturn(DrugsState.loaded(testDrug, isStarred: false));

      late BuildContext context;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return DrugPage(testDrug.id, testDrug.name,
                    cubit: mockDrugsCubit);
              },
            ),
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

      expect(find.text(testDrug.name), findsOneWidget);
      expect(find.text(testDrug.drugclass as String), findsOneWidget);
      expect(find.text(testDrug.indication as String), findsOneWidget);
      expect(
        find.text(
          testDrug.guidelines.first.cpicClassification!.toUpperCase(),
        ),
        findsOneWidget,
      );
      expect(
        find.text(testDrug.guidelines.first.recommendation as String),
        findsOneWidget,
      );
      expect(
        find.text(testDrug.guidelines.first.implication as String),
        findsOneWidget,
      );
      expect(
        find.textContaining(
          testDrug.guidelines.first.phenotype.geneSymbol.name,
        ),
        findsOneWidget,
      );
      expect(find.byType(Disclaimer), findsOneWidget);

      // test the right color of the card
      // ignore: omit_local_variable_types
      final Card card = tester.firstWidget(
        find.byKey(
          ValueKey('recommendationCard'),
        ),
      );
      expect(
        card.color,
        testDrug.guidelines.first.warningLevel?.color,
      );

      context = tester.element(find.byType(Tooltip).first);
      // test tooltips
      expect(
        find.byTooltip(context.l10n.drugs_page_tooltip_classification),
        findsOneWidget,
      );

      expect(
        find.byTooltip(context.l10n.drugs_page_tooltip_further_info),
        findsOneWidget,
      );
    });

    testWidgets('test loaded page without guidelines', (tester) async {
      when(() => mockDrugsCubit.state).thenReturn(
          DrugsState.loaded(testDrugWithoutGuidelines, isStarred: true));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return DrugPage(testDrugWithoutGuidelines.id,
                    testDrugWithoutGuidelines.name,
                    cubit: mockDrugsCubit);
              },
            ),
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

      expect(find.text(testDrugWithoutGuidelines.name), findsOneWidget);
      expect(find.byType(Disclaimer), findsNothing);
    });
  });
}
