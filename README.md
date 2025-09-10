# ChannelTalk SDK Flutter Sample Project

Flutter sample project demonstrating how to use native ChannelTalk SDK in Flutter apps.

## 📋 Project Overview

This project was created to test how to use ChannelTalk SDK in Flutter. It provides practical implementation examples that Flutter developers can reference before adopting ChannelTalk SDK.

### ⚠️ Important Notice

**ChannelTalk SDK does not officially support Flutter and is not optimized for Flutter.**  
**This project is not an official support project, so the content may differ from the latest version.**

This project is an **unofficial integration method** that implements bridge code to use native Android/iOS SDK in Flutter. 
Please conduct thorough testing and verification before using in actual production environments.

## 🏗️ Project Structure

```
channeltalk_sample/
├── lib/
│   ├── constants/
│   │   └── texts.dart                    # App text constants
│   ├── managers/
│   │   ├── channel_io_manager.dart       # Flutter ChannelIO Manager (Singleton)
│   │   └── fcm_manager.dart             # Firebase messaging manager (FCM + ChannelTalk integration)
│   ├── viewmodels/
│   │   ├── boot_test_viewmodel.dart      # Boot functionality test ViewModel
│   │   ├── event_test_viewmodel.dart     # Event handling test ViewModel
│   │   ├── fcm_test_viewmodel.dart       # FCM functionality test ViewModel
│   │   └── profile_test_viewmodel.dart   # Profile functionality test ViewModel
│   ├── views/
│   │   ├── common/                       # Common UI components (8 files)
│   │   ├── pages/                        # Main app pages
│   │   ├── test_sections/                # Test functionality sections (4 files)
│   │   └── widgets/                      # Custom widgets
│   ├── firebase_options.dart            # Firebase configuration (FlutterFire CLI generated)
│   └── main.dart                        # Sample app implementation (UI + ChannelTalk/FCM testing)
├── android/
│   ├── app/
│   │   ├── build.gradle.kts              # Android dependencies (Firebase + ChannelTalk)
│   │   ├── google-services.json          # Firebase configuration file
│   │   └── src/main/
│   │       ├── AndroidManifest.xml       # Custom FCM service registration
│   │       ├── res/values/strings.xml    # FCM channel configuration
│   │       └── kotlin/io/channel/channeltalk_sample/
│   │           ├── MainActivity.kt                    # Flutter ↔ Android bridge
│   │           ├── ChannelIOManager.kt               # Android native logic
│   │           ├── MainApplication.kt                # ChannelTalk initialization
│   │           └── ChannelIOFirebaseMessagingService.kt  # Custom FCM service
├── ios/
│   ├── Podfile                          # iOS dependencies (Firebase + ChannelTalk)
│   ├── GoogleService-Info.plist         # Firebase configuration file
│   └── Runner/
│       ├── AppDelegate.swift            # Flutter ↔ iOS bridge (Firebase + FCM)
│       ├── ChannelIOManager.swift       # iOS native logic (ChannelPluginDelegate)
│       └── Info.plist                  # FCM background mode configuration
├── 📚 Documentation/
│   ├── README.md                        # This file (multi-language support)
│   └── guide/                          # Language-specific guide documents
│       ├── ko/                         # Korean guides
│       │   ├── installation.md                 # SDK Installation Guide
│       │   ├── channel_io_manager_guide.md     # ChannelIOManager Usage Guide
│       │   ├── push_notification_guide.md      # Push Notification Main Guide
│       │   ├── push_notification_android.md    # Android Push Setup Guide
│       │   └── push_notification_ios.md        # iOS Push Setup Guide
│       └── en/                         # English guides
│           ├── installation.md                 # SDK Installation Guide
│           ├── channel_io_manager_guide.md     # ChannelIOManager Usage Guide
│           ├── push_notification_guide.md      # Push Notification Main Guide
│           ├── push_notification_android.md    # Android Push Setup Guide
│           └── push_notification_ios.md        # iOS Push Setup Guide
└── pubspec.yaml                        # Flutter packages (firebase_core, firebase_messaging)
```

## 🔧 Development Environment Requirements

