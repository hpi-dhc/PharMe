import '../common/module.dart';

// For generated routes
export 'pages/gene.dart';
export 'pages/report.dart';

@RoutePage()
class ReportRootPage extends AutoRouter {}

AutoRoute geneRoute() => AutoRoute(page: GeneRoute.page);

AutoRoute reportRoute({ required List<AutoRoute> children }) => AutoRoute(
  path: 'report',
  page: ReportRootRoute.page,
  children: [
    AutoRoute(path: '', page: ReportRoute.page),
    ...children,
  ],
);
