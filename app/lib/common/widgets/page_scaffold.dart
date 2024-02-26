import '../module.dart';

EdgeInsets pagePadding() => EdgeInsets.only(
  left: PharMeTheme.defaultPagePadding,
  right: PharMeTheme.defaultPagePadding,
);

Widget buildTitle(String text) {
  return FittedBox(
    fit: BoxFit.fitWidth,
    child: Text(text, style: PharMeTheme.textTheme.headlineLarge),
  );
}

AppBar? buildBarBottom(String? barBottom) {
  return barBottom == null
    ? null
    : AppBar(
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        backgroundColor: PharMeTheme.appBarTheme.backgroundColor,
        elevation: PharMeTheme.appBarTheme.elevation,
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: barBottom,
                style: PharMeTheme.textTheme.bodyLarge,
              ),
            ]
          ),
        ),
      );
}

Scaffold pageScaffold({
  required String title,
  required List<Widget> body,
  String? barBottom,
  List<Widget>? actions,
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
        floating: true,
        pinned: true,
        snap: false,
        centerTitle: PharMeTheme.appBarTheme.centerTitle,
        title: buildTitle(title),
        actions: actions,
        bottom: buildBarBottom(barBottom),
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
  String? barBottom,
  List<Widget>? actions,
  Widget? drawer,
  bool automaticallyImplyLeading = true,
  Key? key,
}) {
  final appBar = title == null
    ? null
    : AppBar(
        backgroundColor: PharMeTheme.appBarTheme.backgroundColor,
        foregroundColor: PharMeTheme.appBarTheme.foregroundColor,
        elevation: PharMeTheme.appBarTheme.elevation,
        leadingWidth: PharMeTheme.appBarTheme.leadingWidth,
        automaticallyImplyLeading: automaticallyImplyLeading,
        centerTitle: PharMeTheme.appBarTheme.centerTitle,
        title: buildTitle(title),
        actions: actions,
        bottom: buildBarBottom(barBottom),
        scrolledUnderElevation: 0,
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
    drawer: drawer,
  );
}
