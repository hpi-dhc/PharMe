import '../common/module.dart';

// For generated routes
export 'cubit.dart';
export 'pages/drug.dart';

// Used by multiple parent routes, therefore returning function for creation
AutoRoute drugRoute() => AutoRoute(page: DrugRoute.page);