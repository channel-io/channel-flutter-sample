# iOS 푸시 알림 설정 가이드

## 📋 목차

1. [개요](#개요)
2. [채널톡 공식 설정](#channeltalk-공식-설정)
3. [Flutter 프로젝트 추가 구현](#flutter-프로젝트-추가-구현)
4. [테스트 방법](#테스트-방법)
5. [문제 해결](#문제-해결)

---

## 개요

이 문서는 Flutter 프로젝트에서 채널톡 iOS 푸시 알림을 설정하는 방법을 안내합니다.

### 구현 방식
- **기본 설정**: 채널톡 공식 문서 기반
- **추가 구현**: Flutter FCM과 연동하는 AppDelegate 설정

---

## 채널톡 공식 설정

채널톡 iOS 푸시 알림의 기본 설정은 공식 문서를 참조해주세요:

📖 **[채널톡 iOS Push Notification 공식 문서](https://developers.channel.io/docs/ios-push-notification)**

### 주요 설정 사항

#### 1. APNs 자격 증명 설정
Apple Push Notification 서비스를 사용하기 위한 인증서 설정이 필요합니다.

##### Push Notification Key 생성
1. **Apple Developer Console** → **Certificates, Identifiers & Profiles** → **Keys**
2. **Push Notification Key** 생성
3. **Key ID** 및 **Key 파일(.p8)** 다운로드 (한 번만 가능)
4. **Team ID** 확인 (**Account** → **Membership**)

##### Channel Desk에 인증서 등록
1. **채널톡 관리자** → **설정** → **보안 및 개발** → **모바일 SDK Push**
2. **iOS** 섹션에서 Key 파일, Key ID, Bundle ID, Team ID 입력

#### 2. Info.plist 설정
```xml
<!-- ios/Runner/Info.plist -->
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>

<!-- Firebase 자동 초기화 -->
<key>FirebaseMessagingAutoInitEnabled</key>
<true/>
```

#### 3. 권한 요청
iOS에서는 사용자의 명시적인 알림 권한 요청이 필요합니다.

---

## Flutter 프로젝트 추가 구현

이 프로젝트에서는 Flutter FCM과의 호환성을 위해 추가적인 구현을 했습니다.

### 1. AppDelegate.swift 구성

#### 기본 imports 및 설정
```swift
import UIKit
import Flutter
import Firebase
import FirebaseMessaging
import UserNotifications
import ChannelIOSDK

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // Firebase 초기화
        FirebaseApp.configure()
        
        // 알림 권한 설정
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        
        // 원격 알림 등록 요청
        application.registerForRemoteNotifications()
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
```

#### APNs 토큰 등록
```swift
// APNs 토큰을 Firebase 및 채널톡에 등록
func application(_ application: UIApplication, 
                didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    
    // Firebase Messaging에 APNs 토큰 등록
    Messaging.messaging().apnsToken = deviceToken
    
    // 채널톡에 APNs 토큰 등록 (공식 문서 기준)
    ChannelIO.initPushToken(deviceToken: deviceToken)
}
```

#### 알림 수신 처리 (UNUserNotificationCenterDelegate)
```swift
extension AppDelegate: UNUserNotificationCenterDelegate, MessagingDelegate {
    
    // 알림 클릭 시 처리
    override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        // 채널톡 메시지인지 확인
        if ChannelIO.isChannelPushNotification(userInfo) {
            // 채널톡 알림 처리
            ChannelIO.receivePushNotification(userInfo)
            ChannelIO.storePushNotification(userInfo)
        }
        
        // Flutter FCM에도 전달 (onMessageOpenedApp 이벤트 발생)
        super.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
    }
    
    // 백그라운드 알림 처리
    override func application(_ application: UIApplication,
                            didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                            fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if ChannelIO.isChannelPushNotification(userInfo) {
            ChannelIO.receivePushNotification(userInfo)
        }
        
        super.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
    }
}
```

#### 백그라운드 알림 처리 (선택사항)
```swift
// iOS 10 미만 또는 백그라운드 fetch용 (필요시 구현)
func application(_ application: UIApplication,
                didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    
    if ChannelIO.isChannelPushNotification(userInfo) {
        ChannelIO.receivePushNotification(userInfo)
        ChannelIO.storePushNotification(userInfo)
    }
    
    completionHandler(.noData)
}
```

### 2. Stored Push Notification 처리

채널톡에서는 앱이 백그라운드나 종료 상태에서 받은 알림을 "stored push notification"으로 관리합니다.

#### AppDelegate에서 확인
앱 시작 시 저장된 알림이 있는지 확인하고 처리:

```swift
// 채널톡 Boot 완료 후 호출
if ChannelIO.hasStoredPushNotification() {
    ChannelIO.openStoredPushNotification()
}
```

> ⚠️ **중요**: `openStoredPushNotification`은 채널톡 Boot 완료 전에 호출해야 합니다. Boot 시 저장된 알림 정보가 삭제됩니다.

### 3. Notification Service Extension (권장)

백그라운드/종료 상태에서 채널톡 알림을 완전히 처리하려면 Notification Service Extension을 추가하는 것이 좋습니다.

#### Extension Target 생성
1. Xcode → **File** → **New** → **Target**
2. **Notification Service Extension** 선택
3. Target 이름 지정 (예: `NotificationServiceExtension`)

#### NotificationService.swift 구현
```swift
import UserNotifications
import ChannelIOFront

class NotificationService: UNNotificationServiceExtension {
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, 
                           withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        self.bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        // 채널톡 알림 처리 (SMS 기능 연동용)
        ChannelIO.receivePushNotification(request.content.userInfo)
        
        // 이미지 첨부 처리 등 추가 로직...
        
        if let bestAttemptContent = self.bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler, 
           let bestAttemptContent = self.bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}
```

---

## 테스트 방법

### 1. 시뮬레이터 vs 실제 기기
- ⚠️ **중요**: APNs 푸시 알림은 **실제 iOS 기기**에서만 테스트 가능
- 시뮬레이터에서는 FCM 토큰은 생성되지만 APNs는 동작하지 않음

### 2. Firebase Console 테스트

#### FCM 토큰 확인
앱 실행 후 Flutter 로그에서 토큰 확인:
```
🍎 APNs 토큰 확보: 32af8c3d...
🔑 FCM 토큰: fGbY8j2VQE...
```

#### 테스트 메시지 전송
Firebase Console → Cloud Messaging → 새 알림:

1. **일반 FCM 메시지**: 기본 메시지 전송
2. **채널톡 메시지**: 
   - 추가 옵션 → 맞춤 데이터
   - `provider: Channel.io` 추가

### 3. Channel Desk 테스트
Channel Desk에서 실제 고객 메시지를 전송하여 푸시 알림이 정상 작동하는지 확인

⚠️ **중요한 테스트 조건**:
- **유저가 오프라인 상태**여야 푸시 알림이 전송됩니다
- 앱이 포그라운드에 있거나 유저가 온라인 상태일 때는 푸시 대신 인앱 메시지로 처리됩니다
- 테스트 시 앱을 백그라운드로 보내거나 종료한 후 메시지를 전송하세요

---

## 문제 해결

### 1. APNs 토큰을 가져올 수 없음
**원인**: 
- 시뮬레이터에서 테스트
- 인증서 설정 문제
- 네트워크 연결 문제

**해결**:
```swift
// APNs 토큰 획득 재시도 로직
private func retryGetAPNSToken() {
    var attempts = 0
    let maxAttempts = 10
    
    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
        let apnsToken = Messaging.messaging().apnsToken
        
        if apnsToken != nil {
            timer.invalidate()
            // 토큰 획득 성공
        } else if attempts >= maxAttempts {
            timer.invalidate()
            // 토큰 획득 실패
        }
        attempts += 1
    }
}
```

### 2. 알림 권한이 거부됨
**원인**: 사용자가 알림 권한을 거부
**해결**:
```dart
// Flutter에서 권한 상태 확인
final settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
);

if (settings.authorizationStatus == AuthorizationStatus.denied) {
    // 사용자에게 설정 앱에서 알림 허용 안내
    showDialog(/* 설정 앱으로 이동 안내 */);
}
```

### 3. 채널톡 알림이 Flutter로 전달되지 않음
**원인**: AppDelegate 설정 누락
**해결**: 
- `UNUserNotificationCenterDelegate` 구현 확인
- `userNotificationCenter:didReceive:` 메서드에서 `completionHandler` 호출 확인

### 4. Stored Push Notification이 열리지 않음
**원인**: Boot 완료 후 `openStoredPushNotification` 호출
**해결**:
```dart
// Boot 완료 전에 호출
if (await channelIO.hasStoredPushNotification()) {
    await channelIO.openStoredPushNotification();
}
await channelIO.boot(/* ... */);
```

### 5. Extension에서 ChannelIOFront를 찾을 수 없음
**원인**: Extension Target에 SDK 연결 안됨
**해결**:
- CocoaPods: Podfile에 Extension Target 추가
- SPM: Extension Target의 Framework에 ChannelIOFront 추가

### 6. Firebase 관련 빌드 오류
**오류**: 
```
Include of non-modular header inside framework module 'firebase_messaging.FLTFirebaseMessagingPlugin'
```

**원인**: Firebase 플러그인에서 non-modular header를 사용하는데 Xcode가 modular headers만 허용하도록 설정됨

**해결**:
1. **Xcode에서 프로젝트 열기** (`ios/Runner.xcworkspace`)
2. **Runner 타겟 선택**
3. **Build Settings** 탭 이동
4. **검색창에 "Allow Non-modular" 입력**
5. **"Allow Non-modular Includes in Framework Modules"** 항목 찾기
6. **값을 "YES"로 변경**

> 💡 **팁**: Build Settings에서 "All" 및 "Combined" 뷰로 설정하면 항목을 더 쉽게 찾을 수 있습니다.

---

## 추가 참고사항

### Apple Developer 계정 요구사항
- APNs 사용을 위해 **유료 Apple Developer 계정** 필요
- 무료 계정으로는 푸시 알림 테스트 불가

### 인증서 관리
- Push Notification Key(.p8)는 한 번만 다운로드 가능
- Team ID, Bundle ID는 정확히 입력해야 함
- 만료된 인증서는 새로 생성 필요

### iOS 버전 호환성
- iOS 10 이상: UNUserNotificationCenter 사용 권장
- iOS 10 미만: UILocalNotification 사용 (deprecated)

---

> 📖 **더 자세한 정보**: [채널톡 iOS Push Notification 공식 문서](https://developers.channel.io/docs/ios-push-notification)를 참조해주세요.
> 
> 🔧 **기술 지원**: [채널톡 지원센터](https://channel.io)로 문의해주세요.
