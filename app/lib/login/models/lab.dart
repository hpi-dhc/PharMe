import 'dart:convert';

import 'package:http/http.dart';

import '../../common/module.dart';

class LabAuthenticationCanceled implements Exception {
  LabAuthenticationCanceled();
}

class LabAuthenticationError implements Exception {
  LabAuthenticationError();
}

class Lab {
  Lab({
    required this.name,
  });

  String name;
  
  Future<void> authenticate() async {}
  Future<(List<LabResult>, List<String>)> loadData() async {
    throw UnimplementedError();
  }

  (List<LabResult>, List<String>) labDataFromHTTPResponse(Response response) {
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final labData = json['diplotypes'].map<LabResult>(
      LabResult.fromJson
    ).toList();
    var activeDrugs = <String>[];
    if (json.containsKey('medications')) {
      activeDrugs = List<String>.from(json['medications']);
    }
    return (labData, activeDrugs);
  }
}
