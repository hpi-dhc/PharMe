import 'package:auto_route/auto_route.dart';

import '../common/pages/drug/drug.dart';
import 'pages/search.dart';

export '../common/models/module.dart';
export '../common/pages/drug/cubit.dart';
export '../common/pages/drug/drug.dart';
export 'pages/search.dart';

const searchRoutes = AutoRoute(
  path: 'search',
  name: 'SearchRouter',
  page: EmptyRouterPage,
  children: [
    AutoRoute(path: '', page: SearchPage),
    AutoRoute(page: DrugPage),
  ],
);
