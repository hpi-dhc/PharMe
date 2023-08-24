import '../../../common/module.dart';
import '../../common/widgets/drug_list/drug_items/drug_cards.dart';
import '../../common/widgets/drug_search.dart';

class SearchPage extends HookWidget {
  SearchPage({
    Key? key,
    @visibleForTesting DrugListCubit? cubit,
  })  : cubit = cubit ?? DrugListCubit(),
        super(key: key);

  final DrugListCubit cubit;

  @override
  Widget build(BuildContext context) {
    useOnAppLifecycleStateChange((previous, current) async {
      if (current == AppLifecycleState.resumed) {
        await cubit.loadDrugs(useCache: false);
      }
    });
    return unscrollablePageScaffold(
      title: context.l10n.tab_drugs,
      body: DrugSearch(
        showFilter: true,
        buildDrugItems: buildDrugCards,
        cubit: cubit,
        showDrugInteractionIndicator: true,
      ),
    );
  }
}
