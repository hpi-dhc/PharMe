// ignore_for_file: cast_nullable_to_non_nullable

import 'package:app/common/module.dart';
import 'package:app/common/pages/drug/widgets/module.dart';
import 'package:app/search/module.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDrugsCubit extends MockCubit<DrugState> implements DrugCubit {}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final mockDrugsCubit = MockDrugsCubit();

  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.onlyPumps;

  final testDrug = Drug(
      id: '1',
      version: 1,
      name: 'Ibuprofen',
      rxNorm: 'rxnorm',
      annotations: DrugAnnotations(
          drugclass: 'NSAID',
          indication: 'indication',
          brandNames: ['brand name', 'another brand name']),
      guidelines: [
        Guideline(
            id: '1',
            version: 1,
            lookupkey: {
              'CYP2C9': ['2']
            },
            cpicData: GuidelineCpicData(
                guidelineName: 'cpic name',
                guidelineUrl: 'cpic url',
                implications: {'CYP2C9': 'normal metabolization'},
                recommendation: 'default dose',
                comments: 'comments'),
            annotations: GuidelineAnnotations(
                recommendation: 'default dose',
                implication: 'nothing',
                warningLevel: WarningLevel.green))
      ]);
  UserData.instance.lookups = {
    'CYP2C9': CpicPhenotype(
        geneSymbol: 'CYP2C9',
        phenotype: 'Normal Metabolizer',
        genotype: '*1/*1',
        lookupkey: 'Normal Metabolizer')
  };
  UserData.instance.diplotypes = {
    'CYP2C9': Diplotype(
        gene: 'CYP2C9',
        resultType: 'Diplotype',
        phenotype: 'Normal Metabolizer',
        genotype: '*1/*1',
        allelesTested: '1')
  };
  final testDrugWithoutGuidelines = Drug(
    id: '2',
    version: 1,
    name: 'Codeine',
    rxNorm: 'rxnorm',
    annotations: DrugAnnotations(
        drugclass: 'Pain killer',
        indication: 'indication',
        brandNames: ['brand name', 'another brand name']),
    guidelines: [],
  );
  UserData.instance.starredDrugIds = ['1'];

  group('integration test for the drugs page', () {
    testWidgets('test loading', (tester) async {
      when(() => mockDrugsCubit.state).thenReturn(DrugState.loading());

      await tester.pumpWidget(
        MaterialApp(
          home: DrugPage(testDrug, cubit: mockDrugsCubit),
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
        DrugState.error(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return DrugPage(testDrug, cubit: mockDrugsCubit);
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
          .thenReturn(DrugState.loaded(testDrug, isStarred: false));

      late BuildContext context;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return DrugPage(testDrug, cubit: mockDrugsCubit);
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

      expect(find.text(testDrug.name.capitalize()), findsOneWidget);
      expect(find.text(testDrug.annotations.drugclass), findsOneWidget);
      expect(find.text(testDrug.annotations.indication), findsOneWidget);
      expect(
        find.text(testDrug.guidelines.first.annotations.recommendation),
        findsOneWidget,
      );
      expect(
        find.text(testDrug.guidelines.first.annotations.implication),
        findsOneWidget,
      );
      expect(
        find.textContaining(
          testDrug.guidelines.first.lookupkey.keys.first,
        ),
        findsOneWidget,
      );
      expect(find.byType(Disclaimer), findsOneWidget);

      // test the right color of the card
      // ignore: omit_local_variable_types
      final Card card = tester.firstWidget(
        find.byKey(
          ValueKey('annotationCard'),
        ),
      );
      expect(
        card.color,
        testDrug.guidelines.first.annotations.warningLevel.color,
      );

      context = tester.element(find.byType(Tooltip).first);
      // test tooltips
      expect(
        find.byTooltip(context.l10n.drugs_page_tooltip_guideline),
        findsOneWidget,
      );
    });

    testWidgets('test loaded page without guidelines', (tester) async {
      when(() => mockDrugsCubit.state).thenReturn(
          DrugState.loaded(testDrugWithoutGuidelines, isStarred: true));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return DrugPage(
                  testDrugWithoutGuidelines,
                  cubit: mockDrugsCubit,
                );
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
