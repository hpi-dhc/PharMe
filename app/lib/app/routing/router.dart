import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../auth/module.dart';
import '../../medications/module.dart';
import '../../profile/module.dart';
import '../../reports/module.dart';
import '../pages/main.dart';

part 'router.gr.dart';

@MaterialAutoRouter(
  replaceInRouteName: 'Page,Route',
  routes: [
    // To set initial route. Later on very useful for login check
    RedirectRoute(path: '/', redirectTo: 'auth/onboarding'),
    authRoutes,
    AutoRoute(
      path: 'main',
      page: MainPage,
      children: [
        medicationsRoutes,
        profileRoutes,
        reportsRoutes,
      ],
    )
  ],
)
class AppRouter extends _$AppRouter {}
