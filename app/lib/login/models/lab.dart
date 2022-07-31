import '../../common/module.dart';

class Lab {
  Lab({
    required this.name,
    required this.authUrl,
    required this.tokenUrl,
    required this.starAllelesUrl,
  });

  String name;
  Uri authUrl;
  Uri tokenUrl;
  Uri starAllelesUrl;
}

final labs = [
  Lab(
    name: 'Illumina Solutions Center Berlin',
    authUrl: keycloakUrl('/realms/pharme/protocol/openid-connect/auth'),
    tokenUrl: keycloakUrl('/realms/pharme/protocol/openid-connect/token'),
    starAllelesUrl: labServerUrl('/star-alleles'),
  ),
  Lab(
    name: 'Mount Sinai Hospital (NYC)',
    authUrl: keycloakUrl('/realms/pharme/protocol/openid-connect/auth'),
    tokenUrl: keycloakUrl('/realms/pharme/protocol/openid-connect/token'),
    starAllelesUrl: labServerUrl('/star-alleles'),
  )
];
