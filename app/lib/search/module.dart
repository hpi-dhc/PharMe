import '../common/module.dart';
import '../drug/module.dart';

// For generated routes
export 'pages/search.dart';

final searchRoute = AutoRoute(
  path: 'search',
  page: SearchRoute.page,
  children: [ drugRoute() ],
);