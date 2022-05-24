import 'package:auto_route/auto_route.dart';

import '../common/module.dart';

import 'pages/about_us.dart';
import 'pages/privacy_policy.dart';
import 'pages/settings.dart';
import 'pages/terms_and_conditions.dart';

// We need to expose all pages for AutoRouter
export 'pages/about_us.dart';
export 'pages/privacy_policy.dart';
export 'pages/settings.dart';
export 'pages/terms_and_conditions.dart';

const settingsRoutes = AutoRoute(
  path: 'settings',
  name: 'SettingsRouter',
  page: EmptyRouterPage,
  children: [
    AutoRoute(path: '', page: SettingsPage),
    AutoRoute(path: 'about_us', page: AboutUsPage),
    AutoRoute(path: 'privacy_policy', page: PrivacyPolicyPage),
    AutoRoute(path: 'terms_and_conditions', page: TermsAndConditionsPage),
  ],
);
