import '../common/module.dart';
import 'pages/report.dart';

export 'pages/report.dart';

const reportRoutes = AutoRoute(
  path: 'report',
  name: 'ReportRouter',
  page: EmptyRouterPage,
  children: [
    AutoRoute(path: '', page: ReportPage),
  ],
);
