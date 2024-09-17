import 'package:popover/popover.dart';
import '../../module.dart';

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.onPressed,
    required this.label,
    required this.color,
    required this.borderColor,
  });

  final void Function()? onPressed;
  final Widget label;
  final Color color;
  final Color borderColor;
 
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.all(
              Radius.circular(PharMeTheme.outerCardRadius)
            ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: PharMeTheme.mediumSpace * 0.5,
            vertical: PharMeTheme.mediumSpace * 0.4,
          ),
          child: label,
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

  Widget _buildActiveIndicator() {
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
    bool showText = true,
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
        if (showText) ...[
          TextSpan(text: ' '),
          TextSpan(
            text: warningLevel.getLabel(context),
            style: PharMeTheme.textTheme.labelSmall!.copyWith(
              color: enabled
                ? PharMeTheme.textTheme.labelSmall!.color
                : disabledTextColor,
            ),
          ),
        ],
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

  List<Widget> _buildWarningLevelFilters(
    BuildContext context,
    List<Drug> drugs,
    FilterState filter,
  ) {
    FilterState warningLevelFilter(WarningLevel warningLevel) {
      final currentFilter = FilterState.from(filter);
      currentFilter.showWarningLevel.forEach(
          (currentWarningLevel, currentValue) =>
              currentFilter.showWarningLevel[currentWarningLevel] =
                  currentWarningLevel == warningLevel);
      return currentFilter;
    }
    Widget buildWarningLevelItem(WarningLevel warningLevel) {
      final value = filter.showWarningLevel[warningLevel]!;
      final itemFilter = warningLevelFilter(warningLevel);
      final enabled = _filterIsEnabled(itemFilter: itemFilter, drugs: drugs);
      return _FilterChip(
        onPressed: enabled ? () => cubit.search(
          showWarningLevel: {warningLevel: !value},
        ) : null,
        label: _getFilterText(
          context,
          warningLevel,
          itemFilter: itemFilter,
          drugs: drugs,
          enabled: value && enabled,
          showText: false,
        ),
        color: value && enabled ? warningLevel.color : Colors.transparent,
        borderColor: value && enabled
          ? darkenColor(warningLevel.color, 0.05)
          : PharMeTheme.onSurfaceColor,
      );
    }
    return WarningLevel.values.map(buildWarningLevelItem).toList();
  }

  IconButton _buildButton({
    required void Function()? onPressed,
    required bool enableIndicator,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Stack(
        children: [
          Icon(Icons.filter_list),
          if (enableIndicator && _showActiveIndicator()) _buildActiveIndicator(),
        ],
      ),
      color: PharMeTheme.iconColor,
    );
  }

  IconButton _buildDisabledButton() {
    return _buildButton(onPressed: null, enableIndicator: false);
  }

  IconButton _buildEnabledButton(
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
              horizontal: PharMeTheme.smallToMediumSpace
            ),
            child: Container(
              decoration: BoxDecoration(
                color: PharMeTheme.onSurfaceColor,
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
                    ),
                    ..._buildWarningLevelFilters(context, allDrugs, filter),
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
