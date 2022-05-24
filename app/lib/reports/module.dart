import '../common/module.dart';
import 'pages/reports.dart';

// We need to expose all pages for AutoRouter
export 'pages/reports.dart';

const reportsRoutes = AutoRoute(
  path: 'reports',
  name: 'ReportsRouter',
  page: ReportsPage,
);
