import 'package:auto_route/auto_route.dart';

import '../common/pages/medication_details.dart';
import 'pages/reports.dart';

// We need to expose all pages for AutoRouter
export '../common/pages/medication_details.dart';
export 'pages/reports.dart';

const reportsRoutes = AutoRoute(
  path: 'reports',
  name: 'ReportsRouter',
  page: EmptyRouterPage,
  children: [
    AutoRoute(path: '', page: ReportsPage),
    AutoRoute(path: ':id', page: MedicationDetailsPage),
  ],
);
