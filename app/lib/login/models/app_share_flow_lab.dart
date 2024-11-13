import '../../common/module.dart';
import 'lab.dart';

class AppShareFlowLab extends Lab {
  AppShareFlowLab({
    required super.name,
    required this.shareAppName,
  });

  String shareAppName;
  late Uri publishUrl;
  late Map<String, String>? publishHeaders;

  @override
  Future<void> authenticate() async {
    // THIS IS FOR TESTING, SHOULD GET FROM DWA
    publishUrl = Uri.parse(
      'https://hpi-datastore.duckdns.org/userdata?id=1e006a69-b693-43d2-a318-22904e305b5c',
    );
    publishHeaders = null;
  }
  
  @override
  Future<(List<LabResult>, List<String>)> loadData() async {
    return fetchData(
      publishUrl,
      headers: publishHeaders,
    );
  }
}