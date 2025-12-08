import 'dart:convert';

import 'package:flutter/widgets.dart';

class GwellDevice {
  String deviceId;
  String remarkName;
  String snapshotPath;
  String base64Snapshot;
  int status;
  String jsonString;

  GwellDevice._(this.deviceId, this.remarkName, this.snapshotPath, this.base64Snapshot, this.status, this.jsonString);

  factory GwellDevice.fromJson(dynamic json) {
    debugPrint("GwellDevice.fromJson ${json["jsonString"]}");
    var jsonString = "${json["jsonString"] ?? ""}";
    int status = 0;
    try {
      var jsonMap = jsonDecode(jsonString);
      status = int.tryParse("${jsonMap["status"] ?? 0}") ?? 0;
    } catch (e) {
      debugPrint(e.toString());
    }

    return GwellDevice._(
      '${json["deviceId"]}',
      '${json["remarkName"]}',
      '${json["snapshotPath"] ?? ''}',
      '${json["snapshotBase64"] ?? ''}',
      status,
      jsonString,
    );
  }

  String toJsonString() {
    return jsonString;
  }

  bool isOnline() {
    return true;
  }
}
