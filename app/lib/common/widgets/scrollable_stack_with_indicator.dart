import '../module.dart';

class ScrollableStackWithIndicator extends HookWidget {
  const ScrollableStackWithIndicator({
    super.key,
    this.thumbColor,
    this.iconColor,
    this.iconSize,
    this.rightScrollbarPadding,
    required this.children,
  });

  final List<Widget> children;
  final Color? thumbColor;
  final Color? iconColor;
  final double? iconSize;
  final double? rightScrollbarPadding;
  double? _getContentHeight(GlobalKey contentKey) {
    return contentKey.currentContext?.size?.height;
  }

  bool? _contentScrollable(
    GlobalKey contentKey,
    ScrollPosition scrollPosition,
  ) {
    final contentHeight = _getContentHeight(contentKey);
    if (contentHeight == null) return null;
    return scrollPosition.viewportDimension < contentHeight;
  }

  bool? _scrolledToEnd(ScrollPosition scrollPosition) {
    final maxScrollOffset = scrollPosition.maxScrollExtent;
    return scrollPosition.pixels >= maxScrollOffset;
  }

  double? _getRelativeScrollPosition(ScrollPosition scrollPosition) {
    final maxScrollOffset = scrollPosition.maxScrollExtent;
    final relativePosition =
      1 - (maxScrollOffset - scrollPosition.pixels) / maxScrollOffset;
    return relativePosition < 0
      ? 0
      : relativePosition > 1
        ? 1
        : relativePosition;
  }

  @override
  Widget build(BuildContext context) {
    const scrollbarThickness = 6.5;
    final scrollbarPadding = rightScrollbarPadding ?? PharMeTheme.smallSpace;
    final horizontalPadding = scrollbarPadding + 3 * scrollbarThickness;
    final contentKey =  GlobalKey();
    final failedIndicatorInitializationAttempts = useState(0);
    final showScrollIndicatorButton = useState(false);
    final scrollIndicatorButtonOpacity = useState<double>(1);
    final scrollController = useScrollController(
      keepScrollOffset: false,
      initialScrollOffset: 0,
    );

    void handleScrolling() {
      if (scrollController.hasClients) {
        final hideButton = _scrolledToEnd(scrollController.position) ?? false;
        showScrollIndicatorButton.value = !hideButton;
        final relativeScrollPosition =
          _getRelativeScrollPosition(scrollController.position);
        if (relativeScrollPosition != null) {
          scrollIndicatorButtonOpacity.value = 1 - relativeScrollPosition;
        }
      }
    }

    useEffect(() {
      scrollController.addListener(handleScrolling);
      return () => scrollController.removeListener(handleScrolling);
    }, [scrollController]);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final contentScrollable =
          _contentScrollable(contentKey, scrollController.position);
        if (contentScrollable == null) {
          failedIndicatorInitializationAttempts.value += 1;
          return;
        }
        final scrolledToEnd =
          _scrolledToEnd(scrollController.position) ?? false;
        showScrollIndicatorButton.value = contentScrollable && !scrolledToEnd;
      } catch (exception) {
        failedIndicatorInitializationAttempts.value += 1;
      }
    });

    return Stack(
      alignment: Alignment.center,
      children: [
        RawScrollbar(
          controller: scrollController, // needed to always show scrollbar
          thumbVisibility: true,
          shape: StadiumBorder(),
          padding: EdgeInsets.only(
            top: PharMeTheme.mediumToLargeSpace,
            right: scrollbarPadding,
          ),
          thumbColor: thumbColor,
          thickness: scrollbarThickness,
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
              ),
              child: Column(
                key: contentKey,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: children,
              ),
            ),
          ),
        ),
        if (showScrollIndicatorButton.value) Positioned(
          bottom: 0,
          child: Opacity(
            opacity: scrollIndicatorButtonOpacity.value,
            child: IconButton(
            style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                side: BorderSide(
                  color: iconColor ?? PharMeTheme.iconColor,
                  width: 3,
                ),
              ),
              icon: Icon(
                Icons.arrow_downward,
                size: iconSize,
                color: iconColor ?? PharMeTheme.iconColor,
              ),
              onPressed: () async {
                if (scrollController.hasClients) {
                  await scrollController.animateTo(
                    scrollController.position.maxScrollExtent,
                    duration: Duration(milliseconds: 500),
                    curve: Curves.linearToEaseOut,
                  );
                  showScrollIndicatorButton.value = false;
                }
              },
            ),
          ),
        ),
      ],
    );
  } 
}