import 'package:flutter/foundation.dart';
import '../managers/channel_io_manager.dart';

/// ViewModel for Boot Test section
class BootTestViewModel extends ChangeNotifier {
  final ChannelIOManager _channelIO = ChannelIOManager();

  // State management
  Map<String, dynamic>? _lastBootRequest;
  Map<String, dynamic>? _lastBootResponse;

  // Getters
  Map<String, dynamic>? get lastBootRequest => _lastBootRequest;
  Map<String, dynamic>? get lastBootResponse => _lastBootResponse;

  /// Execute anonymous boot
  Future<Map<String, dynamic>> executeAnonymousBoot({
    required String pluginKey,
    String? language,
    String? appearance,
    bool hideDefaultLauncher = false,
    bool hidePopup = false,
    Map<String, dynamic>? profile,
    Map<String, dynamic>? tags,
    String? trackDefaultEvent,
    Map<String, dynamic>? channelButtonOption,
    Map<String, dynamic>? bubbleOption,
  }) async {
    final bootRequest = {
      'pluginKey': pluginKey,
      'memberId': null, // Anonymous boot
      'language': language,
      'appearance': appearance,
      'hideDefaultLauncher': hideDefaultLauncher,
      'hidePopup': hidePopup,
      'profile': profile,
      'tags': tags,
      'trackDefaultEvent': trackDefaultEvent,
      'channelButtonOption': channelButtonOption,
      'bubbleOption': bubbleOption,
    };

    _lastBootRequest = bootRequest;
    notifyListeners();

    try {
      final bootResult = await _channelIO.boot(
        pluginKey: pluginKey,
        language: language,
        appearance: appearance,
        hideDefaultLauncher: hideDefaultLauncher,
        hidePopup: hidePopup,
        profile: profile,
        tags: tags,
        trackDefaultEvent: trackDefaultEvent,
        channelButtonOption: channelButtonOption,
        bubbleOption: bubbleOption,
      );

      _lastBootResponse = bootResult;
      notifyListeners();

      return bootResult;
    } catch (e) {
      final errorResult = {
        'success': false,
        'status': 'ERROR',
        'user': null,
        'error': e.toString(),
      };
      _lastBootResponse = errorResult;
      notifyListeners();
      return errorResult;
    }
  }

  /// Execute member boot
  Future<Map<String, dynamic>> executeMemberBoot({
    required String pluginKey,
    required String memberId,
    String? language,
    String? appearance,
    bool hideDefaultLauncher = false,
    bool hidePopup = false,
    Map<String, dynamic>? profile,
    Map<String, dynamic>? tags,
    String? trackDefaultEvent,
    Map<String, dynamic>? channelButtonOption,
    Map<String, dynamic>? bubbleOption,
  }) async {
    final bootRequest = {
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
    };

    _lastBootRequest = bootRequest;
    notifyListeners();

    try {
      final bootResult = await _channelIO.boot(
        pluginKey: pluginKey,
        memberId: memberId,
        language: language,
        appearance: appearance,
        hideDefaultLauncher: hideDefaultLauncher,
        hidePopup: hidePopup,
        profile: profile,
        tags: tags,
        trackDefaultEvent: trackDefaultEvent,
        channelButtonOption: channelButtonOption,
        bubbleOption: bubbleOption,
      );

      _lastBootResponse = bootResult;
      notifyListeners();

      return bootResult;
    } catch (e) {
      final errorResult = {
        'success': false,
        'status': 'ERROR',
        'user': null,
        'error': e.toString(),
      };
      _lastBootResponse = errorResult;
      notifyListeners();
      return errorResult;
    }
  }

  /// Execute sleep
  Future<bool> executeSleep() async {
    try {
      await _channelIO.sleep();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Execute shutdown
  Future<bool> executeShutdown() async {
    try {
      await _channelIO.shutdown();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// UI Control - Show messenger
  Future<void> showMessenger() async {
    try {
      await _channelIO.showMessenger();
    } catch (e) {
      // Show messenger error occurred
    }
  }

  /// UI Control - Hide messenger
  Future<void> hideMessenger() async {
    try {
      await _channelIO.hideMessenger();
    } catch (e) {
      // Hide messenger error occurred
    }
  }

  /// UI Control - Show channel button
  Future<void> showChannelButton() async {
    try {
      await _channelIO.showChannelButton();
    } catch (e) {
      // Show channel button error occurred
    }
  }

  /// UI Control - Hide channel button
  Future<void> hideChannelButton() async {
    try {
      await _channelIO.hideChannelButton();
    } catch (e) {
      // Hide channel button error occurred
    }
  }

  /// UI Control - Hide popup
  Future<void> hidePopup() async {
    try {
      await _channelIO.hidePopup();
    } catch (e) {
      // Hide popup error occurred
    }
  }

  /// Create Channel Button Option
  Map<String, dynamic>? getChannelButtonOption({
    String? icon,
    String? position,
    String? xMargin,
    String? yMargin,
  }) {
    final option = <String, dynamic>{};

    if (icon != null && icon.isNotEmpty) {
      option['icon'] = icon;
    }
    if (position != null && position.isNotEmpty) {
      option['position'] = position;
    }
    if (xMargin != null && xMargin.isNotEmpty) {
      final margin = int.tryParse(xMargin);
      if (margin != null) {
        option['xMargin'] = margin;
      }
    }
    if (yMargin != null && yMargin.isNotEmpty) {
      final margin = int.tryParse(yMargin);
      if (margin != null) {
        option['yMargin'] = margin;
      }
    }

    return option.isEmpty ? null : option;
  }

  /// Create Bubble Option
  Map<String, dynamic>? getBubbleOption({String? position, String? yMargin}) {
    final option = <String, dynamic>{};

    if (position != null && position.isNotEmpty) {
      option['position'] = position;
    }
    if (yMargin != null && yMargin.isNotEmpty) {
      final margin = int.tryParse(yMargin);
      if (margin != null) {
        option['yMargin'] = margin;
      }
    }

    return option.isEmpty ? null : option;
  }
}
