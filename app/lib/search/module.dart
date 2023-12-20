import '../common/module.dart';

// For generated routes
export 'pages/search.dart';

@RoutePage()      
class SearchRootPage extends AutoRouter {}

AutoRoute searchRoute({ required List<AutoRoute> children }) => AutoRoute(
  path: 'search',
  page: SearchRootRoute.page,
  children: [
    AutoRoute(path: '', page: SearchRoute.page),
    ...children,
  ],
);