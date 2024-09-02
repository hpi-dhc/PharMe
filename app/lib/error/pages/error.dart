import 'dart:io';

import '../../common/module.dart';

@RoutePage()
class ErrorPage extends StatelessWidget {
  const ErrorPage({required this.error, super.key});

  final String error;

  Text _errorText(String text, { TextStyle? style }) => Text(
    text,
    textAlign: TextAlign.center,
    style: style != null
      ? PharMeTheme.textTheme.bodyLarge!.merge(style)
      : PharMeTheme.textTheme.bodyLarge,
  );

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: PharMeLogoPage(
        greyscale: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _errorText(
              context.l10n.error_title,
              style: PharMeTheme.textTheme.headlineMedium,
            ),
            SizedBox(height: PharMeTheme.mediumSpace),
            _errorText(context.l10n.error_uncaught_message_first_part),
            SizedBox(height: PharMeTheme.smallSpace),
            _errorText(
              context.l10n.error_uncaught_message_bold_part,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: PharMeTheme.smallSpace),
            _errorText(context.l10n.error_uncaught_message_contact),
            SizedBox(height: PharMeTheme.smallSpace),
            Hyperlink(
              text: contactEmailAddress,
              style: PharMeTheme.textTheme.bodyLarge,
              onTap: () => sendEmail(
                context,
                subject: context.l10n.error_mail_subject,
                body: context.l10n.error_mail_body(error),
              ),
            ),
            SizedBox(height: PharMeTheme.mediumSpace),
            FullWidthButton(
              context.l10n.error_close_app,
              () => exit(0),
              secondaryColor: true,
            ),
            SizedBox(height: PharMeTheme.mediumSpace),
          ],
        ),
      ),
    );
  }
}