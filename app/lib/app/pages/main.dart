import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../routing/router.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AutoTabsScaffold(
      routes: const [
        TestRouter(),
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
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Test',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.ac_unit),
              label: 'Other',
            ),
          ],
        );
      },
    );
  }
}
