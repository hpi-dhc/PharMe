import '../common/module.dart';
import '../drug/module.dart';

// For generated routes
export 'pages/gene.dart';
export 'pages/report.dart';

@RoutePage()      
class ReportRootPage extends AutoRouter {}

final reportRoute = AutoRoute(
  path: 'report',
  page: ReportRootRoute.page,
  children: [
    AutoRoute(path: '', page: ReportRoute.page),
    AutoRoute(page: GeneRoute.page),
    drugRoute(),
  ],
);
