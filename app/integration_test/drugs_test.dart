// ignore_for_file: cast_nullable_to_non_nullable

import 'package:app/common/module.dart';
import 'package:app/drug/module.dart';
import 'package:app/drug/widgets/annotation_cards/disclaimer.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

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
          externalData: [
            GuidelineExtData(
                source: 'CPIC',
                guidelineName: 'cpic name',
                guidelineUrl: 'cpic url',
                implications: {'CYP2C9': 'Normal Metabolizer'},
                recommendation: 'default dose',
                comments: 'comments')
          ],
          annotations: GuidelineAnnotations(
              recommendation: 'default dose',
              implication: 'nothing',
              warningLevel: WarningLevel.green))
    ]);
    UserData.instance.labData = [
      LabResult(
        gene: 'CYP2C9',
        phenotype: 'Normal Metabolizer',
        variant: '*1/*1',
        allelesTested: '1',
      ),
    ];
    UserData.instance.genotypeResults = {
      'CYP2C9': GenotypeResult(
        gene: UserData.instance.labData![0].gene,
        phenotype: UserData.instance.labData![0].phenotype,
        variant: UserData.instance.labData![0].variant,
        allelesTested: UserData.instance.labData![0].variant,
        lookupkey: '2',
      ),
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
  UserData.instance.activeDrugNames = ['Ibuprofen'];

  group('integration test for the drugs page', () {
    testWidgets('test loaded page', (tester) async {
      when(() => mockDrugsCubit.state)
          .thenReturn(DrugState.loaded());

      late BuildContext context;

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => ActiveDrugs(),
          child: MaterialApp(
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
        ),
      );

      expect(find.text(testDrug.name.capitalize()), findsOneWidget);
      expect(find.text(testDrug.annotations.drugclass), findsOneWidget);
      expect(find.text(testDrug.annotations.indication), findsOneWidget);
      expect(
        find.textContaining(
          testDrug.guidelines.first.annotations.recommendation,
        ),
        findsOneWidget,
      );
      expect(
        find.textContaining(testDrug.guidelines.first.annotations.implication),
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
      final RoundedCard card = tester.firstWidget(
        find.byKey(
          ValueKey('annotationCard'),
        ),
      );
      expect(
        card.color,
        testDrug.guidelines.first.annotations.warningLevel.color,
      );

      // test that drug activity can be set
      final activitySelection = tester.firstWidget(
        find.byType(DropdownButton<bool>)
      ) as DropdownButton<bool>;
      expect(activitySelection.onChanged, isNotNull);

      // test tooltips
      context = tester.element(find.byType(Tooltip).first);
      expect(
        find.byTooltip(context.l10n.drugs_page_tooltip_guideline(
          testDrug.guidelines.first.externalData.first.source
        )),
        findsOneWidget,
      );
    });

    testWidgets('test loaded page without guidelines', (tester) async {
      when(() => mockDrugsCubit.state).thenReturn(
          DrugState.loaded());

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => ActiveDrugs(),
          child: MaterialApp(
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
        ),
      );

      expect(find.text(testDrugWithoutGuidelines.name), findsOneWidget);
    });

    testWidgets('test loading', (tester) async {
      when(() => mockDrugsCubit.state).thenReturn(DrugState.loading());

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => ActiveDrugs(),
          child: MaterialApp(
            home: DrugPage(testDrug, cubit: mockDrugsCubit),
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

      final activitySelection = tester.firstWidget(
        find.byType(DropdownButton<bool>)
      ) as DropdownButton<bool>;
      expect(activitySelection.onChanged, isNull);
    });
  });
}
