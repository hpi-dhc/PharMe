import '../../../common/constants.dart';

class Lab {
  Lab(this.name, this.authUrl, this.allelesUrl);

  String name;
  String authUrl;
  String allelesUrl;
}

final labs = [
  Lab(
    'Illumina Solutions Center Berlin',
    '$keycloakUrl/auth/realms/pharme',
    '$labServerUrl/star-alleles',
  ),
  Lab(
    'Mount Sinai Hospital (NYC)',
    '$keycloakUrl/auth/realms/pharme',
    '$labServerUrl/star-alleles',
  )
];
