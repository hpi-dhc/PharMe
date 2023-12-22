import '../common/module.dart';

// For generated route
export 'cubit.dart';
export 'pages/login.dart';

AutoRoute loginRoute() => AutoRoute(path: '/login', page: LoginRoute.page);