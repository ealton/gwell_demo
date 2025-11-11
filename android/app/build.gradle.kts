plugins {
    id("com.android.application")
    id("kotlin-android")
    id("kotlin-kapt")
    id("com.google.dagger.hilt.android")
    id("com.google.gms.google-services")
    id("therouter")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.gw_demo"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.gw_demo"
        minSdk = 26
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        vectorDrawables.useSupportLibrary = true
        manifestPlaceholders["fileProviderAuthority"] = "${applicationId}"
    }

    buildFeatures {
        buildConfig = true
        viewBinding = true
        dataBinding = true
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    packaging {
        jniLibs {
            pickFirsts += listOf(
                "lib/armeabi/libc++_shared.so",
                "lib/armeabi/libgwmarsxlog.so",
                "lib/armeabi/libavcodec.so",
                "lib/armeabi/libavfilter.so",
                "lib/armeabi/libavformat.so",
                "lib/armeabi/libavutil.so",
                "lib/armeabi/libcrypto.1.1.so",
                "lib/armeabi/libgwbase.so",
                "lib/armeabi/libssl.1.1.so",
                "lib/armeabi/libswresample.so",
                "lib/armeabi/libswscale.so",
                "lib/armeabi/libxml2.so",
                "lib/armeabi/libgwplayer.so",
                "lib/armeabi/libaudiodsp_dynamic.so",
                "lib/armeabi/libtxTraeVoip.so",
                "lib/armeabi/libcurl.so",
                "lib/armeabi/libijkffmpeg.so",
                "lib/armeabi/libijkplayer.so",
                "lib/armeabi/libijksdl.so",
                "lib/armeabi/libbleconfig.so",
                "lib/armeabi/libiotvideomulti.so",
                "lib/armeabi/libmbedtls.so",
                "lib/armeabi-v7a/libc++_shared.so",
                "lib/armeabi-v7a/libgwmarsxlog.so",
                "lib/armeabi-v7a/libavcodec.so",
                "lib/armeabi-v7a/libavfilter.so",
                "lib/armeabi-v7a/libavformat.so",
                "lib/armeabi-v7a/libavutil.so",
                "lib/armeabi-v7a/libcrypto.1.1.so",
                "lib/armeabi-v7a/libgwbase.so",
                "lib/armeabi-v7a/libssl.1.1.so",
                "lib/armeabi-v7a/libswresample.so",
                "lib/armeabi-v7a/libswscale.so",
                "lib/armeabi-v7a/libxml2.so",
                "lib/armeabi-v7a/libgwplayer.so",
                "lib/armeabi-v7a/libaudiodsp_dynamic.so",
                "lib/armeabi-v7a/libtxTraeVoip.so",
                "lib/armeabi-v7a/libcurl.so",
                "lib/armeabi-v7a/libijkffmpeg.so",
                "lib/armeabi-v7a/libijkplayer.so",
                "lib/armeabi-v7a/libijksdl.so",
                "lib/armeabi-v7a/libbleconfig.so",
                "lib/armeabi-v7a/libiotvideomulti.so",
                "lib/armeabi-v7a/libmbedtls.so",
                "lib/arm64-v8a/libc++_shared.so",
                "lib/arm64-v8a/libgwmarsxlog.so",
                "lib/arm64-v8a/libavcodec.so",
                "lib/arm64-v8a/libavfilter.so",
                "lib/arm64-v8a/libavformat.so",
                "lib/arm64-v8a/libavutil.so",
                "lib/arm64-v8a/libcrypto.1.1.so",
                "lib/arm64-v8a/libgwbase.so",
                "lib/arm64-v8a/libssl.1.1.so",
                "lib/arm64-v8a/libswresample.so",
                "lib/arm64-v8a/libswscale.so",
                "lib/arm64-v8a/libxml2.so",
                "lib/arm64-v8a/libgwplayer.so",
                "lib/arm64-v8a/libaudiodsp_dynamic.so",
                "lib/arm64-v8a/libtxTraeVoip.so",
                "lib/arm64-v8a/libcurl.so",
                "lib/arm64-v8a/libijkffmpeg.so",
                "lib/arm64-v8a/libijkplayer.so",
                "lib/arm64-v8a/libijksdl.so",
                "lib/arm64-v8a/libbleconfig.so",
                "lib/arm64-v8a/libiotvideomulti.so",
                "lib/arm64-v8a/libmbedtls.so"
            )
        }
    }
}

dependencies {
    // Hilt dependency injection
    implementation("com.google.dagger:hilt-android:2.56.2")
    kapt("com.google.dagger:hilt-compiler:2.56.2")

    implementation("cn.therouter:router:1.2.2")

    // Gwell IoT API SDK
    implementation("com.gwell:gwiotapi:1.4.10.0")

    // Yoosee/Gwell Plugin Hub - Google variant
    implementation("com.yoosee.gw_plugin_hub:impl_main:google-release-6.36.0.0.24") {
        exclude(group = "com.google.android.material")
        exclude(group = "com.yoosee.gw_plugin_hub", module = "liblog_release")
        exclude(group = "com.gwell", module = "iotvideo-multiplatform")
        exclude(group = "com.gwell", module = "cloud_player")
        exclude(group = "androidx.activity", module = "activity-ktx")
        exclude(group = "com.gwell", module = "gwiotapi")
        exclude(group = "com.tencentcs", module = "txtraevoip")
    }

    // Reoqoo Plugin Hub - ETI variant
    implementation("com.reoqoo.gw_plugin_hub:main:eti-release-01.06.01.0.30") {
        exclude(group = "com.gwell", module = "gwiotapi")
    }

    // Firebase BoM and Messaging
    implementation(platform("com.google.firebase:firebase-bom:34.0.0"))
    implementation("com.google.firebase:firebase-messaging:24.0.0")

    // QR Code scanning
    implementation("com.journeyapps:zxing-android-embedded:4.3.0")
    implementation("com.google.zxing:core:3.5.3")

    // JSON parsing
    implementation("com.google.code.gson:gson:2.10.1")

    // Image loading
    implementation("io.coil-kt:coil:2.6.0")

    // AndroidX libraries
    implementation("androidx.core:core-ktx:1.13.1")
    implementation("androidx.appcompat:appcompat:1.7.0")
    implementation("com.google.android.material:material:1.12.0")
    implementation("androidx.activity:activity:1.9.0")
    implementation("androidx.constraintlayout:constraintlayout:2.1.4")
    implementation("androidx.navigation:navigation-fragment-ktx:2.9.1")
    implementation("androidx.navigation:navigation-ui-ktx:2.9.1")
}

flutter {
    source = "../.."
}
