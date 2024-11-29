import 'package:app/common/module.dart';
import 'package:app/drug/module.dart';
import 'package:app/drug/widgets/annotation_cards/disclaimer.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'fixtures/drugs/aripiprazole_with_any_not_handled_guideline.dart';
import 'fixtures/drugs/ibuprofen_with_proper_guideline.dart';
import 'fixtures/drugs/mirabegron_without_guidelines.dart';
import 'fixtures/drugs/pazopanib_with_multiple_any_not_handled_fallback_guidelines.dart';
import 'fixtures/drugs/rosuvastatin_with_no_result_guideline.dart';
import 'fixtures/drugs/warfarin_with_any_fallback_guideline.dart';
import 'fixtures/set_app_data.dart';
import 'mocks/drug_cubit.dart';

class _TestCase {
  _TestCase({
    required this.description,
    required this.drug,
    this.expectNoMappedGuidelines = false,
    this.explicitNoResult,
    this.explicitLookups,
  });

  final String description;
  final Drug drug;
  final bool expectNoMappedGuidelines;
  final List<String>? explicitNoResult;
  final Map<String, String>? explicitLookups;
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.onlyPumps;

  late MockDrugsCubit mockDrugsCubit;

  setUp(() {
    UserData.instance.activeDrugNames = [];
    UserData.instance.labData = null;
    UserData.instance.genotypeResults = null;
    setAppData(
      drug: ibuprofenWithProperGuideline,
      guideline: ibuprofenWithProperGuideline.guidelines.first,
    );
    mockDrugsCubit = MockDrugsCubit();
  });

  Future<void> expectDrugContent(
    WidgetTester tester, {
    required Drug drug,
    bool isLoading = false,
    bool expectNoMappedGuidelines = false,
    bool expectDrugToBeActive = false,
    bool expectNoBrandNames = false,
    List<String>? explicitNoResult,
    Map<String, String>? explicitLookups,
    Guideline? guideline,
  }) async {
    Guideline? relevantGuideline;
    if (guideline != null || drug.guidelines.isNotEmpty) {
      relevantGuideline = guideline ?? drug.guidelines.first;
      setAppData(
        drug: drug,
        guideline: relevantGuideline,
        explicitNoResult: explicitNoResult,
        explicitLookups: explicitLookups,
      );
    }
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
    await tester.tap(find.byKey(Key('drug-information-expansion-tile')));
    await tester.pumpAndSettle();
    // Drug details
    expect(
      find.textContaining(
        drug.annotations.drugclass,
        skipOffstage: false,
      ),
      findsOneWidget,
    );
    expect(
      find.text(drug.annotations.indication, skipOffstage: false),
      findsOneWidget,
    );
    // Guideline details
    final card = tester.firstWidget(
      find.byKey(
        ValueKey('annotationCard'),
      ),
    ) as RoundedCard;
    expect(find.byType(Disclaimer), findsOneWidget);
    final sourcesSection = find.byKey(Key('sourceCard'));
    final context = tester.element(find.byType(Scaffold).first);
    if (expectNoBrandNames) {
      expect(
        find.textContaining(context.l10n.drug_item_brand_names),
        findsNothing,
      );
    } else {
      expect(
        find.textContaining(context.l10n.drug_item_brand_names),
        findsOneWidget,
      );
      for (final brandName in drug.annotations.brandNames) {
        expect(
          find.textContaining(brandName),
          findsOneWidget,
        );
      }
    }
    if (expectNoMappedGuidelines) {
      expect(card.color, WarningLevel.green.color);
      expect(
        find.byTooltip(context.l10n.drugs_page_tooltip_guideline_missing),
        findsOneWidget,
      );
      expect(
        find.textContaining(context.l10n.drugs_page_no_guidelines_text),
        findsOneWidget,
      );
      if (drug.guidelines.isNotEmpty) {
        expect(sourcesSection, findsOneWidget);
      } else {
        expect(sourcesSection, findsNothing);
      }
      if (drug.guidelines.isEmpty) {
        expect(
          find.text(context.l10n.drugs_page_guidelines_empty(drug.name)),
          findsOneWidget,
        );
      }
    } else {
      expect(card.color, relevantGuideline!.annotations.warningLevel.color);
      expect(
        find.byTooltip(context.l10n.drugs_page_tooltip_guideline_present(
          relevantGuideline.externalData.first.source,
        )),
        findsOneWidget,
      );
      expect(
        find.textContaining(relevantGuideline.annotations.implication),
        findsOneWidget,
      );
      expect(
        find.textContaining(relevantGuideline.annotations.recommendation),
        findsOneWidget,
      );
      expect(sourcesSection, findsOneWidget);
    }
    if (!expectNoMappedGuidelines || explicitLookups != null) {
      for (final genotypeKey in drug.guidelineGenotypes) {
        if (genotypeKey.contains(' ')) {
          expect(
            find.textContaining(genotypeKey.split(' ').first),
            findsOneWidget,
          );
        } else {
          expect(
            find.text(genotypeKey),
            findsOneWidget,
          );
        }
      }
    }
    final noResultGenes = [
      ...(explicitNoResult ?? []),
      ...(relevantGuideline?.lookupkey.entries.filter(
        (lookupEntry) => lookupEntry.value.any(
          (variant) => variant == SpecialLookup.noResult.value
        )
      ).map((lookupEntry) => lookupEntry.key).toList() ?? [])
    ];
    if (noResultGenes.isNotEmpty) {
      for (final noResultGene in noResultGenes) {
        final geneRowFinder = find.ancestor(
          of: find.text(noResultGene),
          matching: find.byType(Table),
        );
        expect(
          find.descendant(
            of: geneRowFinder,
            matching: find.textContaining(context.l10n.general_not_tested),
          ),
          findsOneWidget,
        );
      }
    }
  }

