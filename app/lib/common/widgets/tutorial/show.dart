import '../../module.dart';
import 'container.dart';

Future<void> showTutorial({
  required BuildContext context,
  required List<TutorialContent> pages,
  required bool concludesWholeTutorial,
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
    lastNextButtonText: concludesWholeTutorial
      ? context.l10n.tutorial_to_the_app
      : null,
    finishTutorial: () async {
      final closeTutorial = Navigator.of(context).pop;
      if (concludesWholeTutorial) {
        MetaData.instance.tutorialDone = true;
        await MetaData.save();
      }
      closeTutorial();
    },
  ),
);