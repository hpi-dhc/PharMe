import 'dart:async';

import '../../module.dart';
import 'tutorial_builder.dart';
import 'tutorial_page.dart';

class TutorialController {
  factory TutorialController() {
    return _instance;
  }
  TutorialController._();
  static final TutorialController _instance = TutorialController._();
  static TutorialController get instance => _instance;

  bool _isOpen = false;
  bool _wasRoutedBack = false;

  void initiateRouteBack() => _wasRoutedBack = true;

  FutureOr<void> showTutorial({
    required BuildContext context,
    required List<TutorialPage> pages,
    String? lastNextButtonText,
    String? firstBackButtonText,
    FutureOr<void> Function()? onClose,
    bool fitToContent = false,
  }) async {
    if (_isOpen) return null;
    _isOpen = true;
    _wasRoutedBack = false;
    await showModalBottomSheet(
      context: context,
      enableDrag: true,
      showDragHandle: true,
      isDismissible: false,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      elevation: 0,
      builder: (context) => TutorialBuilder(
        pages: pages,
        lastNextButtonText: lastNextButtonText,
        firstBackButtonText: firstBackButtonText,
        initiateRouteBack: initiateRouteBack,
        fitToContent: fitToContent,
      ),
    );
    _isOpen = false;
    if (!_wasRoutedBack && onClose != null) await onClose();
  }
}
