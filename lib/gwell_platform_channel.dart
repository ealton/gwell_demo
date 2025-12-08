import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'gwell_device.dart';

class GwellPlatformChannel {
  static MethodChannel gwChannel = MethodChannel("gw_channel");

  /// Singleton with factory method
  static GwellPlatformChannel? _instance;
  GwellPlatformChannel._();
  factory GwellPlatformChannel() {
    _instance ??= GwellPlatformChannel._();
    return _instance!;
  }

  // Future<int> onAppInitializedAndUserLoggedIn() async {
  //   final errCode = await gwChannel.invokeMethod<int>(VendorMethodChannelFunction.onAppInitializedAndUserLoggedIn.toShortString());
  //   return errCode ?? -1;
  // }
  //
  // Future<int> clearInitialUserNotification() async {
  //   final errCode = await gwChannel.invokeMethod<int>(VendorMethodChannelFunction.clearInitialUserNotification.toShortString());
  //   return errCode ?? -1;
  // }
  //
  // Future<String> requestPermissions(List<String> permissionTypes) async {
  //   final result = await gwChannel.invokeMethod<String>(VendorMethodChannelFunction.requestPermissions.toShortString(), {
  //     'permissions': permissionTypes.join(","),
  //   });
  //   CDebugManager.debug("requestPermissions result: $result");
  //   return result ?? "";
  // }
  //
  // Future<String> peekPermissions(List<String> permissionTypes) async {
  //   final result = await gwChannel.invokeMethod<String>(VendorMethodChannelFunction.peekPermissions.toShortString(), {
  //     'permissions': permissionTypes.join(","),
  //   });
  //   CDebugManager.debug("peekPermissions result: $result");
  //   return result ?? "";
  // }
  //
  // Future<int> openNativeSystemPermissionSettingsPage(String permissionType) async {
  //   final result = await gwChannel.invokeMethod<int>(VendorMethodChannelFunction.openNativeSystemPermissionSettingsPage.toShortString(), {
  //     'permission': permissionType,
  //   });
  //   CDebugManager.debug("peekPermissions result: $result");
  //   return result ?? -1;
  // }

  Future<int> initSdk() async {
    final params = <String, String>{
      "locale": "en",
      "appName": "Gwell Demo",
      "appId": dotenv.get("GW_APP_ID_IOS"),
      "appToken": dotenv.get("GW_APP_TOKEN_IOS"),
      "isDebug": "0",
    };
    if (Platform.isAndroid) {
      params["appId"] = dotenv.get("GW_APP_ID_ANDROID");
      params["appToken"] = dotenv.get("GW_APP_TOKEN_ANDROID");
    }

    print("initSdk params: $params");
    final errCode = await gwChannel.invokeMethod<int>("initGwellSdk", params);
    if (errCode != 0) {
      print("Gwell initSdk failed: $errCode");
    }

    return errCode ?? -1;
  }

  Future<String> getMobileDeviceUniqueId() async {
    final uniqueId = await gwChannel.invokeMethod<String>("getGwellPhoneUniqueId", {});
    if (uniqueId == null || uniqueId == "") {
      print("Gwell getPhoneUniqueId failed");
      return "";
    }

    return uniqueId;
  }

  Future<int> signInToGwellAccount(String accessId, String accessToken, String expireTime, String terminalId, String expand) async {
    final params = <String, String>{
      "isDebug": "0",
      "accessId": accessId,
      "accessToken": accessToken,
      "expireTime": expireTime,
      "terminalId": terminalId,
      "expand": expand,
    };
    final result = await gwChannel.invokeMethod<int>("signInToGwellAccount", params);
    return result ?? -1;
  }

  Future<int> logoutFromGwellAccount() async {
    final result = await gwChannel.invokeMethod<int>("logoutFromGwellAccount", {});
    return result ?? -1;
  }

  Future<int> openDeviceBindingQRCodeProcess(String qrcode) async {
    final result = await gwChannel.invokeMethod<int>("openGwellBindingQrcode", {"qrcode": qrcode});
    print("openDeviceBindingQRCodeProcess result: $result");
    return result ?? -1;
  }

