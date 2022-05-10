import 'package:auto_route/auto_route.dart';

import 'pages/onboarding.dart';

export 'pages/onboarding.dart';

const onboardingRoutes = AutoRoute(
  path: 'onboarding',
  name: 'OnboardingRouter',
  page: OnboardingPage,
);
