import 'package:auto_route/auto_route.dart';

import '../medications/page.dart';
import 'pages/reports.dart';

// We need to expose all pages for AutoRouter
export '../medications/page.dart';
export 'pages/reports.dart';

const reportsRoutes = AutoRoute(
  path: 'reports',
  name: 'ReportsRouter',
  page: EmptyRouterPage,
  children: [
    AutoRoute(path: '', page: ReportsPage),
    AutoRoute(page: MedicationPage),
  ],
);
