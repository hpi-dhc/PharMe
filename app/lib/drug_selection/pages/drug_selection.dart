import 'package:provider/provider.dart';

import '../../common/models/drug/cached_drugs.dart';
import '../../common/module.dart' hide MetaData;
import '../../common/widgets/drug_list/drug_items/drug_checkbox_list.dart';
import '../../common/widgets/drug_search.dart';
import '../../common/widgets/full_width_button.dart';
import 'cubit.dart';

class DrugSelectionPage extends HookWidget {
  const DrugSelectionPage({
    Key? key,
    @visibleForTesting this.cubit,
  }) : super(key: key);

  final DrugSelectionPageCubit? cubit;

  @override
  Widget build(BuildContext context) {
    return Consumer<ActiveDrugs>(
      builder: (context, activeDrugs, child) => BlocProvider(
        create: (context) => cubit ?? DrugSelectionPageCubit(activeDrugs),
        child: BlocBuilder<DrugSelectionPageCubit, DrugSelectionPageState>(
          builder: (context, state) {
            return unscrollablePageScaffold(
              title: context.l10n.drug_selection_header,
              barBottom: context.l10n.drug_selection_description,
              padding: PharMeTheme.largeSpace,
              body: Column(
                children: [
                  Expanded(child: _buildDrugList(context, state)),
                  SizedBox(height: PharMeTheme.mediumSpace),
                  _buildButton(context, state),
                ],
              ),
            );
          }
        ),
      )
    );
  }

  bool _isEditable(DrugSelectionPageState state) {
    return state.when(
      stable: () => true,
      updating: () => false
    );
  }

  Widget _buildButton(BuildContext context, DrugSelectionPageState state) {
    return FullWidthButton(
      context.l10n.action_continue,
      () => overwriteRoutes(context, nextPage: MainRoute()),
      enabled: _isEditable(state),
    );
  }

  Widget _buildDrugList(BuildContext context, DrugSelectionPageState state) {
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
          .read<DrugSelectionPageCubit>()
          .updateDrugActivity(drug, value),
      },
      showDrugInteractionIndicator: false,
    );
  }
}
