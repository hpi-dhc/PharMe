import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../auth/module.dart';
import '../../medications/module.dart';
import '../../profile/module.dart';
import '../../reports/module.dart';
import '../pages/main.dart';
import 'guards/auth-guard.dart';

part 'router.gr.dart';

@MaterialAutoRouter(
  replaceInRouteName: 'Page,Route',
  routes: [
    authRoutes,
    AutoRoute(
      path: 'main',
      page: MainPage,
      initial: true,
      children: [
        medicationsRoutes,
        profileRoutes,
        reportsRoutes,
      ],
      guards: [AuthGuard],
    ),
  ],
)
class AppRouter extends _$AppRouter {
  AppRouter({required AuthGuard authGuard}) : super(authGuard: authGuard);
}
