import '../common/module.dart';

// For generated route
export 'cubit.dart';
export 'pages/drug_selection.dart';

AutoRoute drugSelectionRoute() => AutoRoute(
  path: '/drugselection',
  page: DrugSelectionRoute.page,
);