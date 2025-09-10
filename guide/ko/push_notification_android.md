# Android 푸시 알림 설정 가이드

## 📋 목차

1. [개요](#개요)
2. [채널톡 공식 설정](#채널톡-공식-설정)
3. [Flutter 프로젝트 추가 구현](#flutter-프로젝트-추가-구현)
4. [테스트 방법](#테스트-방법)
5. [문제 해결](#문제-해결)

---

## 개요

이 문서는 Flutter 프로젝트에서 채널톡 Android 푸시 알림을 설정하는 방법을 안내합니다.

### 구현 방식
- **기본 설정**: 채널톡 공식 문서 기반
- **추가 구현**: Flutter FCM과 호환되는 커스텀 FCM 서비스

---

## 채널톡 공식 설정

채널톡 Android 푸시 알림의 기본 설정은 공식 문서를 참조해주세요:

📖 **[채널톡 Android Push Notification 공식 문서](https://developers.channel.io/docs/android-push-notification)**

### 주요 설정 사항

#### 1. Firebase 프로젝트 설정
- `google-services.json` 파일을 `android/app/` 디렉토리에 배치
- Firebase Console에서 Android 앱 등록

#### 2. 권한 설정

**Flutter Firebase Messaging 패키지 자동 처리**

Flutter의 `firebase_messaging` 패키지는 FCM에 필요한 권한들을 자동으로 AndroidManifest.xml에 추가합니다:

- `android.permission.INTERNET`
- `android.permission.WAKE_LOCK` 
- `android.permission.VIBRATE`
- `android.permission.POST_NOTIFICATIONS` (Android 13+)

> 📌 **권장 사항**: 대부분의 경우 Flutter FCM 패키지가 권한을 자동으로 처리하므로 **별도 권한 추가가 불필요**합니다.

**수동 권한 추가 (필요시)**

만약 권한이 제대로 추가되지 않거나 추가적인 권한이 필요한 경우, `android/app/src/main/AndroidManifest.xml`에 다음을 추가하세요:

```xml
<!-- FCM 관련 권한 (보통 자동 추가됨) -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.VIBRATE" />

<!-- Android 13+ 알림 권한 (자동 추가됨) -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

#### 3. Channel Desk 연동
- Firebase 서비스 계정 키 생성
- Channel Desk에 서비스 계정 키 업로드 
- **Channel Settings > Security and Development > Mobile SDK Push > Android**

---

## Flutter 프로젝트 추가 구현

이 프로젝트에서는 Flutter FCM과의 호환성을 위해 추가적인 구현을 했습니다.

### 1. 의존성 추가

#### build.gradle.kts 설정
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    // Google Services 플러그인: FlutterFirebaseMessagingService 상속을 위해 필요
    id("com.google.gms.google-services")
}

dependencies {
    // 채널톡 Android SDK
    implementation("io.channel:plugin-android:12.13.0")
    
    // Firebase BOM: 버전 관리를 위한 BOM 선언
    // FlutterFirebaseMessagingService 상속을 위해 필요
    implementation(platform("com.google.firebase:firebase-bom:33.1.2"))
    
    // Firebase Messaging: 커스텀 FCM 서비스 구현을 위해 필요
    // FlutterFirebaseMessagingService 클래스를 사용하기 위한 의존성
    implementation("com.google.firebase:firebase-messaging")
    
    // Core library desugaring: Java 8+ 기능 지원
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}
```

### 2. 커스텀 FCM 서비스 구현

#### ChannelIOFirebaseMessagingService.kt
`android/app/src/main/kotlin/[패키지명]/ChannelIOFirebaseMessagingService.kt` 파일을 생성하세요:

```kotlin
package io.channel.channeltalk_sample

import android.util.Log
import com.google.firebase.messaging.RemoteMessage
import com.zoyi.channel.plugin.android.ChannelIO
import io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingService

/**
 * ChannelIO 통합 Firebase 메시징 서비스
 * 
 * FlutterFirebaseMessagingService를 상속받아 Flutter FCM의 모든 기능을 유지하면서
 * ChannelIO 메시지에 대한 네이티브 처리를 추가로 수행합니다.
 * 
 * 동작 원리:
 * 1. 모든 FCM 메시지를 먼저 수신
 * 2. 메시지 데이터에서 ChannelIO 메시지 판별 (SDK 내장 함수 사용)
 * 3. ChannelIO 메시지인 경우 네이티브 ChannelIO SDK로 직접 처리
 * 4. 일반 메시지는 Flutter FCM으로 전달하여 기존 Flutter FCM 동작 유지
 */
class ChannelIOFirebaseMessagingService : FlutterFirebaseMessagingService() {

    companion object {
        private const val TAG = "ChannelIOFCMService"
    }

    /**
     * FCM 메시지 수신 처리
     * 
     * Flutter FCM 서비스의 onMessageReceived를 오버라이드하여
     * ChannelIO 메시지에 대한 추가 처리를 수행합니다.
     * 
     * @param remoteMessage Firebase로부터 수신된 메시지
     */
    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        try {
            // ChannelIO 메시지 판별 (SDK 내장 함수 사용)
            val isChannelMessage = ChannelIO.isChannelPushNotification(remoteMessage.data)

            if (isChannelMessage) {
                // ChannelIO SDK를 통한 네이티브 처리
                // 이 처리는 백그라운드에서도 정상 동작합니다
                ChannelIO.receivePushNotification(this, remoteMessage.data)
            } else {
                // 일반 FCM 메시지는 Flutter FCM으로 전달
                super.onMessageReceived(remoteMessage)
            }
        } catch (e: Exception) {
            Log.e(TAG, "메시지 처리 오류: ${e.message}", e)
            // 오류 발생 시 Flutter FCM으로 전달
            super.onMessageReceived(remoteMessage)
        }
    }

    /**
     * FCM 토큰 갱신 처리
     * 
     * 새로운 FCM 토큰이 생성되거나 갱신될 때 호출됩니다.
     * ChannelIO에도 새 토큰을 등록하고 Flutter로도 전달합니다.
     * 
     * @param token 새로운 FCM 토큰
     */
    override fun onNewToken(token: String) {
        try {
            // ChannelIO에 새 토큰 등록
            ChannelIO.initPushToken(token)
        } catch (e: Exception) {
            Log.e(TAG, "ChannelIO 토큰 등록 실패: ${e.message}", e)
        }

        // Flutter FCM에도 토큰 갱신 알림
        super.onNewToken(token)
    }
}
```

### 3. AndroidManifest.xml 설정

`android/app/src/main/AndroidManifest.xml`에 다음 서비스 설정을 추가하세요:

```xml
<application
    android:label="channeltalk_sample"
    android:name=".MainApplication"
    android:icon="@mipmap/ic_launcher">
    
    <!-- 기존 Activity 설정... -->
    
    <!-- 
    ====================================================================
    ChannelIO 통합 FCM 서비스 설정
    ====================================================================
    
    Flutter FCM과 ChannelIO를 동시에 지원하기 위한 커스텀 서비스입니다.
    기본 FlutterFirebaseMessagingService를 비활성화하고
    ChannelIOFirebaseMessagingService가 대신 처리합니다.
    -->
    
    <!-- ChannelIO 통합 FCM 서비스 등록 -->
    <!-- 
    우선순위 1로 설정하여 이 서비스가 FCM 메시지를 먼저 처리하도록 합니다.
    FlutterFirebaseMessagingService를 상속받아 Flutter FCM 기능을 모두 유지합니다.
    -->
    <service
        android:name=".ChannelIOFirebaseMessagingService"
        android:exported="false">
        <intent-filter android:priority="1">
            <action android:name="com.google.firebase.MESSAGING_EVENT" />
        </intent-filter>
    </service>
    
    <!-- 기본 Flutter FCM 서비스 비활성화 -->
    <!--
    커스텀 서비스가 FlutterFirebaseMessagingService를 상속받아 
    모든 기능을 제공하므로 기본 서비스는 비활성화합니다.
    이렇게 하면 메시지가 중복으로 처리되는 것을 방지할 수 있습니다.
    -->
    <service
        android:name="io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingService"
        android:enabled="false" />
        
    <!-- FCM 기본 알림 채널 설정 -->
    <!-- 
    Android 8.0(API 26) 이상에서 알림을 표시하기 위해 필요한 채널 ID입니다.
    strings.xml에 정의된 채널 ID를 사용합니다.
    -->
    <meta-data
        android:name="com.google.firebase.messaging.default_notification_channel_id"
        android:value="default_channel" />
        
    <!-- FCM 기본 알림 아이콘 설정 (선택사항) -->
    <!-- 
    커스텀 알림 아이콘을 사용하려면 주석을 해제하고 
    app/src/main/res/drawable/에 아이콘 파일을 추가하세요.
    -->
    <!-- <meta-data
        android:name="com.google.firebase.messaging.default_notification_icon"
        android:resource="@drawable/ic_stat_ic_notification" /> -->
</application>
```

### 4. 알림 채널 설정

#### strings.xml
`android/app/src/main/res/values/strings.xml` 파일을 생성하고 다음 내용을 추가하세요:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">채널톡 Sample</string>
    
    <!-- FCM 알림 채널 설정 -->
    <string name="default_notification_channel_id">default_channel</string>
    <string name="default_notification_channel_name">Default Channel</string>
    <string name="default_notification_channel_description">기본 알림 채널</string>
</resources>
```

---

## 테스트 방법

### 1. FCM 토큰 확인
앱 실행 후 Flutter 로그에서 FCM 토큰이 정상적으로 생성되는지 확인:
```
🔑 FCM 토큰: APA91bH... (토큰 미리보기)
📱 알림 권한: 허용됨 (AuthorizationStatus.authorized)
```

### 2. 일반 FCM 메시지 테스트

Flutter 앱에서 일반 FCM 메시지 테스트 방법은 Firebase 공식 문서를 참조하세요:

📖 **[Send your first message - Flutter](https://firebase.google.com/docs/cloud-messaging/flutter/first-message)**

위 문서에서 제공하는 단계를 따라 Firebase Console에서 테스트 메시지를 전송하여 일반 FCM 기능이 정상 작동하는지 확인할 수 있습니다.

### 3. 채널톡 메시지 테스트

실제 채널톡 푸시 알림을 테스트하려면 다음 단계를 따르세요:

#### 3.1. 앱에서 유저챗 생성
1. 앱을 실행하고 채널톡 Boot를 완료합니다
2. 채널톡 채팅 기능을 통해 **유저챗을 생성**합니다:
   - 채널톡 버튼 클릭 → 메시지 입력 → 전송
   - 또는 앱 내에서 `channelIO.openChat()` 호출

#### 3.2. 채널 데스크에서 메시지 전송
1. **[채널 데스크](https://desk.channel.io/)**에 로그인합니다
2. **유저챗** 탭에서 방금 생성된 채팅을 찾습니다
3. 메시지를 작성하고 전송합니다

> ⚠️ **중요**: 푸시 알림이 전송되려면 **유저가 오프라인 상태**여야 합니다.
> - **유저가 온라인일 경우**: 인앱 메시지로만 표시되고 푸시 알림은 전송되지 않습니다
> - **유저가 오프라인일 경우**: 푸시 알림이 전송됩니다

#### 3.3. 오프라인 상태 확인 방법
유저를 오프라인 상태로 만드는 방법:
- **앱을 완전히 종료** (백그라운드가 아닌 완전 종료)
- 또는 **앱을 백그라운드로 전환** 후 일정 시간 대기
- 또는 **다른 앱으로 전환** 후 채널톡에서 오프라인으로 인식될 때까지 대기

#### 3.4. 푸시 알림 도착 확인
1. **알림 수신 확인**: 기기에서 채널톡 푸시 알림이 표시되는지 확인
2. **알림 클릭 테스트**: 알림을 탭하여 앱이 열리고 해당 채팅으로 이동하는지 확인
3. **로그 확인**: Android Studio 로그에서 ChannelIO 메시지 처리 로그 확인

### 4. 동작 확인
채널톡 메시지가 수신되면 다음과 같은 동작이 수행됩니다:

#### 채널톡 메시지인 경우:
- `ChannelIO.isChannelPushNotification()`로 메시지 판별
- `ChannelIO.receivePushNotification()`로 네이티브 처리
- Flutter FCM으로는 전달되지 않음

#### 일반 FCM 메시지인 경우:
- Flutter FCM 서비스로 전달되어 정상 처리

---

## 문제 해결

### 1. FCM 토큰을 가져올 수 없음
**원인**: Google Play Services 미설치 또는 구식 버전
**해결**: 
- 실제 Android 기기에서 테스트 (에뮬레이터 아님)
- Google Play Services 최신 버전으로 업데이트

### 2. 권한 거부로 알림이 오지 않음
**원인**: 알림 권한 거부 (Android 13+에서 POST_NOTIFICATIONS 권한)
**해결**:
```dart
// Flutter에서 권한 요청
final settings = await FirebaseMessaging.instance.requestPermission(
  alert: true,
  badge: true,
  sound: true,
);

if (settings.authorizationStatus != AuthorizationStatus.authorized) {
  // 사용자에게 설정 앱에서 권한 허용 안내
  print('알림 권한이 거부되었습니다. 설정에서 알림을 허용해주세요.');
}
```

### 3. 중복 알림 수신
**원인**: Flutter FCM 서비스와 커스텀 서비스 모두 동작
**해결**: AndroidManifest.xml에서 기본 Flutter FCM 서비스 비활성화 확인
```xml
<service
    android:name="io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingService"
    android:enabled="false" />
```

### 4. 채널톡 메시지가 처리되지 않음
**원인**: 메시지 데이터에 `provider: Channel.io` 키가 없음
**해결**: Channel Desk에서 올바른 서비스 계정 키가 등록되었는지 확인

### 5. 빌드 오류 발생
**원인**: Firebase 의존성 충돌
**해결**:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk --debug
```

### 6. onNewToken이 호출되지 않음
**원인**: Firebase가 이미 설치되어 있던 프로젝트에서 발생
**해결**: 
- 앱을 완전히 삭제 후 재설치
- 또는 Firebase 토큰 강제 갱신:
```dart
await FirebaseMessaging.instance.deleteToken();
await FirebaseMessaging.instance.getToken();
```

### 7. 권한이 자동으로 추가되지 않음
**원인**: Flutter FCM 패키지 버전 또는 설정 문제
**해결**: AndroidManifest.xml에 수동으로 권한 추가 (위의 권한 설정 섹션 참조)

---

## 추가 참고사항

### 커스텀 알림 설정

#### 알림 제목 변경
```xml
<!-- strings.xml -->
<string name="notification_title">내 앱 이름</string>
```

#### 알림 아이콘 변경
```
/res/drawable/ch_push_icon.png
```

---

> 📖 **더 자세한 정보**: [채널톡 Android Push Notification 공식 문서](https://developers.channel.io/docs/android-push-notification)를 참조해주세요.
> 
> 🔧 **기술 지원**: [채널톡 지원센터](https://channel.io)로 문의해주세요.
