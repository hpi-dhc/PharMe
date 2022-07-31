import '../common/module.dart';
import 'pages/login.dart';

// We need to expose all pages for AutoRouter
export 'pages/cubit.dart';
export 'pages/login.dart';

const loginRoutes = AutoRoute(
  path: 'login',
  name: 'LoginRouter',
  page: LoginPage,
);
