import 'dart:async';

import '../../common/module.dart';

@RoutePage()
class SecurePage extends HookWidget {
  const SecurePage({super.key});

  @override
  Widget build(BuildContext context) {
    final appActive = useState(false);
    final showHelp = useState(false);
    useEffect(() {
      final timer = Timer(
        Duration(milliseconds: 500), () {
          if (appActive.value) showHelp.value = true;
        },
      );
      return timer.cancel;
    });
    useOnAppLifecycleStateChange((previous, current) async {
      if (current == AppLifecycleState.resumed) {
        appActive.value = true;
      }
      if (
        current == AppLifecycleState.inactive ||
        current == AppLifecycleState.paused
      ) {
        appActive.value = false;
        showHelp.value = false;
      }
    });
    final buttonText = context.l10n.action_back_to_pharme;
    return PharMeLogoPage(
      child: Padding(
        padding: EdgeInsets.all(PharMeTheme.largeSpace),
        child: Visibility(
          visible: showHelp.value,
          maintainAnimation: true,
          maintainSize: false,
          maintainState: true,
          child:  AnimatedOpacity(
            opacity: showHelp.value ? 1.0 : 0.0,
            duration: Duration(milliseconds: 500),
            child: Column(
              children: [
                FullWidthButton(
                  buttonText,
                  () => routeBackAfterSecurePage(context.router),
                ),
                SizedBox(height: PharMeTheme.mediumSpace),
                Hyperlink(
                  text: context.l10n.secure_page_explanation_link,
                  color: PharMeTheme.buttonColor,
                  onTap: () => showAdaptiveDialog(
                    context: context,
                    builder: (context) => DialogWrapper(
                      title: context.l10n.secure_page_dialog_title,
                      content: DialogContentText(
                        context.l10n.secure_page_dialog_body(buttonText),
                      ),
                      actions: [
                        DialogAction(
                          text: context.l10n.action_ok,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
