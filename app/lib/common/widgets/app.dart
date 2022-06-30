import 'package:flutter_localizations/flutter_localizations.dart';

import '../module.dart' hide MetaData;

class PharmeApp extends StatelessWidget {
  PharmeApp({Key? key}) : super(key: key);

  final _appRouter = AppRouter();
  final _isLoggedIn = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: _appRouter.defaultRouteParser(),
      routerDelegate: _appRouter.delegate(
        initialDeepLink: _isLoggedIn ? 'main' : 'onboarding',
      ),
      theme: PharmeTheme.light,
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