  Future<void> runTestCases(List<_TestCase> testCases) async {
    for (final (testCase) in testCases) {
      final description = 'test drug content with ${testCase.description}';
      final drug = testCase.drug;
      for (final (index, guideline) in drug.guidelines.indexed) {
        // Run per case to ensure clean setup
        final caseDescription = drug.guidelines.length > 1
          ? '$description (${index + 1}/${drug.guidelines.length})'
          : description;
        testWidgets(
          caseDescription,
          (tester) async {        
            await expectDrugContent(
              tester,
              drug: drug,
              guideline: guideline,
              expectNoMappedGuidelines: testCase.expectNoMappedGuidelines,
              explicitNoResult: testCase.explicitNoResult,
              explicitLookups: testCase.explicitLookups,
            );
          },
        );
      }
    }
  }

  group('integration test for the drugs page', () {
    testWidgets(
      'test that activity selection is disabled when loading',
      (tester) async {
        await expectDrugContent(
          tester,
          drug: ibuprofenWithProperGuideline,
          isLoading: true,
        );
      },
    );

    testWidgets('test drug content with guideline', (tester) async {
      await expectDrugContent(
        tester,
        drug: ibuprofenWithProperGuideline,
      );
    });

    testWidgets('test active drug content', (tester) async {
      UserData.instance.activeDrugNames = ['ibuprofen'];
      await expectDrugContent(
        tester,
        drug: ibuprofenWithProperGuideline,
        expectDrugToBeActive: true,
      );
    });

    testWidgets('test drug without brand names', (tester) async {
      final ibuprofenWithoutBrandNames = Drug(
        id: ibuprofenWithProperGuideline.id,
        version: ibuprofenWithProperGuideline.version,
        name: ibuprofenWithProperGuideline.name,
        rxNorm: ibuprofenWithProperGuideline.rxNorm,
        annotations: DrugAnnotations(
          drugclass: ibuprofenWithProperGuideline.annotations.drugclass,
          indication: ibuprofenWithProperGuideline.annotations.indication,
          brandNames: [], // removed for test
        ),
        guidelines: ibuprofenWithProperGuideline.guidelines,
      );
      await expectDrugContent(
        tester,
        drug: ibuprofenWithoutBrandNames,
        expectNoBrandNames: true,
      );
    });

    group('test missing guidelines', () {
      runTestCases([
        _TestCase(
          description: 'no guidelines',
          drug: mirabegronWithoutGuidelines,
          expectNoMappedGuidelines: true,
        ),
        _TestCase(
          description: 'no result and no explicit guideline',
          drug: ibuprofenWithProperGuideline,
          explicitNoResult: [
            ibuprofenWithProperGuideline.guidelines.first.lookupkey.keys.first,
          ],
          expectNoMappedGuidelines: true,
        ),
        _TestCase(
          description: 'no result and no mappable lookup',
          drug: ibuprofenWithProperGuideline,
          explicitLookups: {
            ibuprofenWithProperGuideline.guidelines.first.lookupkey.keys.first:
              '0.0',
          },
          expectNoMappedGuidelines: true,
        ),
        _TestCase(
          description: 'mappable no result',
          drug: rosuvastatinWithNoResultGuidelines,
          expectNoMappedGuidelines: false,
        ),
      ]);
    });

    group('test special guidelines', () {
      runTestCases([
        _TestCase(
          description: 'any fallback guideline',
          drug: warfarinWithAnyFallbackGuideline,
        ),
        _TestCase(
          description: 'any not handled fallback guideline',
          drug: aripiprazoleWithAnyNotHandledFallbackGuideline,
        ),
        _TestCase(
          description: 'multiple any not handled fallback guidelines',
          drug: pazopanibWithMultipleAnyNotHandledFallbackGuidelines,
        )
      ]);
    });
  });
}
