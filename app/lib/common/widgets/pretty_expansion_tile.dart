import '../module.dart';

class PrettyExpansionTile extends StatelessWidget {
  const PrettyExpansionTile({
    super.key,
    required this.title,
    required this.children,
    this.onExpansionChanged,
    this.visualDensity,
    this.titlePadding,
    this.childrenPadding,
    this.icon,
    this.initiallyExpanded = false,
    this.enabled = true,
  });

  final Widget title;
  // ignore: avoid_positional_boolean_parameters
  final void Function(bool)? onExpansionChanged;
  final List<Widget> children;
  final VisualDensity? visualDensity;
  final EdgeInsets? titlePadding;
  final EdgeInsets? childrenPadding;
  final Widget? icon;
  final bool initiallyExpanded;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: ExpansionTile(
        key: GlobalKey(), // force to rebuild
        enabled: enabled,
        initiallyExpanded: initiallyExpanded,
        title: title,
        iconColor: PharMeTheme.iconColor,
        trailing: icon,
        collapsedIconColor: PharMeTheme.iconColor,
        onExpansionChanged: onExpansionChanged,
        visualDensity: visualDensity,
        tilePadding: titlePadding,
        childrenPadding: childrenPadding,
        children: children,
      ),
    );
  }
}