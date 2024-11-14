import '../../common/module.dart';
import 'lab.dart';

class DeepLinkShareFlowLab extends Lab {
  DeepLinkShareFlowLab({
    required super.name,
    required this.shareAppName,
  });

  String shareAppName;
  late Uri publishUrl;
  late Map<String, String>? publishHeaders;

  @override
  Future<(List<LabResult>, List<String>)> loadData() async {
    publishUrl = Uri.parse(
      MetaData.instance.deepLinkSharePublishUrl!,
    );
    publishHeaders = null;
    return Lab.fetchData(
      publishUrl,
      headers: publishHeaders,
    );
  }
}