import '../../../module.dart';

class ProfessionalDisclaimerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => DisclaimerCard(
    text: context.l10n.drugs_page_main_disclaimer_text,
  );
}