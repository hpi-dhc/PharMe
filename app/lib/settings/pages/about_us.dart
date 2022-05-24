import '../../common/module.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({Key? key}) : super(key: key);

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
                context.l10n.settings_page_about_us,
                style: PharmeTheme.textTheme.headlineSmall,
              ),
            ),
            Text(context.l10n.settings_page_about_us_text)
          ],
        ),
      ),
    );
  }
}
