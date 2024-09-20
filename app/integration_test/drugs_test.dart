import 'package:app/common/module.dart';
import 'package:app/drug/module.dart';
import 'package:app/drug/widgets/annotation_cards/disclaimer.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'fixtures/drugs/with_any_fallback_guideline.dart';
import 'fixtures/drugs/with_any_not_handled_guideline.dart';
// import 'fixtures/drugs/with_multiple_any_not_handled_fallback_guidelines.dart';
import 'fixtures/drugs/with_proper_guideline.dart';
import 'fixtures/drugs/without_guidelines.dart';
import 'fixtures/set_user_data.dart';
import 'mocks/drug_cubit.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.onlyPumps;

  late MockDrugsCubit mockDrugsCubit;

  setUp(() {
    UserData.instance.activeDrugNames = [];
    UserData.instance.labData = null;
    UserData.instance.genotypeResults = null;
    setUserDataForGuideline(drugWithProperGuideline.guidelines.first);
    mockDrugsCubit = MockDrugsCubit();
  });

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

    testWidgets('test drug content with any fallback guideline', (tester) async {
      await _expectDrugContent(
        tester,
        mockDrugsCubit,
        drug: drugWithAnyFallbackGuideline,
      );
    });

    testWidgets(
      'test drug content with any not handled fallback guidelines',
      (tester) async {
        Future<void> testPerGuideline(Drug drug) async {
          for (
            final guideline in drug.guidelines
          ) {
            setUserDataForGuideline(guideline);
            await _expectDrugContent(
              tester,
              mockDrugsCubit,
              drug: drug,
              guideline: guideline,
            );
          }
        }
        await testPerGuideline(drugWithAnyNotHandledFallbackGuideline);
        // await testPerGuideline(drugWithMultipleAnyNotHandledFallbackGuidelines);
      },
    );
  });
}

Future<void> _expectDrugContent(
  WidgetTester tester,
  MockDrugsCubit mockDrugsCubit, {
  required Drug drug,
  bool isLoading = false,
  bool expectNoGuidelines = false,
  bool expectDrugToBeActive = false,
  Guideline? guideline,
}) async {
  when(() => mockDrugsCubit.state)
    .thenReturn(isLoading ? DrugState.loading() : DrugState.loaded());
  final relevantGuideline = guideline ?? drug.guidelines.first;
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
      : relevantGuideline.annotations.warningLevel.color,
  );
  expect(find.byType(Disclaimer), findsOneWidget);
  final context = tester.element(find.byType(Scaffold).first);
  if (expectNoGuidelines) {
    expect(
      find.byTooltip(context.l10n.drugs_page_tooltip_guideline_missing),
      findsOneWidget,
    );
    expect(
      find.text(context.l10n.drugs_page_guidelines_empty(drug.name)),
      findsOneWidget,
    );
    expect(
      find.text(context.l10n.drugs_page_no_guidelines_text),
      findsOneWidget,
    );
  } else {
    expect(
      find.byTooltip(context.l10n.drugs_page_tooltip_guideline_present(
        relevantGuideline.externalData.first.source,
      )),
      findsOneWidget,
    );
    expect(
      find.text(relevantGuideline.annotations.implication),
      findsOneWidget,
    );
    expect(
      find.textContaining(relevantGuideline.annotations.recommendation),
      findsOneWidget,
    );
    for (final genotypeKey in drug.guidelineGenotypes) {
      expect(
        find.text(genotypeKey),
        findsOneWidget,
      );
    }
  }
}
