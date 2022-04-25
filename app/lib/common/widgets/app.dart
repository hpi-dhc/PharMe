import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../models/metadata.dart';
import '../routing/router.dart';
import '../theme.dart';

class PharmeApp extends StatelessWidget {
  PharmeApp({Key? key}) : super(key: key);

  final _appRouter = AppRouter();
  final _isLoggedIn = MetadataContainer().data.isLoggedIn ?? false;

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
      supportedLocales: [
        Locale('en', ''),
        Locale('de', ''),
      ],
    );
  }
}
