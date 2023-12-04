import 'dart:io' show Platform;

enum SupportedPlatform { ios, android }

SupportedPlatform getPlatform() {
  if (Platform.isIOS) return SupportedPlatform.ios;
  if (Platform.isAndroid) return SupportedPlatform.android;
  throw Exception('Unsupported platform: ${Platform.operatingSystem}');
}