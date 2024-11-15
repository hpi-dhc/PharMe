import '../../common/module.dart';
import 'lab.dart';

class DummyDemoLab extends Lab {
  DummyDemoLab({
    required super.name,
    required this.dataUrl,
  });

  Uri dataUrl;

  @override
  Future<(List<LabResult>, List<String>)> loadData() async {
    return Lab.fetchData(dataUrl);
  }
}