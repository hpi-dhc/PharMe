import 'package:flutter_localizations/flutter_localizations.dart';

import 'common/module.dart';

class PharMeApp extends StatelessWidget {
  factory PharMeApp() => _instance;

  PharMeApp._();

  static final _instance = PharMeApp._();
  static GlobalKey<NavigatorState> get navigatorKey =>
      _instance._appRouter.navigatorKey;

  final _appRouter = AppRouter();

  Future<void> _setDeepLinkSharePublishUrl(PlatformDeepLink deepLink) async {
    final queryParameters = deepLink.uri.queryParameters;
    MetaData.instance.deepLinkSharePublishUrl =
      queryParameters['provider_url'];
    await MetaData.save();
  }

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
              if (deepLink.path.startsWith('/open_file')) {
                await _setDeepLinkSharePublishUrl(deepLink);
              }
              if (_appRouter.currentPath != '/') {
                return DeepLink.path(_appRouter.currentPath);
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
