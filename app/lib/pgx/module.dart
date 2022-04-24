import 'package:auto_route/auto_route.dart';

import 'pages/pgx.dart';

// We need to expose all pages for AutoRouter
export 'pages/pgx.dart';

const pgxRoutes = AutoRoute(
  path: 'pgx',
  name: 'PgxRouter',
  page: PgxPage,
);
