import '../common/module.dart';
import 'pages/drug_selection.dart';

// We need to expose all pages for AutoRouter
export 'pages/cubit.dart';
export 'pages/drug_selection.dart';

const drugSelectionRoutes = AutoRoute(
  path: 'drugselection',
  name: 'DrugSelectionRouter',
  page: DrugSelectionPage,
);
