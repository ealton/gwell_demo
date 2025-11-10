import Foundation
import Flutter
import GWIoTApi
import RQCore
import Vision

class VendorMethodChannelController {
    
    static var isDebug = false
    static var cachedPushNotificationUserInfo: [AnyHashable : Any] = [:]
    static var isAppInitializedAndUserLoggedIn = false
    
    var brandDomain = "gwelldemo.com"
    var helperPageUrl = "https://helper.gwelldemo.com"
    var bidirectionalChannel: FlutterMethodChannel? = nil
    
    internal enum MethodChannelFunctionFromFlatter: String{
        /// Gwell
        case initGwellSdk
        case getGwellPhoneUniqueId
        case signInToGwellAccount
        case openGwellBindingQrcode
        case openGwellMessageCenterPage
    }
    
    /**
     * Register method channel functions to their respective handlers.
     * Equivalent to Kotlin's `registerVendorMethodChannel`.
     *
     * - Parameter flutterEngine: The FlutterEngine instance.
     */
    func registerVendorMethodChannel(
        flutterViewController: FlutterViewController
    ) {
        let channel = FlutterMethodChannel(name: "gw_channel", binaryMessenger: flutterViewController.engine.binaryMessenger)
        bidirectionalChannel = channel
        
        channel.setMethodCallHandler { [weak self] (call, result) in
            guard let self = self else {
                result(FlutterError(code: "INSTANCE_DEALLOCATED", message: "Self was deallocated", details: nil))
                return
            }
            if call.method != "printLog" {
                Logger.info(content: "VendorMethodChannel: received methodCall (\(call.method))")
            }

            Task {
                switch MethodChannelFunctionFromFlatter(rawValue: call.method) {
                    
                case .initGwellSdk:
                    await self.initGwellSdk(call: call, flutterResult: result)
                    
                case .getGwellPhoneUniqueId:
                    self.getGwellPhoneUniqueId(call: call, flutterResult: result)
                    
                case .signInToGwellAccount:
                    await self.signInToGwellAccount(call: call, flutterResult: result)
                    
                case .openGwellBindingQrcode:
                    await self.openGwellQrcode(
                        call: call,
                        flutterResult: result,
                        isBindDevice: true,
                        isShareDevice: false
                    )
                    
                case .openGwellMessageCenterPage:
                    await self.openGwellMessageCenterPage(call: call, flutterResult: result)
                    
                default:
                    result(FlutterMethodNotImplemented)
                }
            }
        }
    }
    
    /**
     * Universal response for missing required arguments.
     * Equivalent to Kotlin's `missingArgumentResultError`.
     *
     * - Parameter result: The FlutterResult handler to send the error.
     */
    private func missingArgumentResultError(flutterResult: FlutterResult) {
        flutterResult(FlutterError(code: "MISSING_ARGUMENT", message: "Missing required arguments", details: nil))
    }
    
    /**
     * Init Gwell_SDK.
     * Equivalent to Kotlin's `initGwellSdk`.
     *
     * Calls result.success(errorCode), where errorCode = 0 on success, or -1 on failure.
     * - Parameter call: The FlutterMethodCall containing arguments.
     * - Parameter result: The FlutterResult handler.
     */
    private func initGwellSdk(call: FlutterMethodCall, flutterResult: FlutterResult) async {
        Logger.info(content: "initGwellSDK")
        guard let args = call.arguments as? [String: Any] else {
            return missingArgumentResultError(flutterResult: flutterResult)
        }

        guard let locale = args["locale"] as? String, !locale.isEmpty,
              let appName = args["appName"] as? String, !appName.isEmpty,
              let appId = args["appId"] as? String, !appId.isEmpty,
              let appToken = args["appToken"] as? String, !appToken.isEmpty else {
            return missingArgumentResultError(flutterResult: flutterResult)
        }

        Logger.debug(content: "locale: \(locale) appName: \(appName) \n appId: \(appId) \n appToken: \(appToken)")
        VendorMethodChannelController.isDebug = false

        let languageCode = LanguageCode.en

        let cId = "8.3"
        let opts = GWIoTApi.InitOptions(appConfig: .init(appId: appId, appToken: appToken, appName: appName, cId: cId))
        opts.language = languageCode
        opts.disableMultipleLogins = true
        opts.disableAccountService = true
        opts.brandDomain = self.brandDomain
        opts.soundOnByDefault = false
        opts.hostConfig = .init(env: .prod)
        
        do {
            let gwResult = try await GWIoT.shared.initialize(opts: opts)
        } catch let error {
            Logger.error(content: "\(error)")
            flutterResult(-1)
        }

        /// Configure custom helper page
        GWIoT.shared.helperPageUrl = self.helperPageUrl
        GWIoT.shared.isCustomHelperPage = true
        
        let themeColors = Theme.Colors(
            brand: "0xFFB549",
            brandHighlight: nil,
            brandDisable: nil,
            brand2: nil,
            brand2Highlight: nil,
            brand2Disable: nil,
            text: "0xFFB549",
            secondaryText: nil,
            tertiaryText: nil,
            lightText: nil,
            linkText: nil,
            maskBackground: nil,
            hudBackground: nil,
            inputLineDisable: nil,
            inputLineEnable: nil,
            separatorLine: nil,
            mainBackground: nil,
            secondaryBackground: nil,
            stateSafe: nil,
            stateWarning: nil,
            stateError: nil
        )
        
        let theme = Theme(colors: themeColors)
        let apperanceConfiguration: GWIoTApi.UIConfiguration = {
            let icons = GWIoTApi.Theme.Icons(
                app: nil,
                accountSharedIcon: nil
            )

            return .init(
                theme: Theme(colors: nil, icons: nil),
                texts: AppTexts(appNamePlaceHolder: "Defender ClearVu")
            )

        }()
        
        GWIoT.shared.setUIConfiguration(configuration: apperanceConfiguration)
        
        flutterResult(0)
    }
    
