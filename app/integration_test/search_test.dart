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
  final loadedMedications = [
    Medication(1, 'Codeine', 'test description', 'test class', 'test'),
    Medication(2, 'Clopidogrel', 'test description', 'test class', 'test'),
    Medication(3, 'Ibuprofen', 'test description', 'test class', 'test'),
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
      when(() => mockSearchCubit.state).thenReturn(
          SearchState.loaded(loadedMedications, filterStarred: false));

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
        find.byType(MedicationCard),
        findsNWidgets(loadedMedications.length),
      );
    });
  });
}
