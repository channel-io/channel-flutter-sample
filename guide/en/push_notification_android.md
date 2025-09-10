# Android Push Notification Setup Guide

## 📋 Table of Contents

1. [Overview](#overview)
2. [ChannelTalk Official Setup](#channeltalk-official-setup)
3. [Flutter Project Additional Implementation](#flutter-project-additional-implementation)
4. [Testing Methods](#testing-methods)
5. [Troubleshooting](#troubleshooting)

---

## Overview

This guide explains how to set up ChannelTalk Android push notifications in Flutter projects.

### Implementation Approach
- **Basic Setup**: Based on ChannelTalk official documentation
- **Additional Implementation**: Custom FCM service compatible with Flutter FCM

---

## ChannelTalk Official Setup

For basic ChannelTalk Android push notification setup, please refer to the official documentation:

📖 **[ChannelTalk Android Push Notification Official Documentation](https://developers.channel.io/docs/android-push-notification)**

### Key Configuration Steps

#### 1. Firebase Project Setup
- Place `google-services.json` file in `android/app/` directory
- Register Android app in Firebase Console

#### 2. Permission Setup

**Flutter Firebase Messaging Package Auto-handling**

Flutter's `firebase_messaging` package automatically adds FCM-required permissions to AndroidManifest.xml:

- `android.permission.INTERNET`
- `android.permission.WAKE_LOCK` 
- `android.permission.VIBRATE`
- `android.permission.POST_NOTIFICATIONS` (Android 13+)

> 📌 **Recommendation**: In most cases, **no additional permission setup is required** as Flutter FCM package handles permissions automatically.

**Manual Permission Addition (if needed)**

If permissions aren't properly added or additional permissions are needed, add the following to `android/app/src/main/AndroidManifest.xml`:

```xml
<!-- FCM related permissions (usually auto-added) -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.VIBRATE" />

<!-- Android 13+ notification permission (auto-added) -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

#### 3. Channel Desk Integration
- Generate Firebase service account key
- Upload service account key to Channel Desk
- Configure in **Channel Settings > Security and Development > Mobile SDK Push > Android**

---

## Flutter Project Additional Implementation

This project includes additional implementation for Flutter FCM compatibility.

### 1. Dependency Addition

#### build.gradle.kts Configuration
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    // Google Services plugin: Required for FlutterFirebaseMessagingService inheritance
    id("com.google.gms.google-services")
}

dependencies {
    // ChannelTalk Android SDK
    implementation("io.channel:plugin-android:12.13.0")
    
    // Firebase BOM: BOM declaration for version management
    // Required for FlutterFirebaseMessagingService inheritance
    implementation(platform("com.google.firebase:firebase-bom:33.1.2"))
    
    // Firebase Messaging: Required for custom FCM service implementation
    // Dependency for using FlutterFirebaseMessagingService class
    implementation("com.google.firebase:firebase-messaging")
    
    // Core library desugaring: Support Java 8+ features
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}
```

### 2. Custom FCM Service Implementation

#### ChannelIOFirebaseMessagingService.kt
Create `android/app/src/main/kotlin/[package_name]/ChannelIOFirebaseMessagingService.kt` file:

```kotlin
package io.channel.channeltalk_sample

import android.util.Log
import com.google.firebase.messaging.RemoteMessage
import com.zoyi.channel.plugin.android.ChannelIO
import io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingService

/**
 * ChannelIO Integrated Firebase Messaging Service
 * 
 * Inherits FlutterFirebaseMessagingService to maintain all Flutter FCM functionality while
 * additionally performing native handling for ChannelIO messages.
 * 
 * How it works:
 * 1. First receive all FCM messages
 * 2. Determine ChannelIO messages from message data (using SDK built-in function)
 * 3. If it's a ChannelIO message, handle directly with native ChannelIO SDK
 * 4. Forward general messages to Flutter FCM to maintain existing Flutter FCM behavior
 */
class ChannelIOFirebaseMessagingService : FlutterFirebaseMessagingService() {

    companion object {
        private const val TAG = "ChannelIOFCMService"
    }

    /**
     * Handle FCM message reception
     * 
     * Override onMessageReceived from Flutter FCM service to
     * perform additional processing for ChannelIO messages.
     * 
     * @param remoteMessage Message received from Firebase
     */
    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        try {
            // Determine ChannelIO message (using SDK built-in function)
            val isChannelMessage = ChannelIO.isChannelPushNotification(remoteMessage.data)

            if (isChannelMessage) {
                // Native processing through ChannelIO SDK
                // This processing works normally even in the background
                ChannelIO.receivePushNotification(this, remoteMessage.data)
            } else {
                // Forward general FCM messages to Flutter FCM
                super.onMessageReceived(remoteMessage)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Message processing error: ${e.message}", e)
            // Forward to Flutter FCM on error
            super.onMessageReceived(remoteMessage)
        }
    }

    /**
     * Handle FCM token refresh
     * 
     * Called when a new FCM token is generated or refreshed.
     * Register the new token with ChannelIO and also forward to Flutter.
     * 
     * @param token New FCM token
     */
    override fun onNewToken(token: String) {
        try {
            // Register new token with ChannelIO
            ChannelIO.initPushToken(token)
        } catch (e: Exception) {
            Log.e(TAG, "❌ ChannelIO token registration failed: ${e.message}", e)
        }

        // Also notify Flutter FCM of token refresh
        super.onNewToken(token)
    }
}
```

### 3. AndroidManifest.xml Configuration

Add the following service configuration to `android/app/src/main/AndroidManifest.xml`:

```xml
<application
    android:label="channeltalk_sample"
    android:name=".MainApplication"
    android:icon="@mipmap/ic_launcher">
    
    <!-- Existing Activity configuration... -->
    
    <!-- 
    ====================================================================
    ChannelIO Integrated FCM Service Configuration
    ====================================================================
    
    Custom service to support both Flutter FCM and ChannelIO simultaneously.
    Disables default FlutterFirebaseMessagingService and
    ChannelIOFirebaseMessagingService handles instead.
    -->
    
    <!-- Register ChannelIO integrated FCM service -->
    <!-- 
    Set priority to 1 so this service handles FCM messages first.
    Inherits FlutterFirebaseMessagingService to maintain all Flutter FCM functionality.
    -->
    <service
        android:name=".ChannelIOFirebaseMessagingService"
        android:exported="false">
        <intent-filter android:priority="1">
            <action android:name="com.google.firebase.MESSAGING_EVENT" />
        </intent-filter>
    </service>
    
    <!-- Disable default Flutter FCM service -->
    <!--
    Since the custom service inherits FlutterFirebaseMessagingService
    and provides all functionality, disable the default service.
    This prevents duplicate message processing.
    -->
    <service
        android:name="io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingService"
        android:enabled="false" />
        
    <!-- FCM default notification channel configuration -->
    <!-- 
    Channel ID required to display notifications on Android 8.0 (API 26) and above.
    Uses channel ID defined in strings.xml.
    -->
    <meta-data
        android:name="com.google.firebase.messaging.default_notification_channel_id"
        android:value="default_channel" />
        
    <!-- FCM default notification icon configuration (optional) -->
    <!-- 
    To use a custom notification icon, uncomment and 
    add icon file to app/src/main/res/drawable/.
    -->
    <!-- <meta-data
        android:name="com.google.firebase.messaging.default_notification_icon"
        android:resource="@drawable/ic_stat_ic_notification" /> -->
</application>
```

### 4. Notification Channel Setup

#### strings.xml
Create `android/app/src/main/res/values/strings.xml` file and add the following content:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">ChannelTalk Sample</string>
    
    <!-- FCM notification channel configuration -->
    <string name="default_notification_channel_id">default_channel</string>
    <string name="default_notification_channel_name">Default Channel</string>
    <string name="default_notification_channel_description">Default notification channel</string>
</resources>
```

---

## Testing Methods

### 1. FCM Token Verification
Check that FCM token is generated properly in Flutter logs after app launch:
```
🔑 FCM token: APA91bH... (token preview)
📱 Notification permission: Authorized (AuthorizationStatus.authorized)
```

### 2. General FCM Message Testing

For testing general FCM message functionality in Flutter app, refer to Firebase official documentation:

📖 **[Send your first message - Flutter](https://firebase.google.com/docs/cloud-messaging/flutter/first-message)**

Follow the steps provided in the above documentation to send test messages from Firebase Console and verify that general FCM functionality works properly.

### 3. ChannelTalk Message Testing

To test actual ChannelTalk push notifications, follow these steps:

#### 3.1. Create User Chat in App
1. Launch app and complete ChannelTalk Boot
2. Create **user chat** through ChannelTalk chat functionality:
   - Click ChannelTalk button → Enter message → Send
   - Or call `channelIO.openChat()` in app

#### 3.2. Send Message from Channel Desk
1. Login to **[Channel Desk](https://desk.channel.io/)**
2. Find the newly created chat in **User Chats** tab
3. Write and send a message

> ⚠️ **Important**: For push notifications to be sent, **user must be in offline status**.
> - **When user is online**: Only displayed as in-app message, no push notification sent
> - **When user is offline**: Push notification is sent

#### 3.3. How to Check Offline Status
Ways to make user offline:
- **Completely terminate the app** (not just background, complete termination)
- Or **switch app to background** and wait for some time
- Or **switch to another app** and wait until ChannelTalk recognizes as offline

#### 3.4. Verify Push Notification Arrival
1. **Check notification receipt**: Verify ChannelTalk push notification appears on device
2. **Test notification click**: Tap notification to confirm app opens and navigates to the chat
3. **Check logs**: Verify ChannelIO message processing logs in Android Studio

### 4. Behavior Verification
When ChannelTalk messages are received, the following behaviors are performed:

#### For ChannelTalk Messages:
- Message determination by `ChannelIO.isChannelPushNotification()`
- Native processing by `ChannelIO.receivePushNotification()`
- Not forwarded to Flutter FCM

#### For General FCM Messages:
- Forwarded to Flutter FCM service for normal processing

---

## Troubleshooting

### 1. Cannot obtain FCM token
**Cause**: Google Play Services not installed or outdated version
**Solution**: 
- Test on real Android device (not emulator)
- Update Google Play Services to latest version

### 2. No notifications due to permission denial
**Cause**: Notification permission denied (POST_NOTIFICATIONS permission on Android 13+)
**Solution**:
```dart
// Request permission in Flutter
final settings = await FirebaseMessaging.instance.requestPermission(
  alert: true,
  badge: true,
  sound: true,
);

if (settings.authorizationStatus != AuthorizationStatus.authorized) {
  // Guide user to allow permission in settings
  print('Notification permission denied. Please allow notifications in settings.');
}
```

### 3. Duplicate notification receipt
**Cause**: Both Flutter FCM service and custom service are operating
**Solution**: Verify default Flutter FCM service is disabled in AndroidManifest.xml
```xml
<service
    android:name="io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingService"
    android:enabled="false" />
```

### 4. ChannelTalk messages not processed
**Cause**: Message data doesn't contain `provider: Channel.io` key
**Solution**: Verify correct service account key is registered in Channel Desk

### 5. Build errors
**Cause**: Firebase dependency conflicts
**Solution**:
```bash
# Clean build
flutter clean
cd android && ./gradlew clean && cd ..
flutter pub get
```

### 6. onNewToken not called
**Cause**: Occurs in projects where Firebase was already installed
**Solution**: 
- Completely uninstall and reinstall the app
- Clear app data and restart

### 7. Permissions not automatically added
**Cause**: flutter_firebase_messaging plugin not working properly
**Solution**: Manually add permissions to AndroidManifest.xml

---

## Additional References

### Custom Notification Settings

#### Change Notification Title
```xml
<!-- strings.xml -->
<string name="notification_title">My App Name</string>
```

#### Change Notification Icon
```
app/src/main/res/drawable/ch_push_icon.png
```

---

> 📖 **More Information**: Refer to [ChannelTalk Android Push Notification Official Documentation](https://developers.channel.io/docs/android-push-notification).

> 🔧 **Technical Support**: Contact [ChannelTalk Support Center](https://channel.io) for assistance.
