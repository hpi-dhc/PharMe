final serverUrl = Uri.http('vm-bp2021eb1.dhclab.i.hpi.de', '');
final annotationServerUrl = serverUrl.replace(port: 8080, path: 'api/v1');
final labServerUrl = serverUrl.replace(port: 8081, path: 'api/v1');
final keycloakUrl = serverUrl.replace(port: 28080);