    /**
     * Get Gwell phoneUniqueId.
     * Equivalent to Kotlin's `uninitGwellSdk`.
     *
     * Calls result.success(errorCode), where errorCode = 0 on success, or -1 on failure.
     * - Parameter call: The FlutterMethodCall.
     * - Parameter result: The FlutterResult handler.
     */
    private func getGwellPhoneUniqueId(call: FlutterMethodCall, flutterResult: FlutterResult) {
        flutterResult(UIDevice.current.identifierForVendor?.uuidString ?? UUID())
    }
    
    /**
     * SignInToGwellAccount
     *
     * Calls result.success(errorCode), where errorCode = 0 on success, or -1 on failure.
     * - Parameter call: The FlutterMethodCall containing arguments.
     * - Parameter result: The FlutterResult handler.
     */
    private func signInToGwellAccount(call: FlutterMethodCall, flutterResult: FlutterResult) async {
        guard let args = call.arguments as? [String: Any] else {
            return missingArgumentResultError(flutterResult: flutterResult)
        }
        
        guard let isDebug = args["isDebug"] as? String, !isDebug.isEmpty,
              let accessId = args["accessId"] as? String, !accessId.isEmpty,
              let accessToken = args["accessToken"] as? String, !accessToken.isEmpty,
//              let area = args["area"] as? String, !area.isEmpty,
              let expireTime = args["expireTime"] as? String, !expireTime.isEmpty,
              let terminalId = args["terminalId"] as? String, !terminalId.isEmpty,
//              let userId = args["userId"] as? String, !userId.isEmpty,
//              let regRegion = args["regRegion"] as? String, !regRegion.isEmpty,
              let expand = args["expand"] as? String else {
            return missingArgumentResultError(flutterResult: flutterResult)
        }
        
        Logger.debug(content: "accessId: \(accessId) accessToken: \(accessToken) expireTime: \(expireTime) terminalId: \(terminalId) expand: \(expand)")

        let c2cInfo = UserC2CInfo(
            accessId: accessId,
            accessToken: accessToken,
            expireTime: expireTime,
            terminalId: terminalId,
            expend: expand
        )
        
        GWIoT.shared.login(c2c: c2cInfo)
        GWIoT.shared.setEnv(env: isDebug == "1" ? .test : .prod)
        VendorMethodChannelController.isDebug = isDebug == "1"
        
        flutterResult(0)
    }
    
