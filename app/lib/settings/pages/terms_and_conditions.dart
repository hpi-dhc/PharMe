import 'package:comprehension_measurement/comprehension_measurement.dart';

import '../../common/module.dart';

class TermsAndConditionsPage extends AutoComprehensiblePage {
  TermsAndConditionsPage({
    Key? key,
    required BuildContext comprehensionContext,
  }) : super(
          key: key,
          comprehensionContext: comprehensionContext,
          surveyId: 1,
          supabaseConfig: supabaseConfig,
        );

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PharmeTheme.backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 16),
              child: Text(
                context.l10n.settings_page_terms_and_conditions,
                style: PharmeTheme.textTheme.headlineSmall,
              ),
            ),
            Text(context.l10n.settings_page_terms_and_conditions_text)
          ],
        ),
      ),
    );
  }
}
