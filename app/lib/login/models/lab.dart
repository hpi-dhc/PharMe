import '../../common/module.dart';

class Lab {
  Lab({
    required this.name,
    required this.type,
  });

  String name;
  String type;
}

class KeycloakLab extends Lab {
  KeycloakLab({
    required String name,
    required this.authUrl,
    required this.tokenUrl,
    required this.starAllelesUrl}):
      super(name: name, type: labTypes['keycloak']!);

  Uri authUrl;
  Uri tokenUrl;
  Uri starAllelesUrl;
}

class AppShareLab extends Lab {
  AppShareLab({
    required String name,
    required this.appLink,
  }): super(name: name, type: labTypes['appshare']!);

  String appLink;
}

final labs = [
  AppShareLab(name: 'Health-X dataLOFT', appLink: 'com.healthx.dwa'),
  KeycloakLab(
    name: 'Mount Sinai Health System',
    authUrl: keycloakUrl('realms/pharme/protocol/openid-connect/auth'),
    tokenUrl: keycloakUrl('realms/pharme/protocol/openid-connect/token'),
    starAllelesUrl: labServerUrl('star-alleles'),
  ),
];
