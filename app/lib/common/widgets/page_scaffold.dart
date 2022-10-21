import '../module.dart';

Scaffold pageScaffold(
    {required String title, Widget? barBottom, required List<Widget> body}) {
  return Scaffold(
    body: CustomScrollView(slivers: [
      SliverAppBar(
        backgroundColor: PharMeTheme.surfaceColor,
        elevation: 0,
        floating: true,
        pinned: true,
        snap: false,
        centerTitle: false,
        title: Text(title, style: PharMeTheme.textTheme.headlineLarge),
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
