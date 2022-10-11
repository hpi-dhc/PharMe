// ignore_for_file: cast_nullable_to_non_nullable

import 'package:app/common/module.dart';
import 'package:app/common/pages/medications/widgets/module.dart';
import 'package:app/search/module.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';

class MockMedicationsCubit extends MockCubit<MedicationsState>
    implements MedicationsCubit {}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final mockMedicationsCubit = MockMedicationsCubit();

  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.onlyPumps;

  final testMedication = MedicationWithGuidelines(
    id: 1,
    name: 'Codeine',
    drugclass: 'Pain killer',
    indication: 'Codeine is used to treat pain and coughing.',
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
  );
  final testMedicationWithoutGuidelines = MedicationWithGuidelines(
    id: 2,
    name: 'Acetaminophen',
    guidelines: []
  );
  UserData.instance.starredMediationIds = [2];

  group('integration test for the medications page', () {
    testWidgets('test loading', (tester) async {
      when(() => mockMedicationsCubit.state)
          .thenReturn(MedicationsState.loading());

      await tester.pumpWidget(
        MaterialApp(
          home: MedicationPage(1, cubit: mockMedicationsCubit),
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
      when(() => mockMedicationsCubit.state).thenReturn(
        MedicationsState.error(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return MedicationPage(1, cubit: mockMedicationsCubit);
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
      when(() => mockMedicationsCubit.state)
          .thenReturn(MedicationsState.loaded(testMedication, isStarred: false));

      late BuildContext context;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return MedicationPage(1, cubit: mockMedicationsCubit);
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

      expect(find.text(testMedication.name), findsOneWidget);
      expect(find.text(testMedication.drugclass as String), findsOneWidget);
      expect(find.text(testMedication.indication as String), findsOneWidget);
      expect(
        find.text(
          testMedication.guidelines.first.cpicClassification!.toUpperCase(),
        ),
        findsOneWidget,
      );
      expect(
        find.text(testMedication.guidelines.first.recommendation as String),
        findsOneWidget,
      );
      expect(
        find.text(testMedication.guidelines.first.implication as String),
        findsOneWidget,
      );
      expect(
        find.textContaining(
          testMedication.guidelines.first.phenotype.geneSymbol.name,
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
        recommendationColorMap[testMedication.guidelines.first.warningLevel],
      );

      context = tester.element(find.byType(Tooltip).first);
      // test tooltips
      expect(
        find.byTooltip(context.l10n.medications_page_tooltip_classification),
        findsOneWidget,
      );

      expect(
        find.byTooltip(context.l10n.medications_page_tooltip_further_info),
        findsOneWidget,
      );
    });

    testWidgets('test loaded page without guidelines', (tester) async {
      when(() => mockMedicationsCubit.state)
          .thenReturn(MedicationsState.loaded(testMedicationWithoutGuidelines, isStarred: true));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return MedicationPage(2, cubit: mockMedicationsCubit);
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

      expect(find.text(testMedicationWithoutGuidelines.name), findsOneWidget);
      expect(find.byType(Disclaimer), findsNothing);
    });
  });
}
