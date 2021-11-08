import 'package:auto_route/auto_route.dart';

import 'pages/medications_overview/page.dart';

// We need to expose all pages for AutoRouter
export 'pages/medications_overview/page.dart';

const medicationsRoutes = AutoRoute(
  path: 'medications',
  name: 'MedicationsRouter',
  page: EmptyRouterPage,
  children: [
    AutoRoute(path: '', page: MedicationsOverviewPage),
  ],
);
