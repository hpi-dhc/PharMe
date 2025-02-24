import '../../module.dart';

class ProfessionalDisclaimerCard extends StatelessWidget {
  const ProfessionalDisclaimerCard({super.key, this.elevation});

  final double? elevation;

  @override
  Widget build(BuildContext context) => DisclaimerCard(
    text: context.l10n.drugs_page_main_disclaimer_text,
    elevation: elevation,
  );
}