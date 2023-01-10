import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:scio/scio.dart';

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

            ComprehensionHelper.instance.measure(
              context: context,
              surveyId: 4,
              introText: context.l10n.comprehension_intro_text,
              surveyButtonText: context.l10n.comprehension_survey_button_text,
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
