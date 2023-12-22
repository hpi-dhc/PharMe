import '../common/module.dart';

// For generated routes
export 'pages/about.dart';
export 'pages/more.dart';
export 'pages/privacy.dart';
export 'pages/terms.dart';

@RoutePage()      
class MoreRootPage extends AutoRouter {}

AutoRoute aboutRoute() => AutoRoute(path: 'about', page: AboutRoute.page);
AutoRoute privacyRoute() => AutoRoute(path: 'privacy', page: PrivacyRoute.page);
AutoRoute termsRoute() => AutoRoute(path: 'terms', page: TermsRoute.page);

AutoRoute moreRoute({ required List<AutoRoute> children }) => AutoRoute(
  path: 'more',
  page: MoreRootRoute.page,
  children: [
    AutoRoute(path: '', page: MoreRoute.page),
    ...children,
  ],
);