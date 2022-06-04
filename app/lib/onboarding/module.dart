import '../common/module.dart';
import 'pages/page.dart';

export 'pages/page.dart';

const onboardingRoutes = AutoRoute(
  path: 'onboarding',
  name: 'OnboardingRouter',
  page: OnboardingPage,
);
