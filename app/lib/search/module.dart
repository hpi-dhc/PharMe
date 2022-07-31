import 'package:auto_route/auto_route.dart';

import '../common/pages/medications/medication.dart';
import 'pages/search.dart';

export '../common/pages/medications/cubit.dart';
// We need to expose all pages for AutoRouter
export '../common/pages/medications/medication.dart';
export 'pages/cubit.dart';
export 'pages/search.dart';

const searchRoutes = AutoRoute(
  path: 'search',
  name: 'SearchRouter',
  page: EmptyRouterPage,
  children: [
    AutoRoute(path: '', page: SearchPage),
    AutoRoute(page: MedicationPage),
  ],
);
