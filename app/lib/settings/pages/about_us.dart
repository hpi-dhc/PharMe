import '../../common/module.dart';

@RoutePage()
class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return pageScaffold(title: context.l10n.settings_page_about_us, body: [
      Container(
        color: PharMeTheme.backgroundColor,
        child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(context.l10n.settings_page_about_us_text,
                style: PharMeTheme.textTheme.bodyLarge)),
      ),
    ]);
  }
}
