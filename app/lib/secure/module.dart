import '../common/module.dart';

// For generated routes
export 'pages/secure.dart';

const secureRoutePath = '/secure';

CustomRoute secureRoute() => CustomRoute(
  path: secureRoutePath,
  page: SecureRoute.page,
  transitionsBuilder: TransitionsBuilders.fadeIn,
);
