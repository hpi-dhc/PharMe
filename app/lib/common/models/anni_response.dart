import 'package:freezed_annotation/freezed_annotation.dart';

import '../module.dart';

part 'anni_response.g.dart';

@JsonSerializable()
class AnniVersion {
  AnniVersion({
    required this.version,
  });
  factory AnniVersion.fromJson(dynamic json) => _$AnniVersionFromJson(json);

  int version;
}

@JsonSerializable()
class AnniData {
  AnniData({
    required this.version,
    required this.drugs,
  });
  factory AnniData.fromJson(dynamic json) => _$AnniDataFromJson(json);

  @JsonKey(name: '_v')
  int version;
  List<Drug> drugs;
}

@JsonSerializable()
class AnniDataResponse {
  AnniDataResponse({
    required this.success,
    required this.data,
  });
  factory AnniDataResponse.fromJson(dynamic json) =>
      _$AnniDataResponseFromJson(json);

  bool success;
  AnniData data;
}

@JsonSerializable()
class AnniVersionResponse {
  AnniVersionResponse({
    required this.success,
    required this.data,
  });
  factory AnniVersionResponse.fromJson(dynamic json) =>
      _$AnniVersionResponseFromJson(json);

  bool success;
  AnniVersion data;
}
