# ChannelTalk SDK Installation Guide

> 📖 **Guide Information**: This guide provides instructions for installing ChannelTalk SDK in **general Flutter projects**.
>
> 🚀 **Sample Project**: For installation and execution instructions for this sample project, please refer to [README.md](../../README.md).

## Overview

This guide provides step-by-step instructions for installing and setting up ChannelTalk SDK in a Flutter project.

## 🔧 Project Environment Information

This project was developed and tested in the following environment:

### Flutter & Dart
- **Flutter**: 3.35.2 (stable channel)
- **Dart**: 3.9.0
- **DevTools**: 2.48.0

### iOS
- **Xcode**: 16.3 (Build 16E140)
- **Swift**: 6.1
- **Minimum iOS Version**: 15.0
- **CocoaPods**: 1.16.2

### Android
- **Gradle**: 8.12
- **Minimum SDK**: API 21 (Android 5.0)
- **Target SDK**: API 35 (Android 15)
- **Compile SDK**: API 35

### ChannelTalk SDK
- **Android SDK**: 12.13.0
- **iOS SDK**: Latest (version unspecified - automatic latest version)

## ✅ Installation Requirements

- **Flutter SDK**: 3.0 or higher
- **iOS**: iOS 15.0 or higher (ChannelIOSDK requirement)
- **Android**: API 21 or higher (Android 5.0)
- **Channel Talk**: Paid service plan

## 📱 Platform-specific SDK Setup

### Android Setup

#### 1. Add ChannelTalk Android SDK

Add the following dependency to your `android/app/build.gradle.kts` file:

```kotlin
dependencies {
    // Add ChannelTalk Android SDK
    implementation("io.channel:plugin-android:12.13.0")
}
```

#### 2. Create Application Class

Create `android/app/src/main/kotlin/[package_name]/MainApplication.kt` file:

```kotlin
package io.channel.channeltalk_sample

import android.app.Application
import com.zoyi.channel.plugin.android.ChannelIO

class MainApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        // Initialize ChannelIO Android SDK
        ChannelIO.initialize(this)
    }
}
```

#### 3. Modify AndroidManifest.xml

Register the Application class in `android/app/src/main/AndroidManifest.xml`:

```xml
<application
    android:label="channeltalk_sample"
    android:name=".MainApplication"
    android:icon="@mipmap/ic_launcher">
```

### iOS Setup

#### 1. Add ChannelTalk iOS SDK

Add the following to your `ios/Podfile`:

```ruby
platform :ios, '15.0'  # ChannelIOSDK minimum requirement

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
  
  # Add ChannelTalk iOS SDK (automatic latest version)
  pod 'ChannelIOSDK'
end
```

#### 2. Install CocoaPods

Run the following command in terminal:

```bash
cd ios && pod install
```

#### 3. Modify AppDelegate.swift

Modify `ios/Runner/AppDelegate.swift` file as follows:

```swift
import Flutter
import UIKit
import ChannelIOFront

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Initialize ChannelIO iOS SDK
    ChannelIO.initialize(application)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

## 🚀 Build and Run

### 1. Update Flutter Packages

```bash
flutter pub get
```

### 2. Install iOS CocoaPods (iOS only)

```bash
cd ios && pod install && cd ..
```

### 3. Build and Run App

```bash
# Debug build (for development)
flutter run

# Build Release APK (Android)
flutter build apk --release

# iOS Build
flutter build ios --release
```

## 📬 Push Notification Setup (Optional)

To use ChannelTalk push notification features, additional setup is required.

### Firebase FCM Integration

This project processes ChannelTalk push notifications through Firebase Cloud Messaging (FCM).

📬 **[Push Notification Setup Guide](push_notification_guide.md)** - Detailed Firebase FCM + ChannelTalk integration method

### Key Configuration Items

#### 1. Create and Configure Firebase Project
- Create new project in Firebase Console
- Register Android/iOS apps
- Download `google-services.json` (Android) / `GoogleService-Info.plist` (iOS)

#### 2. Add Flutter Packages
```yaml
# pubspec.yaml
dependencies:
  firebase_core: ^2.32.0
  firebase_messaging: ^14.7.10
```

#### 3. Platform-specific Additional Setup
- **Android**: Implement custom FCM service (handle ChannelTalk messages natively)
- **iOS**: Implement UNUserNotificationCenter delegate in AppDelegate
- **Permissions**: Android 13+ `POST_NOTIFICATIONS` permission, iOS notification permission

#### 4. Channel Desk Integration
- Upload Firebase service account key to Channel Desk
- **Channel Settings > Security and Development > Mobile SDK Push**

> ⚠️ **Note**: Push notifications can only be fully tested on real devices. (Simulator/Emulator limitations)

## 🔗 Official Documentation Reference

For detailed setup instructions, please refer to ChannelTalk official developer documentation:

- 📱 **[iOS SDK Quickstart](https://developers.channel.io/docs/ios-quickstart)**
- 🤖 **[Android SDK Quickstart](https://developers.channel.io/docs/android-quickstart)**
- 🌐 **[ChannelTalk Developer Documentation](https://developers.channel.io/)**

## 🛠️ Troubleshooting

### Common Problem Solutions

#### iOS Build Errors
- **Issue**: iOS 15.0 related error messages
- **Solution**: Check `platform :ios, '15.0'` setting in `ios/Podfile`

#### Android Build Errors
- **Issue**: minSdkVersion related error messages  
- **Solution**: Verify Android API 21 or higher configuration

#### CocoaPods Errors (iOS)
- **Issue**: Errors during Pod installation
- **Solution**: 
  ```bash
  cd ios 
  pod deintegrate
  pod install --repo-update
  ```

#### Native Code Changes Not Reflected
- **Flutter**: `flutter clean && flutter pub get`
- **iOS**: `cd ios && pod install && cd ..`
- **Android**: Gradle Sync in Android Studio

### Need Help?

- 💬 **[ChannelTalk Support Center](https://channel.io)** - For technical inquiries, please contact ChannelTalk Support Center directly

## ⚠️ Important Notes

1. **Native Code Modification Required**: Complete integration is not possible with Flutter alone; iOS and Android native code modification is essential.

2. **Version Compatibility**: Tested based on the environment versions specified above; compatibility issues may occur when using different versions.

3. **Paid Service**: ChannelTalk is a paid service, so a service plan subscription is required for actual use.

4. **Plugin Key Required**: A plugin key issued by ChannelTalk is required to use the SDK.

---

**Need Help?** Contact [ChannelTalk Support](https://channel.io) for technical assistance.
