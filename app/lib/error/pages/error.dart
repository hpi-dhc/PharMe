import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

import '../../common/module.dart';

@RoutePage()
class ErrorPage extends StatelessWidget {
  const ErrorPage({required this.error, super.key});

  final String error;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: PharMeLogoPage(
        greyscale: true,
        child: Column(
          children: [
            Text(
              context.l10n.error_title,
              style: PharMeTheme.textTheme.headlineMedium,
            ),
            SizedBox(height: PharMeTheme.mediumSpace),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: PharMeTheme.textTheme.bodyLarge,
                children: [
                  TextSpan(
                    text: context.l10n.error_uncaught_message_first_part,
                  ),
                  TextSpan(
                    text: context.l10n.error_uncaught_message_bold_part,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
            SizedBox(height: PharMeTheme.mediumSpace),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: PharMeTheme.textTheme.bodyLarge,
                children: [
                  TextSpan(text: context.l10n.error_uncaught_message_contact),
                  TextSpan(
                    text: context.l10n.error_contact_link_text,
                    style: TextStyle(
                      color: PharMeTheme.secondaryColor,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()..onTap =
                      () {
                        sendEmail(
                          subject: context.l10n.error_mail_subject,
                          body: context.l10n.error_mail_body(error),
                        );
                      },
                  ),
                  TextSpan(
                    text: context.l10n.error_uncaught_message_after_link,
                  ),
                ],
              ),
            ),
            SizedBox(height: PharMeTheme.mediumSpace),
            FullWidthButton(context.l10n.error_close_app, () async {
              if (Platform.isIOS) {
                exit(0);
              }
              await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
            }),
          ],
        ),
      ),
    );
  }
}