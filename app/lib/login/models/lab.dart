import '../../common/module.dart';

class Lab {
  Lab({
    required this.name,
    required this.authUrl,
    required this.tokenUrl,
    required this.endpoint,
  });

  String name;
  Uri authUrl;
  Uri tokenUrl;
  String endpoint;
}

final labs = [
  Lab(
    name: 'Illumina Solutions Center Berlin',
    authUrl: keycloakUrl.replace(
      path: '/auth/realms/pharme/protocol/openid-connect/auth',
    ),
    tokenUrl: keycloakUrl.replace(
      path: '/auth/realms/pharme/protocol/openid-connect/token',
    ),
    endpoint: '$labServerUrl/star-alleles',
  ),
  Lab(
    name: 'Mount Sinai Hospital (NYC)',
    authUrl: keycloakUrl.replace(
      path: '/auth/realms/pharme/protocol/openid-connect/auth',
    ),
    tokenUrl: keycloakUrl.replace(
      path: '/auth/realms/pharme/protocol/openid-connect/token',
    ),
    endpoint: '$labServerUrl/star-alleles',
  )
];
