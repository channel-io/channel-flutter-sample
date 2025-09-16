# Flutter ChannelTalk Push Notification Setup Guide

## 📋 Table of Contents

1. [Overview](#overview)
2. [Flutter FCM Basic Setup](#flutter-fcm-basic-setup)
3. [Platform-specific ChannelTalk Push Setup](#platform-specific-channeltalk-push-setup)
4. [FCM Manager Guide](#fcm-manager-guide)

---

## Overview

This guide explains how to set up push notifications for ChannelTalk in Flutter projects.

To implement ChannelTalk push notifications, you need:
1. **Flutter FCM Basic Setup** (refer to Firebase official documentation)
2. **Platform-specific Native Work** (refer to ChannelTalk official documentation)
3. **FCM Manager Implementation** (custom implementation in this project)

---

## Flutter FCM Basic Setup

For setting up FCM (Firebase Cloud Messaging) in Flutter, please refer to Firebase official documentation:

📖 **[Set up Firebase Cloud Messaging client app on Flutter](https://firebase.google.com/docs/cloud-messaging/flutter/client)**

### Key Setup Requirements
- Create Firebase project and register app
- Set up `google-services.json` (Android) / `GoogleService-Info.plist` (iOS)
- FlutterFire setup via Firebase CLI
- Install `firebase_core`, `firebase_messaging` packages

---

## Platform-specific ChannelTalk Push Setup

Platform-specific native work is required to properly handle ChannelTalk push messages:

### Android Setup
📖 **[Android Push Notification Setup Guide](./push_notification_android.md)**
- Based on ChannelTalk Android official documentation
- Custom FCM service implementation
- Firebase and ChannelTalk SDK integration

### iOS Setup  
📖 **[iOS Push Notification Setup Guide](./push_notification_ios.md)**
- Based on ChannelTalk iOS official documentation
- APNs certificate setup
- AppDelegate configuration and notification handling

---

## FCM Manager Guide

This project implements the `FCMManager` class to integrate FCM handling between Flutter and native platforms.

### Key Features

#### Platform-specific Optimization
- **Android**: ChannelTalk message native handling in custom FCM service
- **iOS**: ChannelTalk message native direct handling

#### Accurate ChannelTalk Message Detection
```dart
bool _isChannelIOMessage(Map<String, dynamic> data) {
  final provider = data['provider']?.toString();
  return provider == 'Channel.io';
}
```

All push messages sent by ChannelTalk include the `provider: Channel.io` key in the `data` field.

### FCMManager Usage

#### 1. Initialization
```dart
final fcmManager = FCMManager();
await fcmManager.initialize();
```

#### 2. Status Check
```dart
final status = fcmManager.getStatus();
print('FCM initialized: ${status['initialized']}');
print('Permission granted: ${status['permissionGranted']}');
print('Platform: ${status['platform']}');
```

#### 3. Token Information
```dart
print('FCM token: ${fcmManager.fcmToken}');
if (Platform.isIOS) {
  print('APNs token: ${fcmManager.apnsToken}');
}
```

#### 4. ChannelTalk Message Detection Example

⚠️ **Recommended Approach**:
We basically recommend using `isChannelPushNotification` provided by the SDK.
However, in background situations, native code access can be difficult, so in such cases we recommend filtering as shown below.

##### Using SDK Method in Native Code (Recommended)
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

##### Data Filtering in Flutter
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

### Message Processing Flow

#### Android
1. **Background**: Native handling in `ChannelIOFirebaseMessagingService`
2. **Foreground**: Duplication prevention in Flutter as already handled by custom service
3. **Notification Click**: Handled in Flutter after checking `hasStoredPushNotification()`

#### iOS
1. **Background**: Handled natively as stored push notification
2. **Foreground**: Direct native handling with `receivePushNotification()`
3. **Notification Click**: Handled natively (no separate handling in Flutter)

### Debugging and Troubleshooting

#### FCM Token Check
```dart
final status = fcmManager.getStatus();
if (!status['hasToken']) {
  print('Unable to obtain FCM token.');
}
```

#### Permission Check
```dart
if (!status['permissionGranted']) {
  print('Notification permission denied. Please allow permission in settings.');
}
```

#### Platform-specific Considerations
- **Android**: Test on real device with Google Play Services installed
- **iOS**: APNs push testing only works on real device (not simulator)

#### Important Processing Considerations
⚠️ **Native Processing and Flutter Filtering**:
- ChannelTalk messages are primarily handled natively, but may still be delivered to the Flutter layer due to Flutter's internal logic
- We recommend filtering once more with code like `_isChannelIOMessage()` to handle such cases
- Refer to the **ChannelTalk Message Detection Example** code above

⚠️ **Testing Considerations**:
- For push notification testing, **users must be in offline status**
- When the app is in foreground or user is online, messages are handled as in-app messages instead of push notifications

---

## Additional References

### Test Environment
- **Important**: FCM push notifications can only be fully tested on real devices
- Limited functionality works on emulators/simulators

### Firebase Console Testing
1. Firebase Console → Cloud Messaging → Compose notification
2. **General Message**: Send regular FCM message
3. **ChannelTalk Message**: Additional options → Custom data, add `provider: Channel.io`

### Support
For ChannelTalk technical support, please contact [ChannelTalk Support Center](https://channel.io).

---
