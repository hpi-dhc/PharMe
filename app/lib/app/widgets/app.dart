import 'package:flutter/material.dart';

import '../routing/guards/auth-guard.dart';
import '../routing/router.dart';
import '../theme/theme.dart';

class FrasecysApp extends StatelessWidget {
  FrasecysApp({Key? key}) : super(key: key);

  final _appRouter = AppRouter(authGuard: AuthGuard());

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: _appRouter.defaultRouteParser(),
      routerDelegate: _appRouter.delegate(),
      theme: FrasecysTheme.light,
    );
  }
}
