import '../../common/module.dart';

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
      pageRouteInfo: ReportRoute(),
      label: context.l10n.nav_report,
      icon: Icon(Icons.summarize_rounded),
    ),
    TabRouteDefinition(
      pageRouteInfo: SearchRoute(),
      label: context.l10n.nav_drugs,
      icon: Icon(Icons.medication_rounded),
    ),
    TabRouteDefinition(
      pageRouteInfo: FaqRoute(),
      label: context.l10n.nav_faq,
      icon: Icon(Icons.lightbulb_rounded),
    ),
    TabRouteDefinition(
      pageRouteInfo: MoreRoute(),
      label: context.l10n.nav_more,
      icon: Icon(Icons.more_horiz_rounded),
    ),
  ];
}

@RoutePage()
class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tutorialDone = MetaData.instance.tutorialDone ?? false;
    if (!tutorialDone) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await showAppTour(
          context,
          lastNextButtonText: context.l10n.tutorial_to_the_app,
          revisiting: false,
        );
      });
    }
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
