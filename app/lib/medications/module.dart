import 'package:auto_route/auto_route.dart';

import 'pages/details.dart';

// We need to expose all pages for AutoRouter
export 'pages/details.dart';

const medicationsRoutes = AutoRoute(
  path: 'medications',
  name: 'MedicationsRouter',
  page: EmptyRouterPage,
  children: [AutoRoute(path: ':id', page: MedicationDetailsPage)],
);
