# ChannelIOManager Guide

## 📋 Table of Contents

1. [Overview](#overview)
2. [Architecture Structure](#architecture-structure)
3. [Code Reuse Guide](#code-reuse-guide)
4. [Platform-specific ChannelIOManager Implementation](#platform-specific-channeliomanager-implementation)
5. [Using ChannelIOManager in Flutter](#using-channeliomanager-in-flutter)
6. [Important Notes](#important-notes)

## Overview

`ChannelIOManager` is a core management class for using the ChannelTalk SDK in Flutter projects. It serves as a bridge between Flutter and native platforms (Android/iOS), enabling all ChannelTalk SDK functionality to be used in Flutter.

### Key Features

- **Unified Interface**: Access all ChannelTalk features through a single class in Flutter
- **Real-time Event Reception**: Real-time delivery of events from native SDKs to Flutter
- **Platform-specific Optimization**: Implementation considering the characteristics of Android and iOS
- **FCM Integration**: Perfect compatibility with Firebase Cloud Messaging

## Architecture Structure

```
┌─────────────────────────────────────────────────────────────────┐
│                          Flutter Layer                          │
├─────────────────────────────────────────────────────────────────┤
│                    ChannelIOManager.dart                        │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │ - Singleton instance                                      │  │
│  │ - MethodChannel communication                             │  │
│  │ - Event callback management                               │  │
│  │ - SDK feature methods (boot, showMessenger, etc.)         │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                                   ↕
                         MethodChannel Communication
                                   ↕
┌─────────────────────────────────┬─────────────────────────────────┐
│           Android               │              iOS                │
├─────────────────────────────────┼─────────────────────────────────┤
│       MainActivity.kt           │        AppDelegate.swift        │
│  ┌─────────────────────────────┐│  ┌─────────────────────────────┐│
│  │ - FlutterActivity           ││  │ - FlutterAppDelegate        ││
│  │ - MethodChannel setup       ││  │ - MethodChannel setup       ││
│  └─────────────────────────────┘│  └─────────────────────────────┘│
│              ↕                  │              ↕                  │
│    ChannelIOManager.kt          │    ChannelIOManager.swift       │
│  ┌─────────────────────────────┐│  ┌─────────────────────────────┐│
│  │ - ChannelPluginListener     ││  │ - CHTChannelPluginDelegate  ││
│  │ - SDK method impl.          ││  │ - SDK method impl.          ││
│  │ - Event handling            ││  │ - Event handling            ││
│  └─────────────────────────────┘│  └─────────────────────────────┘│
│              ↕                  │              ↕                  │
│      ChannelIO SDK              │      ChannelIOFront SDK         │
└─────────────────────────────────┴─────────────────────────────────┘
```

## Code Reuse Guide

### Recommendations for Reusing Sample Project

**⚠️ Important**: We recommend using the sample project code as **reference material rather than direct reuse**.
If you do reuse it, please modify the code according to the instructions below.

### Required Modifications

#### 1. Change Package Names
```kotlin
// Android - Modify package name at the top of files
package io.channel.channeltalk_sample  // ← Change to your actual project package name

// Modification needed in all Kotlin files:
// - MainActivity.kt
// - MainApplication.kt
// - ChannelIOManager.kt  
// - ChannelIOFirebaseMessagingService.kt
```

#### 2. Set Plugin Key
```dart
// In lib/main.dart, change to your actual plugin key
final result = await channelIO.boot(
  pluginKey: "YOUR_ACTUAL_PLUGIN_KEY",  // ← Use actual key issued by ChannelTalk
  // ... other settings
);
```

#### 3. Replace Firebase Configuration Files
- **Android**: `android/app/google-services.json`
- **iOS**: `ios/Runner/GoogleService-Info.plist`

Replace with your actual project's Firebase configuration files.

#### 4. Change App Identifiers and Bundle IDs
```xml
<!-- Android - android/app/src/main/AndroidManifest.xml -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.yourcompany.yourapp">  <!-- Change to actual package name -->
```

```xml
<!-- iOS - ios/Runner/Info.plist -->
<key>CFBundleIdentifier</key>
<string>com.yourcompany.yourapp</string>  <!-- Change to actual bundle ID -->
```

### Platform-specific Additional Considerations

#### Android Related

1. **Modify gradle files**
```kotlin
// android/app/build.gradle.kts
android {
    namespace = "com.yourcompany.yourapp"  // Change to actual namespace
    applicationId = "com.yourcompany.yourapp"  // Change to actual app ID
}
```

2. **Check permission settings**
```xml
<!-- Keep only necessary permissions in AndroidManifest.xml -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />  <!-- Android 13+ -->
```

#### iOS Related

1. **⚠️ Special Note for ChannelIOManager.swift Reuse**
   - **We recommend adding the `ChannelIOManager.swift` file directly in Xcode**
   - Copying from file explorer or creating with external editors may cause the iOS project not to recognize it
   - For details, refer to [Apple Developer Documentation](https://developer.apple.com/xcode/)

2. **Modify Podfile**
```ruby
# ios/Podfile
platform :ios, '15.0'  # Check minimum supported version

target 'YourAppName' do  # Change to actual app name
  use_frameworks!
  # ... other settings
end
```

3. **Check app settings**
```xml
<!-- ios/Runner/Info.plist -->
<key>CFBundleName</key>
<string>YourAppName</string>  <!-- Change to actual app name -->
```

### Code Reuse Checklist

- [ ] Change package name/bundle ID
- [ ] Set actual ChannelTalk plugin key
- [ ] Replace Firebase configuration files (`google-services.json`, `GoogleService-Info.plist`)
- [ ] Check Android permissions (especially Android 13+ `POST_NOTIFICATIONS`)
- [ ] Check iOS notification permissions
- [ ] Modify app information in Gradle/Podfile
- [ ] Add ChannelIOManager.swift directly in Xcode
- [ ] Test that FCM token is properly registered with ChannelIO
- [ ] Test that ChannelTalk push notifications work correctly

## Platform-specific ChannelIOManager Implementation

### 1. Flutter Layer: `ChannelIOManager.dart`

The Flutter layer ChannelIOManager is implemented using the Singleton pattern and handles communication with native platforms.

#### Key Components:

- **MethodChannel**: Communicates with native platforms using the name `'channel_io_manager'`
- **Event Callbacks**: Receives events from native platforms and delivers them to Flutter apps
- **SDK Methods**: Wraps all ChannelTalk SDK functionality for use in Flutter

#### Key Methods:

```dart
// SDK initialization
Future<Map<String, dynamic>> boot({
  required String pluginKey,
  String? memberId,
  String? language = 'ko',
  // ... other options
})

// Chat related
Future<void> showMessenger()
Future<void> hideMessenger()
Future<void> openChat({String? chatId, String? message})

// User management
Future<void> updateUser(Map<String, dynamic> userData)
Future<void> addTags(List<String> tags)
Future<void> removeTags(List<String> tags)

// Push notifications
Future<void> initPushToken(String token)
Future<bool> isChannelPushNotification(Map<String, String> payload)
```

#### Event Callbacks:

```dart
// Badge change events
Function(int unread, int alert)? onBadgeChanged;

// Chat creation events
Function(String chatId)? onChatCreated;

// Messenger show/hide events
Function()? onShowMessenger;
Function()? onHideMessenger;

// Push notification click events
Function(String chatId)? onPushNotificationClicked;
```

### 2. Android: `ChannelIOManager.kt`

The Android ChannelIOManager implements `ChannelPluginListener` to receive ChannelTalk SDK events.

#### Key Features:

- **ChannelPluginListener Implementation**: Receives SDK events in real-time
- **Handler + Looper**: Delivers events to Flutter on the UI thread
- **Complete SDK Wrapping**: Makes all ChannelIO Android SDK functionality available in Flutter

#### ChannelPluginListener Implementation:

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
    return true // Let ChannelIO handle directly
}
```

### 3. iOS: `ChannelIOManager.swift`

The iOS ChannelIOManager implements `CHTChannelPluginDelegate` to receive ChannelTalk SDK events.

#### Key Features:

- **CHTChannelPluginDelegate Implementation**: Receives SDK events in real-time
- **DispatchQueue**: Delivers events to Flutter on the main thread
- **Complete SDK Wrapping**: Makes all ChannelIOFront SDK functionality available in Flutter

#### CHTChannelPluginDelegate Implementation:

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
    return false // Open in default browser
}
```

## Using ChannelIOManager in Flutter

### 1. Initialization

```dart
final ChannelIOManager channelIO = ChannelIOManager();

// Set event listeners (optional)
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
    memberId: 'user123',          // Optional
    language: 'en',               // Optional
    appearance: 'system',         // Optional ('light', 'dark', 'system')
    profile: {                    // Optional
      'name': 'John Doe',
      'email': 'user@example.com'
    },
    tags: ['VIP', 'Premium'],     // Optional
  );

  if (result['success'] == true) {
    print('ChannelIO boot successful');
    print('Status: ${result['status']}');
    print('User: ${result['user']}');
  } else {
    print('ChannelIO boot failed: ${result['error']}');
  }
}
```

### 3. Messenger Control

```dart
// Show messenger
await channelIO.showMessenger();

// Hide messenger
await channelIO.hideMessenger();

// Open specific chat
await channelIO.openChat(
  chatId: 'specific_chat_id',
  message: 'Pre-filled message'
);

// Execute workflow
await channelIO.openWorkflow(workflowId: 'workflow_id');
```

### 4. User Management

```dart
// Update user information
await channelIO.updateUser({
  'name': 'New Name',
  'email': 'new@example.com',
  'customField': 'Custom Value'
});

// Add tags
await channelIO.addTags(['New Tag', 'Another Tag']);

// Remove tags
await channelIO.removeTags(['Old Tag']);
```

### 5. Event Tracking

```dart
// Track user events
await channelIO.track(
  eventName: 'PurchaseCompleted',
  eventProperty: {
    'productId': 'product123',
    'amount': 29.99,
    'currency': 'USD'
  }
);
```

### 6. Push Notification Handling

```dart
// Initialize FCM token
await channelIO.initPushToken(fcmToken);

// Check if push is from ChannelIO
bool isChannelPush = await channelIO.isChannelPushNotification(
  {'key1': 'value1', 'key2': 'value2'}
);

if (isChannelPush) {
  // Handle ChannelIO push
  await channelIO.receivePushNotification(payload);
} else {
  // Handle general push
}
```

## Important Notes

### 1. Platform-specific Differences

#### Android vs iOS SDK Differences
- **Method Signatures**: Some methods may have different parameters across platforms
- **Event Callbacks**: Supported events may vary slightly by platform
- **Push Notification Handling**: Android uses FCM, iOS uses APNs - different approaches

### 2. Debugging Tips

```dart
// Enable debug mode
await channelIO.setDebugMode(true);

// Check boot status
bool isBooted = await channelIO.isBooted();
print('ChannelIO Boot Status: $isBooted');
```

### 3. Troubleshooting

#### Common Issues

1. **Boot Failure**
   - Check plugin key
   - Check network connection status
   - Check ChannelTalk service status

2. **Events Not Received**
   - Verify listeners are properly registered
   - Ensure MethodChannel calls in native code run on main thread

3. **Push Notification Issues**
   - Check if FCM token is properly registered
   - Verify Firebase configuration files are correct
   - Check if push settings are enabled in Channel Desk

## Additional Resources

- 📖 **Official Documentation**: [ChannelTalk Developer Docs](https://developers.channel.io/)
- 🔧 **Technical Support**: [ChannelTalk Support Center](https://channel.io)
- 📱 **iOS SDK**: [ChannelTalk iOS Guide](https://developers.channel.io/docs/ios-quickstart)
- 🤖 **Android SDK**: [ChannelTalk Android Guide](https://developers.channel.io/docs/android-quickstart)

---

> **Note**: This guide is based on the sample project. For actual production environments, additional considerations for security, performance, error handling, etc. should be taken into account.
