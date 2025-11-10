package com.example.gw_demo

import android.app.Activity
import android.app.Application
import android.os.Build
import com.gw.gwiotapi.GWIoT
import com.gw.gwiotapi.entities.AlbumConfig
import com.gw.gwiotapi.entities.AppConfig
import com.gw.gwiotapi.entities.AppTexts
import com.gw.gwiotapi.entities.DeviceShareOption
import com.gw.gwiotapi.entities.HostConfig
import com.gw.gwiotapi.entities.InitOptions
import com.gw.gwiotapi.entities.LanguageCode
import com.gw.gwiotapi.entities.Theme
import com.gw.gwiotapi.entities.UIConfiguration
import com.google.firebase.FirebaseApp
import dagger.hilt.android.HiltAndroidApp
import java.io.File

@HiltAndroidApp
class MyApplication : Application() {
    companion object {
        var mainApp: MyApplication? = null
    }

    override fun onCreate() {
        super.onCreate()
        mainApp = this

        // Initialize Firebase before any SDK that uses it
        FirebaseApp.initializeApp(this)

    }

    fun initGwiot(appId: String, appToken: String) {
        val appId = appId
        val appToken = appToken
        val appName = "Demo"
        val cId = "8.3"
        val brandDomain = "domain.com"
        val supportCenter = "https://support.domain.com"

        val packageInfo = this.packageManager.getPackageInfo(this.packageName, 0)
        val versionName = packageInfo.versionName ?: "1.1"
        var versionCode = 1
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            versionCode = packageInfo.longVersionCode.toInt()
        } else {
            versionCode = packageInfo.versionCode
        }

        // Init options for GWIoT SDK
        val option = InitOptions(
            app = this,
//            versionName = "1.1",
//            versionCode = 1,
            versionName = versionName,
            versionCode = versionCode,
            appConfig = AppConfig(
                appId = appId,
                appToken = appToken,
                appName = appName,
                cId = cId,
            ),
            mainActvityKlass = MainActivity::class.java as Class<Activity>,
        )
        option.hostConfig = HostConfig(env = HostConfig.Env.Prod)

        // Set album config
        val snapshotDir =
            "${this.getExternalFilesDir(null)}${File.separator}iotplugin${File.separator}ScreenShots"
        val recordDir =
            "${this.getExternalFilesDir(null)}${File.separator}iotplugin${File.separator}RecordVideo"
        option.albumConfig = AlbumConfig(
            snapshotDir = snapshotDir,
            recordDir = recordDir,
            watermarkConfig = null
        )

        // Only allow QR code sharing
        option.language = LanguageCode.EN
        option.deviceShareOptions = listOf(DeviceShareOption.QRCode)
        option.disableMultipleLogins = true
        option.disableAccountService = true
        option.disableMultiLiveView = false
        option.brandDomain = brandDomain
        option.soundOnByDefault = false

        GWIoT.helperPageUrl = supportCenter
        GWIoT.isCustomHelperPage = true

        // Initialize GWIoT SDK
        GWIoT.initialize(option)

        // Set UI
        GWIoT.setUIConfiguration(
            UIConfiguration(
                theme = Theme(),
                texts = AppTexts(
                    appNamePlaceHolder = appName
                )
            )
        )
    }

}
