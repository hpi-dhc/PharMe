import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../routing/router.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AutoTabsScaffold(
      routes: const [
        // The order maps to BottomNavigationBar
        MedicationsRouter(),
        ReportsRouter(),
        ProfileRouter(),
      ],
      appBarBuilder: (_, tabsRouter) => AppBar(
        title: const Text('Frasecys'),
        centerTitle: true,
        leading: const AutoBackButton(),
      ),
      bottomNavigationBuilder: (_, tabsRouter) {
        return BottomNavigationBar(
          currentIndex: tabsRouter.activeIndex,
          onTap: tabsRouter.setActiveIndex,
          items: _bottomNavigationBarItems,
        );
      },
    );
  }

  List<BottomNavigationBarItem> get _bottomNavigationBarItems {
    return const <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: Icon(Icons.medication),
        label: 'Medications',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.assessment),
        label: 'Reports',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Profile',
      ),
    ];
  }
}
