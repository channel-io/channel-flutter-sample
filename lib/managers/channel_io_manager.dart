import 'dart:async';
import 'package:flutter/services.dart';

/// Manager class for using ChannelIO SDK in Flutter
///
/// This class provides ChannelIO SDK functionality through MethodChannel
/// communication between Flutter and native platforms (Android/iOS).
/// It also receives ChannelPluginListener/Delegate events and provides callbacks.
class ChannelIOManager {
  /// MethodChannel for communication with native platforms
  /// Channel name: 'channel_io_manager'
  static const MethodChannel _channel = MethodChannel('channel_io_manager');

  /// Singleton instance
  static final ChannelIOManager _instance = ChannelIOManager._internal();

  /// Event callbacks
  Function()? _onChannelButtonClicked;
  Function(int unread, int alert)? _onBadgeChanged;
  Function(String chatId)? _onChatCreated;
  Function(Map<String, dynamic> popupData)? _onPopupDataReceived;
  Function(String chatId)? _onPushNotificationClicked;
  Function(String url)? _onUrlClicked;
  Function()? _onShowMessenger;
  Function()? _onHideMessenger;
  Function(Map<String, dynamic> user)? _onFollowUpChanged;

  /// Singleton factory constructor
  factory ChannelIOManager() {
    return _instance;
  }

  /// Internal constructor
  ChannelIOManager._internal() {
    // Set up event reception from native
    _channel.setMethodCallHandler(_handleNativeMethodCall);
  }

