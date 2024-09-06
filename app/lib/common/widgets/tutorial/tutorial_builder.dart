import '../../module.dart';
import 'tutorial_page.dart';

class TutorialBuilder extends HookWidget {
  const TutorialBuilder({
    super.key,
    required this.pages,
    this.lastNextButtonText,
  });

  final List<TutorialPage> pages;
  final String? lastNextButtonText;

  Widget getImageAsset(String assetPath) {
    return Container(
      color: PharMeTheme.onSurfaceColor,
      child: Center(child: Image.asset(assetPath)),
    );
  }

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
    final titleStyle = PharMeTheme.textTheme.headlineMedium!.copyWith(
      fontSize: PharMeTheme.textTheme.headlineSmall!.fontSize,
    );
    final assetContainer = currentPage.assetPath != null
      ? Stack(
          children: [
            getImageAsset(currentPage.assetPath!),
            Positioned(
              top: PharMeTheme.smallSpace,
              right: PharMeTheme.smallSpace,
              child: IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: PharMeTheme.onSurfaceText,
                ),
                color: PharMeTheme.onSurfaceColor,
                onPressed: () async => {
                  await showDialog(
                  // ignore: use_build_context_synchronously
                    context: context,
                    builder: (context) => Dialog.fullscreen(
                      backgroundColor: Colors.transparent,
                      child: SafeArea(
                        child: RoundedCard(
                          outerHorizontalPadding: 0,
                          outerVerticalPadding: 0,
                          innerPadding: EdgeInsets.all(PharMeTheme.largeSpace),
                          child: Column(
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  if (title != null) Expanded(
                                    child: FittedBox(
                                      fit: BoxFit.fitWidth,
                                      child: Text(
                                        title,
                                        style: titleStyle,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: PharMeTheme.smallSpace),
                                  GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: Icon(
                                      Icons.close,
                                      color: PharMeTheme.onSurfaceText,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: PharMeTheme.smallToMediumSpace),
                              Expanded(
                                child: getImageAsset(currentPage.assetPath!),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                },
                icon: Icon(Icons.zoom_in),
              ),
            ),
          ],
      )
      : null;
    return [
      if (title != null) Text(
        title,
        style: titleStyle,
      ),
      if (content != null) Padding(
        padding: EdgeInsetsDirectional.only(top: PharMeTheme.mediumSpace),
        child: Text.rich(content, style: PharMeTheme.textTheme.bodyLarge),
      ),
      if (assetContainer != null) Expanded(
        child: Padding(
          padding: EdgeInsetsDirectional.only(top: PharMeTheme.mediumSpace),
          child: assetContainer,
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
    final directionButtonTextStyle =
      PharMeTheme.textTheme.titleLarge!.copyWith(fontSize: 20);
    const directionButtonIconSize = 22.0;
    return Row(
      mainAxisAlignment: isFirstPage
        ? MainAxisAlignment.end
        : MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: [
        if (!isFirstPage) DirectionButton(
          direction: ButtonDirection.backward,
          onPressed: () => currentPageIndex.value = currentPageIndex.value - 1,
          text: context.l10n.onboarding_prev,
          buttonTextStyle: directionButtonTextStyle,
          iconSize: directionButtonIconSize,
        ),
        DirectionButton(
          direction: ButtonDirection.forward,
          onPressed: isLastPage
            ? Navigator.of(context).pop
            : () => currentPageIndex.value = currentPageIndex.value + 1,
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