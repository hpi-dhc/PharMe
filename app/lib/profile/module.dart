import 'package:auto_route/auto_route.dart';

import 'pages/profile.dart';

// We need to expose all pages for AutoRouter
export 'pages/profile.dart';

const profileRoutes = AutoRoute(
  path: 'profile',
  name: 'ProfileRouter',
  page: ProfilePage,
);
