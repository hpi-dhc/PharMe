import 'package:flutter_localizations/flutter_localizations.dart';

import '../models/metadata.dart';
import '../module.dart' hide MetaData;

class PharMeApp extends StatelessWidget {
  factory PharMeApp() => _instance;

  PharMeApp._({Key? key}) : super(key: key);

  static final _instance = PharMeApp._();
  static GlobalKey<NavigatorState> get navigatorKey =>
      _instance._appRouter.navigatorKey;

  final _appRouter = AppRouter();
  final _isLoggedIn = MetaData.instance.isLoggedIn ?? false;
  final _onboardingDone = MetaData.instance.onboardingDone ?? false;
  final _initialDrugSelectionDone =
    MetaData.instance.initialDrugSelectionDone ?? false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routeInformationParser: _appRouter.defaultRouteParser(),
      routerDelegate: _appRouter.delegate(
        initialDeepLink: !_isLoggedIn
          ? 'login'
          : !_onboardingDone
            ? 'onboarding'
            : !_initialDrugSelectionDone
              ? 'drugselection'
              : 'main',
      ),
      theme: PharMeTheme.light,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale('en', '')],
    );
  }
}
