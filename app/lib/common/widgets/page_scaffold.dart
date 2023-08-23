import '../module.dart';

Text buildTitle(String text) {
  return Text(text, style: PharMeTheme.textTheme.headlineLarge);
}

AppBar? buildBarBottom(Widget? barBottom) {
  return barBottom == null
    ? null
    : AppBar(
        backgroundColor: PharMeTheme.appBarTheme.backgroundColor,
        elevation: PharMeTheme.appBarTheme.elevation,
        title: barBottom,
      );
}

Scaffold pageScaffold({
  required String title,
  required List<Widget> body,
  Widget? barBottom,
  List<Widget>? actions,
  Key? key,
}) {
  return Scaffold(
    key: key,
    body: CustomScrollView(slivers: [
      SliverAppBar(
        backgroundColor: PharMeTheme.appBarTheme.backgroundColor,
        foregroundColor: PharMeTheme.appBarTheme.foregroundColor,
        elevation: PharMeTheme.appBarTheme.elevation,
        leadingWidth: PharMeTheme.appBarTheme.leadingWidth,
        floating: true,
        pinned: true,
        snap: false,
        centerTitle: PharMeTheme.appBarTheme.centerTitle,
        title: buildTitle(title),
        actions: actions,
        bottom: buildBarBottom(barBottom),
      ),
      SliverList(delegate: SliverChildListDelegate(body))
    ]),
  );
}

Scaffold unscrollablePageScaffold({
  required Widget body,
  String? title,
  Widget? barBottom,
  List<Widget>? actions,
  Key? key,
}) {
  final appBar = title == null
    ? null
    : AppBar(
      backgroundColor: PharMeTheme.appBarTheme.backgroundColor,
      foregroundColor: PharMeTheme.appBarTheme.foregroundColor,
      elevation: PharMeTheme.appBarTheme.elevation,
      leadingWidth: PharMeTheme.appBarTheme.leadingWidth,
      centerTitle: PharMeTheme.appBarTheme.centerTitle,
      title: buildTitle(title),
      actions: actions,
      bottom: buildBarBottom(barBottom),
    );
  return Scaffold(
    key: key,
    appBar: appBar,
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(PharMeTheme.smallSpace),
        child: body,
      ),
    ),
  );
}
