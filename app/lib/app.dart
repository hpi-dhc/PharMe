import 'package:flutter_localizations/flutter_localizations.dart';

import 'common/module.dart';

class PharMeApp extends StatelessWidget {
  factory PharMeApp() => _instance;

  PharMeApp._();

  static final _instance = PharMeApp._();
  static GlobalKey<NavigatorState> get navigatorKey =>
      _instance._appRouter.navigatorKey;

  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return ErrorHandler(
      appRouter: _appRouter,
      child: LifecycleObserver(
        appRouter: _appRouter,
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routeInformationParser: _appRouter.defaultRouteParser(),
          routerDelegate: _appRouter.delegate(deepLinkBuilder: getInitialRoute),
          theme: PharMeTheme.light,
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
  }
}
