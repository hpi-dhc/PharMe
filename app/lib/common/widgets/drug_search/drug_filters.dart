import 'package:popover/popover.dart';
import '../../module.dart';

@visibleForTesting
class WarningLevelFilterChip extends HookWidget {
  const WarningLevelFilterChip({
    required this.warningLevel,
    required this.cubit,
    required this.filter,
    required this.drugs,
    required this.activeDrugs,
    required this.searchForDrugClass,
  });

  final WarningLevel warningLevel;
  final DrugListCubit cubit;
  final FilterState filter;
  final List<Drug> drugs;
  final ActiveDrugs activeDrugs;
  final bool searchForDrugClass;

  int _getFilteredNumber({
    required FilterState itemFilter,
    required List<Drug> drugs,
  }) {
    return itemFilter
      .filter(drugs, activeDrugs, searchForDrugClass: searchForDrugClass)
      .length;
  }

  bool _filterIsEnabled({
    required FilterState itemFilter,
    required List<Drug> drugs,
  }) => _getFilteredNumber(itemFilter: itemFilter, drugs: drugs) > 0;

  Widget _getFilterText(
    BuildContext context,
    WarningLevel warningLevel, {
    required FilterState itemFilter,
    required List<Drug> drugs,
    bool enabled = true,
  }) {
    final numberTextColor = darkenColor(PharMeTheme.onSurfaceText, -0.2);
    final disabledTextColor = darkenColor(numberTextColor, -0.2);
    return Text.rich(
      TextSpan(children: [
        WidgetSpan(
          child: Icon(
          enabled ? warningLevel.icon : warningLevel.outlinedIcon,
          color: PharMeTheme.onSurfaceText,
          size: PharMeTheme.textTheme.labelMedium!.fontSize,
        )),
        TextSpan(text: ' '),
        TextSpan(
          text: warningLevel.getLabel(context),
          style: PharMeTheme.textTheme.labelSmall!.copyWith(
            color: enabled
              ? PharMeTheme.textTheme.labelSmall!.color
              : disabledTextColor,
          ),
        ),
        TextSpan(
          text: ' (${
            _getFilteredNumber(itemFilter: itemFilter, drugs: drugs)
          })',
          style: PharMeTheme.textTheme.labelSmall!.copyWith(
            color: enabled ? numberTextColor : disabledTextColor,
          ),
        ),
      ]),
    );
  }

  FilterState _warningLevelFilter(WarningLevel warningLevel) {
      final currentFilter = FilterState.from(filter);
      currentFilter.showWarningLevel.forEach(
          (currentWarningLevel, currentValue) =>
              currentFilter.showWarningLevel[currentWarningLevel] =
                  currentWarningLevel == warningLevel);
      return currentFilter;
    }
 
  @override
  Widget build(BuildContext context) {
    final selected = useState(filter.showWarningLevel[warningLevel]!);
    final itemFilter = _warningLevelFilter(warningLevel);
    final enabled = _filterIsEnabled(itemFilter: itemFilter, drugs: drugs);
    return GestureDetector(
      onTap: enabled
        ? () {
          final newValue = !selected.value;
          cubit.search(
            showWarningLevel: {warningLevel: newValue},
          );
          // Need to additionally set state to update chip in popover
          selected.value = newValue;
        }
        : null,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected.value && enabled
            ? warningLevel.color
            : Colors.transparent,
          border: Border.all(
            color: selected.value && enabled
              ? darkenColor(warningLevel.color, 0.05)
              : PharMeTheme.onSurfaceColor,
          ),
          borderRadius: BorderRadius.all(
              Radius.circular(PharMeTheme.outerCardRadius)
            ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: PharMeTheme.mediumSpace * 0.5,
            vertical: PharMeTheme.mediumSpace * 0.4,
          ),
          child: _getFilterText(
            context,
            warningLevel,
            itemFilter: itemFilter,
            drugs: drugs,
            enabled: selected.value && enabled,
          ),
        ),
      ),
    );
  }
}

class DrugFilters extends StatelessWidget {
  const DrugFilters({
    super.key,
    required this.cubit,
    required this.state,
    required this.activeDrugs,
    required this.searchForDrugClass,
  });

