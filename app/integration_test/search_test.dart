import 'package:app/common/module.dart';
import 'package:app/search/module.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'fixtures/drugs/with_any_fallback_guideline.dart';
import 'fixtures/drugs/with_proper_guideline.dart';
import 'fixtures/drugs/without_guidelines.dart';
import 'mocks/drug_list_cubit.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final mockDrugListCubit = MockDrugListCubit();
  UserData.instance.labData = [];

  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.onlyPumps;
  final loadedDrugs = [
    drugWithProperGuideline,
    drugWithoutGuidelines,
    drugWithAnyFallbackGuideline,
  ];
  group('integration test for the search page', () {
    testWidgets('test search page in loading state', (tester) async {
      when(() => mockDrugListCubit.state).thenReturn(DrugListState.loading());
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => ActiveDrugs(),
          child: BlocProvider.value(
            value: mockDrugListCubit,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              home: SearchPage(cubit: mockDrugListCubit),
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: [Locale('en', '')],
            ),
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator, skipOffstage: false), findsOneWidget);
    });

    testWidgets('test search page in loaded state', (tester) async {
      when(() => mockDrugListCubit.state)
          .thenReturn(DrugListState.loaded(loadedDrugs, FilterState.initial()));

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => ActiveDrugs(),
          child: BlocProvider.value(
            value: mockDrugListCubit,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              home: SearchPage(cubit: mockDrugListCubit),
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: [Locale('en', '')],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byType(DrugCard, skipOffstage: false),
        findsNWidgets(loadedDrugs.length),
      );
    });
  });
}
