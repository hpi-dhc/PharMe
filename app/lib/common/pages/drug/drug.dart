// ignore_for_file: avoid_returning_null_for_void

import '../../module.dart';
import '../../utilities/pdf_utils.dart';
import 'cubit.dart';
import 'widgets/module.dart';

class DrugPage extends StatelessWidget {
  const DrugPage(
    this.drug, {
    @visibleForTesting this.cubit,
  });

  final Drug drug;
  final DrugCubit? cubit;

  @override
  Widget build(BuildContext context) {
    final drugName = drug.name.capitalize();
    return BlocProvider(
      create: (context) => cubit ?? DrugCubit(drug),
      child: BlocBuilder<DrugCubit, DrugState>(
        builder: (context, state) {
          return state.when(
            initial: () => pageScaffold(title: drugName, body: []),
            error: () => pageScaffold(
                title: drugName,
                body: [errorIndicator(context.l10n.err_generic)]),
            loading: () =>
                pageScaffold(title: drugName, body: [loadingIndicator()]),
            loaded: (drug, isActive) => pageScaffold(
              title: drugName,
              actions: [
                IconButton(
                  onPressed: () => sharePdf(drug, context),
                  icon: Icon(
                    Icons.ios_share_rounded,
                    color: PharMeTheme.primaryColor,
                  ),
                )
              ],
              body: [
                _buildDrugsPage(drug, isActive: isActive, context: context)
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDrugsPage(
    Drug drug, {
    required bool isActive,
    required BuildContext context,
  }) {
    final userGuideline = drug.userGuideline();
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SubHeader(context.l10n.drugs_page_header_drug),
            SizedBox(height: 12),
            DrugAnnotationCard(
              drug,
              isActive: isActive,
              setActivity: context.read<DrugCubit>().setActivity,
            ),
            SizedBox(height: 20),
            SubHeader(
              context.l10n.drugs_page_header_guideline,
              tooltip: context.l10n.drugs_page_tooltip_guideline,
            ),
            SizedBox(height: 12),
            ...(userGuideline != null)
                ? [
                    Disclaimer(),
                    SizedBox(height: 12),
                    GuidelineAnnotationCard(userGuideline)
                  ]
                : [Text(context.l10n.drugs_page_no_guidelines_for_phenotype(drug.name))]
          ],
        ));
  }
}
