import 'package:auto_route/auto_route.dart';

import '../details/pages/details.dart';
import 'pages/reports.dart';

// We need to expose all pages for AutoRouter
export '../details/module.dart';
export 'pages/reports.dart';

const reportsRoutes = AutoRoute(
  path: 'reports',
  name: 'ReportsRouter',
  page: EmptyRouterPage,
  children: [
    AutoRoute(path: '', page: ReportsPage),
    AutoRoute(page: MedicationDetailsPage),
  ],
);
