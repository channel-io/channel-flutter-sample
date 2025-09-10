import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../firebase_options.dart';

/// Background message handler (top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  try {
    final isChannelMessage = _isChannelIOMessage(message.data);

    if (isChannelMessage) {
      // ChannelIO messages are handled natively, skip Flutter processing
      return;
    }
  } catch (e) {
    // Background message handling error occurred
  }
}

/// Determine if message is from ChannelIO
bool _isChannelIOMessage(Map<String, dynamic> data) {
  final provider = data['provider']?.toString();
  return provider == 'Channel.io';
}

class FCMManager {
  static final FCMManager _instance = FCMManager._internal();
  factory FCMManager() => _instance;
  FCMManager._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  String? _fcmToken;
  String? _apnsToken;
  String? get fcmToken => _fcmToken;
  String? get apnsToken => _apnsToken;

  bool _initialized = false;
  bool get isInitialized => _initialized;

  AuthorizationStatus? _notificationPermission;
  AuthorizationStatus? get notificationPermission => _notificationPermission;

  /// Initialize FCM
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      if (Firebase.apps.isEmpty) {
        throw Exception('Firebase is not initialized.');
      }

      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );
      await _requestPermissions();
      await _setupFCM();

      _initialized = true;

      // Print token status after initialization
      printTokens();
    } catch (e) {
      rethrow;
    }
  }

  /// Request notification permission
  Future<void> _requestPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      provisional:
          false, // Explicit permission request (shows popup on iOS too)
      sound: true,
      criticalAlert: false,
      announcement: false,
    );

    _notificationPermission = settings.authorizationStatus;

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      throw Exception(
        'FCM cannot be used because notification permission is denied',
      );
    }
  }

  /// Setup FCM
  Future<void> _setupFCM() async {
    // iOS: Get APNs token
    if (Platform.isIOS) {
      int attempts = 0;
      const maxAttempts = 10;

      debugPrint('🍎 Attempting to get APNs token...');
      while (_apnsToken == null && attempts < maxAttempts) {
        _apnsToken = await _firebaseMessaging.getAPNSToken();
        if (_apnsToken == null) {
          debugPrint(
            '🍎 Failed to get APNs token (${attempts + 1}/$maxAttempts)',
          );
          await Future.delayed(const Duration(milliseconds: 500));
          attempts++;
        }
      }

      if (_apnsToken == null) {
        debugPrint('❌ Final failure to get APNs token');
        throw Exception('Unable to get APNs token');
      } else {
        debugPrint(
          '✅ APNs token acquired successfully: ${_apnsToken!.substring(0, 20)}...${_apnsToken!.substring(_apnsToken!.length - 10)}',
        );
        debugPrint('🍎 Full APNs Token: $_apnsToken');
      }
    }

    // Get FCM token
    debugPrint('🔑 Attempting to get FCM token...');
    _fcmToken = await _firebaseMessaging.getToken(
      vapidKey: kIsWeb ? "YOUR_VAPID_KEY" : null,
    );

    if (_fcmToken == null) {
      debugPrint('❌ Failed to get FCM token');
      throw Exception('Unable to get FCM token');
    } else {
      debugPrint(
        '✅ FCM token acquired successfully: ${_fcmToken!.substring(0, 30)}...${_fcmToken!.substring(_fcmToken!.length - 10)}',
      );
      debugPrint('🔑 Full FCM token: $_fcmToken');
    }

    // Token refresh listener
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      debugPrint(
        '🔄 FCM token refreshed: ${newToken.substring(0, 30)}...${newToken.substring(newToken.length - 10)}',
      );
      debugPrint('🔄 Full new FCM token: $newToken');
    });

    // Setup message handlers
    _setupMessageHandlers();
  }

  /// Setup message handlers
  void _setupMessageHandlers() {
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        _handleMessageOpened(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpened);
  }

  /// Handle foreground messages
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

  /// Handle notification clicks
  void _handleMessageOpened(RemoteMessage message) async {
    try {
      final isChannelMessage = _isChannelIOMessage(message.data);

      if (isChannelMessage) {
        // ChannelIO messages are handled natively, skip Flutter processing
        return;
      }

      // Handle general message clicks - app routing, etc.
    } catch (e) {
      // Notification click handling error occurred
    }
  }

  /// Display foreground notifications
  void _showForegroundNotification(RemoteMessage message) {
    // Foreground notification display logic (implement if needed)
  }

  /// Control FCM auto initialization
  Future<void> setAutoInitEnabled(bool enabled) async {
    await _firebaseMessaging.setAutoInitEnabled(enabled);
  }

  /// Re-request notification permission
  Future<AuthorizationStatus> requestPermissionAgain() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false, // Explicit permission request
      sound: true,
      criticalAlert: false,
      announcement: false,
    );

    _notificationPermission = settings.authorizationStatus;

    return settings.authorizationStatus;
  }

  /// Get current status information
  Map<String, dynamic> getStatus() {
    String permissionDescription = _getPermissionDescription();

    return {
      'initialized': _initialized,
      'hasToken': _fcmToken != null,
      'tokenPreview': _fcmToken?.substring(0, 30) ?? 'N/A',
      'hasApnsToken': _apnsToken != null,
      'apnsTokenPreview': _apnsToken?.substring(0, 20) ?? 'N/A',
      'platform': Platform.isIOS ? 'iOS' : 'Android',
      'permissionStatus': _notificationPermission?.name ?? 'unknown',
      'permissionDescription': permissionDescription,
      'permissionGranted':
          _notificationPermission == AuthorizationStatus.authorized ||
          _notificationPermission == AuthorizationStatus.provisional,
      'hasFullPermission':
          _notificationPermission == AuthorizationStatus.authorized,
      'isSilentOnly':
          _notificationPermission == AuthorizationStatus.provisional,
    };
  }

  /// Get permission status description
  String _getPermissionDescription() {
    switch (_notificationPermission) {
      case AuthorizationStatus.authorized:
        return '✅ Full notification permission (including sound/vibration)';
      case AuthorizationStatus.provisional:
        return '⚠️ Only silent notifications allowed (no sound/vibration)';
      case AuthorizationStatus.denied:
        return '❌ Notification permission denied';
      case AuthorizationStatus.notDetermined:
        return '❔ Permission not requested';
      default:
        return '❓ Permission status unknown';
    }
  }

  /// Print token information
  void printTokens() {
    debugPrint('');
    debugPrint('=== 📱 FCM & APNs Token Information ===');
    debugPrint('Platform: ${Platform.isIOS ? 'iOS' : 'Android'}');
    debugPrint(
      'Permission Status: ${_notificationPermission?.name ?? 'unknown'}',
    );
    debugPrint('');

    if (Platform.isIOS) {
      if (_apnsToken != null) {
        debugPrint('🍎 APNs Token (iOS only):');
        debugPrint(
          '   Preview: ${_apnsToken!.substring(0, 20)}...${_apnsToken!.substring(_apnsToken!.length - 10)}',
        );
        debugPrint('   Full: $_apnsToken');
        debugPrint('');
      } else {
        debugPrint('❌ No APNs token');
        debugPrint('');
      }
    }

    if (_fcmToken != null) {
      debugPrint('🔑 FCM Token:');
      debugPrint(
        '   Preview: ${_fcmToken!.substring(0, 30)}...${_fcmToken!.substring(_fcmToken!.length - 10)}',
      );
      debugPrint('   Full: $_fcmToken');
      debugPrint('');
    } else {
      debugPrint('❌ No FCM token');
      debugPrint('');
    }
    debugPrint('================================');
    debugPrint('');
  }

  /// Cleanup FCM
  Future<void> dispose() async {
    // Cleanup listeners etc. if needed
  }
}
