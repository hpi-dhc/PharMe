import '../../common/module.dart';

class Lab {
  Lab(this.name, this.authUrl, this.endpoint);

  String name;
  String authUrl;
  String endpoint;
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
