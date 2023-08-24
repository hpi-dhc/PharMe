import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Uri anniUrl([String slug = '']) =>
    Uri.http('vm-slosarek01.dhclab.i.hpi.de:8000', 'api/v1/$slug');
Uri labServerUrl([String slug = '']) =>
    Uri.http('vm-slosarek01.dhclab.i.hpi.de:8081', 'api/v1/$slug');
Uri keycloakUrl([String slug = '']) =>
    Uri.http('vm-slosarek01.dhclab.i.hpi.de:28080', 'auth/$slug');

// Note that sending emails will not work on the iPhone Simulator since it does
// not have any email application installed.
String _mailContact = 'pgx-app-validation-study@lists.myhpi.de';
Future<void> sendEmail({String subject = ''}) async {
  await launchUrl(Uri(
      scheme: 'mailto',
      path: _mailContact,
      queryParameters: {'subject': subject}));
}

final cpicMaxCacheTime = Duration(days: 90);
const maxCachedDrugs = 10;
const cpicLookupUrl =
    'https://api.cpicpgx.org/v1/diplotype?select=genesymbol,diplotype,generesult,lookupkey';
const indeterminateIcon = Icons.help_outline_rounded;

const drugInteractionIndicator = '*';
const drugInteractionIndicatorName = 'asterisk';
