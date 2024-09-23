import 'package:app/common/module.dart';
import 'package:app/report/module.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

import 'fixtures/guidelines/aripiprazole_cyp2d6_poor.dart';
import 'fixtures/guidelines/pazopanib_hlab5701_positive_ugt1a1_poor_guideline.dart';
import 'fixtures/set_user_data.dart';

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
                return ReportPage();
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

  Future<void> testReportContent(
    WidgetTester tester, {
      required List<Guideline> expectedGuidelines,
      required List<GenotypeResult> missingResults,
    }) async {
    expectedGuidelines.forEach(setUserDataForGuideline);
    missingResults.forEach(setGenotypeResult);
    await loadReportPage(tester);
    final expectedGenes = [
      ...expectedGuidelines.flatMap(
        (guideline) => guideline.lookupkey.keys
      ),
      ...missingResults.map((genotypeResult) => genotypeResult.gene),
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
  }

  group('integration test for the report page', () {
    testWidgets(
      'tests that genes for drugs with guidelines are shown',
      (tester) async {
        final expectedGuidelines = [
          aripiprazoleCyp2d6PoorGuideline,
          pazopanibHlab5701PositiveUgt1a1PoorGuideline,
        ];
        final missingResults = [
          GenotypeResult.missingResult('HLA-B', variant: '*15:02'),
        ];
        await testReportContent(
          tester,
          expectedGuidelines: expectedGuidelines,
          missingResults: missingResults,
        );
      },
    );
  });
}
