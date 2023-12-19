import '../common/module.dart';

// For generated routes
export 'pages/about_us.dart';
export 'pages/privacy_policy.dart';
export 'pages/settings.dart';
export 'pages/terms_and_conditions.dart';

final settingsRoute = AutoRoute(
  path: 'settings',
  page: SettingsRoute.page,
  children: [
    AutoRoute(path: 'about', page: AboutUsRoute.page),
    AutoRoute(path: 'privacy', page: PrivacyPolicyRoute.page),
    AutoRoute(path: 'terms', page: TermsAndConditionsRoute.page),
  ],
);