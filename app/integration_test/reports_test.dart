import 'package:app/common/module.dart';
import 'package:app/reports/pages/cubit.dart';
import 'package:app/reports/pages/reports.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';

class MockReportsCubit extends MockCubit<ReportsState> implements ReportsCubit {
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final mockReportsCubit = MockReportsCubit();

  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.onlyPumps;

  final testMedications = [
    MedicationWithGuidelines(
      id: 1,
      name: 'Codeine',
      drugclass: 'Pain killer',
      guidelines: [
        Guideline(
          id: 1,
          warningLevel: 'danger',
          recommendation: 'Dont take too much from this medication',
          implication:
              'Because of your gene, you cannot digest this medication so well',
          cpicGuidelineUrl: 'some url',
          cpicClassification: 'strong',
          phenotype: Phenotype(
            id: 1,
            geneResult: GeneResult(id: 1, name: 'CYP2C9'),
            geneSymbol: GeneSymbol(id: 1, name: 'Normal Metabolizer'),
          ),
        )
      ],
    ),
    MedicationWithGuidelines(
      id: 2,
      name: 'Clopidogrel',
      drugclass: 'Blood thinner',
      guidelines: [
        Guideline(
          id: 1,
          warningLevel: 'warning',
          recommendation: 'Dont take too much from this medication',
          implication:
              'Because of your gene, you cannot digest this medication so well',
          cpicGuidelineUrl: 'some url',
          cpicClassification: 'strong',
          phenotype: Phenotype(
            id: 1,
            geneResult: GeneResult(id: 1, name: 'CYP2C9'),
            geneSymbol: GeneSymbol(id: 1, name: 'Normal Metabolizer'),
          ),
        )
      ],
    ),
    MedicationWithGuidelines(
      id: 3,
      name: 'Some medication',
      drugclass: 'Blood thinner',
      guidelines: [
        Guideline(
          id: 1,
          warningLevel: 'warning',
          recommendation: 'Dont take too much from this medication',
          implication:
              'Because of your gene, you cannot digest this medication so well',
          cpicGuidelineUrl: 'some url',
          cpicClassification: 'strong',
          phenotype: Phenotype(
            id: 1,
            geneResult: GeneResult(id: 1, name: 'CYP2C9'),
            geneSymbol: GeneSymbol(id: 1, name: 'Normal Metabolizer'),
          ),
        )
      ],
    ),
  ];

  group('integration tests for the reports page', () {
    testWidgets('test loading state', (tester) async {
      when(() => mockReportsCubit.state).thenReturn(ReportsState.loading());

      await tester.pumpWidget(
        MaterialApp(
          home: ReportsPage(cubit: mockReportsCubit),
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
      when(() => mockReportsCubit.state).thenReturn(ReportsState.error());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ReportsPage(cubit: mockReportsCubit)),
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

    testWidgets('test loaded state', (tester) async {
      when(() => mockReportsCubit.state).thenReturn(
        ReportsState.loaded(testMedications),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ReportsPage(cubit: mockReportsCubit)),
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en', '')],
        ),
      );

      expect(find.byType(SliverPersistentHeader), findsOneWidget);

      expect(find.byType(ReportCard), findsNWidgets(3));

      final result = tester
          .widgetList(find.descendant(
              of: find.byType(ReportCard), matching: find.byType(Card)))
          .toList();

      for (var i = 0; i < result.length; i++) {
        expect(
          (result[i] as Card).color,
          recommendationColorMap[
              testMedications[i].guidelines.first.warningLevel],
        );
      }
    });
  });
}
