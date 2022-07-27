import 'package:app/common/module.dart';
import 'package:app/search/pages/cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

class MockSearchCubit extends MockCubit<SearchState> implements SearchCubit {}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.onlyPumps;

  late SearchCubit searchCubit;

  setUp(() {
    searchCubit = MockSearchCubit();
  });

  group('integration test for the faq page', () {
    final appRouter = AppRouter();
    final searchWidget = MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routeInformationParser: appRouter.defaultRouteParser(),
      routerDelegate: appRouter.delegate(
        initialDeepLink: 'main/search',
      ),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale('en', '')],
    );

    testWidgets('test search page', (tester) async {
      await tester.pumpWidget(BlocProvider.value(
        value: searchCubit,
        child: searchWidget,
      ));
      await tester.pumpAndSettle();
      print('5');
    });
  });
}
