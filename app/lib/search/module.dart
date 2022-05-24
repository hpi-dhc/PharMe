import '../common/module.dart';
import 'pages/search.dart';

// We need to expose all pages for AutoRouter
export 'pages/search.dart';

const searchRoutes = AutoRoute(
  path: 'search',
  name: 'SearchRouter',
  page: SearchPage,
);
