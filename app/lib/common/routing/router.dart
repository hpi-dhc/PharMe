import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../faq/module.dart';
import '../../login/module.dart';
import '../../medications/module.dart';
import '../../onboarding/module.dart';
import '../../reports/module.dart';
import '../../settings/module.dart';
import '../pages/main.dart';

part 'router.gr.dart';

@MaterialAutoRouter(
  replaceInRouteName: 'Page,Route',
  routes: [
    onboardingRoutes,
    loginRoutes,
    AutoRoute(
      path: 'main',
      page: MainPage,
      children: [
        medicationsRoutes,
        settingsRoutes,
        faqRoutes,
        reportsRoutes,
      ],
    ),
  ],
)
class AppRouter extends _$AppRouter {}
