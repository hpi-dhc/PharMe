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

Future<void> _expectDrugContent(
  WidgetTester tester,
  MockDrugsCubit mockDrugsCubit, {
  required Drug drug,
  bool isLoading = false,
  bool expectNoGuidelines = false,
  bool expectDrugToBeActive = false,
}) async {
  when(() => mockDrugsCubit.state)
    .thenReturn(isLoading ? DrugState.loading() : DrugState.loaded());
  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (context) => ActiveDrugs(),
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return DrugPage(drug, cubit: mockDrugsCubit);
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
  // Title
  final drugName = isInhibitor(drug.name) ? '${drug.name}*' : drug.name;
  expect(
    find.text(drugName.capitalize()),
    findsOneWidget,
  );
  // Activity selection
  final activitySelection = tester.firstWidget(
    find.byType(Switch)
  ) as Switch;
  expect(activitySelection.onChanged, isLoading ? isNull : isNotNull);
  expect(activitySelection.value, expectDrugToBeActive ? isTrue : isFalse);
  // Drug details
  expect(
    find.textContaining(
      drug.annotations.drugclass
    ),
    findsOneWidget,
  );
  expect(find.text(drug.annotations.indication), findsOneWidget);
  // Guideline details
  final card = tester.firstWidget(
    find.byKey(
      ValueKey('annotationCard'),
    ),
  ) as RoundedCard;
  expect(
    card.color,
    expectNoGuidelines
      ? WarningLevel.green.color
      : drug.guidelines.first.annotations.warningLevel.color,
  );
  expect(find.byType(Disclaimer), findsOneWidget);
  String tooltipText;
  List<String> guidelineTexts;
  final context = tester.element(find.byType(Scaffold).first);
  if (expectNoGuidelines) {
    tooltipText = context.l10n.drugs_page_tooltip_guideline_missing;
    guidelineTexts = [
      context.l10n.drugs_page_guidelines_empty(drug.name),
      context.l10n.drugs_page_no_guidelines_text,
    ];
  } else {
    tooltipText = context.l10n.drugs_page_tooltip_guideline_present(
      drug.guidelines.first.externalData.first.source,
    );
    guidelineTexts = [
      drug.guidelines.first.annotations.implication,
      drug.guidelines.first.annotations.recommendation,
      ...drug.guidelineGenotypes
    ];
  }
  for (final guidelineText in guidelineTexts) {
    expect(
      find.textContaining(guidelineText),
      findsOneWidget,
    );
  }
  expect(
    find.byTooltip(tooltipText),
    findsOneWidget,
  );
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final mockDrugsCubit = MockDrugsCubit();

  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.onlyPumps;

  final drugWithProperGuideline = Drug(
    id: '6407768b92a4868065b6c466',
    version: 1,
    name: 'ibuprofen',
    rxNorm: 'RxNorm:5640',
    annotations: DrugAnnotations(
        drugclass: 'Non-steroidal anti-inflammatory drug (NSAID)',
        indication: 'Ibuprofen is used to treat pain, fever, and inflammation.',
        brandNames: ['Advil', 'Motrin']),
    guidelines: [
      Guideline(
          id: '64552859a1b68082babc8c31',
          version: 1,
          lookupkey: {
            'CYP2C9': ['2.0']
          },
          externalData: [
            GuidelineExtData(
                source: 'CPIC',
                guidelineName: 'CYP2C9 and NSAIDs',
                guidelineUrl: 'https://cpicpgx.org/guidelines/cpic-guideline-for-nsaids-based-on-cyp2c9-genotype/',
                implications: {'CYP2C9': 'Normal metabolism'},
                recommendation: 'Initiate therapy with recommended starting dose. In accordance with the prescribing information, use the lowest effective dosage for shortest duration consistent with individual patient treatment goals.',
                comments: 'n/a')
          ],
          annotations: GuidelineAnnotations(
              implication: 'You break down ibuprofen as expected.',
              recommendation: 'You can use ibuprofen at standard dose. Consult your pharmacist or doctor for more information.',
              warningLevel: WarningLevel.green))
    ]);
    UserData.instance.labData = [
      LabResult(
        gene: 'CYP2C9',
        phenotype: 'Normal Metabolizer',
        variant: '*1/*1',
        allelesTested: '"*2.*3.*5.*11"',
      ),
    ];
    UserData.instance.genotypeResults = {
      'CYP2C9': GenotypeResult(
        gene: UserData.instance.labData![0].gene,
        phenotype: UserData.instance.labData![0].phenotype,
        variant: UserData.instance.labData![0].variant,
        allelesTested: UserData.instance.labData![0].variant,
        lookupkey: '2.0',
      ),
    };
  final drugWithoutGuidelines = Drug(
    id: '64c187431006f51bc6e24959',
    version: 2,
    name: 'mirabegron',
    rxNorm: 'RxNorm:1300786',
    annotations: DrugAnnotations(
        drugclass: 'Urology drug',
        indication: 'Mirabegron is used to treat overactive bladder.',
        brandNames: ['Myrbetriq']),
    guidelines: [],
  );

  setUp(() => UserData.instance.activeDrugNames = []);

  group('integration test for the drugs page', () {
    testWidgets(
      'test that activity selection is disabled when loading',
      (tester) async {
        await _expectDrugContent(
          tester,
          mockDrugsCubit,
          drug: drugWithProperGuideline,
          isLoading: true,
        );
      },
    );

    testWidgets('test drug content with proper guideline', (tester) async {
      await _expectDrugContent(
        tester,
        mockDrugsCubit,
        drug: drugWithProperGuideline,
      );
    });

    testWidgets('test active drug content', (tester) async {
      UserData.instance.activeDrugNames = ['ibuprofen'];
      await _expectDrugContent(
        tester,
        mockDrugsCubit,
        drug: drugWithProperGuideline,
        expectDrugToBeActive: true,
      );
    });

    testWidgets('test drug content without guidelines', (tester) async {
      await _expectDrugContent(
        tester,
        mockDrugsCubit,
        drug: drugWithoutGuidelines,
        expectNoGuidelines: true,
      );
    });
  });
}
