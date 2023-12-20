import '../common/module.dart';
import '../drug/module.dart';

// For generated routes
export 'pages/search.dart';

@RoutePage()      
class SearchRootPage extends AutoRouter {}

final searchRoute = AutoRoute(
  path: 'search',
  page: SearchRootRoute.page,
  children: [
    AutoRoute(path: '', page: SearchRoute.page),
    drugRoute()
  ],
);