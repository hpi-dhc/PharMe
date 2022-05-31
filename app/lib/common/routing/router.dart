import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../faq/module.dart';
import '../../login/module.dart';
import '../../onboarding/module.dart';
import '../../reports/module.dart';
import '../../search/module.dart';
import '../../settings/module.dart';
import '../pages/main/main.dart';

part 'router.gr.dart';

@MaterialAutoRouter(
  replaceInRouteName: 'Page,Route',
  routes: [
    loginRoutes,
    onboardingRoutes,
    AutoRoute(
      path: 'main',
      page: MainPage,
      children: [
        searchRoutes,
        settingsRoutes,
        faqRoutes,
        reportsRoutes,
      ],
    ),
  ],
)
class AppRouter extends _$AppRouter {}
