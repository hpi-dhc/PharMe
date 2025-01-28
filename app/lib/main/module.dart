import '../common/module.dart';

// For generated route
export 'pages/main.dart';

const _path = '/main';
const _page = MainRoute.page;

AutoRoute mainRoute({ required List<AutoRoute> children }) =>
  MetaData.instance.tutorialDone ?? false
    ? AutoRoute(
        path: _path,
        page: _page,
        children: children,
      )
    : CustomRoute(
        path: _path,
        page: _page,
        children: children,
        transitionsBuilder: TransitionsBuilders.noTransition,
      ) ;
