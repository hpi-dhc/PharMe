import 'package:hive/hive.dart';

import '../services.dart';

part 'metadata.g.dart';

/// MetadataContainer is a singleton which contains various user-specific preferences
/// and datapoints. It is intended to be loaded from a hive box once at app
/// launch, from where it's contents can be modified by accessing it's
/// properties.
class MetadataContainer {
  factory MetadataContainer() => _instance;

  // private constructor
  MetadataContainer._(this.data);

  static Future<void> save() async {
    await getBox<Metadata>(Boxes.metadata).put('data', _instance.data);
  }

  static final MetadataContainer _instance =
      MetadataContainer._(Metadata());

  static MetadataContainer get instance => _instance;

  Metadata data;
}

@HiveType(typeId: 4)
class Metadata {
  Metadata({
    this.lookupsLastFetchDate,
    this.isLoggedIn,
  });

  @HiveField(0)
  DateTime? lookupsLastFetchDate;

  @HiveField(1)
  bool? isLoggedIn;
}
