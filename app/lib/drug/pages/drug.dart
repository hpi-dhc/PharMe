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
      title: isInhibitor(drug.name)
        ? '${drug.name.capitalize()}$drugInteractionIndicator'
        : drug.name.capitalize(),
      actions: [
        IconButton(
          key: Key('share-${drug.name}'),
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
              DrugAnnotationCards(
                drug,
                isActive: drug.isActive,
                setActivity: ({ value }) =>
                  context.read<DrugCubit>().setActivity(drug, value),
                disabled: loading,
              ),
              SizedBox(height: PharMeTheme.mediumSpace),
              GuidelineAnnotationCard(drug),
            ],
          ),
        ),
      ],
    );
  }
}
