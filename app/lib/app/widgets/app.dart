import 'package:flutter/material.dart';

import '../routing/router.dart';

class FrasecysApp extends StatelessWidget {
  FrasecysApp({Key? key}) : super(key: key);

  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: _appRouter.defaultRouteParser(),
      routerDelegate: _appRouter.delegate(),
    );
  }
}
