import 'dart:async';

import '../../module.dart';
import 'container.dart';

class TutorialController {
  factory TutorialController() {
    return _instance;
  }
  TutorialController._();
  static final TutorialController _instance = TutorialController._();

  bool _isOpen = false;

  FutureOr<void> showTutorial({
    required BuildContext context,
    required List<TutorialContent> pages,
    String? lastNextButtonText,
    FutureOr<void> Function()? onClose,
  }) {
    if (_isOpen) return null;
    _isOpen = true;
    return showModalBottomSheet(
      context: context,
      enableDrag: true,
      showDragHandle: true,
      isDismissible: false,
      isScrollControlled: true,
      useSafeArea: true,
      elevation: 0,
      builder: (context) => TutorialContainer(
        pages: pages,
        lastNextButtonText: lastNextButtonText,
        finishTutorial: () async {
          final closeTutorial = Navigator.of(context).pop;
          if (onClose != null) await onClose();
          _isOpen = false;
          closeTutorial();
        },
      ),
    );
  }
}