  /// Handle events from native platforms.
  Future<dynamic> _handleNativeMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onChannelButtonClicked':
        _onChannelButtonClicked?.call();
        break;
      case 'onBadgeChanged':
        final unread = call.arguments['unread'] as int;
        final alert = call.arguments['alert'] as int;
        _onBadgeChanged?.call(unread, alert);
        break;
      case 'onChatCreated':
        final chatId = call.arguments['chatId'] as String;
        _onChatCreated?.call(chatId);
        break;
      case 'onPopupDataReceived':
        final popupData = Map<String, dynamic>.from(call.arguments);
        _onPopupDataReceived?.call(popupData);
        break;
      case 'onPushNotificationClicked':
        final chatId = call.arguments['chatId'] as String;
        _onPushNotificationClicked?.call(chatId);
        break;
      case 'onUrlClicked':
        final url = call.arguments['url'] as String;
        _onUrlClicked?.call(url);
        break;
      case 'onShowMessenger':
        _onShowMessenger?.call();
        break;
      case 'onHideMessenger':
        _onHideMessenger?.call();
        break;
      case 'onFollowUpChanged':
        final user = Map<String, dynamic>.from(call.arguments);
        _onFollowUpChanged?.call(user);
        break;
    }
  }

  /// Boot the ChannelIO SDK.
  ///
  /// [pluginKey]: ChannelIO plugin key
  /// [memberId]: User ID (optional)
  /// [language]: Language setting (optional, default: 'ko')
  /// [appearance]: Dark mode (optional, 'light', 'dark', 'system')
  /// [hideDefaultLauncher]: Hide default launcher button (optional, default: false)
  /// [hidePopup]: Hide popup (optional, default: false)
  ///
  /// Returns: Future<Map<String, dynamic>> - Boot result { 'success': bool, 'status': String?, 'user': Map? }
  Future<Map<String, dynamic>> boot({
    required String pluginKey,
    String? memberId,
    String? language = 'ko',
    String? appearance,
    bool hideDefaultLauncher = false,
    bool hidePopup = false,
    Map<String, dynamic>? profile,
    Map<String, dynamic>? tags,
    String? trackDefaultEvent,
    Map<String, dynamic>? channelButtonOption,
    Map<String, dynamic>? bubbleOption,
  }) async {
    try {
      final result = await _channel.invokeMethod('boot', {
        'pluginKey': pluginKey,
        'memberId': memberId,
        'language': language,
        'appearance': appearance,
        'hideDefaultLauncher': hideDefaultLauncher,
        'hidePopup': hidePopup,
        'profile': profile,
        'tags': tags,
        'trackDefaultEvent': trackDefaultEvent,
        'channelButtonOption': channelButtonOption,
        'bubbleOption': bubbleOption,
      });

      if (result is Map) {
        return Map<String, dynamic>.from(result);
      } else {
        // Handle failure for unexpected result type
        return {
          'success': false,
          'status': 'INVALID_RESULT',
          'user': null,
          'error': 'Unexpected result type from native: ${result.runtimeType}',
        };
      }
    } on PlatformException catch (e) {
      return {
        'success': false,
        'status': null,
        'user': null,
        'error': e.message,
      };
    }
  }

  /// Put ChannelIO SDK into sleep mode.
  /// In sleep mode, only push notifications and event tracking are active.
  ///
  /// Returns: Future<void>
  Future<void> sleep() async {
    try {
      await _channel.invokeMethod('sleep');
    } on PlatformException {
      // Sleep error occurred
    }
  }

  /// Completely shut down connection with ChannelIO SDK.
  /// All functions (including push notifications and event tracking) are disabled.
  ///
  /// Returns: Future<void>
  Future<void> shutdown() async {
    try {
      await _channel.invokeMethod('shutdown');
    } on PlatformException {
      // Shutdown error occurred
    }
  }

  /// Show the channel button.
  ///
  /// Returns: Future<void>
  Future<void> showChannelButton() async {
    try {
      await _channel.invokeMethod('showChannelButton');
    } on PlatformException {
      // Show channel button error occurred
    }
  }

  /// Hide the channel button.
  ///
  /// Returns: Future<void>
  Future<void> hideChannelButton() async {
    try {
      await _channel.invokeMethod('hideChannelButton');
    } on PlatformException {
      // Hide channel button error occurred
    }
  }

  /// Show the messenger.
  ///
  /// Returns: Future<void>
  Future<void> showMessenger() async {
    try {
      await _channel.invokeMethod('showMessenger');
    } on PlatformException {
      // Show messenger error occurred
    }
  }

  /// Hide the messenger.
  ///
  /// Returns: Future<void>
  Future<void> hideMessenger() async {
    try {
      await _channel.invokeMethod('hideMessenger');
    } on PlatformException {
      // Hide messenger error occurred
    }
  }

  /// Open a chat.
  ///
  /// [chatId]: Specific chat ID (optional)
  /// [message]: Pre-filled message (optional)
  ///
  /// Returns: Future<void>
  Future<void> openChat({String? chatId, String? message}) async {
    try {
      await _channel.invokeMethod('openChat', {
        'chatId': chatId,
        'message': message,
      });
    } on PlatformException {
      // Open chat error occurred
    }
  }

  /// Execute a workflow.
  ///
  /// [workflowId]: Workflow ID (optional)
  ///
  /// Returns: Future<void>
  Future<void> openWorkflow({String? workflowId}) async {
    try {
      await _channel.invokeMethod('openWorkflow', {'workflowId': workflowId});
    } on PlatformException {
      // Open workflow error occurred
    }
  }

  /// Track user events.
  ///
  /// [eventName]: Event name (required)
  /// [eventProperty]: Event properties (optional)
  ///
  /// Returns: Future<void>
  Future<void> track({
    required String eventName,
    Map<String, dynamic>? eventProperty,
  }) async {
    try {
      await _channel.invokeMethod('track', {
        'eventName': eventName,
        'eventProperty': eventProperty,
      });
    } on PlatformException {
      // Track error occurred
    }
  }

  /// Update user information.
  ///
  /// [profile]: User profile information
  /// [language]: Language setting
  /// [tags]: User tag list
  /// [unsubscribeTexting]: Unsubscribe from text messaging
  /// [unsubscribeEmail]: Unsubscribe from email
  ///
  /// Returns: Future<bool> - Update success status
  Future<bool> updateUser({
    Map<String, dynamic>? profile,
    String? language,
    List<String>? tags,
    bool? unsubscribeTexting,
    bool? unsubscribeEmail,
  }) async {
    try {
      final result = await _channel.invokeMethod('updateUser', {
        'profile': profile,
        'language': language,
        'tags': tags,
        'unsubscribeTexting': unsubscribeTexting,
        'unsubscribeEmail': unsubscribeEmail,
      });
      return result == true;
    } on PlatformException {
      return false;
    }
  }

  /// Add tags to user.
  ///
  /// [tags]: Tags to add
  ///
  /// Returns: Future<bool> - Addition success status
  Future<bool> addTags(List<String> tags) async {
    try {
      final result = await _channel.invokeMethod('addTags', {'tags': tags});
      return result == true;
    } on PlatformException {
      return false;
    }
  }

  /// Remove tags from user.
  ///
  /// [tags]: Tags to remove
  ///
  /// Returns: Future<bool> - Removal success status
  Future<bool> removeTags(List<String> tags) async {
    try {
      final result = await _channel.invokeMethod('removeTags', {'tags': tags});
      return result == true;
    } on PlatformException {
      return false;
    }
  }

  /// Set the current page.
  ///
  /// [page]: Page name (setting to null explicitly sets page info to null)
  /// [profile]: User chat profile information
  ///
  /// Returns: Future<void>
  Future<void> setPage({String? page, Map<String, dynamic>? profile}) async {
    try {
      await _channel.invokeMethod('setPage', {
        'page': page,
        'profile': profile,
      });
    } on PlatformException {
      // Set page error occurred
    }
  }

  /// Reset page setting to default value.
  ///
  /// Returns: Future<void>
  Future<void> resetPage() async {
    try {
      await _channel.invokeMethod('resetPage');
    } on PlatformException {
      // Reset page error occurred
    }
  }

  /// Hide channel popup globally.
  ///
  /// Returns: Future<void>
  Future<void> hidePopup() async {
    try {
      await _channel.invokeMethod('hidePopup');
    } on PlatformException {
      // Hide popup error occurred
    }
  }

  /// Initialize FCM token.
  ///
  /// [token]: FCM token
  ///
  /// Returns: Future<void>
  Future<void> initPushToken(String token) async {
    try {
      await _channel.invokeMethod('initPushToken', {'token': token});
    } on PlatformException {
      // Init push token error occurred
    }
  }

  /// Check if push data is from ChannelIO.
  ///
  /// [payload]: Push data
  ///
  /// Returns: Future<bool> - Whether it's a ChannelIO push
  Future<bool> isChannelPushNotification(Map<String, String> payload) async {
    try {
      final result = await _channel.invokeMethod('isChannelPushNotification', {
        'payload': payload,
      });
      return result == true;
    } on PlatformException {
      return false;
    }
  }

  /// Receive push notification.
  ///
  /// [payload]: Push data
  ///
  /// Returns: Future<void>
  Future<void> receivePushNotification(Map<String, String> payload) async {
    try {
      await _channel.invokeMethod('receivePushNotification', {
        'payload': payload,
      });
    } on PlatformException {
      // Receive push notification error occurred
    }
  }

  /// Check if there are stored push notifications.
  ///
  /// Returns: Future<bool> - Whether stored push notifications exist
  Future<bool> hasStoredPushNotification() async {
    try {
      final result = await _channel.invokeMethod('hasStoredPushNotification');
      return result == true;
    } on PlatformException {
      return false;
    }
  }

  /// Open stored push notification.
  ///
  /// Returns: Future<void>
  Future<void> openStoredPushNotification() async {
    try {
      await _channel.invokeMethod('openStoredPushNotification');
    } on PlatformException {
      // Open stored push notification error occurred
    }
  }

  /// Check if ChannelIO is booted.
  ///
  /// Returns: Future<bool> - Boot status
  Future<bool> isBooted() async {
    try {
      final result = await _channel.invokeMethod('isBooted');
      return result == true;
    } on PlatformException {
      return false;
    }
  }

  /// Set debug mode.
  ///
  /// [flag]: Whether to enable debug mode
  ///
  /// Returns: Future<void>
  Future<void> setDebugMode(bool flag) async {
    try {
      await _channel.invokeMethod('setDebugMode', {'flag': flag});
    } on PlatformException {
      // Set debug mode error occurred
    }
  }

  /// Set dark mode.
  ///
  /// [appearance]: Dark mode ('light', 'dark', 'system')
  ///
  /// Returns: Future<void>
  Future<void> setAppearance(String appearance) async {
    try {
      await _channel.invokeMethod('setAppearance', {'appearance': appearance});
    } on PlatformException {
      // Set appearance error occurred
    }
  }

  // =============================================================================
  // Event callback setup methods
  // =============================================================================

  /// Set callback for when channel button is clicked.
  ///
  /// [callback]: Callback function to be called when channel button is clicked
  void setOnChannelButtonClicked(Function() callback) {
    _onChannelButtonClicked = callback;
  }

  /// Set callback for when badge count changes.
  ///
  /// [callback]: Callback function to be called when badge count changes (unread: unread message count, alert: alert count)
  void setOnBadgeChanged(Function(int unread, int alert) callback) {
    _onBadgeChanged = callback;
  }

  /// Set callback for when a chat room is created.
  ///
  /// [callback]: Callback function to be called when chat room is created
  void setOnChatCreated(Function(String chatId) callback) {
    _onChatCreated = callback;
  }

  /// Set callback for when popup data is received.
  ///
  /// [callback]: Callback function to be called when popup data is received
  void setOnPopupDataReceived(
    Function(Map<String, dynamic> popupData) callback,
  ) {
    _onPopupDataReceived = callback;
  }

  /// Set callback for when push notification is clicked.
  ///
  /// [callback]: Callback function to be called when push notification is clicked
  void setOnPushNotificationClicked(Function(String chatId) callback) {
    _onPushNotificationClicked = callback;
  }

  /// Set callback for when URL is clicked.
  ///
  /// [callback]: Callback function to be called when URL is clicked
  void setOnUrlClicked(Function(String url) callback) {
    _onUrlClicked = callback;
  }

  /// Set callback for when messenger is shown.
  ///
  /// [callback]: Callback function to be called when messenger is shown
  void setOnShowMessenger(Function() callback) {
    _onShowMessenger = callback;
  }

  /// Set callback for when messenger is hidden.
  ///
  /// [callback]: Callback function to be called when messenger is hidden
  void setOnHideMessenger(Function() callback) {
    _onHideMessenger = callback;
  }

  /// Set callback for when user follow-up is changed.
  ///
  /// [callback]: Callback function to be called when follow-up is changed
  void setOnFollowUpChanged(Function(Map<String, dynamic> user) callback) {
    _onFollowUpChanged = callback;
  }

  /// Clear all event callbacks.
  void clearAllCallbacks() {
    _onChannelButtonClicked = null;
    _onBadgeChanged = null;
    _onChatCreated = null;
    _onPopupDataReceived = null;
    _onPushNotificationClicked = null;
    _onUrlClicked = null;
    _onShowMessenger = null;
    _onHideMessenger = null;
    _onFollowUpChanged = null;
  }
}
