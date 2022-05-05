import 'package:auto_route/auto_route.dart';

import 'pages/settings.dart';

// We need to expose all pages for AutoRouter
export 'pages/settings.dart';

const settingsRoutes = AutoRoute(
  path: 'settings',
  name: 'SettingsRouter',
  page: SettingsPage,
);
