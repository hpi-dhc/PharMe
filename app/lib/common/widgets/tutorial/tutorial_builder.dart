import 'package:expandable_page_view/expandable_page_view.dart';

import '../../module.dart';
import '../scrollable_stack_with_indicator.dart';
import 'tutorial_page.dart';

class TutorialBuilder extends HookWidget {
  const TutorialBuilder({
    super.key,
    required this.pages,
    required this.initiateRouteBack,
    this.lastNextButtonText,
    this.firstBackButtonText,
    required this.fitToContent,
  });

  final List<TutorialPage> pages;
  final String? lastNextButtonText;
  final String? firstBackButtonText;
  final void Function() initiateRouteBack;
  final bool fitToContent;

  Widget getImageAsset(String assetPath) {
    return Container(
      color: PharMeTheme.onSurfaceColor,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: PharMeTheme.largeSpace),
        child: Image.asset(assetPath),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pageWidgets = pages.map(
      (page) => _buildPageContent(context, page),
    );
    final currentPageIndex = useState(0);
    final pageController = usePageController(initialPage: currentPageIndex.value);
    final pageView = fitToContent
      ? ExpandablePageView(
          controller: pageController,
          onPageChanged: (newPage) => currentPageIndex.value = newPage,
          children: pageWidgets.toList(),
        )
      : Expanded(
          child: PageView(
            controller: pageController,
            onPageChanged: (newPage) => currentPageIndex.value = newPage,
            children: pageWidgets.toList(),
          )
        );
    return Padding(
      padding: EdgeInsets.only(
        left: PharMeTheme.mediumSpace,
        bottom: PharMeTheme.mediumSpace,
        right: PharMeTheme.mediumSpace,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          pageView,
          Padding(
            padding: EdgeInsets.only(top: PharMeTheme.smallSpace),
            child: _buildActionBar(
              context,
              currentPageIndex,
              pageController,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent(
    BuildContext context,
    TutorialPage currentPage,
  ) {
    final title = currentPage.title != null
      ? currentPage.title!(context)
      : null;
    final content = currentPage.content != null
      ? currentPage.content!(context)
      : null;
    final titleStyle = PharMeTheme.textTheme.headlineMedium!.copyWith(
      fontSize: PharMeTheme.textTheme.headlineSmall!.fontSize,
    );
    final assetContainer = currentPage.assetPath != null
      ? getImageAsset(currentPage.assetPath!)
      : null;
    return ScrollableStackWithIndicator(
      rightScrollbarPadding: 0,
      thumbColor: PharMeTheme.subheaderColor,
      children: [
        if (title != null) Text(
          title,
          style: titleStyle,
        ),
        if (content != null) Padding(
          padding: EdgeInsetsDirectional.only(top: PharMeTheme.mediumSpace),
          child: content,
        ),
        if (assetContainer != null) Padding(
          padding: EdgeInsetsDirectional.only(top: PharMeTheme.mediumSpace),
          child: assetContainer,
        ),
      ],
    );
  }

  Widget _buildActionBar(
    BuildContext context,
    ValueNotifier<int> currentPageIndex,
    PageController pageController,
  ) {
    final isFirstPage = currentPageIndex.value == 0;
    final showFirstButton = !isFirstPage || (
      firstBackButtonText.isNotNullOrBlank &&
      context.router.canPop(
        ignoreChildRoutes: true,
        ignorePagelessRoutes: true,
      )
    );
    final isLastPage = currentPageIndex.value == pages.length - 1;
    final directionButtonTextStyle =
      PharMeTheme.textTheme.titleLarge!.copyWith(fontSize: 20);
    const directionButtonIconSize = 22.0;
    void navigateIfSafe(void Function() navigate, { required bool isForward }) {
      if (pageController.page == null) {
        navigate();
        return;
      }
      final pageChangeProgress = pageController.page! % 1;
      if (pageChangeProgress == 0) {
        navigate();
        return;
      }
      const allowPageChangeThreshold = 0.5;
      final allowPageChange = isForward
        ? pageChangeProgress >= allowPageChangeThreshold
        : pageChangeProgress <= (1 - allowPageChangeThreshold);
      if (allowPageChange) navigate();
    }
    return Row(
      mainAxisAlignment: showFirstButton
        ? MainAxisAlignment.spaceBetween
        : MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      children: [
        if (showFirstButton) DirectionButton(
          direction: ButtonDirection.backward,
          onPressed: () => navigateIfSafe(
            isFirstPage
              ? () {
                initiateRouteBack();
                routeBackToContent(context.router, popNull: true);
              }
              : () => pageController.previousPage(
                duration: Duration(milliseconds: 500),
                curve: Curves.ease,
              ),
            isForward: false,
          ),
          text: isFirstPage
            ? firstBackButtonText!
            : context.l10n.onboarding_prev,
          buttonTextStyle: directionButtonTextStyle,
          iconSize: directionButtonIconSize,
        ),
        DirectionButton(
          direction: ButtonDirection.forward,
          onPressed: () => navigateIfSafe(
            isLastPage
              ? Navigator.of(context).pop
              : () => pageController.nextPage(
                duration: Duration(milliseconds: 500),
                curve: Curves.ease,
              ),
            isForward: true,
          ),
          text: isLastPage && lastNextButtonText != null
            ? lastNextButtonText!
            : context.l10n.action_continue,
          emphasize: true,
          buttonTextStyle: directionButtonTextStyle,
          iconSize: directionButtonIconSize,
        ),
      ],
    );
  }
}