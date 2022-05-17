import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../l10n.dart';
import '../routing/router.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AutoTabsScaffold(
      routes: const [
        // The order maps to BottomNavigationBar
        SearchRouter(),
        ReportsRouter(),
        FaqRouter(),
        SettingsRouter(),
      ],
      appBarBuilder: (_, tabsRouter) => AppBar(
        title: Text(context.l10n.general_appName),
        centerTitle: true,
        leading: const AutoBackButton(),
      ),
      bottomNavigationBuilder: (_, tabsRouter) {
        return BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: tabsRouter.activeIndex,
          onTap: tabsRouter.setActiveIndex,
          items: _bottomNavigationBarItems(context),
        );
      },
    );
  }

  List<BottomNavigationBarItem> _bottomNavigationBarItems(
      BuildContext context) {
    return <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: Icon(Icons.search),
        label: context.l10n.nav_search,
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.assessment),
        label: context.l10n.nav_reports,
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.lightbulb),
        label: context.l10n.nav_faq,
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.settings),
        label: context.l10n.nav_settings,
      ),
    ];
  }
}
