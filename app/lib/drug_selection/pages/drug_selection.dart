import 'package:provider/provider.dart';

import '../../common/models/metadata.dart';
import '../../common/module.dart' hide MetaData;
import '../../common/widgets/drug_list/drug_items/drug_checkbox_list.dart';
import '../../common/widgets/drug_search.dart';
import '../cubit.dart';

@RoutePage()
class DrugSelectionPage extends HookWidget {
  const DrugSelectionPage({
    super.key,
    this.concludesOnboarding = true,
    @visibleForTesting this.cubit,
  });

  final DrugSelectionCubit? cubit;
  final bool concludesOnboarding;

  @override
  Widget build(BuildContext context) {
    return Consumer<ActiveDrugs>(
      builder: (context, activeDrugs, child) => BlocProvider(
        create: (context) => cubit ?? DrugSelectionCubit(activeDrugs),
        child: BlocBuilder<DrugSelectionCubit, DrugSelectionState>(
          builder: (context, state) {
            return unscrollablePageScaffold(
              title: context.l10n.drug_selection_header,
              body: Column(
                children: [
                  if (concludesOnboarding) PageDescription(
                    context.l10n.drug_selection_onboarding_description,
                  ),
                  Expanded(child: _buildDrugList(context, state)),
                  if (concludesOnboarding) _buildButton(context, state),
                ],
              ),
            );
          }
        ),
      )
    );
  }

  bool _isEditable(DrugSelectionState state) {
    return state.when(
      stable: () => true,
      updating: () => false
    );
  }

  Widget _buildButton(BuildContext context, DrugSelectionState state) {
    return Padding(
      padding: EdgeInsets.all(PharMeTheme.mediumSpace),
      child: FullWidthButton(
        context.l10n.action_continue,
        () async {
          MetaData.instance.initialDrugSelectionDone = true;
          await MetaData.save();
          // ignore: use_build_context_synchronously
          await overwriteRoutes(context, nextPage: MainRoute());
        },
        enabled: _isEditable(state),
      )
    );
  }

  Widget _buildDrugList(BuildContext context, DrugSelectionState state) {
    if (CachedDrugs.instance.drugs!.isEmpty) {
      return Column(
        children: [
          Text(
            context.l10n.drug_selection_no_drugs_loaded,
            style: PharMeTheme.textTheme.bodyLarge!.copyWith(
              fontStyle: FontStyle.italic
            ),
          ),
        ],
      );
    }
    return DrugSearch(
      showFilter: false,
      keepPosition: true,
      useDrugClass: false,
      buildDrugItems: buildDrugCheckboxList,
      drugItemsBuildParams: {
        'checkboxesEnabled': _isEditable(state),
        'onCheckboxChange': (drug, value) => context
          .read<DrugSelectionCubit>()
          .updateDrugActivity(drug, value),
      },
      showDrugInteractionIndicator: false,
    );
  }
}