  Future<int> openMessageCenterPage() async {
    final result = await gwChannel.invokeMethod<int>("openGwellMessageCenterPage", {});
    print("openMessageCenterPage result: $result");
    return result ?? -1;
  }

  Future<int> bindDevice() async {
    final result = await gwChannel.invokeMethod<int>("bindDevice", {});
    print("bindDevice result: $result");
    return result ?? -1;
  }

  Future<int> openCloudServicePage() async {
    final result = await gwChannel.invokeMethod<int>("openGwellCloudServicePage", {});
    print("openCloudServicePage result: $result");
    return result ?? -1;
  }

  Future<int> openAlbumPage() async {
    final result = await gwChannel.invokeMethod<int>("openGwellAlbumPage", {});
    print("openAlbumPage result: $result");
    return result ?? -1;
  }

  Future<int> openDeviceUpdatePage() async {
    final result = await gwChannel.invokeMethod<int>("openGwellDeviceUpdatePage", {});
    print("openDeviceUpdatePage result: $result");
    return result ?? -1;
  }

  Future<int> openDeviceSharePage() async {
    final result = await gwChannel.invokeMethod<int>("openGwellDeviceSharePage", {});
    print("openDeviceSharePage result: $result");
    return result ?? -1;
  }

  // Future<int> openDeviceSharingQRCodeProcess(String qrcode) async {
  //   final result = await gwChannel.invokeMethod<int>("openGwellShareQrcode", {"qrcode": qrcode});
  //   print("openDeviceSharingQRCodeProcess result: $result");
  //   return result ?? -1;
  // }
  //
  Future<List<GwellDevice>> getDeviceList({int retryCount = 0, bool cacheFirst = false}) async {
    try {
      List<dynamic>? deviceList = [];
      deviceList = await gwChannel.invokeMethod<List<dynamic>>("getGwellDeviceList", {});
      if (deviceList == null) {
        return [];
      }

      final deviceIdList = <String>[];
      final gwellDeviceList = <GwellDevice>[];
      for (var item in deviceList) {
        final gwellDevice = GwellDevice.fromJson(item);
        deviceIdList.add(gwellDevice.deviceId);
        gwellDeviceList.add(gwellDevice);
      }

      debugPrint("getDeviceList deviceIds: ${deviceIdList.join(',')}");

      return gwellDeviceList;
    } on PlatformException catch (e) {
      debugPrint("getDeviceList error: $e");
      if (retryCount > 4) {
        // If retried more than 4 times, then consider it failed, return the default empty result
        return [];
      }
      await Future.delayed(const Duration(seconds: 1));
      return getDeviceList(retryCount: retryCount + 1);
    }
  }

  Future<int> openLiveviewPage(String deviceId) async {
    final result = await gwChannel.invokeMethod<int>("openGwellDeviceLiveviewPage", {"deviceId": deviceId});
    return result ?? -1;
  }

