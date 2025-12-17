import org.gradle.kotlin.dsl.implementation

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    signingConfigs {
        getByName("debug") {
            storeFile = file("C:\\Users\\12769\\Desktop\\key")
            storePassword = "123456"
            keyAlias = "key"
            keyPassword = "123456"
        }
    }
    namespace = "com.example.amps_sdk_example"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.amps_sdk_example"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        getByName("debug") {
            // 禁用代码混淆（必选，避免类名/方法名被替换）
            isMinifyEnabled = false
            // 禁用资源压缩（必选，避免资源被删除/重命名）
            isShrinkResources = false
            // 禁用代码优化（可选，保留原始代码结构，便于调试）
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            // 关联你的自定义 debug 签名（已配置，无需修改）
            signingConfig = signingConfigs.getByName("debug")
            // 启用调试模式（默认 true，显式声明更稳妥）
            isDebuggable = true
        }

        getByName("release") {
            // 关键：禁用代码混淆（实现 Release 包不加密）
            isMinifyEnabled = false
            // 关键：禁用资源压缩（配合混淆禁用）
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            // 复用 debug 签名（你的原始配置，无需修改）
            signingConfig = signingConfigs.getByName("debug")
        }
    }
    dependencies {
        implementation("androidx.appcompat:appcompat:1.7.1")
    }
}


flutter {
    source = "../.."
}
