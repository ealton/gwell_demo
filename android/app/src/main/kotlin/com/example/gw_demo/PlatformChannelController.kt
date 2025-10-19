package com.example.gw_demo

import android.util.Log
import com.gw.gwiotapi.GWIoT
import com.gw.gwiotapi.entities.GWResult
import com.gw.gwiotapi.entities.HostConfig
import com.gw.gwiotapi.entities.QRCodeType
import com.gw.gwiotapi.entities.UserC2CInfo
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.launch

class PlatformChannelController {

    companion object {
        private var isDebug: Boolean = false

        private fun debugLog(content: String) {
            if (isDebug) {
                Log.d("GWDemo", content)
            }
        }

        private fun infoLog(content: String) {
            Log.d("GWDemo", content)
        }
    }

    private var brandDomain: String = "defendercameras.com"
    private var helperPageUrl: String = "https://support.defendercameras.com"
    private val scope by lazy { MainScope() }


    /**
     * Internal enum for method channel functions
     */
    internal enum class MethodChannelFunction {
        // GWELL
        initGwellSdk,
        getGwellPhoneUniqueId,
        signInToGwellAccount,

        // openGwellBindingProcess,
        openGwellBindingQrcode,
        openGwellMessageCenterPage,
    }

    /**
     * Register method channel enum to functions
     */
    fun registerVendorMethodChannel(
        flutterEngine: FlutterEngine,
    ) {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "gw_channel",
        ).setMethodCallHandler { call, result ->


            Log.d("DEMO", "MethodChannelFunction: ${call.method}")
            when (call.method) {

                MethodChannelFunction.initGwellSdk.toString() -> {
                    initGwellSdk(call, result)
                }

                MethodChannelFunction.getGwellPhoneUniqueId.toString() -> {
                    getGwellPhoneUniqueId(call, result)
                }

                MethodChannelFunction.signInToGwellAccount.toString() -> {
                    scope.launch(Dispatchers.IO) {
                        signInToGwellAccount(call, result)
                    }
                }

                MethodChannelFunction.openGwellBindingQrcode.toString() -> {
                    scope.launch(Dispatchers.IO) {
                        openGwellBindingQrcode(call, result)
                    }
                }

                MethodChannelFunction.openGwellMessageCenterPage.toString() -> {
                    scope.launch(Dispatchers.IO) {
                        openGwellMessageCenterPage(call, result)
                    }
                }

            }
        }
    }

    /**
     * Init Gwell_SDK
     *
     * Calls result.success(returnCode), where returnCode = 0 on success, or -1 on failure.
     * @param call MethodCall
     * @param result MethodChannel.Result
     */
    private fun initGwellSdk(call: MethodCall, result: MethodChannel.Result) {
        infoLog("initGwellSdk")


        val appId = call.argument<String>("appId")
        val appToken = call.argument<String>("appToken")

        if (appId == null || appToken == null) {
            result.success(-1)
            return
        }

        val errCode = MyApplication.mainApp?.initGwiot(appId, appToken)

        result.success(0)
    }

    /**
     * Uninit Closeli_SDK
     *
     * Calls result.success(returnCode), where returnCode = 0 on success, or -1 on failure.
     * @param call MethodCall
     * @param result MethodChannel.Result
     */
    private fun getGwellPhoneUniqueId(call: MethodCall, result: MethodChannel.Result) {
        infoLog("uninitGwellSdk")
        val ret = GWIoT.phoneUniqueId()
        if (ret is GWResult.Success) {
            if (ret.data == null) {
                result.success("")
            } else {
                result.success("${ret.data}")
            }
        } else if (ret is GWResult.Failure) {
            print("Unable to get phoneUniqueId: ${ret.err.toString()}")
            result.success("")
        }
    }

    /**
     * Sign in to GwellAccount
     *
     * Calls result.success(returnCode), where returnCode = 0 on success, or -1 on failure.
     * @param call MethodCall
     * @param result MethodChannel.Result
     */
    private fun signInToGwellAccount(
        call: MethodCall,
        flutterResult: MethodChannel.Result
    ) {
        infoLog("signInToGwellAccount")

        val accessId = call.argument<String>("accessId")
        val accessToken = call.argument<String>("accessToken")
        val expireTime = call.argument<String>("expireTime")
        val terminalId = call.argument<String>("terminalId")
        val expand = call.argument<String>("expand")
        if (accessId.isNullOrEmpty() || accessToken.isNullOrEmpty() ||
            expireTime.isNullOrEmpty() ||
            terminalId.isNullOrEmpty() || expand.isNullOrEmpty()
        ) {
            print("missing arguments")
            flutterResult.success(-1)
            return
        }

        debugLog("accessId: $accessId accessToken: $accessToken expireTime: $expireTime terminalId: $terminalId expand: $expand")

        val info = UserC2CInfo(
            accessId,
            accessToken,
            expireTime,
            terminalId,
            expand
        )
        print("Calling GWIoT.login")
        print("GWIoT.login: accessId=$accessId, accessToken=$accessToken, expireTime=$expireTime, terminalId=$terminalId, expand=$expand")
        GWIoT.login(info)
        print("Calling GWIoT.setEnv")
        GWIoT.setEnv(HostConfig.Env.Prod)
        flutterResult.success(0)
    }


    private suspend fun openGwellBindingQrcode(
        call: MethodCall,
        flutterResult: MethodChannel.Result
    ) {
        infoLog("openGwellBindingQrcode")
        val qrcodeContent = call.argument<String>("qrcode")
        if (qrcodeContent.isNullOrEmpty()) {
            print("Missing arguments")
            flutterResult.success(-1)
            return
        }

        var enableBuiltInHandling = true
            print("Calling GWIoT.recognizeQRCode($qrcodeContent, $enableBuiltInHandling)")
            val recognizeRet = GWIoT.recognizeQRCode(qrcodeContent, enableBuiltInHandling)
            if (recognizeRet is GWResult.Success) {
                val qrcodeType = recognizeRet.data
                print("QRCodeScanner recognizeQRCode success: $qrcodeType")

                if (qrcodeType is QRCodeType.ShareDevice) {
                    val expireTimestamp = qrcodeType.expireTime.toInt()
                    val currentTimestampSeconds = System.currentTimeMillis() / 1000;
                    if (expireTimestamp < currentTimestampSeconds) {
                        print("qrcode expired")
                        flutterResult.success(-1)
                        return
                    }

                    print("Calling GWIoT.acceptShareDevice($qrcodeType)")
                    val acceptRet = GWIoT.acceptShareDevice(qrcodeType)
                    if (acceptRet is GWResult.Failure) {
                        print("Unable to accept share device: ${acceptRet.err?.message}")
                        flutterResult.success(-1)
                        return
                    }

                    flutterResult.success(0)

                } else if (qrcodeType is QRCodeType.BindDevice) {
                    // BindDevice were already handled by the previous API
                    flutterResult.success(0)
                } else if (qrcodeType is QRCodeType.Unknown) {
                    flutterResult.success(-1)
                }
            } else {
                flutterResult.success(-1)
            }
    }

    private suspend fun openGwellMessageCenterPage(call: MethodCall, flutterResult: MethodChannel.Result) {
        infoLog("openGwellSharePage")
        when (val result = GWIoT.openMessageCenterPage()) {
            is GWResult.Success<*> -> {
            }
            is GWResult.Failure<*> -> {
                infoLog("openGwellSharePage error ${result.err}")
            }
        }
        flutterResult.success(0)
    }

}