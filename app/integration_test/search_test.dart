import 'package:app/common/module.dart';
import 'package:app/search/module.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSearchCubit extends MockCubit<SearchState> implements SearchCubit {}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final mockSearchCubit = MockSearchCubit();

  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.onlyPumps;
  final loadedDrugs = [
    DrugWithGuidelines(
        id: 1,
        name: 'Codeine',
        description: 'test description',
        drugclass: 'test class',
        indication: 'test',
        guidelines: []),
    DrugWithGuidelines(
        id: 2,
        name: 'Clopidogrel',
        description: 'test description',
        drugclass: 'test class',
        indication: 'test',
        guidelines: []),
    DrugWithGuidelines(
        id: 3,
        name: 'Ibuprofen',
        description: 'test description',
        drugclass: 'test class',
        indication: 'test',
        guidelines: []),
  ];
  group('integration test for the search page', () {
    testWidgets('test search page in loading state', (tester) async {
      when(() => mockSearchCubit.state)
          .thenReturn(SearchState.loading(filterStarred: false));
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
          .thenReturn(SearchState.loaded(loadedDrugs, filterStarred: false));

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
