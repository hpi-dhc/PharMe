import 'package:flutter_localizations/flutter_localizations.dart';

import '../models/metadata.dart';
import '../module.dart' hide MetaData;

class PharMeApp extends StatelessWidget {
  factory PharMeApp() => _instance;

  PharMeApp._({Key? key}) : super(key: key);

  static final _instance = PharMeApp._();

  final _appRouter = AppRouter();
  final _isLoggedIn = MetaData.instance.isLoggedIn ?? false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routeInformationParser: _appRouter.defaultRouteParser(),
      routerDelegate: _appRouter.delegate(
        initialDeepLink: _isLoggedIn ? 'main' : 'login',
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
