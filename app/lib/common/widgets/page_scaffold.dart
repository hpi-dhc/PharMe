import '../module.dart';

Scaffold pageScaffold(
    {required String title,
    Widget? barBottom,
    List<Widget>? actions,
    required List<Widget> body}) {
  return Scaffold(
    body: CustomScrollView(slivers: [
      SliverAppBar(
        backgroundColor: PharMeTheme.surfaceColor,
        foregroundColor: PharMeTheme.onSurfaceText,
        elevation: 0,
        leadingWidth: 24,
        floating: true,
        pinned: true,
        snap: false,
        centerTitle: false,
        title: Text(title, style: PharMeTheme.textTheme.headlineLarge),
        actions: actions,
        bottom: barBottom == null
            ? null
            : AppBar(
                backgroundColor: PharMeTheme.backgroundColor,
                elevation: 0,
                title: barBottom,
              ),
      ),
      SliverList(delegate: SliverChildListDelegate(body))
    ]),
  );
}
