import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../l10n.dart';
import '../../routing/router.dart';

class TabRouteDefinition {
  TabRouteDefinition({
    required this.pageRouteInfo,
    required this.label,
    required this.icon,
  });
  PageRouteInfo<void> pageRouteInfo;
  String label;
  Icon icon;
}

List<TabRouteDefinition> getTabRoutesDefinition(BuildContext context) {
  return [
    TabRouteDefinition(
      pageRouteInfo: ReportRouter(),
      label: context.l10n.nav_report,
      icon: Icon(Icons.summarize_rounded),
    ),
    TabRouteDefinition(
      pageRouteInfo: SearchRouter(),
      label: context.l10n.nav_drugs,
      icon: Icon(Icons.medication_rounded),
    ),
    TabRouteDefinition(
      pageRouteInfo: FaqRouter(),
      label: context.l10n.nav_faq,
      icon: Icon(Icons.lightbulb_rounded),
    ),
    TabRouteDefinition(
      pageRouteInfo: SettingsRouter(),
      label: context.l10n.nav_more,
      icon: Icon(Icons.more_horiz_rounded),
    ),
  ];
}

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AutoTabsScaffold(
      routes: getTabRoutesDefinition(context).map(
        (routeDefinition) => routeDefinition.pageRouteInfo
      ).toList(),
      bottomNavigationBuilder: (_, tabsRouter) {
        return BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: tabsRouter.activeIndex,
          onTap: (index) {
            if (index != tabsRouter.activeIndex) {
              tabsRouter.setActiveIndex(index);
            } else {
              tabsRouter.stackRouterOfIndex(index)?.popUntilRoot();
            }
          },
          items: _bottomNavigationBarItems(context),
        );
      },
    );
  }

  List<BottomNavigationBarItem> _bottomNavigationBarItems(
    BuildContext context
  ) {
    return getTabRoutesDefinition(context).map(
      (routeDefinition) => BottomNavigationBarItem(
        icon: routeDefinition.icon,
        label: routeDefinition.label,  
      )
    ).toList();
  }
}
