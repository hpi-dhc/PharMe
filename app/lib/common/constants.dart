final serverUrl = Uri.http('172.20.24.66', '');
final annotationServerUrl = serverUrl.replace(port: 8080, path: 'api/v1');
final labServerUrl = serverUrl.replace(port: 8081, path: 'api/v1');
final keycloakUrl = serverUrl.replace(port: 28080);
