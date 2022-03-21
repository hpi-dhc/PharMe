import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive/hive.dart';

import '../routing/router.dart';
import '../theme.dart';

class FrasecysApp extends StatelessWidget {
  FrasecysApp({Key? key}) : super(key: key);

  final _appRouter = AppRouter();
  final _isLoggedIn =
      Hive.box('preferences').get('isLoggedIn', defaultValue: false) as bool;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: _appRouter.defaultRouteParser(),
      routerDelegate: _appRouter.delegate(
        initialDeepLink: _isLoggedIn ? 'main' : 'auth/onboarding',
      ),
      theme: FrasecysTheme.light,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en', ''),
        Locale('de', ''),
      ],
    );
  }
}
