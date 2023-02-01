import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../l10n.dart';
import '../../routing/router.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AutoTabsScaffold(
      routes: const [
        // The order maps to BottomNavigationBar
        ReportRouter(),
        SearchRouter(),
        FaqRouter(),
        SettingsRouter(),
      ],
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
      BuildContext context) {
    return <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: Icon(Icons.summarize_rounded),
        label: context.l10n.nav_report,
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.medication_rounded),
        label: context.l10n.nav_drugs,
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.lightbulb_rounded),
        label: context.l10n.nav_faq,
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.more_horiz_rounded),
        label: context.l10n.nav_more,
      ),
    ];
  }
}
