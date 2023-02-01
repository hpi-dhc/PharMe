import '../common/module.dart';
import 'pages/gene.dart';
import 'pages/report.dart';

export 'pages/gene.dart';
export 'pages/report.dart';

const reportRoutes = AutoRoute(
  path: 'report',
  name: 'ReportRouter',
  page: EmptyRouterPage,
  children: [
    AutoRoute(path: '', page: ReportPage),
    AutoRoute(page: GenePage),
  ],
);
