import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// This is supposed to be handled on the server side
class GwellSignBackendController {
  Future<Map<String, dynamic>?> customerLogInV2({required String phoneUniqueId}) async {
    print("GWELL API CustomerLogInV2");

    final host = "openapi-sg.dophigo.com";
    final appInfo = _getAppIdAndToken();
    final appId = appInfo[0];
    final appToken = appInfo[1];

    final secretID = "";
    final secretKey = dotenv.get("GW_CLOUD_SECRET_KEY");
    if (secretKey.isEmpty) {
      throw Exception("missing 'GW_CLOUD_SECRET_KEY' env");
    }

    final nonce = Random().nextInt(1 << 31 - 1).toString();
    final timestamp = (DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000).toString();

    final payloadMap = {
      "action": "thirdCustLogin",
      "appId": appId,
      "appToken": appToken,
      "regRegion": "us",
      "unionId": "e2f8f760-dc19-435c-a655-7729a63f0cde", // user UUID
      "uniqueId": phoneUniqueId,
    };

    print("gwell login payload: $payloadMap");

    final payloadStr = jsonEncode(payloadMap);
    final payloadSha256Hex = _sha256Hex(payloadStr);

    final headers = {"Host": host, "Payload": payloadSha256Hex, "X-IotVideo-AccessID": secretID, "X-IotVideo-Nonce": nonce, "X-IotVideo-Timestamp": timestamp};

    final signature = _sign(headers, secretKey);
    headers["X-IotVideo-Signature"] = signature;
    headers["Content-Type"] = "application/json";
    headers.remove("Payload");

    final url = "https://$host/openapi/custCloud/app/user/thirdCustLogin";

    final res = await _callGwellApiHelperPost(url, headers, payloadMap);

    print("gwell login result: $res");

    final resCode = res["code"];
    if (resCode is! num || resCode != 0) {
      print("GwellThirdCustLoginError: ${jsonEncode(res)}");
    }

    return res;
  }

  /// Get appId and appToken from env based on frontendOs
  List<String> _getAppIdAndToken() {
    final frontendOs = Platform.isIOS ? "ios" : "android";
    String appId = "";
    String appToken = "";

    if (frontendOs == "ios") {
      appId = dotenv.get("GW_APP_ID_IOS");
      appToken = dotenv.get("GW_APP_TOKEN_IOS");
    } else {
      appId = dotenv.get("GW_APP_ID_ANDROID");
      appToken = dotenv.get("GW_APP_TOKEN_ANDROID");
    }

    if (appId.isEmpty) {
      throw Exception("missing 'GW_APP_ID_${frontendOs.toUpperCase()}' env");
    }
    if (appToken.isEmpty) {
      throw Exception("missing 'GW_APP_TOKEN${frontendOs.toUpperCase()}' env");
    }

    return <String>[appId, appToken];
  }

  /// Calculate the SHA256 hash of a string and return it as a hex string
  String _sha256Hex(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Calculates HMAC-SHA1 signature of the params using secretKey
  String _sign(Map<String, dynamic> params, String key) {
    final stringToSign = _getStringToSign(params);
    final hmacSha1 = Hmac(sha1, utf8.encode(key));
    final digest = hmacSha1.convert(utf8.encode(stringToSign));
    return base64Encode(digest.bytes);
  }

  /// Converts map to "\n".join("%s:%s")
  String _getStringToSign(Map<String, dynamic> params) {
    final keys = params.keys.toList()..sort();
    final buffer = StringBuffer();

    for (final k in keys) {
      buffer.write('$k:${params[k]}\n');
    }

    final str = buffer.toString();
    return str.isNotEmpty ? str.substring(0, str.length - 1) : "";
  }

  /// Helper to send POST request to Gwell API
  Future<Map<String, dynamic>> _callGwellApiHelperPost(String url, Map<String, String> headers, Map<String, dynamic> body) async {
    final response = await http.post(Uri.parse(url), headers: headers, body: jsonEncode(body));

    if (response.statusCode != 200) {
      throw Exception("HTTP ${response.statusCode}: ${response.body}");
    }

    final jsonRes = jsonDecode(response.body);
    if (jsonRes is Map<String, dynamic>) {
      return jsonRes;
    } else {
      throw Exception("Unexpected response format: ${response.body}");
    }
  }
}