### Minimum Requirements
- **Flutter SDK**: 3.0 or higher
- **iOS**: iOS 15.0 or higher  
- **Android**: API 21 or higher (Android 5.0)
- **ChannelTalk Plan**: Paid service plan

### This Project's Development Environment

#### Flutter
- **Flutter**: 3.35.2 (stable channel)
- **Dart**: 3.9.0
- **Firebase Core**: 2.32.0
- **Firebase Messaging**: 14.7.10

#### iOS
- **Xcode**: 16.3 (Build 16E140)
- **Swift**: 6.1
- **CocoaPods**: 1.16.2

#### Android
- **Android Gradle**: 8.12
- **Android Target SDK**: API 35
- **Android Compile SDK**: API 35
- **Android Min SDK**: API 21
- **Firebase BOM**: 33.1.2
- **Google Services Plugin**: Latest (automatic)

#### ChannelIO SDK
- **ChannelTalk Android SDK**: 12.13.0
- **ChannelTalk iOS SDK**: Latest (automatic latest version)

## 🚀 SDK Guide

### 1. SDK Installation Guide

For detailed information on ChannelTalk SDK installation and project setup:

📋 **[English Installation Guide](guide/en/installation.md)** - Step-by-step installation guide

### 2. Push Notification Setup

Firebase FCM integration setup for ChannelTalk push notifications:

📬 **[English Push Notification Guide](guide/en/push_notification_guide.md)** - Firebase FCM + ChannelTalk Integration

### 3. ChannelIOManager Usage Guide

Detailed guide on using ChannelIOManager in Flutter and code reuse:

⚙️ **[English ChannelIOManager Guide](guide/en/channel_io_manager_guide.md)** - Implementation, Usage, Reuse Guide

### 4. Official Documentation

