import 'package:provider/provider.dart';

import '../../common/module.dart';
import '../cubit.dart';
import '../widgets/module.dart';

@RoutePage()
class DrugPage extends StatelessWidget {
  const DrugPage(
    this.drug, {
    @visibleForTesting this.cubit,
  });

  final Drug drug;
  final DrugCubit? cubit;

  @override
  Widget build(BuildContext context) {
    return Consumer<ActiveDrugs>(
      builder: (context, activeDrugs, child) => BlocProvider(
        create: (context) => cubit ?? DrugCubit(activeDrugs),
        child: BlocBuilder<DrugCubit, DrugState>(
          builder: (context, state) {
            return state.when(
              loaded: () => _buildDrugsPage(context, loading: false),
              loading: () => _buildDrugsPage(context, loading: true),
            );
          },
        ),
      )
    );
  }

  Widget _buildDrugsPage(BuildContext context, { required bool loading }) {
    return pageScaffold(
      title: drug.name.capitalize(),
      actions: [
        IconButton(
          onPressed: loading ? null : () =>
            context.read<DrugCubit>().createAndSharePdf(drug, context),
          icon: Icon(
            Icons.ios_share_rounded,
            color: PharMeTheme.primaryColor,
          ),
        )
      ],
      body: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DrugAnnotationCard(
                drug,
                isActive: drug.isActive,
                setActivity: ({ value }) =>
                  context.read<DrugCubit>().setActivity(drug, value),
                disabled: loading,
              ),
              SizedBox(height: PharMeTheme.mediumSpace),
              SubHeader(
                context.l10n.drugs_page_header_guideline,
                tooltip: _buildGuidelineTooltipText(context),
              ),
              SizedBox(height: PharMeTheme.smallSpace),
              GuidelineAnnotationCard(drug),
            ],
          ),
        ),
      ],
    );
  }

  String _buildGuidelineTooltipText(BuildContext context) {
    return drug.userGuideline != null
      ? context.l10n.drugs_page_tooltip_guideline(
          drug.userGuideline!.externalData.first.source
        )
      : drug.userOrFirstGuideline != null
        // Guideline for drug is present but not for genotype
        ? context.l10n.drugs_page_tooltip_missing_guideline_for_drug_or_genotype(
            context.l10n.drugs_page_tooltip_missing_genotype
          )
        : context.l10n.drugs_page_tooltip_missing_guideline_for_drug_or_genotype(
            context.l10n.drugs_page_tooltip_missing_drug
          );
  }
}
