import '../../module.dart';
import 'container.dart';

Future<void> showTutorial({
  required BuildContext context,
  required List<TutorialContent> pages,
  String? lastNextButtonText,
  required Function() updateMetadata,
}) =>  showModalBottomSheet(
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
      updateMetadata();
      await MetaData.save();
      closeTutorial();
    },
  ),
);