# Flutter 채널톡 푸시 알림 설정 가이드

## 📋 목차

1. [개요](#개요)
2. [Flutter FCM 기본 설정](#flutter-fcm-기본-설정)
3. [플랫폼별 채널톡 푸시 설정](#플랫폼별-채널톡-푸시-설정)
4. [FCM Manager 가이드](#fcm-manager-가이드)

---

## 개요

이 가이드는 Flutter 프로젝트에서 채널톡 푸시 알림을 설정하는 방법을 안내합니다.

채널톡 푸시 알림을 구현하려면 다음 단계가 필요합니다:
1. **Flutter FCM 기본 설정** (Firebase 공식 문서 참조)
2. **플랫폼별 네이티브 작업** (채널톡 공식 문서 참조)
3. **FCM Manager 구현** (이 프로젝트의 커스텀 구현)

---

## Flutter FCM 기본 설정

Flutter에서 FCM(Firebase Cloud Messaging)을 설정하는 방법은 Firebase 공식 문서를 참조해주세요:

📖 **[Flutter용 Firebase Cloud Messaging 클라이언트 설정](https://firebase.google.com/docs/cloud-messaging/flutter/client?hl=ko)**

### 주요 설정 사항
- Firebase 프로젝트 생성 및 앱 등록
- `google-services.json` (Android) / `GoogleService-Info.plist` (iOS) 설정
- Firebase CLI를 통한 FlutterFire 설정
- `firebase_core`, `firebase_messaging` 패키지 설치

---

## 플랫폼별 채널톡 푸시 설정

채널톡 푸시 메시지를 정상적으로 처리하기 위해서는 플랫폼별 네이티브 작업이 필요합니다:

### Android 설정
📖 **[Android 푸시 알림 설정 가이드](./push_notification_android.md)**
- 채널톡 Android 공식 문서 기반
- 커스텀 FCM 서비스 구현
- Firebase와 채널톡 SDK 연동

### iOS 설정  
📖 **[iOS 푸시 알림 설정 가이드](./push_notification_ios.md)**
- 채널톡 iOS 공식 문서 기반
- APNs 인증서 설정
- AppDelegate 구성 및 알림 처리

---

## FCM Manager 가이드

이 프로젝트에서는 Flutter와 네이티브 플랫폼 간의 FCM 처리를 통합하기 위해 `FCMManager` 클래스를 구현했습니다.

### 주요 특징

#### 플랫폼별 최적화 처리
- **Android**: 커스텀 FCM 서비스에서 채널톡 메시지 네이티브 처리
- **iOS**: 채널톡 메시지 네이티브에서 직접 처리

#### 채널톡 메시지 정확한 판별
```dart
bool _isChannelIOMessage(Map<String, dynamic> data) {
  final provider = data['provider']?.toString();
  return provider == 'Channel.io';
}
```

채널톡에서 전송하는 모든 푸시 메시지는 `data` 필드에 `provider: Channel.io` 키를 포함합니다.

### FCMManager 사용법

#### 1. 초기화
```dart
final fcmManager = FCMManager();
await fcmManager.initialize();
```

#### 2. 상태 확인
```dart
final status = fcmManager.getStatus();
print('FCM 초기화: ${status['initialized']}');
print('알림 권한: ${status['permissionGranted']}');
print('플랫폼: ${status['platform']}');
```

#### 3. 토큰 정보
```dart
print('FCM 토큰: ${fcmManager.fcmToken}');
if (Platform.isIOS) {
  print('APNs 토큰: ${fcmManager.apnsToken}');
}
```

#### 4. 채널톡 메시지 판별 예시

⚠️ **권장 사용 방법**:
SDK에서 제공하는 `isChannelPushNotification` 사용을 기본적으로 권장합니다.
다만, 백그라운드 등의 상황에서는 네이티브 코드 접근이 어렵기 때문에, 해당 상황에서는 아래와 같이 필터링하는 것을 권장합니다.

##### 네이티브에서 SDK 메소드 사용 (권장)
```kotlin
// Android - ChannelIOFirebaseMessagingService.kt
override fun onMessageReceived(remoteMessage: RemoteMessage) {
    val isChannelMessage = ChannelIO.isChannelPushNotification(remoteMessage.data)
    
    if (isChannelMessage) {
        ChannelIO.receivePushNotification(this, remoteMessage.data)
    } else {
        super.onMessageReceived(remoteMessage)
    }
}
```

```swift
// iOS - AppDelegate.swift
override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                   didReceive response: UNNotificationResponse,
                                   withCompletionHandler completionHandler: @escaping () -> Void) {
    
    let userInfo = response.notification.request.content.userInfo
    
    if ChannelIO.isChannelPushNotification(userInfo) {
        ChannelIO.receivePushNotification(userInfo)
        ChannelIO.storePushNotification(userInfo)
    }
    
    super.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
}

override func application(_ application: UIApplication,
                        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    
    if ChannelIO.isChannelPushNotification(userInfo) {
        ChannelIO.receivePushNotification(userInfo)
    }
    
    super.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
}
```

##### Flutter에서 데이터 필터링
```dart
void _handleForegroundMessage(RemoteMessage message) async {
  try {
    final isChannelMessage = _isChannelIOMessage(message.data);

    if (isChannelMessage) {
      // ChannelIO messages are handled natively, skip Flutter processing
      return;
    }

    // Handle general FCM messages
    _showForegroundNotification(message);
  } catch (e) {
    _showForegroundNotification(message);
  }
}
```

### 메시지 처리 흐름

#### Android
1. **백그라운드**: `ChannelIOFirebaseMessagingService`에서 네이티브 처리
2. **포그라운드**: 커스텀 서비스에서 이미 처리되므로 Flutter에서 중복 방지
3. **알림 클릭**: Flutter에서 `hasStoredPushNotification()` 확인 후 처리

#### iOS
1. **백그라운드**: 네이티브에서 stored push notification으로 처리
2. **포그라운드**: 네이티브에서 `receivePushNotification()` 직접 처리
3. **알림 클릭**: 네이티브에서 처리 (Flutter에서는 별도 처리 안함)

### 디버깅 및 문제 해결

#### FCM 토큰 확인
```dart
final status = fcmManager.getStatus();
if (!status['hasToken']) {
  print('FCM 토큰을 가져올 수 없습니다.');
}
```

#### 권한 확인
```dart
if (!status['permissionGranted']) {
  print('알림 권한이 거부되었습니다. 설정에서 권한을 허용해주세요.');
}
```

#### 플랫폼별 주의사항
- **Android**: Google Play Services가 설치된 실제 기기에서 테스트
- **iOS**: 실제 기기에서만 APNs 푸시 테스트 가능 (시뮬레이터 X)

#### 중요한 처리 주의사항
⚠️ **네이티브 처리와 Flutter 필터링**:
- 채널톡 메시지는 네이티브에서 우선 처리되지만, Flutter 자체 로직으로 인해 필터되지 않고 Flutter 레이어에도 메시지가 전달될 수 있습니다
- 이런 경우를 대비해 `_isChannelIOMessage()` 같은 코드로 한번 더 걸러내고 사용하는 것을 권장합니다
- 위의 **채널톡 메시지 판별 예시** 코드를 참고하세요

⚠️ **테스트 시 주의사항**:
- 푸시 알림 테스트 시 **유저가 오프라인 상태**여야 푸시 알림이 전송됩니다
- 앱이 포그라운드에 있거나 유저가 온라인 상태일 때는 푸시 대신 인앱 메시지로 처리됩니다

---

## 추가 참고 사항

### 테스트 환경
- **중요**: FCM 푸시 알림은 실제 기기에서만 완전히 테스트 가능
- 에뮬레이터/시뮬레이터에서는 제한적 기능만 동작

### Firebase Console을 통한 테스트
1. Firebase Console → Cloud Messaging → 새 알림 작성
2. **일반 메시지**: 일반적인 FCM 메시지 전송
3. **채널톡 메시지**: 추가 옵션 → 맞춤 데이터에 `provider: Channel.io` 추가

### 문의사항
채널톡 관련 기술 지원이 필요한 경우 [채널톡 지원센터](https://channel.io)로 문의해주세요.

---
