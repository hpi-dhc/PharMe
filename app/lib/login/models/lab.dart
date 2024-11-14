import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../common/module.dart';

class LabProcessCanceled implements Exception {
  LabProcessCanceled();
}

class LabAuthenticationError implements Exception {
  LabAuthenticationError();
}

class Lab {
  Lab({
    required this.name,
  });

  String name;
  bool cancelAuthInApp = false;
  bool authenticationWasCanceled = false;

  String? authLoadingMessage() => null;
  
  Future<void> authenticate() async {}
  Future<(List<LabResult>, List<String>)> loadData() async {
    throw UnimplementedError();
  }

  Future<(List<LabResult>, List<String>)> fetchData(
    Uri dataUrl,
    {
      Map<String,String>? headers,
    }) async {
    final response = await http.get(dataUrl, headers: headers);
    if (response.statusCode != 200) throw Exception();
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final labData = json['diplotypes'].map<LabResult>(
      LabResult.fromJson
    ).toList() as List<LabResult>;
    var activeDrugs = <String>[];
    if (json.containsKey('medications')) {
      activeDrugs = List<String>.from(json['medications']);
    }
    return (labData, activeDrugs);
  }
}
