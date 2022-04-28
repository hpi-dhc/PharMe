import 'package:hive/hive.dart';

part 'metadata.g.dart';

const _boxName = 'metadata';

/// MetadataContainer is a singleton dataclass which contains various
/// user-specific preferences and datapoints. It is intended to be loaded from
/// a hive box once at app launch, from where it's contents can be modified by
/// accessing it's properties.
class MetadataContainer {
  factory MetadataContainer() => _instance;

  // private constructor
  MetadataContainer._(this.data);

  static final MetadataContainer _instance = MetadataContainer._(Metadata());
  static MetadataContainer get instance => _instance;

  /// Writes the current state of `data` to local storage
  static Future<void> save() async =>
      Hive.box<Metadata>(_boxName).put('data', _instance.data);

  late Metadata data;
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

/// Initializes the user's metadata by registering all necessary adapters and
/// loading pre-existing data from local storage, if it exists.
Future<void> initMetaData() async {
  // We only want to register the adapter once. If it has already been
  // registered, we return early as to avoid overwriting changed data from the
  // session which has not yet been written to local storage.
  try {
    Hive.registerAdapter(MetadataAdapter());
  } catch (e) {
    return;
  }
  // if user's metadata is not null, assign it's contents to the singleton
  await Hive.openBox<Metadata>(_boxName);
  final metaData = Hive.box<Metadata>(_boxName);
  final sessionData = metaData.get('data') ?? Metadata();

  MetadataContainer.instance.data = sessionData;
}
