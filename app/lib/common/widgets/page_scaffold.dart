import '../../drug/widgets/tooltip_icon.dart';
import '../module.dart';

double? _getTitleSpacing({required bool backButtonPresent}) {
  return backButtonPresent ? 0 : null;
}

EdgeInsets pagePadding() => EdgeInsets.only(
  left: PharMeTheme.defaultPagePadding,
  right: PharMeTheme.defaultPagePadding,
);

Widget buildTitle(String text, { String? tooltipText }) {
  return FittedBox(
    fit: BoxFit.fitWidth,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(text, style: PharMeTheme.textTheme.headlineMedium),
        if (tooltipText.isNotNullOrBlank) Padding(
          padding: EdgeInsets.only(left: PharMeTheme.smallSpace),
          child: TooltipIcon(
            tooltipText!,
            size: PharMeTheme.textTheme.headlineLarge!.fontSize! * 0.8,
          ),
        ),
      ]
    ),
  );
}

Scaffold pageScaffold({
  required List<Widget> body,
  required String title,
  List<Widget>? actions,
  bool canNavigateBack = true,
  Key? key,
}) {
  return Scaffold(
    key: key,
    body: CustomScrollView(slivers: [
      SliverAppBar(
        scrolledUnderElevation: 0,
        backgroundColor: PharMeTheme.appBarTheme.backgroundColor,
        foregroundColor: PharMeTheme.appBarTheme.foregroundColor,
        elevation: PharMeTheme.appBarTheme.elevation,
        leadingWidth: PharMeTheme.appBarTheme.leadingWidth,
        automaticallyImplyLeading: canNavigateBack,
        floating: true,
        pinned: true,
        snap: false,
        centerTitle: PharMeTheme.appBarTheme.centerTitle,
        title: buildTitle(title),
        actions: actions,
        titleSpacing: _getTitleSpacing(backButtonPresent: canNavigateBack),
      ),
      SliverPadding(
        padding: pagePadding(),
        sliver: SliverList(delegate: SliverChildListDelegate(body)),  
      ),
    ]),
  );
}

Scaffold unscrollablePageScaffold({
  required Widget body,
  String? title,
  String? titleTooltip,
  List<Widget>? actions,
  bool canNavigateBack = true,
  Key? key,
}) {
  final appBar = title == null
    ? null
    : AppBar(
        backgroundColor: PharMeTheme.appBarTheme.backgroundColor,
        foregroundColor: PharMeTheme.appBarTheme.foregroundColor,
        elevation: PharMeTheme.appBarTheme.elevation,
        leadingWidth: PharMeTheme.appBarTheme.leadingWidth,
        automaticallyImplyLeading: canNavigateBack,
        centerTitle: PharMeTheme.appBarTheme.centerTitle,
        title: buildTitle(title, tooltipText: titleTooltip),
        actions: actions,
        scrolledUnderElevation: 0,
        titleSpacing: _getTitleSpacing(backButtonPresent: canNavigateBack),
      );
  return Scaffold(
    key: key,
    appBar: appBar,
    body: SafeArea(
      child: Padding(
        padding: pagePadding(),
        child: body,
      ),
    ),
  );
}
