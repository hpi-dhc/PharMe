import '../module.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AutoTabsScaffold(
      routes: const [
        // The order maps to BottomNavigationBar
        MedicationsRouter(),
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
        icon: Icon(Icons.medication),
        label: context.l10n.nav_medications,
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