  final DrugListCubit cubit;
  final DrugListState state;
  final ActiveDrugs activeDrugs;
  final bool searchForDrugClass;

  bool _showActiveIndicator() => state.whenOrNull(
    loaded: (allDrugs, filter) {
      final relevantDrugsFilter = FilterState.from(
        FilterState.initial(),
        query: filter.query,
      );
      final totalNumberOfDrugs = relevantDrugsFilter.filter(
        allDrugs,
        activeDrugs,
        searchForDrugClass: searchForDrugClass,
      ).length;
      final currentNumberOfDrugs = filter.filter(
        allDrugs,
        activeDrugs,
        searchForDrugClass: searchForDrugClass,
      ).length;
      return totalNumberOfDrugs != currentNumberOfDrugs;
    },
  ) ?? false;

  Widget _buildActiveIndicator() {
    const indicatorSize = PharMeTheme.smallSpace;
    return Positioned(
      right: 0 + indicatorSize * 0.25,
      bottom: 0 + indicatorSize * 0.25,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: PharMeTheme.sinaiCyan,
        ),
        width: indicatorSize,
        height: indicatorSize,
      ),
    );
  }

  List<Widget> _buildWarningLevelFilters(
    List<Drug> drugs,
    FilterState filter,
  ) {
    Widget buildWarningLevelItem(WarningLevel warningLevel) =>
      Padding(
        padding: EdgeInsets.only(
          bottom: PharMeTheme.smallSpace,
          left: PharMeTheme.smallToMediumSpace,
          right: PharMeTheme.smallToMediumSpace,
        ),
        child: WarningLevelFilterChip(
          warningLevel: warningLevel,
          cubit: cubit,
          drugs: drugs,
          filter: filter,
          activeDrugs: activeDrugs,
          searchForDrugClass: searchForDrugClass,
        ),
      );
    return [
      ...WarningLevel.values.map(buildWarningLevelItem),
      // General padding minus applied bottom padding 
      SizedBox(height: PharMeTheme.mediumSpace - PharMeTheme.smallSpace),
    ];
  }

  Widget _buildButton({
    required void Function()? onPressed,
    required bool enableIndicator,
  }) {
    return ResizedIconButton(
      onPressed: onPressed,
      size: PharMeTheme.largeSpace,
      backgroundColor: PharMeTheme.iconColor,
      iconWidgetBuilder: (size) => Stack(
        children: [
          Icon(
            Icons.filter_list,
            size: size,
            color: PharMeTheme.surfaceColor,
          ),
          if (enableIndicator && _showActiveIndicator())
            _buildActiveIndicator(),
        ],
      ),
    );
  }

  Widget _buildDisabledButton() {
    return _buildButton(onPressed: null, enableIndicator: false);
  }

  Widget _buildEnabledButton(
    BuildContext context,
    List<Drug> allDrugs,
    FilterState filter,
  ) {
    return _buildButton(
      onPressed: () {
        showPopover(
          context: context,
          bodyBuilder: (context) => Padding(
            padding: EdgeInsets.symmetric(
              horizontal: PharMeTheme.mediumSpace,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: PharMeTheme.surfaceColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: IntrinsicWidth(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SubheaderDivider(
                      text: context.l10n.search_page_filter_label,
                      useLine: false,
                      padding: PharMeTheme.smallToMediumSpace,
                    ),
                    ..._buildWarningLevelFilters(allDrugs, filter),
                  ],
                ),
              ),
            ),
          ),
          direction: PopoverDirection.bottom,
          arrowHeight: 0,
          arrowWidth: 0,
          transitionDuration: Duration(milliseconds: 100),
          barrierColor: Color.fromRGBO(0, 0, 0, 0.05),
          backgroundColor: Color.fromRGBO(1, 1, 1, 0),
          shadow: [],
        );
      },
      enableIndicator: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return state.when(
      initial: _buildDisabledButton,
      loading: _buildDisabledButton,
      loaded: (allDrugs, filter) =>
        _buildEnabledButton(context, allDrugs, filter),
      error: _buildDisabledButton,
    );
  }
}
