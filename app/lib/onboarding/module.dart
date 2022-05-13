import '../common/module.dart';
import 'pages/onboarding.dart';

export 'pages/onboarding.dart';

const onboardingRoutes = AutoRoute(
  path: 'onboarding',
  name: 'OnboardingRouter',
  page: OnboardingPage,
);
