import '../common/module.dart';

// For generated route
export 'pages/main.dart';

AutoRoute mainRoute({ required List<AutoRoute> children }) => AutoRoute(
  path: '/main',
  page: MainRoute.page,
  children: children,
);