import 'package:auto_route/auto_route.dart';
import 'package:comprehension_measurement/comprehension_measurement.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../l10n.dart';
import '../../routing/router.dart';

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
        leading: const AutoLeadingButton(),
      ),
      bottomNavigationBuilder: (_, tabsRouter) {
        return BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: tabsRouter.activeIndex,
          onTap: (index) {
            tabsRouter.setActiveIndex(index);
            ComprehensionHelper.measure(
              context: context,
              surveyId: 4,
              introText:
                  '''Would you like to participate in a survey with the aim to measure user comprehension 
                of the applications content? This would help the developer team greatly to improve PharMe 
                and make it understandable for everyone!''',
              surveyButtonText: 'Continue to survey',
              supabaseConfig: supabaseConfig,
            );
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
        icon: Icon(Icons.more_horiz),
        label: context.l10n.nav_more,
      ),
    ];
  }
}
