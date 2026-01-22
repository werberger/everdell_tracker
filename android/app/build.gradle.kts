plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.everdell_tracker"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.everdell_tracker"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "icon"
    productFlavors {
        create("teacher") {
            dimension = "icon"
            applicationIdSuffix = ".teacher"
            versionNameSuffix = "-teacher"
            manifestPlaceholders["appIcon"] = "@mipmap/ic_launcher_teacher"
        }
        create("badger") {
            dimension = "icon"
            applicationIdSuffix = ".badger"
            versionNameSuffix = "-badger"
            manifestPlaceholders["appIcon"] = "@mipmap/ic_launcher_badger"
        }
        create("evertree") {
            dimension = "icon"
            applicationIdSuffix = ".evertree"
            versionNameSuffix = "-evertree"
            manifestPlaceholders["appIcon"] = "@mipmap/ic_launcher_evertree"
        }
        create("squirrel") {
            dimension = "icon"
            applicationIdSuffix = ".squirrel"
            versionNameSuffix = "-squirrel"
            manifestPlaceholders["appIcon"] = "@mipmap/ic_launcher_squirrel"
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
