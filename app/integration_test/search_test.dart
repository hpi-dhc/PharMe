import 'package:app/common/module.dart';
import 'package:app/search/module.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSearchCubit extends MockCubit<SearchState> implements SearchCubit {
  @override
  bool get filterActive => false;
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final mockSearchCubit = MockSearchCubit();

  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.onlyPumps;
  final loadedDrugs = [
    Drug(
        id: '1',
        version: 1,
        name: 'Ibuprofen',
        rxNorm: 'rxnorm',
        annotations: DrugAnnotations(
            drugclass: 'NSAID',
            indication: 'indication',
            brandNames: ['brand name', 'another brand name']),
        guidelines: []),
    Drug(
        id: '2',
        version: 1,
        name: 'Codeine',
        rxNorm: 'rxnorm',
        annotations: DrugAnnotations(
            drugclass: 'Pain killer',
            indication: 'indication',
            brandNames: ['brand name', 'another brand name']),
        guidelines: []),
    Drug(
        id: '3',
        version: 1,
        name: 'Amitryptiline',
        rxNorm: 'rxnorm',
        annotations: DrugAnnotations(
            drugclass: 'Antidepressant',
            indication: 'indication',
            brandNames: ['brand name', 'another brand name']),
        guidelines: []),
  ];
  group('integration test for the search page', () {
    testWidgets('test search page in loading state', (tester) async {
      when(() => mockSearchCubit.state).thenReturn(SearchState.loading());
      await tester.pumpWidget(BlocProvider.value(
        value: mockSearchCubit,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: SearchPage(cubit: mockSearchCubit),
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en', '')],
        ),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('test search page in loaded state', (tester) async {
      when(() => mockSearchCubit.state)
          .thenReturn(SearchState.loaded(loadedDrugs, loadedDrugs));

      await tester.pumpWidget(BlocProvider.value(
        value: mockSearchCubit,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: SearchPage(cubit: mockSearchCubit),
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en', '')],
        ),
      ));
      await tester.pumpAndSettle();

      expect(
        find.byType(DrugCard),
        findsNWidgets(loadedDrugs.length),
      );
    });
  });
}
