# 채널톡 SDK 설치 가이드

> 📖 **가이드 정보**: 이 가이드는 **일반적인 Flutter 프로젝트**에서 채널톡 SDK를 설치하는 방법에 대한 안내입니다.
>
> 🚀 **샘플 프로젝트**: 이 샘플 프로젝트의 설치 및 실행 방법은 [README.md](../../README.md#채널톡-sdk-flutter-sample-project)를 참조해주세요.

## 📋 개요

이 문서는 Flutter 앱에 채널톡 SDK를 설치하고 설정하는 방법을 단계별로 안내합니다.

## 🔧 프로젝트 환경 정보

본 프로젝트는 다음 환경에서 개발 및 테스트되었습니다:

### Flutter & Dart
- **Flutter**: 3.35.2 (stable channel)
- **Dart**: 3.9.0
- **DevTools**: 2.48.0

### iOS
- **Xcode**: 16.3 (Build 16E140)
- **Swift**: 6.1
- **최소 iOS 버전**: 15.0
- **CocoaPods**: 1.16.2

### Android
- **Gradle**: 8.12
- **최소 SDK**: API 21 (Android 5.0)
- **Target SDK**: API 35 (Android 15)
- **Compile SDK**: API 35

### 채널톡 SDK
- **Android SDK**: 12.13.0
- **iOS SDK**: Latest (버전 미지정 - 최신 버전 자동 사용)

## ✅ 설치 요구사항

- **Flutter SDK**: 3.0 이상
- **iOS**: iOS 15.0 이상 (ChannelIOSDK 요구사항)
- **Android**: API 21 이상 (Android 5.0)
- **Channel Talk**: 유료 서비스 플랜

## 📱 플랫폼별 SDK 설정

### Android 설정

#### 1. 채널톡 Android SDK 추가

`android/app/build.gradle.kts` 파일에 다음 의존성을 추가하세요:

```kotlin
dependencies {
    // 채널톡 Android SDK 추가
    implementation("io.channel:plugin-android:12.13.0")
}
```

#### 2. Application 클래스 생성

`android/app/src/main/kotlin/[패키지명]/MainApplication.kt` 파일을 생성하세요:

```kotlin
package io.channel.channeltalk_sample

import android.app.Application
import com.zoyi.channel.plugin.android.ChannelIO

class MainApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        // ChannelIO Android SDK 초기화
        ChannelIO.initialize(this)
    }
}
```

#### 3. AndroidManifest.xml 수정

`android/app/src/main/AndroidManifest.xml`에서 Application 클래스를 등록하세요:

```xml
<application
    android:label="channeltalk_sample"
    android:name=".MainApplication"
    android:icon="@mipmap/ic_launcher">
```

### iOS 설정

#### 1. 채널톡 iOS SDK 추가

`ios/Podfile`에 다음을 추가하세요:

```ruby
platform :ios, '15.0'  # ChannelIOSDK 최소 요구사항

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
  
  # 채널톡 iOS SDK 추가 (최신 버전 자동 사용)
  pod 'ChannelIOSDK'
end
```

#### 2. CocoaPods 설치

터미널에서 다음 명령어를 실행하세요:

```bash
cd ios && pod install
```

#### 3. AppDelegate.swift 수정

`ios/Runner/AppDelegate.swift` 파일을 다음과 같이 수정하세요:

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
    
    // ChannelIO iOS SDK 초기화
    ChannelIO.initialize(application)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

## 🚀 빌드 및 실행

### 1. Flutter 패키지 업데이트

```bash
flutter pub get
```

### 2. iOS CocoaPods 설치 (iOS만 해당)

```bash
cd ios && pod install && cd ..
```

### 3. 앱 빌드 및 실행

```bash
# Debug 빌드 (개발용)
flutter run

# Release APK 빌드 (Android)
flutter build apk --release

# iOS 빌드
flutter build ios --release
```

## 📬 푸시 알림 설정 (선택사항)

채널톡 푸시 알림 기능을 사용하려면 추가 설정이 필요합니다.

### Firebase FCM 연동

이 프로젝트는 Firebase Cloud Messaging(FCM)을 통해 채널톡 푸시 알림을 처리합니다.

📬 **[푸시 알림 설정 가이드](push_notification_guide.md)** - 상세한 Firebase FCM + 채널톡 연동 방법

### 주요 설정 사항

#### 1. Firebase 프로젝트 생성 및 설정
- Firebase Console에서 새 프로젝트 생성
- Android/iOS 앱 등록
- `google-services.json` (Android) / `GoogleService-Info.plist` (iOS) 다운로드

#### 2. Flutter 패키지 추가
```yaml
# pubspec.yaml
dependencies:
  firebase_core: ^2.32.0
  firebase_messaging: ^14.7.10
```

#### 3. 플랫폼별 추가 설정
- **Android**: 커스텀 FCM 서비스 구현 (네이티브에서 채널톡 메시지 처리)
- **iOS**: AppDelegate에서 UNUserNotificationCenter 델리게이트 구현
- **권한**: Android 13+ `POST_NOTIFICATIONS` 권한, iOS 알림 권한

#### 4. Channel Desk 연동
- Firebase 서비스 계정 키를 Channel Desk에 업로드
- **Channel Settings > Security and Development > Mobile SDK Push**

> ⚠️ **참고**: 푸시 알림은 실제 기기에서만 완전히 테스트 가능합니다. (시뮬레이터/에뮬레이터 제한)

## 🔗 공식 문서 참조

자세한 설정 방법은 채널톡 공식 개발자 문서를 참조하세요:

- 📱 **[iOS SDK 퀵스타트](https://developers.channel.io/docs/ios-quickstart)**
- 🤖 **[Android SDK 퀵스타트](https://developers.channel.io/docs/android-quickstart)**

## 🛠️ 트러블슈팅

### 일반적인 문제 해결

#### iOS 빌드 오류
- **문제**: iOS 15.0 관련 오류 메시지
- **해결**: `ios/Podfile`에서 `platform :ios, '15.0'` 설정 확인

#### Android 빌드 오류  
- **문제**: minSdkVersion 관련 오류 메시지
- **해결**: Android API 21 이상 설정 확인

#### CocoaPods 오류 (iOS)
- **문제**: Pod 설치 중 오류 발생
- **해결**: 
  ```bash
  cd ios 
  pod deintegrate
  pod install --repo-update
  ```

#### 네이티브 코드 변경사항 미반영
- **Flutter**: `flutter clean && flutter pub get`
- **iOS**: `cd ios && pod install && cd ..`
- **Android**: Android Studio에서 Gradle Sync

### 도움이 필요한 경우

- 💬 **[채널톡 지원센터](https://channel.io)** - 기술적 문의사항은 채널톡 지원센터로 직접 문의해 주세요

## ⚠️ 중요 사항

1. **네이티브 코드 수정 필요**: Flutter만으로는 완전한 통합이 불가능하며, iOS와 Android 네이티브 코드 수정이 필수입니다.

2. **버전 호환성**: 위에 명시된 환경 버전을 기준으로 테스트되었으며, 다른 버전 사용 시 호환성 문제가 발생할 수 있습니다.

3. **유료 서비스**: 채널톡은 유료 서비스이므로, 실제 사용을 위해서는 서비스 플랜 구독이 필요합니다.

4. **플러그인 키 필요**: SDK 사용을 위해서는 채널톡에서 발급받은 플러그인 키가 필요합니다.
