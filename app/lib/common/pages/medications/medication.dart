// ignore_for_file: avoid_returning_null_for_void

import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../module.dart';
import '../../utilities/pdf_utils.dart';
import 'cubit.dart';

class MedicationPage extends StatelessWidget {
  const MedicationPage(this.id);

  final int id;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MedicationsCubit(id),
      child: BlocBuilder<MedicationsCubit, MedicationsState>(
        builder: (context, state) {
          return RoundedCard(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
            child: state.when(
              initial: Container.new,
              error: () => Text(context.l10n.err_generic),
              loading: () => Center(child: CircularProgressIndicator()),
              loaded: (medication) => _buildMedicationsPage(
                filterUserGuidelines(medication),
                context,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMedicationsPage(
    MedicationWithGuidelines medication,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(medication),
        SizedBox(height: 20),
        _buildDisclaimer(context),
        SizedBox(height: 20),
        _SubHeader(
          context.l10n.medications_page_header_guideline,
          tooltip: context.l10n.medications_page_tooltip_guideline,
        ),
        SizedBox(height: 12),
        if (medication.guidelines.isNotEmpty)
          ClinicalAnnotationCard(medication)
        else
          Text(context.l10n.medications_page_no_guidelines_for_phenotype),
      ],
    );
  }

  Widget _buildHeader(
    MedicationWithGuidelines medication,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(medication.name, style: PharmeTheme.textTheme.displaySmall),
            IconButton(
              onPressed: () => sharePdf(medication),
              icon: Icon(
                Icons.ios_share,
                size: 32,
                color: PharmeTheme.primaryColor,
              ),
            ),
          ],
        ),
        if (medication.drugclass != null)
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: PharmeTheme.onSurfaceColor,
              borderRadius: BorderRadius.all(Radius.circular(6)),
            ),
            child: Text(
              medication.drugclass!,
              style: PharmeTheme.textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.w100,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDisclaimer(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        color: PharmeTheme.surfaceColor,
        border: Border.all(color: PharmeTheme.errorColor, width: 1.2),
      ),
      child: Row(children: [
        Icon(
          Icons.warning_rounded,
          size: 52,
          color: PharmeTheme.errorColor,
        ),
        SizedBox(width: 8),
        Flexible(
          child: Text(
            context.l10n.medications_page_disclaimer,
            style: PharmeTheme.textTheme.labelMedium!.copyWith(
              fontWeight: FontWeight.w100,
            ),
          ),
        ),
      ]),
    );
  }
}

class ClinicalAnnotationCard extends StatelessWidget {
  const ClinicalAnnotationCard(this.medication);

  final MedicationWithGuidelines medication;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: RoundedCard(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: SingleChildScrollView(
          child: Column(children: [
            _buildHeader(context),
            SizedBox(height: 16),
            if (medication.guidelines[0].implication.isNotNullOrBlank ||
                medication.guidelines[0].cpicImplication.isNotNullOrBlank) ...[
              _buildImplicationInfo(context),
              SizedBox(height: 16),
            ],
            if (medication.guidelines[0].recommendation.isNotNullOrBlank ||
                medication
                    .guidelines[0].cpicRecommendation.isNotNullOrBlank) ...[
              _buildRecommendationCard(context),
              SizedBox(height: 16),
            ],
            _buildSourcesSection(context),
            SizedBox(height: 16),
          ]),
        ),
      ),
    );
  }

  Widget _buildImplicationInfo(BuildContext context) {
    return Row(children: [
      Text(
        context.l10n.medications_page_info_big_i,
        style: GoogleFonts.robotoSlab(
          fontSize: 48,
          fontWeight: FontWeight.w900,
        ),
      ),
      SizedBox(width: 24),
      Flexible(
        child: Text(
          medication.guidelines[0].implication ??
              medication.guidelines[0].cpicImplication!,
          style: PharmeTheme.textTheme.bodySmall,
        ),
      ),
    ]);
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          context.l10n.medications_page_gene_name(
            medication.guidelines[0].phenotype.geneSymbol.name,
          ),
          style: PharmeTheme.textTheme.bodyLarge!.copyWith(
            color: Colors.black.withOpacity(0.5),
          ),
        ),
        Row(children: [
          Text(
            medication.guidelines[0].cpicClassification!.toUpperCase(),
            style: PharmeTheme.textTheme.bodyLarge!.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black.withOpacity(0.7),
            ),
          ),
          SizedBox(width: 6),
          _TooltipIcon(context.l10n.medications_page_tooltip_classification),
        ]),
      ],
    );
  }

  Widget _buildRecommendationCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.red[200],
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SubHeader(
                context.l10n.medications_page_header_recommendation,
              ),
              Icon(Icons.warning_rounded, size: 32),
            ],
          ),
          SizedBox(height: 4),
          Text(
            medication.guidelines[0].recommendation ??
                medication.guidelines[0].cpicRecommendation!,
            style: PharmeTheme.textTheme.bodyLarge,
          ),
        ]),
      ),
    );
  }

  Widget _buildSourcesSection(BuildContext context) {
    return Column(children: [
      _SubHeader(
        context.l10n.medications_page_header_further_info,
        tooltip: context.l10n.medications_page_tooltip_further_info,
      ),
      if (medication.pharmgkbId.isNotNullOrBlank) ...[
        SizedBox(height: 8),
        _buildSourceCard(
          context.l10n.medications_page_sources_pharmGkb_name,
          context.l10n.medications_page_sources_pharmGkb_description,
          () => _launchPharmGkbUrl(medication.pharmgkbId),
        ),
      ],
      SizedBox(height: 8),
      _buildSourceCard(
        context.l10n.medications_page_sources_cpic_name,
        context.l10n.medications_page_sources_cpic_description,
        () => _launchUrl(Uri.parse(medication.guidelines[0].cpicGuidelineUrl)),
      ),
    ]);
  }

  Widget _buildSourceCard(
    String name,
    String description,
    GestureTapCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          gradient: LinearGradient(colors: [
            PharmeTheme.primaryColor.withOpacity(0.8),
            PharmeTheme.secondaryColor.withOpacity(0.8),
          ]),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(children: [
            Expanded(
              flex: 3,
              child: Text(
                name,
                style: PharmeTheme.textTheme.bodyMedium!.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 4),
            Expanded(
              flex: 10,
              child: Text(
                description,
                style: PharmeTheme.textTheme.bodySmall!.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _SubHeader extends StatelessWidget {
  const _SubHeader(
    this.title, {
    this.tooltip,
  });

  final String title;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: PharmeTheme.textTheme.bodySmall!.copyWith(letterSpacing: 2),
        ),
        if (tooltip.isNotNullOrBlank) ...[
          SizedBox(width: 8),
          _TooltipIcon(tooltip!),
        ]
      ],
    );
  }
}

class _TooltipIcon extends StatelessWidget {
  const _TooltipIcon(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      child: Icon(Icons.help_outline_rounded, size: 16),
    );
  }
}

Future<void> _launchPharmGkbUrl(String? id) async {
  var url = 'https://pharmgkb.org';

  // redirect to specific pharmgkb page if id is present
  if (id.isNotNullOrBlank) {
    url += '/chemical/$id/clinicalAnnotation';
  }

  await _launchUrl(Uri.parse(url));
}

Future<void> _launchUrl(Uri url) async {
  if (!await launchUrl(url)) throw Error();
}
