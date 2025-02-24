import '../../../module.dart';

class PgxInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => DisclaimerCard(
    icon: Icons.info,
    iconPadding: EdgeInsets.all(PharMeTheme.smallSpace * 0.1),
    textWidget: Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '${context.l10n.pgx_abbreviation} ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: context.l10n.pharmacogenomics_info_box_text,
          ),
        ]
      ),
    ),
  );
}