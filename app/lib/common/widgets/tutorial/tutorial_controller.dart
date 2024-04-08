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

  FutureOr<void> showTutorial({
    required BuildContext context,
    required List<TutorialPage> pages,
    String? lastNextButtonText,
    FutureOr<void> Function()? onClose,
  }) async {
    if (_isOpen) return null;
    _isOpen = true;
    await showModalBottomSheet(
      context: context,
      enableDrag: true,
      showDragHandle: true,
      isDismissible: false,
      isScrollControlled: true,
      useSafeArea: true,
      elevation: 0,
      builder: (context) => TutorialBuilder(
        pages: pages,
        lastNextButtonText: lastNextButtonText,
      ),
    );
    if (onClose != null) await onClose();
    _isOpen = false;
  }
}
