import 'package:app/common/module.dart';
import 'package:app/login/module.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'mocks/login_cubit.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final mockLoginCubit = MockLoginCubit();

  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.onlyPumps;

  group('integration tests for the login page', () {
    testWidgets('test loading state', (tester) async {
      when(() => mockLoginCubit.state).thenReturn(
        LoginState.loadingUserData(null),
      );

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => ActiveDrugs(),
            child: MaterialApp(
            home: LoginPage(cubit: mockLoginCubit),
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

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('test error state', (tester) async {
      when(() => mockLoginCubit.state).thenReturn(
        LoginState.error('Some error'),
      );

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => ActiveDrugs(),
          child: MaterialApp(
            home: LoginPage(cubit: mockLoginCubit),
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

      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);

      expect(find.text('Some error'), findsOneWidget);
    });

    testWidgets('test loaded state', (tester) async {
      when(() => mockLoginCubit.state).thenReturn(
        LoginState.loadedUserData(),
      );

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => ActiveDrugs(),
          child: MaterialApp(
            home: Scaffold(body: LoginPage(cubit: mockLoginCubit)),
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

      final BuildContext context = tester.element(find.byType(Scaffold).first);

      expect(find.byIcon(Icons.check_circle_outline_rounded), findsOneWidget);
      expect(find.text(context.l10n.auth_success), findsOneWidget);
    });

    testWidgets('test initial state', (tester) async {
      when(() => mockLoginCubit.state).thenReturn(
        LoginState.initial(),
      );

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => ActiveDrugs(),
          child: MaterialApp(
            home: Scaffold(body: LoginPage(cubit: mockLoginCubit)),
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

      expect(find.byType(DropdownButtonHideUnderline), findsOneWidget);

      expect(find.byType(DropdownMenuItem<String>), findsNWidgets(labs.length));
    });
  });
}
