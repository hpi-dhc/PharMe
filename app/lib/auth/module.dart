import 'package:auto_route/auto_route.dart';

import 'onboarding/pages/onboarding.dart';

// We need to expose all pages for AutoRouter
export 'onboarding/pages/onboarding.dart';

const authRoutes = AutoRoute(
  path: 'auth',
  name: 'AuthRouter',
  page: EmptyRouterPage,
  children: [
    AutoRoute(path: 'onboarding', page: OnboardingPage),
  ],
);
