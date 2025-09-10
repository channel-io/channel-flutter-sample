plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Google Services plugin: Required for FlutterFirebaseMessagingService inheritance
    id("com.google.gms.google-services")
}

android {
    namespace = "io.channel.channeltalk_sample"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        // Enable core library desugaring
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "io.channel.channeltalk_sample"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
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

dependencies {
    // ChannelTalk Android SDK
    implementation("io.channel:plugin-android:12.13.0")
    
    // Firebase BOM: BOM declaration for version management
    // Required for FlutterFirebaseMessagingService inheritance
    implementation(platform("com.google.firebase:firebase-bom:33.1.2"))
    
    // Firebase Messaging: Required for custom FCM service implementation
    // Dependency to use FlutterFirebaseMessagingService class
    implementation("com.google.firebase:firebase-messaging")
    
    // Core library desugaring: Support for Java 8+ features
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}
