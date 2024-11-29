import 'package:app/common/module.dart';
import 'package:app/report/module.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

import 'fixtures/drugs/aripiprazole_with_any_not_handled_guideline.dart';
import 'fixtures/drugs/ibuprofen_with_proper_guideline.dart';
import 'fixtures/drugs/oxcarbazepine_with_hlab1502_guideline.dart';
import 'fixtures/drugs/pazopanib_with_multiple_any_not_handled_fallback_guidelines.dart';
import 'fixtures/guidelines/aripiprazole_cyp2d6_poor.dart';
import 'fixtures/guidelines/ibuprofen_cyp2c9_normal.dart';
import 'fixtures/guidelines/pazopanib_hlab5701_positive_ugt1a1_poor.dart';
import 'fixtures/set_app_data.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.onlyPumps;

  setUp(() {
    UserData.instance.labData = null;
    UserData.instance.genotypeResults = null;
  });

  Future<void> loadReportPage(WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => ActiveDrugs(),
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ReportPage(onlyShowWholeReport: true);
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
  }

  Finder findGeneCard(String gene) {
    return find.ancestor(
      of: find.textContaining(gene, skipOffstage: false),
      matching: find.byType(GeneCard, skipOffstage: false),
    );
  }

  Future<void> testReportContent(
    WidgetTester tester, {
      required Map<Drug, Guideline?> testData,
      Map<Drug, Guideline>? missingLookupData,
    }) async {
    for (final drug in testData.keys) {
      setAppData(drug: drug, guideline: testData[drug]);
    }
    if (missingLookupData != null) {
      for (final drug in missingLookupData.keys) {
        setAppData(
          drug: drug,
          guideline: missingLookupData[drug],
          missingLookup: true,
        );
      }
    }
    await loadReportPage(tester);
    final expectedGenesWithGuidelines = testData.values.filterNotNull().flatMap(
      (guideline) => guideline.lookupkey.keys
    );
    final expectedGenesWithUnmappableGuideline =
      missingLookupData?.values.flatMap(
        (guideline) => guideline.lookupkey.keys
      ) ?? [];
    final expectedNotTestedGenes = testData.keys.filter(
        (drug) => testData[drug] == null
      ).map(
        (drug) => UserData.instance.genotypeResults![GenotypeKey(
          drug.guidelines.first.lookupkey.keys.first,
          drug.guidelines.first.lookupkey.values.first.first,
        ).value]?.gene
      ).filterNotNull();
    final expectedGenes = <String>[
      ...expectedGenesWithGuidelines,
      ...expectedGenesWithUnmappableGuideline,
      ...expectedNotTestedGenes,
    ];
    expect(
      find.byType(GeneCard, skipOffstage: false),
      findsNWidgets(expectedGenes.length),
    );
    for (final gene in expectedGenes.toSet()) {
      final expectedGeneOccurrences =
        expectedGenes.count((expectedGene) => expectedGene == gene);
      expect(
        find.textContaining(gene, skipOffstage: false),
        findsNWidgets(expectedGeneOccurrences),
      );
    }
    if (missingLookupData != null) {
      for (final guideline in missingLookupData.values) {
        for (final lookup in guideline.lookupkey.entries) {
          final gene = lookup.key;
          final testPhenotype = lookup.value.first;
          final geneCard = findGeneCard(gene);
          expect(
            find.descendant(
              of: geneCard,
              matching: find.text(testPhenotype, skipOffstage: false)
            ),
            findsOneWidget,
          );
        }
      }
    }
    final context = tester.element(find.byType(Scaffold).first);
    if (expectedNotTestedGenes.isNotEmpty) {
      for (final gene in expectedNotTestedGenes) {
        final geneCardsFinder = findGeneCard(gene);
        expect(
          find.descendant(
            of: geneCardsFinder,
            matching:
              find.text(context.l10n.general_not_tested, skipOffstage: false),
            skipOffstage: false,
          ),
          findsOneWidget,
        );
        final geneCard = tester.widgetList(geneCardsFinder).last as GeneCard;
        expect(geneCard.color, PharMeTheme.onSurfaceColor);
      }
    }
  }

  group('integration test for the report page', () {
    testWidgets(
      'tests that genes for drugs with guidelines are shown',
      (tester) async {
        final testData = {
          aripiprazoleWithAnyNotHandledFallbackGuideline:
            aripiprazoleCyp2d6PoorGuideline,
          pazopanibWithMultipleAnyNotHandledFallbackGuidelines:
            pazopanibHlab5701PositiveUgt1a1PoorGuideline,
          oxcarbazepineWithHlab1502Guideline: null,
        };
        final missingLookupData = {
          ibuprofenWithProperGuideline: ibuprofenCyp2c9NormalGuideline,
        };
        await testReportContent(
          tester,
          testData: testData,
          missingLookupData: missingLookupData,
        );
      },
    );
  });
}
