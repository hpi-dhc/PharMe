import 'package:auto_route/auto_route.dart';

import '../common/pages/medications/medication.dart';
import 'pages/reports.dart';

// We need to expose all pages for AutoRouter
export '../common/pages/medications/cubit.dart';
export '../common/pages/medications/medication.dart';
export '../reports/pages/cubit.dart';
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
