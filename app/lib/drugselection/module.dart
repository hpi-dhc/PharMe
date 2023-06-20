import '../common/module.dart';
import 'pages/drugselection.dart';

// We need to expose all pages for AutoRouter
export 'pages/cubit.dart';
export 'pages/drugselection.dart';

const drugSelectionRoutes = AutoRoute(
  path: 'drugselection',
  name: 'DrugSelectionRouter',
  page: DrugSelectionPage,
);
