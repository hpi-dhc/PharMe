import '../../common/module.dart';
import 'cubit.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({
    @visibleForTesting this.cubit,
  });

  final ReportsCubit? cubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => cubit ?? ReportsCubit(),
      child: BlocBuilder<ReportsCubit, ReportsState>(
        builder: (context, state) {
          return RoundedCard(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
            child: state.when(
              initial: Container.new,
              error: () => Text(context.l10n.err_generic),
              loading: () => Center(child: CircularProgressIndicator()),
              loaded: (medications) => _buildReportsPage(medications, context),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReportsPage(
    List<MedicationWithGuidelines> medications,
    BuildContext context,
  ) {
    return CustomScrollView(slivers: [
      SliverPersistentHeader(
        delegate: SliverReportsHeaderDelegate(48, 96, 136),
        floating: true,
      ),
      _buildMedicationsList(medications),
    ]);
  }

  Widget _buildMedicationsList(List<MedicationWithGuidelines> medications) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final med = medications[index];
          return ReportCard(
            warningLevel: _getWarningLevel(med.guidelines),
            onTap: () => context.router.push(MedicationRoute(id: med.id)),
            medicationName: med.name,
            medicationIndication: med.indication,
          );
        },
        childCount: medications.length,
      ),
    );
  }

  WarningLevel _getWarningLevel(List<Guideline> guidelines) {
    for (final guideline in guidelines) {
      if (guideline.warningLevel == WarningLevel.danger) {
        return WarningLevel.danger;
      }
    }
    return WarningLevel.warning;
  }
}

class SliverReportsHeaderDelegate extends SliverPersistentHeaderDelegate {
  const SliverReportsHeaderDelegate(
    this.toolBarHeight,
    this.closedHeight,
    this.openHeight,
  ) : super();

  final double toolBarHeight;
  final double closedHeight;
  final double openHeight;

  @override
  double get maxExtent => toolBarHeight + openHeight;

  @override
  double get minExtent => toolBarHeight + closedHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: PharMeTheme.secondaryColor,
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(children: [
          Text(
            context.l10n.reports_page_disclaimer_title,
            style:
                PharMeTheme.textTheme.titleLarge!.copyWith(color: Colors.white),
          ),
          SizedBox(height: 8),
          Expanded(
            child: Row(children: [
              Flexible(
                child: Text(
                  context.l10n.reports_page_disclaimer_text,
                  style: PharMeTheme.textTheme.bodyMedium!
                      .copyWith(color: Colors.white),
                ),
              ),
              SvgPicture.asset('assets/images/reports_icon.svg'),
            ]),
          ),
        ]),
      ),
    );
  }
}

class ReportCard extends StatelessWidget {
  const ReportCard({
    required this.warningLevel,
    required this.onTap,
    required this.medicationName,
    this.medicationIndication,
  }) : super();

  final WarningLevel warningLevel;
  final VoidCallback onTap;
  final String medicationName;
  final String? medicationIndication;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 5,
        color: warningLevel.color,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(
                        warningLevel == WarningLevel.danger
                            ? Icons.dangerous_rounded
                            : Icons.warning_rounded,
                      ),
                      SizedBox(width: 12),
                      Text(
                        medicationName,
                        style: PharMeTheme.textTheme.titleMedium,
                      ),
                    ]),
                    if (medicationIndication.isNotNullOrBlank) ...[
                      SizedBox(height: 12),
                      Text(
                        medicationIndication!,
                        style: PharMeTheme.textTheme.titleSmall,
                      ),
                    ]
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
