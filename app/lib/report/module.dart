import '../common/module.dart';
import '../drug/module.dart';

// For generated routes
export 'pages/gene.dart';
export 'pages/report.dart';

final reportRoute = AutoRoute(
  path: 'report',
  page: ReportRoute.page,
  children: [
    AutoRoute(page: GeneRoute.page),
    drugRoute(),
  ],
);
