import 'package:auto_route/auto_route.dart';

import 'pages/details/page.dart';
import 'pages/overview/page.dart';

// We need to expose all pages for AutoRouter
export 'pages/details/page.dart';
export 'pages/overview/page.dart';

const medicationsRoutes = AutoRoute(
  path: 'medications',
  name: 'MedicationsRouter',
  page: EmptyRouterPage,
  children: [
    AutoRoute(path: '', page: MedicationsOverviewPage),
    AutoRoute(path: ':id', page: MedicationDetailsPage)
  ],
);
