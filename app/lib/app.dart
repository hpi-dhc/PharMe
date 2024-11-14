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
          routerConfig: _appRouter.config(
            deepLinkBuilder: (deepLink) async {
              final queryParameters = deepLink.uri.queryParameters;
              final isDeepLinkShareRequest = deepLink.path == '' &&
                queryParameters.containsKey('provider_url');
              if (isDeepLinkShareRequest) {
                MetaData.instance.deepLinkSharePublishUrl =
                  queryParameters['provider_url'];
                await MetaData.save();
                if (_appRouter.currentPath != '/') {
                  return DeepLink.path(_appRouter.currentPath);
                }
              }
              // default route
              return getInitialRoute();
            },
          ),
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
