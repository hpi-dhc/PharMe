import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../medications/module.dart';
import '../../profile/module.dart';
import '../../reports/module.dart';
import '../pages/main.dart';

part 'router.gr.dart';

@MaterialAutoRouter(
  replaceInRouteName: 'Page,Route',
  routes: <AutoRoute>[
    AutoRoute(
      path: '/',
      page: MainPage,
      children: <AutoRoute>[
        medicationsRoutes,
        profileRoutes,
        reportsRoutes,
      ],
    )
  ],
)
class AppRouter extends _$AppRouter {}
