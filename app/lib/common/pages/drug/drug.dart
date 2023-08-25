import '../../module.dart';
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
    return BlocProvider(
      create: (context) => cubit ?? DrugCubit(),
      child: BlocBuilder<DrugCubit, DrugState>(
        builder: (context, state) {
          return state.when(
            loaded: () => _buildDrugsPage(context, loading: false),
            loading: () => _buildDrugsPage(context, loading: true),
          );
        },
      ),
    );
  }

  Widget _buildDrugsPage(BuildContext context, { required bool loading }) {
    final userGuideline = drug.userGuideline();
    final isActive = drug.isActive();
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
              SubHeader(context.l10n.drugs_page_header_drug),
              SizedBox(height: 12),
              DrugAnnotationCard(
                drug,
                isActive: isActive,
                setActivity: (value) =>
                  context.read<DrugCubit>().setActivity(drug, value),
                disabled: loading,
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
                  : [GuidelineAnnotationCard(userGuideline, drug: drug)],
            ],
          ),
        ),
      ],
    );
  }
}