- 📱 [iOS SDK Guide](https://developers.channel.io/docs/ios-quickstart)
- 🤖 [Android SDK Guide](https://developers.channel.io/docs/android-quickstart)
- 🌐 [ChannelTalk Developer Documentation](https://developers.channel.io/)
- 💬 [ChannelTalk Support Center](https://channel.io)

## 📝 Sample Project Execution Method

> ⚠️ **Important**: **Firebase FCM configuration is required** to run this sample project. Push notification functionality will not work without proper Firebase setup.

### 1. Project Clone and Setup
```bash
# 1. Clone project
git clone https://github.com/channel-io/channel-flutter-sample
cd channeltalk_sample

# 2. Install Flutter dependencies
flutter pub get

# 3. Install iOS dependencies (when building for iOS)
cd ios && pod install && cd ..
```

### 2. ChannelTalk Configuration
```dart
// Set plugin key in lib/main.dart file
await channelIO.boot(
  pluginKey: "YOUR_PLUGIN_KEY",  // ← Change to actual plugin key
  // ... other settings
);
```

### 3. Firebase Configuration (Required)
1. **Create Firebase Project** in [Firebase Console](https://console.firebase.google.com/)
2. **Add Android/iOS apps** to the project
3. **Download configuration files**:
   - `google-services.json` → `android/app/`
   - `GoogleService-Info.plist` → `ios/Runner/`
4. **Enable Firebase Cloud Messaging** in Firebase Console
5. **Configure push notification credentials** in ChannelTalk Admin

### 4. Run App
```bash
# Run in debug mode
flutter run

# Release build
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

## 🛠️ Code Reuse Guide

We recommend using the sample project code as reference material rather than direct reuse.
If you plan to reuse the code, please refer to the content below and modify accordingly.

### Core Implementation Files

To use in actual projects, please check the following files.

#### Flutter Layer
```
📁 Flutter
├── lib/managers/channel_io_manager.dart    # ChannelTalk SDK Flutter interface (MethodChannel + event management)
├── lib/managers/fcm_manager.dart          # Firebase FCM + ChannelTalk integrated manager
└── lib/firebase_options.dart             # Firebase configuration (FlutterFire CLI generated)
```

#### Android Native
```
📁 Android  
├── android/app/src/main/kotlin/.../ChannelIOManager.kt           # ChannelTalk native logic (ChannelPluginListener)
├── android/app/src/main/kotlin/.../MainActivity.kt              # Flutter ↔ Android bridge
├── android/app/src/main/kotlin/.../MainApplication.kt           # ChannelTalk initialization
├── android/app/src/main/kotlin/.../ChannelIOFirebaseMessagingService.kt  # Custom FCM service
├── android/app/src/main/AndroidManifest.xml  # FCM service registration + permissions
└── android/app/src/main/res/values/strings.xml  # FCM channel configuration
```

#### iOS Native
```
📁 iOS
├── ios/Runner/ChannelIOManager.swift     # ChannelTalk native logic (ChannelPluginDelegate)
├── ios/Runner/AppDelegate.swift          # Flutter ↔ iOS bridge (Firebase + FCM + UNUserNotificationCenter)
└── ios/Runner/Info.plist                # FCM background mode configuration
```

#### Configuration Files
```
📁 Firebase Configuration
├── android/app/google-services.json      # Android Firebase configuration
├── ios/GoogleService-Info.plist          # iOS Firebase configuration
├── android/app/build.gradle.kts          # Android dependencies (Firebase BOM + ChannelTalk)
└── ios/Podfile                           # iOS dependencies (Firebase + ChannelTalk)
```

#### Key Implementation Features
1. **Integrated ChannelIOManager Architecture**:
   - **Flutter**: Provides unified SDK interface with Singleton pattern
   - **Android**: Real-time event reception with `ChannelPluginListener` implementation
   - **iOS**: Real-time event reception with `CHTChannelPluginDelegate` implementation
   - **MethodChannel**: Bidirectional communication between platforms (method calls + event callbacks)

2. **Platform-optimized FCM Processing**:
   - **Android**: Native processing in `ChannelIOFirebaseMessagingService` (inherits FlutterFirebaseMessagingService)
   - **iOS**: Integration with Flutter through `UNUserNotificationCenterDelegate` in `AppDelegate`
   
3. **Accurate ChannelTalk Message Detection**: Distinguished by `data['provider'] == 'Channel.io'` key

4. **Flutter FCM Compatibility**: Completely preserves existing Flutter FCM functionality while adding ChannelTalk message processing

> 📖 **Detailed ChannelIOManager Usage**: Check [ChannelIOManager Guide](guide/en/channel_io_manager_guide.md) for detailed information on implementation structure, usage, and code reuse.

#### Precautions for Reuse
1. **Package Name Change**: Modify package names in files to match your actual project
2. **Plugin Key Configuration**: Use actual key issued by ChannelTalk  
3. **Firebase Configuration**: Replace `google-services.json` / `GoogleService-Info.plist` files with actual project settings
4. **Permission Settings**: Check Android 13+ `POST_NOTIFICATIONS` permission and iOS notification permissions
5. **⚠️ Notes for Reusing ChannelIOManager.swift**: 
   - **We recommend adding the `ChannelIOManager.swift` file directly in Xcode**
   - Copying from file explorer or creating with external editors may not be recognized by iOS project.
   - Refer to [Apple Developer Documentation](https://developer.apple.com/xcode/) for details.

## 🤝 Contributing

This project was created for learning and reference purposes. 
If you find improvements or issues, feel free to create Issues or PRs in the project,
but contacting through ChannelTalk service will enable faster responses.

## 📄 License

This project is used only for learning and testing purposes. ChannelTalk SDK license applies separately.

---

---

# 채널톡 SDK Flutter Sample Project

Flutter 앱에서 네이티브 채널톡 SDK를 사용하는 방법에 대한 샘플 프로젝트입니다.

## 📋 프로젝트 개요

이 프로젝트는 Flutter에서 채널톡 SDK를 사용하는 방법을 테스트하기 위해 만들어졌습니다. 
Flutter 개발자들이 채널톡 SDK를 도입하기 전에 참고할 수 있는 실제 구현 예제를 제공합니다.

### ⚠️ 주의사항

**채널톡 SDK는 Flutter를 공식 지원하지 않고 있으며, Flutter에 최적화 되지 않았습니다.**  
**이 프로젝트는 공식 지원 프로젝트가 아니기 때문에, 최신 버전과 내용이 다를 수 있습니다.**

이 프로젝트는 네이티브 Android/iOS SDK를 Flutter에서 사용할 수 있도록 브리지 코드를 구현한 **비공식 연동 방법**입니다. 
실제 프로덕션 환경에서 사용하실 때는 충분한 테스트와 검증을 거치시기 바랍니다.

## 🏗️ 프로젝트 구조

```
channeltalk_sample/
├── lib/
│   ├── constants/
│   │   └── texts.dart                    # 앱 텍스트 상수
│   ├── managers/
│   │   ├── channel_io_manager.dart       # Flutter ChannelIO Manager (Singleton)
│   │   └── fcm_manager.dart             # Firebase 메시징 매니저 (FCM + 채널톡 연동)
│   ├── viewmodels/
│   │   ├── boot_test_viewmodel.dart      # Boot 기능 테스트 ViewModel
│   │   ├── event_test_viewmodel.dart     # 이벤트 처리 테스트 ViewModel
│   │   ├── fcm_test_viewmodel.dart       # FCM 기능 테스트 ViewModel
│   │   └── profile_test_viewmodel.dart   # 프로필 기능 테스트 ViewModel
│   ├── views/
│   │   ├── common/                       # 공통 UI 컴포넌트 (8개 파일)
│   │   ├── pages/                        # 메인 앱 페이지들
│   │   ├── test_sections/                # 테스트 기능 섹션들 (4개 파일)
│   │   └── widgets/                      # 커스텀 위젯들
│   ├── firebase_options.dart            # Firebase 설정 파일 (FlutterFire CLI 생성)
│   └── main.dart                        # 샘플 앱 구현 (UI + 채널톡/FCM 테스트)
├── android/
│   ├── app/
│   │   ├── build.gradle.kts              # Android 종속성 설정 (Firebase + 채널톡)
│   │   ├── google-services.json          # Firebase 설정 파일
│   │   └── src/main/
│   │       ├── AndroidManifest.xml       # 커스텀 FCM 서비스 등록
│   │       ├── res/values/strings.xml    # FCM 채널 설정
│   │       └── kotlin/io/channel/channeltalk_sample/
│   │           ├── MainActivity.kt                    # Flutter ↔ Android 브리지
│   │           ├── ChannelIOManager.kt               # Android 네이티브 로직
│   │           ├── MainApplication.kt                # 채널톡 초기화
│   │           └── ChannelIOFirebaseMessagingService.kt  # 커스텀 FCM 서비스
├── ios/
│   ├── Podfile                          # iOS 종속성 설정 (Firebase + 채널톡)
│   ├── GoogleService-Info.plist         # Firebase 설정 파일
│   └── Runner/
│       ├── AppDelegate.swift            # Flutter ↔ iOS 브리지 (Firebase + FCM)
│       ├── ChannelIOManager.swift       # iOS 네이티브 로직 (ChannelPluginDelegate)
│       └── Info.plist                  # FCM 백그라운드 모드 설정
├── 📚 문서들/
│   ├── README.md                        # 이 파일 (다국어 지원)
│   └── guide/                          # 언어별 가이드 문서
│       ├── ko/                         # 한국어 가이드
│       │   ├── installation.md                 # SDK 설치 가이드
│       │   ├── channel_io_manager_guide.md     # ChannelIOManager 사용 가이드
│       │   ├── push_notification_guide.md      # 푸시 알림 메인 가이드
│       │   ├── push_notification_android.md    # Android 푸시 설정 가이드
│       │   └── push_notification_ios.md        # iOS 푸시 설정 가이드
│       └── en/                         # English guides
│           ├── installation.md                 # SDK Installation Guide
│           ├── channel_io_manager_guide.md     # ChannelIOManager Usage Guide
│           ├── push_notification_guide.md      # Push Notification Main Guide
│           ├── push_notification_android.md    # Android Push Setup Guide
│           └── push_notification_ios.md        # iOS Push Setup Guide
└── pubspec.yaml                        # Flutter 패키지 (firebase_core, firebase_messaging)
```

## 🔧 개발환경 요구사항

### 최소 요구사항
- **Flutter SDK**: 3.0 이상
- **iOS**: iOS 15.0 이상  
- **Android**: API 21 이상 (Android 5.0)
- **채널톡 플랜**: 유료 서비스 플랜

### 이 프로젝트의 개발환경

#### Flutter
- **Flutter**: 3.35.2 (stable channel)
- **Dart**: 3.9.0
- **Firebase Core**: 2.32.0
- **Firebase Messaging**: 14.7.10

#### iOS
- **Xcode**: 16.3 (Build 16E140)
- **Swift**: 6.1
- **CocoaPods**: 1.16.2

#### Android
- **Android Gradle**: 8.12
- **Android Target SDK**: API 35
- **Android Compile SDK**: API 35
- **Android Min SDK**: API 21
- **Firebase BOM**: 33.1.2
- **Google Services Plugin**: Latest (자동)

#### ChannelIO SDK
- **채널톡 Android SDK**: 12.13.0
- **채널톡 iOS SDK**: Latest (자동 최신 버전)

## 🚀 SDK 가이드

### 1. SDK 설치 가이드

채널톡 SDK 설치 및 프로젝트 설정에 대한 자세한 내용:

📋 **[한국어 설치 가이드](guide/ko/installation.md)** - 단계별 설치 가이드

### 2. 푸시 알림 설정

채널톡 푸시 알림을 위한 Firebase FCM 연동 설정:

📬 **[한국어 푸시 알림 설정 가이드](guide/ko/push_notification_guide.md)** - Firebase FCM + 채널톡 연동

### 3. ChannelIOManager 사용 가이드

Flutter에서 ChannelIOManager를 사용하는 방법과 코드 재사용에 대한 상세 가이드:

⚙️ **[한국어 ChannelIOManager 가이드](guide/ko/channel_io_manager_guide.md)** - 구현 구조, 사용법, 재사용 가이드

### 4. 공식 문서

- 📱 [iOS SDK 가이드](https://developers.channel.io/docs/ios-quickstart)
- 🤖 [Android SDK 가이드](https://developers.channel.io/docs/android-quickstart)
- 🌐 [채널톡 개발자 문서](https://developers.channel.io/)
- 💬 [채널톡 지원센터](https://channel.io)

## 📝 샘플 프로젝트 실행 방법

> ⚠️ **중요**: 이 샘플 프로젝트를 실행하려면 **Firebase FCM 설정이 필수**입니다. Firebase 설정 없이는 푸시 알림 기능이 동작하지 않습니다.

### 1. 프로젝트 클론 및 설정
```bash
# 1. 프로젝트 클론
git clone https://github.com/channel-io/channel-flutter-sample
cd channeltalk_sample

# 2. Flutter 종속성 설치
flutter pub get

# 3. iOS 종속성 설치 (iOS 빌드시)
cd ios && pod install && cd ..
```

### 2. 채널톡 설정
```dart
// lib/main.dart 파일에서 플러그인 키 설정
await channelIO.boot(
  pluginKey: "YOUR_PLUGIN_KEY",  // ← 실제 플러그인 키로 변경
  // ... 기타 설정
);
```

### 3. Firebase 설정 (필수)
1. **Firebase 프로젝트 생성** ([Firebase Console](https://console.firebase.google.com/)에서)
2. **Android/iOS 앱 추가** 
3. **설정 파일 다운로드**:
   - `google-services.json` → `android/app/`
   - `GoogleService-Info.plist` → `ios/Runner/`
4. **Firebase Cloud Messaging 활성화** (Firebase Console에서)
5. **푸시 알림 자격증명 설정** (채널톡 관리자에서)

### 4. 앱 실행
```bash
# Debug 모드 실행
flutter run

# Release 빌드
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

## 🛠️ 코드 재사용 가이드

샘플 프로젝트의 코드를 재사용하기보다는 참고자료로 사용하시는 것을 권장드립니다.
만약 재사용을 하는 경우, 아래 내용을 참조하여 코드를 수정해주세요.

### 핵심 구현 파일들

실제 프로젝트에서 사용하려면 다음 파일들을 확인해주세요.

#### Flutter 레이어
```
📁 Flutter
├── lib/managers/channel_io_manager.dart    # 채널톡 SDK Flutter 인터페이스 (MethodChannel + 이벤트 관리)
├── lib/managers/fcm_manager.dart          # Firebase FCM + 채널톡 통합 관리자
└── lib/firebase_options.dart             # Firebase 설정 (FlutterFire CLI 생성)
```

#### Android 네이티브
```
📁 Android  
├── android/app/src/main/kotlin/.../ChannelIOManager.kt           # 채널톡 네이티브 로직 (ChannelPluginListener)
├── android/app/src/main/kotlin/.../MainActivity.kt              # Flutter ↔ Android 브리지
├── android/app/src/main/kotlin/.../MainApplication.kt           # 채널톡 초기화
├── android/app/src/main/kotlin/.../ChannelIOFirebaseMessagingService.kt  # 커스텀 FCM 서비스
├── android/app/src/main/AndroidManifest.xml  # FCM 서비스 등록 + 권한 설정
└── android/app/src/main/res/values/strings.xml  # FCM 채널 설정
```

#### iOS 네이티브
```
📁 iOS
├── ios/Runner/ChannelIOManager.swift     # 채널톡 네이티브 로직 (ChannelPluginDelegate)
├── ios/Runner/AppDelegate.swift          # Flutter ↔ iOS 브리지 (Firebase + FCM + UNUserNotificationCenter)
└── ios/Runner/Info.plist                # FCM 백그라운드 모드 설정
```

#### 설정 파일
```
📁 Firebase 설정
├── android/app/google-services.json      # Android Firebase 설정
├── ios/GoogleService-Info.plist          # iOS Firebase 설정
├── android/app/build.gradle.kts          # Android 종속성 (Firebase BOM + 채널톡)
└── ios/Podfile                           # iOS 종속성 (Firebase + 채널톡)
```

#### 주요 구현 특징
1. **통합된 ChannelIOManager 아키텍처**:
   - **Flutter**: Singleton 패턴으로 단일화된 SDK 인터페이스 제공
   - **Android**: `ChannelPluginListener` 구현으로 실시간 이벤트 수신
   - **iOS**: `CHTChannelPluginDelegate` 구현으로 실시간 이벤트 수신
   - **MethodChannel**: 플랫폼 간 양방향 통신 (메소드 호출 + 이벤트 콜백)

2. **플랫폼별 최적화된 FCM 처리**:
   - **Android**: `ChannelIOFirebaseMessagingService` (FlutterFirebaseMessagingService 상속)에서 네이티브 처리
   - **iOS**: `AppDelegate`의 `UNUserNotificationCenterDelegate`에서 Flutter와 연동
   
3. **채널톡 메시지 정확한 판별**: `data['provider'] == 'Channel.io'` 키로 구분

4. **Flutter FCM 호환성 유지**: 기존 Flutter FCM 기능을 완전히 보존하면서 채널톡 메시지 추가 처리

> 📖 **자세한 ChannelIOManager 사용법**: [ChannelIOManager 가이드](guide/ko/channel_io_manager_guide.md)에서 구현 구조, 사용법, 코드 재사용에 대한 상세 정보를 확인하세요.

#### 재사용 시 주의사항
1. **패키지명 변경**: 파일 내 패키지명을 실제 프로젝트에 맞게 수정
2. **플러그인 키 설정**: 채널톡에서 발급받은 실제 키 사용  
3. **Firebase 설정**: `google-services.json` / `GoogleService-Info.plist` 파일을 실제 프로젝트 설정으로 교체
4. **권한 설정**: Android 13+ `POST_NOTIFICATIONS` 권한 및 iOS 알림 권한 확인
5. **⚠️ ChannelIOManager.swift 재사용 시 참고사항**: 
   - **`ChannelIOManager.swift` 파일은 Xcode에서 직접 추가하는 것을 권장드립니다**
   - 파일 탐색기에서 복사하거나 외부 에디터로 생성하면 iOS 프로젝트에서 인지하지 못할 수 있습니다.
   - 자세한 내용은 [Apple 개발자 문서](https://developer.apple.com/xcode/)를 참고하세요.

## 🤝 기여 방법

이 프로젝트는 학습 및 참고 목적으로 만들어졌습니다. 
개선 사항이나 문제점을 발견하시면 프로젝트의 Issue 혹은 PR을 요청해주셔도 좋지만,
채널톡 서비스를 통해 문의를 주시면 빠른 응답이 가능합니다.

## 📄 라이선스

이 프로젝트는 학습 및 테스트 목적으로만 사용됩니다. 채널톡 SDK의 라이선스는 별도로 적용됩니다.

---