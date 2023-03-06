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
    name: 'Mount Sinai Health System',
    authUrl: keycloakUrl('/realms/pharme/protocol/openid-connect/auth'),
    tokenUrl: keycloakUrl('/realms/pharme/protocol/openid-connect/token'),
    starAllelesUrl: labServerUrl('/star-alleles'),
  )
];
