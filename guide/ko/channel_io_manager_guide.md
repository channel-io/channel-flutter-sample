# ChannelIOManager 가이드

## 📋 목차

1. [개요](#개요)
2. [아키텍처 구조](#아키텍처-구조)
3. [코드 재사용 가이드](#코드-재사용-가이드)
4. [플랫폼별 ChannelIOManager 구현](#플랫폼별-channeliomanager-구현)
5. [Flutter에서 ChannelIOManager 사용법](#flutter에서-channeliomanager-사용법)
6. [주의사항](#주의사항)

## 개요

`ChannelIOManager`는 Flutter 프로젝트에서 채널톡 SDK를 사용하기 위한 핵심 관리 클래스입니다. Flutter와 네이티브 플랫폼(Android/iOS) 간의 브리지 역할을 하며, 채널톡 SDK의 모든 기능을 Flutter에서 사용할 수 있도록 합니다.

### 주요 특징

- **단일화된 인터페이스**: Flutter에서 하나의 클래스로 모든 채널톡 기능 접근
- **실시간 이벤트 수신**: 네이티브 SDK에서 발생하는 이벤트를 실시간으로 Flutter로 전달
- **플랫폼별 최적화**: Android와 iOS 각각의 특성을 고려한 구현
- **FCM 연동**: Firebase Cloud Messaging과 완벽 호환

## 아키텍처 구조

```
┌─────────────────────────────────────────────────────────────────┐
│                          Flutter Layer                          │
├─────────────────────────────────────────────────────────────────┤
│                    ChannelIOManager.dart                        │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │ - Singleton 인스턴스                                        │  │
│  │ - MethodChannel 통신                                       │  │
│  │ - 이벤트 콜백 관리                                            │  │
│  │ - SDK 기능 메소드 (boot, showMessenger 등)                   │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                                   ↕
                         MethodChannel 통신
                                   ↕
┌─────────────────────────────────┬─────────────────────────────────┐
│           Android               │              iOS                │
├─────────────────────────────────┼─────────────────────────────────┤
│       MainActivity.kt           │        AppDelegate.swift        │
│  ┌─────────────────────────────┐│  ┌─────────────────────────────┐│
│  │ - FlutterActivity           ││  │ - FlutterAppDelegate        ││
│  │ - MethodChannel 설정         ││  │ - MethodChannel 설정        ││
│  └─────────────────────────────┘│  └─────────────────────────────┘│
│              ↕                  │              ↕                  │
│    ChannelIOManager.kt          │    ChannelIOManager.swift       │
│  ┌─────────────────────────────┐│  ┌─────────────────────────────┐│
│  │ - ChannelPluginListener     ││  │ - CHTChannelPluginDelegate  ││
│  │ - SDK 메소드 구현              ││  │ - SDK 메소드 구현              ││
│  │ - 이벤트 처리                  ││  │ - 이벤트 처리                  ││
│  └─────────────────────────────┘│  └─────────────────────────────┘│
│              ↕                  │              ↕                  │
│      ChannelIO SDK              │      ChannelIOFront SDK         │
└─────────────────────────────────┴─────────────────────────────────┘
```

## 코드 재사용 가이드

### 샘플 프로젝트 재사용 시 권장사항

**⚠️ 중요**: 샘플 프로젝트의 코드를 재사용하기보다는 **참고자료로 사용하시는 것을 권장드립니다**.
만약 재사용을 하는 경우, 아래 내용을 참조하여 코드를 수정해주세요.

### 필수 수정사항

#### 1. 패키지명 변경
```kotlin
// Android - 파일 상단의 패키지명 수정
package io.channel.channeltalk_sample  // ← 실제 프로젝트 패키지명으로 변경

// 모든 Kotlin 파일에서 수정 필요:
// - MainActivity.kt
// - MainApplication.kt
// - ChannelIOManager.kt  
// - ChannelIOFirebaseMessagingService.kt
```

#### 2. 플러그인 키 설정
```dart
// lib/main.dart에서 실제 플러그인 키로 변경
final result = await channelIO.boot(
  pluginKey: "YOUR_ACTUAL_PLUGIN_KEY",  // ← 채널톡에서 발급받은 실제 키 사용
  // ... 기타 설정
);
```

#### 3. Firebase 설정 파일 교체
- **Android**: `android/app/google-services.json`
- **iOS**: `ios/Runner/GoogleService-Info.plist`

실제 프로젝트의 Firebase 설정 파일로 교체해야 합니다.

#### 4. 앱 식별자 및 번들 ID 변경
```xml
<!-- Android - android/app/src/main/AndroidManifest.xml -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.yourcompany.yourapp">  <!-- 실제 패키지명으로 변경 -->
```

```xml
<!-- iOS - ios/Runner/Info.plist -->
<key>CFBundleIdentifier</key>
<string>com.yourcompany.yourapp</string>  <!-- 실제 번들 ID로 변경 -->
```

### 플랫폼별 추가 고려사항

#### Android 관련

1. **gradle 파일 수정**
```kotlin
// android/app/build.gradle.kts
android {
    namespace = "com.yourcompany.yourapp"  // 실제 네임스페이스로 변경
    applicationId = "com.yourcompany.yourapp"  // 실제 앱 ID로 변경
}
```

2. **권한 설정 확인**
```xml
<!-- AndroidManifest.xml에서 필요한 권한만 유지 -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />  <!-- Android 13+ -->
```

#### iOS 관련

1. **⚠️ ChannelIOManager.swift 재사용 시 특별 주의사항**
   - **`ChannelIOManager.swift` 파일은 Xcode에서 직접 추가하는 것을 권장드립니다**
   - 파일 탐색기에서 복사하거나 외부 에디터로 생성하면 iOS 프로젝트에서 인지하지 못할 수 있습니다
   - 자세한 내용은 [Apple 개발자 문서](https://developer.apple.com/xcode/)를 참고하세요

2. **Podfile 수정**
```ruby
# ios/Podfile
platform :ios, '15.0'  # 최소 지원 버전 확인

target 'YourAppName' do  # 실제 앱 이름으로 변경
  use_frameworks!
  # ... 나머지 설정
end
```

3. **앱 설정 확인**
```xml
<!-- ios/Runner/Info.plist -->
<key>CFBundleName</key>
<string>YourAppName</string>  <!-- 실제 앱 이름으로 변경 -->
```

### 코드 재사용 체크리스트

- [ ] 패키지명/번들 ID 변경
- [ ] 실제 채널톡 플러그인 키 설정
- [ ] Firebase 설정 파일 교체 (`google-services.json`, `GoogleService-Info.plist`)
- [ ] Android 권한 설정 확인 (특히 Android 13+ `POST_NOTIFICATIONS`)
- [ ] iOS 알림 권한 설정 확인
- [ ] Gradle/Podfile의 앱 정보 수정
- [ ] ChannelIOManager.swift를 Xcode에서 직접 추가
- [ ] FCM 토큰이 올바르게 ChannelIO에 등록되는지 테스트
- [ ] 채널톡 푸시 알림이 정상 동작하는지 테스트

## 플랫폼별 ChannelIOManager 구현

### 1. Flutter Layer: `ChannelIOManager.dart`

Flutter 레이어의 ChannelIOManager는 Singleton 패턴으로 구현되어 있으며, 네이티브 플랫폼과의 통신을 담당합니다.

#### 주요 구성 요소:

- **MethodChannel**: `'channel_io_manager'` 이름으로 네이티브와 통신
- **이벤트 콜백**: 네이티브에서 발생하는 이벤트를 수신하여 Flutter 앱으로 전달
- **SDK 메소드**: 채널톡 SDK의 모든 기능을 Flutter에서 사용할 수 있도록 래핑

#### 주요 메소드:

```dart
// SDK 초기화
Future<Map<String, dynamic>> boot({
  required String pluginKey,
  String? memberId,
  String? language = 'ko',
  // ... 기타 옵션들
})

// 채팅 관련
Future<void> showMessenger()
Future<void> hideMessenger()
Future<void> openChat({String? chatId, String? message})

// 사용자 관리
Future<void> updateUser(Map<String, dynamic> userData)
Future<void> addTags(List<String> tags)
Future<void> removeTags(List<String> tags)

// 푸시 알림
Future<void> initPushToken(String token)
Future<bool> isChannelPushNotification(Map<String, String> payload)
```

#### 이벤트 콜백:

```dart
// 배지 변경 이벤트
Function(int unread, int alert)? onBadgeChanged;

// 채팅 생성 이벤트
Function(String chatId)? onChatCreated;

// 메신저 표시/숨김 이벤트
Function()? onShowMessenger;
Function()? onHideMessenger;

// 푸시 알림 클릭 이벤트
Function(String chatId)? onPushNotificationClicked;
```

### 2. Android: `ChannelIOManager.kt`

Android의 ChannelIOManager는 `ChannelPluginListener`를 구현하여 채널톡 SDK 이벤트를 수신합니다.

#### 주요 특징:

- **ChannelPluginListener 구현**: SDK 이벤트를 실시간으로 수신
- **Handler + Looper**: UI 스레드에서 Flutter로 이벤트 전달
- **완전한 SDK 래핑**: 모든 ChannelIO Android SDK 기능을 Flutter에서 사용 가능

#### ChannelPluginListener 구현:

```kotlin
override fun onBadgeChanged(unread: Int, alert: Int) {
    Handler(Looper.getMainLooper()).post {
        methodChannel.invokeMethod("onBadgeChanged", mapOf(
            "unread" to unread,
            "alert" to alert
        ))
    }
}

override fun onChatCreated(chatId: String) {
    Handler(Looper.getMainLooper()).post {
        methodChannel.invokeMethod("onChatCreated", mapOf("chatId" to chatId))
    }
}

override fun onPushNotificationClicked(chatId: String): Boolean {
    Handler(Looper.getMainLooper()).post {
        methodChannel.invokeMethod("onPushNotificationClicked", mapOf("chatId" to chatId))
    }
    return true // ChannelIO가 직접 처리하도록 함
}
```

### 3. iOS: `ChannelIOManager.swift`

iOS의 ChannelIOManager는 `CHTChannelPluginDelegate`를 구현하여 채널톡 SDK 이벤트를 수신합니다.

#### 주요 특징:

- **CHTChannelPluginDelegate 구현**: SDK 이벤트를 실시간으로 수신
- **DispatchQueue**: 메인 스레드에서 Flutter로 이벤트 전달
- **완전한 SDK 래핑**: 모든 ChannelIOFront SDK 기능을 Flutter에서 사용 가능

#### CHTChannelPluginDelegate 구현:

```swift
@objc func onBadgeChanged(unread: Int, alert: Int) {
    DispatchQueue.main.async {
        self.methodChannel.invokeMethod("onBadgeChanged", arguments: [
            "unread": Int(unread),
            "alert": Int(alert)
        ])
    }
}

@objc func onChatCreated(chatId: String) {
    DispatchQueue.main.async {
        self.methodChannel.invokeMethod("onChatCreated", arguments: ["chatId": chatId])
    }
}

@objc func onUrlClicked(url: URL) -> Bool {
    DispatchQueue.main.async {
        self.methodChannel.invokeMethod("onUrlClicked", arguments: ["url": url.absoluteString])
    }
    return false // 기본 브라우저에서 열기
}
```

## Flutter에서 ChannelIOManager 사용법

### 1. 초기화

```dart
final ChannelIOManager channelIO = ChannelIOManager();

// 이벤트 리스너 설정 (선택사항)
channelIO.setOnBadgeChangedCallback((unread, alert) {
  print('Badge changed: unread=$unread, alert=$alert');
});

channelIO.setOnChatCreatedCallback((chatId) {
  print('Chat created: $chatId');
});
```

### 2. SDK Boot

```dart
Future<void> bootChannelIO() async {
  final result = await channelIO.boot(
    pluginKey: 'YOUR_PLUGIN_KEY',
    memberId: 'user123',          // 선택사항
    language: 'ko',               // 선택사항
    appearance: 'system',         // 선택사항 ('light', 'dark', 'system')
    profile: {                    // 선택사항
      'name': '홍길동',
      'email': 'user@example.com'
    },
    tags: ['VIP', 'Premium'],     // 선택사항
  );

  if (result['success'] == true) {
    print('ChannelIO boot 성공');
    print('Status: ${result['status']}');
    print('User: ${result['user']}');
  } else {
    print('ChannelIO boot 실패: ${result['error']}');
  }
}
```

### 3. 메신저 제어

```dart
// 메신저 표시
await channelIO.showMessenger();

// 메신저 숨김
await channelIO.hideMessenger();

// 특정 채팅 열기
await channelIO.openChat(
  chatId: 'specific_chat_id',
  message: '미리 입력할 메시지'
);

// 워크플로우 실행
await channelIO.openWorkflow(workflowId: 'workflow_id');
```

### 4. 사용자 관리

```dart
// 사용자 정보 업데이트
await channelIO.updateUser({
  'name': '새로운 이름',
  'email': 'new@example.com',
  'customField': '커스텀 값'
});

// 태그 추가
await channelIO.addTags(['New Tag', 'Another Tag']);

// 태그 제거
await channelIO.removeTags(['Old Tag']);
```

### 5. 이벤트 추적

```dart
// 사용자 이벤트 추적
await channelIO.track(
  eventName: 'PurchaseCompleted',
  eventProperty: {
    'productId': 'product123',
    'amount': 29.99,
    'currency': 'USD'
  }
);
```

### 6. 푸시 알림 처리

```dart
// FCM 토큰 초기화
await channelIO.initPushToken(fcmToken);

// ChannelIO 푸시인지 확인
bool isChannelPush = await channelIO.isChannelPushNotification(
  {'key1': 'value1', 'key2': 'value2'}
);

if (isChannelPush) {
  // ChannelIO 푸시 처리
  await channelIO.receivePushNotification(payload);
} else {
  // 일반 푸시 처리
}
```

## 주의사항

### 1. 플랫폼별 차이점

#### Android vs iOS SDK 차이
- **메소드 시그니처**: 일부 메소드는 플랫폼별로 파라미터가 다를 수 있음
- **이벤트 콜백**: 플랫폼별로 지원하는 이벤트가 약간 다를 수 있음
- **푸시 알림 처리**: Android는 FCM, iOS는 APNs로 서로 다른 방식

### 2. 디버깅 팁

```dart
// 디버그 모드 활성화
await channelIO.setDebugMode(true);

// 부트 상태 확인
bool isBooted = await channelIO.isBooted();
print('ChannelIO Boot Status: $isBooted');
```

### 3. 문제 해결

#### 일반적인 문제들

1. **Boot 실패**
   - 플러그인 키 확인
   - 네트워크 연결 상태 확인
   - 채널톡 서비스 상태 확인

2. **이벤트가 수신되지 않음**
   - 리스너가 올바르게 등록되었는지 확인
   - 네이티브 코드에서 MethodChannel 호출이 메인 스레드에서 실행되는지 확인

3. **푸시 알림 문제**
   - FCM 토큰이 올바르게 등록되었는지 확인
   - Firebase 설정 파일이 올바른지 확인
   - 채널 데스크에서 푸시 설정이 활성화되어 있는지 확인

## 추가 리소스

- 📖 **공식 문서**: [채널톡 개발자 문서](https://developers.channel.io/)
- 🔧 **기술 지원**: [채널톡 지원센터](https://channel.io)
- 📱 **iOS SDK**: [채널톡 iOS 가이드](https://developers.channel.io/docs/ios-quickstart)
- 🤖 **Android SDK**: [채널톡 Android 가이드](https://developers.channel.io/docs/android-quickstart)

---

> **참고**: 이 가이드는 샘플 프로젝트를 기준으로 작성되었습니다. 실제 프로덕션 환경에서는 보안, 성능, 에러 처리 등을 추가로 고려해야 합니다.
