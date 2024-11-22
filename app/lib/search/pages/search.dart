import '../../../common/module.dart';

@RoutePage()
class SearchPage extends HookWidget {
  SearchPage({
    super.key,
    @visibleForTesting DrugListCubit? cubit,
  })  : cubit = cubit ?? DrugListCubit();

  final DrugListCubit cubit;

  @override
  Widget build(BuildContext context) {
    useOnAppLifecycleStateChange((previous, current) async {
      if (current == AppLifecycleState.resumed) {
        await cubit.loadDrugs(useCache: false);
      }
    });
    const searchForDrugClass = true;
    return withFilterData(
      cubit: cubit,
      builder: (context, cubit, state, activeDrugs) => PopScope(
        canPop: false,
        child: unscrollablePageScaffold(
          title: context.l10n.tab_drugs,
          canNavigateBack: false,
          contextToDismissFocusOnTap: context,
          body: DrugSearch(
            key: Key('drug-search'),
            showFilter: true,
            buildDrugItems: buildDrugCards,
            cubit: cubit,
            state: state,
            activeDrugs: activeDrugs,
            searchForDrugClass: searchForDrugClass,
            showDrugInteractionIndicator: false,
          ),
        ),
      ),
    );
  }
}
