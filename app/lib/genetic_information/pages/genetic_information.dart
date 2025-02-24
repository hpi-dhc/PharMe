import 'package:url_launcher/url_launcher.dart';

import '../../common/module.dart';

@RoutePage()
class GeneticInformationPage extends HookWidget {
  const GeneticInformationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return pageScaffold(
      title: context.l10n.more_page_genetic_information,
      body: [
        Padding(
          padding: const EdgeInsets.only(
            left: PharMeTheme.smallSpace,
            right: PharMeTheme.smallSpace,
            bottom: PharMeTheme.smallSpace,
          ),
          child: LargeMarkdownBody(
            data: context.l10n.more_page_genetic_information_markdown,
            onTapLink: (text, href, title) => launchUrl(Uri.parse(href!)),
          ),
        ),
      ]
    );
  }
}