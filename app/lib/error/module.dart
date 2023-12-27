import '../common/module.dart';

// For generated routes
export 'pages/error.dart';

CustomRoute errorRoute() => CustomRoute(
  path: '/error',
  page: ErrorRoute.page,
  transitionsBuilder: TransitionsBuilders.fadeIn,
);