  //
  // Future<int> openCloudServicePage(String deviceId) async {
  //   await VendorManager().initVendorSdk(VendorType.gwell);
  //   final result = await gwChannel.invokeMethod<int>(VendorMethodChannelFunction.openGwellDeviceCloudServicePage.toShortString(), {"deviceId": deviceId});
  //   return result ?? -1;
  // }
  //
  // Future<int> openPlaybackPage(String deviceId) async {
  //   await VendorManager().initVendorSdk(VendorType.gwell);
  //   final result = await gwChannel.invokeMethod<int>(VendorMethodChannelFunction.openGwellDevicePlaybackPage.toShortString(), {"deviceId": deviceId});
  //   return result ?? -1;
  // }
  //
  // Future<int> openDeviceInfoPage(String deviceId) async {
  //   await VendorManager().initVendorSdk(VendorType.gwell);
  //   final result = await gwChannel.invokeMethod<int>(VendorMethodChannelFunction.openGwellDeviceInfoPage.toShortString(), {"deviceId": deviceId});
  //   return result ?? -1;
  // }
  //
  // // Future<int> openHelperPage() async {
  // //   await VendorManager().initVendorSdk(VendorType.gwell);
  // //   final result = await gwChannel.invokeMethod<int>(VendorMethodChannelFunction.openGwellHelperPage.toShortString(), {});
  // //   return result ?? -1;
  // // }
  //
  // // Future<int> openTrafficPage(String deviceId) async {
  // //   await VendorManager().initVendorSdk(VendorType.gwell);
  // //   final result = await gwChannel.invokeMethod<int>(VendorMethodChannelFunction.openGwellTrafficPage.toShortString(), {
  // //     "deviceId": deviceId,
  // //   });
  // //   return result ?? -1;
  // // }
  //
  // Future<int> openAlbumPage(String deviceId) async {
  //   await VendorManager().initVendorSdk(VendorType.gwell);
  //   final result = await gwChannel.invokeMethod<int>(VendorMethodChannelFunction.openGwellAlbumPage.toShortString(), {"deviceId": deviceId});
  //   return result ?? -1;
  // }
  //
  // Future<int> openSharePage() async {
  //   await VendorManager().initVendorSdk(VendorType.gwell);
  //   final result = await gwChannel.invokeMethod<int>(VendorMethodChannelFunction.openGwellSharePage.toShortString(), {});
  //   return result ?? -1;
  // }
  //
  // Future<int> openBatchUpgradePage2() async {
  //   await VendorManager().initVendorSdk(VendorType.gwell);
  //   final result = await gwChannel.invokeMethod<int>(VendorMethodChannelFunction.openGwellBatchUpgradePage.toShortString(), {});
  //   return result ?? -1;
  // }
  //
  // Future<int> openEventsPage2() async {
  //   await VendorManager().initVendorSdk(VendorType.gwell);
  //   final result = await gwChannel.invokeMethod<int>(VendorMethodChannelFunction.openGwellEventsPage.toShortString(), {});
  //   return result ?? -1;
  // }
  //
  // Future<int> openMultiviewPage() async {
  //   await VendorManager().initVendorSdk(VendorType.gwell);
  //   final result = await gwChannel.invokeMethod<int>(VendorMethodChannelFunction.openGwellMultiviewPage.toShortString(), {});
  //   return result ?? -1;
  // }
  //
  // Future<int> openOpenBindPage(String model) async {
  //   await VendorManager().initVendorSdk(VendorType.gwell);
  //   final result = await gwChannel.invokeMethod<int>(VendorMethodChannelFunction.openGwellOpenBindPage.toShortString(), {"model": model});
  //   return result ?? -1;
  // }
  //
  // Future<int> openAutoPairDevicePage() async {
  //   await VendorManager().initVendorSdk(VendorType.gwell);
  //   final result = await gwChannel.invokeMethod<int>(VendorMethodChannelFunction.openGwellAutoPairDevicePage.toShortString(), {});
  //   return result ?? -1;
  // }
  //
  // Future<int> openDeviceEventsPage(String deviceId) async {
  //   await VendorManager().initVendorSdk(VendorType.gwell);
  //   final result = await gwChannel.invokeMethod<int>(VendorMethodChannelFunction.openGwellDeviceEventsPage.toShortString(), {"deviceId": deviceId});
  //   return result ?? -1;
  // }
  //
  // Future<int> setSdkLocale(Locale locale) async {
  //   await VendorManager().initVendorSdk(VendorType.gwell);
  //   final result = await gwChannel.invokeMethod<int>(VendorMethodChannelFunction.setGwellSdkLanguage.toShortString(), {'locale': locale.languageCode});
  //   return result ?? -1;
  // }
  //
  // Future<int> printLog(String content) async {
  //   final result = await gwChannel.invokeMethod<int>(VendorMethodChannelFunction.printLog.toShortString(), {'content': content});
  //   return result ?? -1;
  // }
}
