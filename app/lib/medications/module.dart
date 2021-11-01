import 'package:auto_route/auto_route.dart';

import 'pages/medications.dart';

// We need to expose all pages for AutoRouter
export 'pages/medications.dart';

const medicationsRoutes = AutoRoute(
  path: 'medications',
  name: 'MedicationsRouter',
  page: EmptyRouterPage,
  children: <AutoRoute>[
    AutoRoute(path: '', page: MedicationsPage),
  ],
);