    /**
     * Process QR code, opens the processing page if QR code is valid.
     *
     * Calls result.success(errorCode), where errorCode = 0 on success, or -1 on failure.
     * - Parameter call: The FlutterMethodCall.
     * - Parameter result: The FlutterResult handler.
     */
    private func openGwellQrcode(call: FlutterMethodCall, flutterResult: FlutterResult, isBindDevice: Bool, isShareDevice: Bool) async {
        guard let args = call.arguments as? [String: Any] else {
            return missingArgumentResultError(flutterResult: flutterResult)
        }
        guard let qrcode = args["qrcode"] as? String, !qrcode.isEmpty else {
            return missingArgumentResultError(flutterResult: flutterResult)
        }
        
        do {
            var enableBuiltInHandling: Bool = false
            if isBindDevice || isShareDevice {
                // Both bindDevice and shareDevice will be handled by SDK automatically
                enableBuiltInHandling = true
            }
            let gwResult = try await GWIoT.shared.recognizeQRCode(value: qrcode, enableBuiltInHandling: true)
            guard case let .success(codeType) = gwiot_swiftResult(of: gwResult) else {
                Logger.error(content: "recognizeQRCode failed")
                flutterResult(-1)
                return
            }
            
            if let a = codeType as? QRCodeType.Unknown {
                Logger.info(content: "QRCodeType.Unknown")
                flutterResult(-1)
                return
            }
            
            if let a = codeType as? QRCodeType.BindDevice {
                flutterResult(0)
                return
            }
            if let a = codeType as? QRCodeType.ShareDevice {
                flutterResult(0)
                return
            }
            
            flutterResult(-1)
        } catch let error {
            Logger.info(content: "\(error)")
            flutterResult(-1)
        }
    }
    
    
    /**
     * Opens Gwell message center page
     *
     * Calls result.success(errorCode), where errorCode = 0 on success, or -1 on failure.
     * - Parameter call: The FlutterMethodCall containing arguments.
     * - Parameter result: The FlutterResult handler.
     */
    private func openGwellMessageCenterPage(call: FlutterMethodCall, flutterResult: FlutterResult) async {
        do {
            let gwResult = try await GWIoT.shared.openMessageCenterPage()
            guard case .success(_) = gwiot_swiftResult(of: gwResult) else {
                Logger.error(content: "openMessageCenterPage failed")
                flutterResult(-1)
                return
            }
            
            flutterResult(0)
        } catch let error {
            Logger.error(content: "\(error)")
            flutterResult(-1)
        }
    }
    
    
    
    /**
     * Set SDK language
     *
     * Calls result.success(errorCode), where errorCode = 0 on success, or -1 on failure.
     * - Parameter call: The FlutterMethodCall containing arguments.
     * - Parameter result: The FlutterResult handler.
     */
    private func setGwellSdkLanguage(call: FlutterMethodCall, flutterResult: FlutterResult) {
        Logger.info(content: "setGwellSdkLanguage")
        guard let args = call.arguments as? [String: Any] else {
            return missingArgumentResultError(flutterResult: flutterResult)
        }
    
        guard let locale = args["locale"] as? String, !locale.isEmpty else {
            return missingArgumentResultError(flutterResult: flutterResult)
        }
        
        GWIoT.shared.setLanguage(code: LanguageCode.en)
        flutterResult(0)
    }
    
    private func encodeGwDevice(gwDevice: GWIoTApi.Device) -> [String: String] {
        Logger.info(content: "DeviceId: \(gwDevice.deviceId)")
//        LogController.infoLog(content: "\(type(of: gwDevice.properties))")
        let snapshotPath = GWIoT.shared.getLastSnapshotPath(device: gwDevice) ?? ""
        var deviceMap : [String: String] = [
            "deviceId": gwDevice.deviceId,
            "remarkName": gwDevice.remarkName,
            "vssCornerUrl": gwDevice.vss.cornerUrl,
            "snapshotPath": snapshotPath,
            "snapshotBase64": "",
            "jsonString": gwDevice.jsonString,
        ]
        
        if snapshotPath.hasSuffix(".jpg") || snapshotPath.hasSuffix(".jpeg") || snapshotPath.hasSuffix(".png") {
            do {
                if let base64EncodedString = try fileToBase64(filePath: snapshotPath) {
                    deviceMap["snapshotBase64"] = base64EncodedString
                }
            } catch {
                Logger.error(content: "Error reading file or encoding to Base64: \(error.localizedDescription)")
            }
        }
        
        return deviceMap
    }
    
    private func printLog(call: FlutterMethodCall, flutterResult: FlutterResult) {
        guard let args = call.arguments as? [String: Any] else {
            return missingArgumentResultError(flutterResult: flutterResult)
        }
    
        guard let content = args["content"] as? String, !content.isEmpty else {
            return missingArgumentResultError(flutterResult: flutterResult)
        }
        
        Logger.info(content: content)
        flutterResult(0)
    }
    
    func fileToBase64(filePath: String) throws -> String? {
        let fileURL = URL(fileURLWithPath: filePath)

        do {
            // Read the content of the file into Data
            let fileData = try Data(contentsOf: fileURL)

            // Encode the Data to a Base64 string
            let base64String = fileData.base64EncodedString()

            return base64String
        } catch {
            // Propagate any errors that occur during file reading or encoding
            Logger.error(content: "Error reading file or encoding to Base64: \(error.localizedDescription)")
            throw error
        }
    }
    
}
