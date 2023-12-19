import '../common/module.dart';

// For generated route
export 'cubit.dart';
export 'pages/drug_selection.dart';

final drugSelectionRoute = AutoRoute(
  path: '/drugselection',
  page: DrugSelectionRoute.page,
);