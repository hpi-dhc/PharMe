import 'package:flutter_dotenv/flutter_dotenv.dart';

class Lab {
  Lab(this.name, this.authUrl, this.allelesUrl);

  String name;
  String authUrl;
  String allelesUrl;
}

final labs = [
  Lab(
    'Illumina Solutions Center Berlin',
    'http://172.20.24.66:28080/auth/realms/pharme',
    '${dotenv.get('BACKEND_URL', fallback: 'https://example.com')}/api/v1/star-alleles',
  ),
  Lab(
    'Mount Sinai Hospital (NYC)',
    'http://172.20.24.66:28080/auth/realms/pharme',
    '${dotenv.get('BACKEND_URL', fallback: 'https://example.com')}/api/v1/star-alleles',
  )
];
