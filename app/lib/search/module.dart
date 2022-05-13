import 'package:auto_route/auto_route.dart';

import '../details/module.dart';
import 'pages/search.dart';

// We need to expose all pages for AutoRouter
export '../details/module.dart';
export 'pages/search.dart';

const searchRoutes = AutoRoute(
  path: 'search',
  name: 'SearchRouter',
  page: EmptyRouterPage,
  children: [
    AutoRoute(path: '', page: SearchPage),
    AutoRoute(path: ':id', page: MedicationDetailsPage),
  ],
);
