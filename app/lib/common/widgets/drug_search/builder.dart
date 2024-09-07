
import 'package:flutter/cupertino.dart';

import '../../../../common/module.dart';
import '../../../drug/widgets/tooltip_icon.dart';

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

class DrugSearch extends HookWidget {
  const DrugSearch({
    super.key,
    required this.showFilter,
    required this.buildDrugItems,
    required this.showDrugInteractionIndicator,
    required this.searchForDrugClass,
    required this.cubit,
    required this.state,
    required this.activeDrugs,
    this.keepPosition = false,
    this.repeatMedications = false,
  });

  final bool showFilter;
  final bool searchForDrugClass;
  final bool keepPosition;
  final bool repeatMedications;
  final DrugItemBuilder buildDrugItems;
  final bool showDrugInteractionIndicator;
  final DrugListCubit cubit;
  final DrugListState state;
  final ActiveDrugs activeDrugs;

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

  @override
  Widget build(BuildContext context) {
    final searchController = useTextEditingController();
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: PharMeTheme.smallSpace,
            right: PharMeTheme.smallSpace,
            bottom: PharMeTheme.smallSpace,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: _buildSearchBarItems(context, searchController),
              ),
            ],
          ),
        ),
        if (showFilter) state.whenOrNull(
          loaded: (allDrugs, filter) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SubheaderDivider(
                text: context.l10n.search_page_filter_label,
                useLine: false,
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: PharMeTheme.smallSpace,
                  right: PharMeTheme.smallSpace,
                  bottom: PharMeTheme.smallSpace,
                ),
                child: Wrap(
                  spacing: PharMeTheme.smallSpace,
                  runSpacing: PharMeTheme.smallSpace,
                  runAlignment: WrapAlignment.center,
                  alignment: WrapAlignment.start,
                  children: [
                    ..._buildWarningLevelFilters(context, allDrugs, filter),
                  ],
                ),
              ),
            ],
          )
        ) ?? SizedBox.shrink(),
        DrugList(
          state: state,
          activeDrugs: activeDrugs,
          buildDrugItems: buildDrugItems,
          showDrugInteractionIndicator: showDrugInteractionIndicator,
          noDrugsMessage: context.l10n.search_no_drugs(
            showFilter
              ? context.l10n.search_no_drugs_with_filter_amendment
              : ''
          ),
          searchForDrugClass: searchForDrugClass,
          buildContainer:
            (children) => scrollList(keepPosition: keepPosition, children),
          repeatMedications: repeatMedications,
        ),
        _maybeBuildInteractionIndicator(context, state, activeDrugs)
          ?? SizedBox.shrink(),
      ],
    );
  }

  List<Widget> _buildSearchBarItems(
    BuildContext context,
    TextEditingController searchController,
  ) {
    return [
      Expanded(
        child: CupertinoSearchTextField(
          controller: searchController,
          onChanged: (value) {
            context.read<DrugListCubit>().search(
              query: value,
            );
          },
        ),
      ),
      SizedBox(width: PharMeTheme.smallToMediumSpace),
      TooltipIcon(searchForDrugClass
        ? context.l10n.search_page_tooltip_search
        : context.l10n.search_page_tooltip_search_no_class
      ),
    ];
  }

  Widget? _maybeBuildInteractionIndicator(
    BuildContext context,
    DrugListState state,
    ActiveDrugs activeDrugs,
  ) {
    return state.whenOrNull(
      loaded: (drugs, filter) {
        if (showDrugInteractionIndicator) {
          final filteredDrugs = filter.filter(
            drugs,
            activeDrugs,
            searchForDrugClass: searchForDrugClass,
          );
          if (filteredDrugs.any((drug) => isInhibitor(drug.name))) {
            return PageIndicatorExplanation(
              context.l10n.search_page_indicator_explanation(
                drugInteractionIndicatorName,
                drugInteractionIndicator
              ),
            );
          }
        }
        return null;
      }
    );
  }
}
