import '../../module.dart';

class FilterButton extends StatelessWidget {
  const FilterButton(
    this.state,
    this.activeDrugs,
    {
      required this.searchForDrugClass,
    }
  );

  final DrugListState state;
  final ActiveDrugs activeDrugs;
  final bool searchForDrugClass;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Stack(
        children: [
          Icon(Icons.filter_list),
          if (_showActiveIndicator()) _buildActiveIndicator(context),
        ],
      ),
      color: PharMeTheme.iconColor,
      onPressed: Scaffold.of(context).openDrawer,
    );
  }

  bool _showActiveIndicator() {
    final itemsAreFiltered = state.whenOrNull(
      loaded: (allDrugs, filter) {
        final totalNumberOfDrugs = allDrugs.length;
        final currentNumberOfDrugs = filter.filter(
          allDrugs,
          activeDrugs,
          searchForDrugClass: searchForDrugClass,
        ).length;
        return totalNumberOfDrugs != currentNumberOfDrugs;
      },
    );
    return itemsAreFiltered ?? false;
  }

  Widget _buildActiveIndicator(BuildContext context) {
    const indicatorSize = PharMeTheme.smallToMediumSpace;
    return Positioned(
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: PharMeTheme.sinaiPurple,
          border: Border.all(
            color: PharMeTheme.surfaceColor,
            width: indicatorSize / 8,
          ),
        ),
        width: indicatorSize,
        height: indicatorSize,
      ),
    );
  }
}
