import '../../module.dart';
import 'content.dart';

class TutorialContainer extends HookWidget {
  const TutorialContainer({
    super.key,
    required this.pages,
    this.lastNextButtonText,
  });

  final List<TutorialContent> pages;
  final String? lastNextButtonText;

  @override
  Widget build(BuildContext context) {
    final currentPageIndex = useState(0);
    return Padding(
      padding: EdgeInsets.only(
        left: PharMeTheme.largeSpace,
        bottom: PharMeTheme.largeSpace,
        right: PharMeTheme.largeSpace,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _buildPageContent(context, currentPageIndex),
      ),
    );
  }

  List<Widget> _buildPageContent(
    BuildContext context,
    ValueNotifier<int> currentPageIndex,
  ) {
    final currentPage = pages[currentPageIndex.value];
    final title = currentPage.title != null
      ? currentPage.title!(context)
      : null;
    final content = currentPage.content != null
      ? currentPage.content!(context)
      : null;
    final asset = currentPage.assetPath != null
      ? Image.asset(currentPage.assetPath!)
      : null;
    return [
      if (title != null) Text(
        title,
        style: PharMeTheme.textTheme.headlineMedium!.copyWith(
          fontSize: PharMeTheme.textTheme.headlineSmall!.fontSize,
        ),
      ),
      if (content != null) Padding(
        padding: EdgeInsetsDirectional.only(top: PharMeTheme.mediumSpace),
        child: Text.rich(content, style: PharMeTheme.textTheme.bodyLarge),
      ),
      if (asset != null) Expanded(
        child: Padding(
          padding: EdgeInsetsDirectional.only(top: PharMeTheme.mediumSpace),
          // child: Container(),
          child: Center(child: asset),
        ),
      ),
      Padding(
        padding: EdgeInsetsDirectional.only(top: PharMeTheme.mediumSpace),
        child: _buildActionBar(context, currentPageIndex),
      ),
    ];
  }

  Widget _buildActionBar(
    BuildContext context,
    ValueNotifier<int> currentPageIndex,
  ) {
    final isFirstPage = currentPageIndex.value == 0;
    final isLastPage = currentPageIndex.value == pages.length - 1;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (!isFirstPage) DirectionButton(
          direction: ButtonDirection.backward,
          onPressed: () => currentPageIndex.value = currentPageIndex.value - 1,
          text: context.l10n.onboarding_prev,
        ),
        DirectionButton(
          direction: ButtonDirection.forward,
          onPressed: isLastPage
            ? Navigator.of(context).pop
            : () => currentPageIndex.value = currentPageIndex.value + 1,
          
          text: isLastPage && lastNextButtonText != null
            ? lastNextButtonText!
            : context.l10n.action_continue,
          emphasize: isLastPage,
          ),
      ],
    );
  }
}