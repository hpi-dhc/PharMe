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
              return getInitialRoute();
            },
            navigatorObservers:  () => [RemoveFocusOnNavigate()],
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

// Based on https://github.com/flutter/flutter/issues/48464#issuecomment-586635827
class RemoveFocusOnNavigate extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    final focus = FocusManager.instance.primaryFocus;
    focus?.unfocus();
  }
}
