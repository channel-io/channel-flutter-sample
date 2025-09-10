# iOS Push Notification Setup Guide

## 📋 Table of Contents

1. [Overview](#overview)
2. [ChannelTalk Official Setup](#channeltalk-official-setup)  
3. [Flutter Project Additional Implementation](#flutter-project-additional-implementation)
4. [Testing Methods](#testing-methods)
5. [Troubleshooting](#troubleshooting)

---

## Overview

This guide explains how to set up ChannelTalk iOS push notifications in Flutter projects.

### Implementation Approach
- **Basic Setup**: Based on ChannelTalk official documentation
- **Additional Implementation**: AppDelegate configuration for Flutter FCM integration

---

## ChannelTalk Official Setup

For basic ChannelTalk iOS push notification setup, please refer to the official documentation:

📖 **[ChannelTalk iOS Push Notification Official Documentation](https://developers.channel.io/docs/ios-push-notification)**

### Key Configuration Steps

#### 1. APNs Credential Setup
Apple Push Notification service certificate setup is required.

##### Push Notification Key Generation
1. **Apple Developer Console** → **Certificates, Identifiers & Profiles** → **Keys**
2. Generate **Push Notification Key**
3. Download **Key ID** and **Key file (.p8)** (only available once)
4. Check **Team ID** (**Account** → **Membership**)

##### Register Certificate in Channel Desk
1. **ChannelTalk Admin** → **Settings** → **Security & Development** → **Mobile SDK Push**
2. In **iOS** section, enter Key file, Key ID, Bundle ID, Team ID

#### 2. Info.plist Configuration
```xml
<!-- ios/Runner/Info.plist -->
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>

<!-- Firebase Auto Initialization -->
<key>FirebaseMessagingAutoInitEnabled</key>
<true/>
```

#### 3. Permission Request
iOS requires explicit notification permission request from users.

---

## Flutter Project Additional Implementation

This project includes additional implementation for Flutter FCM compatibility.

### 1. AppDelegate.swift Configuration

#### Basic Imports and Setup
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
        
        // Initialize Firebase
        FirebaseApp.configure()
        
        // Configure notification permissions
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        
        // Request remote notification registration
        application.registerForRemoteNotifications()
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
```

#### APNs Token Registration
```swift
// Register APNs token with Firebase and ChannelTalk
func application(_ application: UIApplication, 
                didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    
    // Register APNs token with Firebase Messaging
    Messaging.messaging().apnsToken = deviceToken
    
    // Register APNs token with ChannelTalk (according to official documentation)
    ChannelIO.initPushToken(deviceToken: deviceToken)
}
```

#### Notification Handling (UNUserNotificationCenterDelegate)
```swift
extension AppDelegate: UNUserNotificationCenterDelegate, MessagingDelegate {
    
    // Handle notification clicks
    override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        // Check if it's a ChannelTalk message
        if ChannelIO.isChannelPushNotification(userInfo) {
            // Handle ChannelTalk notification
            ChannelIO.receivePushNotification(userInfo)
            ChannelIO.storePushNotification(userInfo)
        }
        
        // Forward to Flutter FCM as well (triggers onMessageOpenedApp event)
        super.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
    }
    
    // Handle background notifications
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

#### Background Notification Handling (Optional)
```swift
// For iOS versions below 10 or background fetch (implement if needed)
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

### 2. Stored Push Notification Handling

ChannelTalk manages notifications received when the app is in background or terminated state as "stored push notifications".

#### Check in AppDelegate
Check and handle stored notifications when the app starts:

```swift
// Call after ChannelTalk Boot completion
if ChannelIO.hasStoredPushNotification() {
    ChannelIO.openStoredPushNotification()
}
```

> ⚠️ **Important**: `openStoredPushNotification` should be called before ChannelTalk Boot completion. Stored notification information is deleted during Boot.

### 3. Notification Service Extension (Recommended)

To completely handle ChannelTalk notifications in background/terminated state, adding a Notification Service Extension is recommended.

#### Create Extension Target
1. Xcode → **File** → **New** → **Target**
2. Select **Notification Service Extension**
3. Specify target name (e.g., `NotificationServiceExtension`)

#### Implement NotificationService.swift
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
        
        // Handle ChannelTalk notifications (for SMS feature integration)
        ChannelIO.receivePushNotification(request.content.userInfo)
        
        // Additional logic for image attachment handling...
        
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

## Testing Methods

### 1. Simulator vs Real Device
- ⚠️ **Important**: APNs push notifications can only be tested on **real iOS devices**
- Simulator generates FCM tokens but APNs doesn't work

### 2. Firebase Console Testing

#### Check FCM Token
Verify token in Flutter logs after app launch:
```
🍎 APNs token acquired: 32af8c3d...
🔑 FCM token: fGbY8j2VQE...
```

#### Send Test Message
Firebase Console → Cloud Messaging → Create notification:

1. **General FCM Message**: Send basic message
2. **ChannelTalk Message**: 
   - Advanced options → Custom data
   - Add `provider: Channel.io`

### 3. Channel Desk Testing
Test actual ChannelTalk push notifications by sending real customer messages from Channel Desk

⚠️ **Important Test Conditions**:
- **User must be in offline status** for push notifications to be sent
- When app is in foreground or user is online, messages are handled as in-app messages instead of push notifications
- For testing, put app in background or terminate it before sending messages

---

## Troubleshooting

### 1. Cannot obtain APNs token
**Causes**: 
- Testing on simulator
- Certificate configuration issues
- Network connection problems

**Solution**:
```swift
// APNs token acquisition retry logic
private func retryGetAPNSToken() {
    var attempts = 0
    let maxAttempts = 10
    
    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
        let apnsToken = Messaging.messaging().apnsToken
        
        if apnsToken != nil {
            timer.invalidate()
            // Token acquisition successful
        } else if attempts >= maxAttempts {
            timer.invalidate()
            // Token acquisition failed
        }
        attempts += 1
    }
}
```

### 2. Notification permission denied
**Cause**: User denied notification permission
**Solution**:
```dart
// Check permission status in Flutter
final settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
);

if (settings.authorizationStatus == AuthorizationStatus.denied) {
    // Guide user to enable notifications in settings
    showDialog(/* Guide to settings app */);
}
```

### 3. ChannelTalk notifications not forwarded to Flutter
**Cause**: Missing AppDelegate configuration
**Solution**: 
- Check `UNUserNotificationCenterDelegate` implementation
- Verify `completionHandler` call in `userNotificationCenter:didReceive:` method

### 4. Stored Push Notification won't open
**Cause**: Calling `openStoredPushNotification` after Boot completion
**Solution**:
```dart
// Call before Boot completion
if (await channelIO.hasStoredPushNotification()) {
    await channelIO.openStoredPushNotification();
}
await channelIO.boot(/* ... */);
```

### 5. Cannot find ChannelIOFront in Extension
**Cause**: SDK not linked to Extension Target
**Solution**:
- CocoaPods: Add Extension Target to Podfile
- SPM: Add ChannelIOFront to Extension Target's Framework

### 6. Firebase-related build errors
**Error**: 
```
Include of non-modular header inside framework module 'firebase_messaging.FLTFirebaseMessagingPlugin'
```

**Cause**: Firebase plugin uses non-modular headers, but Xcode is configured to allow only modular headers

**Solution**:
1. **Open project in Xcode** (`ios/Runner.xcworkspace`)
2. **Select Runner target**
3. **Go to Build Settings tab**
4. **Search for "Allow Non-modular"**
5. **Find "Allow Non-modular Includes in Framework Modules" item**
6. **Change value to "YES"**

> 💡 **Tip**: Set Build Settings to "All" and "Combined" view to find items more easily.

---

## Additional References

### Apple Developer Account Requirements
- **Paid Apple Developer Account** required for APNs usage
- Push notification testing not available with free account

### Certificate Management
- Push Notification Key (.p8) can only be downloaded once
- Team ID and Bundle ID must be entered accurately
- Expired certificates need to be regenerated

### iOS Version Compatibility
- iOS 10+: Recommend using UNUserNotificationCenter
- iOS 10 below: Use UILocalNotification (deprecated)

---

> 📖 **More Information**: Refer to [ChannelTalk iOS Push Notification Official Documentation](https://developers.channel.io/docs/ios-push-notification).

> 🔧 **Technical Support**: Contact [ChannelTalk Support Center](https://channel.io) for assistance.
