pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        google()
        mavenCentral()
        maven("https://maven.aliyun.com/repository/central")
        maven("https://maven.aliyun.com/repository/jcenter")
        maven("https://maven.aliyun.com/repository/public")
        maven("https://maven.aliyun.com/repository/google")
        maven("https://maven.aliyun.com/repository/gradle-plugin")
        maven("https://jitpack.io")

//        Properties properties = new Properties()
//        InputStream inputStream = file("upload.properties").newDataInputStream();
//        properties.load(inputStream)
        val GWIOT_NEXUS_BASE_URL = "https://nexus-sg.gwell.cc/nexus/repository/"

        maven {
            url = uri("${GWIOT_NEXUS_BASE_URL}/maven-releases/")
            credentials {
                username = "iptime_eti_user"
                password = "6S1Moa^HFaL!rEqQC"
            }
            isAllowInsecureProtocol = true
        }
        maven {
            url = uri("${GWIOT_NEXUS_BASE_URL}/maven-gwiot/")
            credentials {
                username = "iptime_eti_user"
                password = "6S1Moa^HFaL!rEqQC"
            }
            isAllowInsecureProtocol = true
        }
        maven {
            url = uri("${GWIOT_NEXUS_BASE_URL}/maven-gwiot/")
            credentials {
                username = "iptime_eti_user"
                password = "6S1Moa^HFaL!rEqQC"
            }
            isAllowInsecureProtocol = true
        }
        // Yoosee插件要用到的
        maven {
            url = uri("https://mvn.zztfly.com/android")
            content {
                includeGroup("cn.fly")
                includeGroup("cn.fly.verify")
                includeGroup("cn.fly.verify.plugins")
            }
        }
        maven {
            url = uri("https://developer.huawei.com/repo/")
            content {
                includeGroupByRegex("com\\.huawei.*")
            }
        }
        maven {
            url = uri("https://artifact.bytedance.com/repository/Volcengine/")
        }
        maven {
            url = uri("https://artifact.bytedance.com/repository/pangle/")
        }
        // Flutter storage repository
        val storageUrl = System.getenv("FLUTTER_STORAGE_BASE_URL") ?: "https://storage.googleapis.com"
        maven {
            url = uri("$storageUrl/download.flutter.io")
        }
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.9.1" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
    id("com.google.dagger.hilt.android") version "2.56.2" apply false
    id("cn.therouter.agp8") version "1.2.2" apply false
//    id("kotlin-android")
}

include(":app")
