import '../../drug/module.dart';
import '../../drug_selection/module.dart';
import '../../error/module.dart';
import '../../faq/module.dart';
import '../../login/module.dart';
import '../../main/module.dart';
import '../../more/module.dart';
import '../../onboarding/module.dart';
import '../../report/module.dart';
import '../../search/module.dart';
import '../../secure/module.dart';
import '../module.dart';

part 'router.gr.dart';

@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  @override
  RouteType get defaultRouteType => RouteType.adaptive();
  @override
  List<AutoRoute> get routes => [
    drugSelectionRoute(),
    errorRoute(),
    loginRoute(),
    mainRoute(
      children: [
        reportRoute(children: [ geneRoute(), drugRoute() ]),
        searchRoute(children: [ drugRoute() ]),
        faqRoute(),
        moreRoute(
          children: [ aboutRoute(), termsRoute(), privacyRoute() ],
        ),
      ],
    ),
    onboardingRoute(),
    secureRoute(),
    // See https://github.com/Milad-Akarie/auto_route_library/issues/1722#issuecomment-2344394468
    RedirectRoute(path: '*', redirectTo: '/main'),
  ];
}
