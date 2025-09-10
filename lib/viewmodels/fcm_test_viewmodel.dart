import 'package:flutter/foundation.dart';
import '../managers/fcm_manager.dart';

/// ViewModel for FCM Test section
class FCMTestViewModel extends ChangeNotifier {
  final FCMManager _fcmManager = FCMManager();

  /// Get FCM status
  Map<String, dynamic> getStatus() {
    return _fcmManager.getStatus();
  }

  /// Re-request notification permission
  Future<Map<String, String>> requestNotificationPermission() async {
    try {
      await _fcmManager.requestPermissionAgain();

      final status = _fcmManager.getStatus();
      final hasFullPermission = status['hasFullPermission'] ?? false;
      final isSilentOnly = status['isSilentOnly'] ?? false;

      String resultKey;
      if (hasFullPermission) {
        resultKey = 'fullPermissionGranted';
      } else if (isSilentOnly) {
        resultKey = 'silentNotificationGranted';
      } else {
        resultKey = 'notificationPermissionDeniedMessage';
      }

      return {'status': 'success', 'messageKey': resultKey};
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  /// Print token information
  void printTokens() {
    _fcmManager.printTokens();
  }

  /// Return permission status icon and color
  Map<String, dynamic> getPermissionStatusDisplay(
    Map<String, dynamic> fcmStatus,
  ) {
    final permissionGranted = fcmStatus['permissionGranted'] ?? false;
    final hasFullPermission = fcmStatus['hasFullPermission'] ?? false;
    final isSilentOnly = fcmStatus['isSilentOnly'] ?? false;

    if (hasFullPermission) {
      return {'color': 'green', 'icon': 'check_circle'};
    } else if (isSilentOnly) {
      return {'color': 'orange', 'icon': 'notifications_paused'};
    } else if (!permissionGranted) {
      return {'color': 'red', 'icon': 'block'};
    }

    return {'color': 'grey', 'icon': 'help_outline'};
  }

  /// Return permission request button style
  Map<String, dynamic> getPermissionButtonStyle(
    Map<String, dynamic> fcmStatus,
  ) {
    final permissionGranted = fcmStatus['permissionGranted'] ?? false;

    return {
      'color': permissionGranted ? 'orange' : 'red',
      'icon': permissionGranted ? 'volume_up' : 'notifications',
    };
  }
}
