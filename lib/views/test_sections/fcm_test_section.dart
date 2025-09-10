import 'package:flutter/material.dart';
import '../../constants/texts.dart';
import '../../viewmodels/fcm_test_viewmodel.dart';
import '../common/common_card.dart';
import '../common/common_button.dart';
import '../common/snackbar_helper.dart';

class FCMTestSection extends StatefulWidget {
  const FCMTestSection({super.key});

  @override
  State<FCMTestSection> createState() => _FCMTestSectionState();
}

class _FCMTestSectionState extends State<FCMTestSection> {
  late final FCMTestViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = FCMTestViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _requestNotificationPermission() async {
    final result = await _viewModel.requestNotificationPermission();

    if (!mounted) return;

    setState(() {}); // Refresh UI to show updated permission status

    if (result['status'] == 'success') {
      final messageKey = result['messageKey']!;
      String message;

      switch (messageKey) {
        case 'fullPermissionGranted':
          message = AppTexts.fullPermissionGranted;
          break;
        case 'silentNotificationGranted':
          message = AppTexts.silentNotificationGranted;
          break;
        case 'notificationPermissionDeniedMessage':
          message = AppTexts.notificationPermissionDenied;
          break;
        default:
          message = AppTexts.permissionUpdated;
      }

      SnackBarHelper.showCustom(
        context,
        message,
        duration: const Duration(seconds: 4),
      );
    } else {
      SnackBarHelper.showError(
        context,
        '${AppTexts.permissionRequestFailed} ${result['message']!}',
      );
    }
  }

  void _printTokens() {
    if (!mounted) return;

    _viewModel.printTokens();
    SnackBarHelper.showInfo(context, AppTexts.tokenInfoPrinted);
  }

  Widget _buildPermissionStatus(Map<String, dynamic> fcmStatus) {
    final permissionGranted = fcmStatus['permissionGranted'] ?? false;
    final hasFullPermission = fcmStatus['hasFullPermission'] ?? false;
    final isSilentOnly = fcmStatus['isSilentOnly'] ?? false;
    final permissionDescription =
        fcmStatus['permissionDescription'] ?? AppTexts.unknown;

    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.help_outline;

    if (hasFullPermission) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (isSilentOnly) {
      statusColor = Colors.orange;
      statusIcon = Icons.notifications_paused;
    } else if (!permissionGranted) {
      statusColor = Colors.red;
      statusIcon = Icons.block;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppTexts.notificationPermissionStatus,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  permissionDescription,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTokenDisplay(Map<String, dynamic> fcmStatus) {
    return CommonCard(
      title: AppTexts.fcmTokens,
      children: [
        _buildTokenRow(
          'FCM Token',
          fcmStatus['hasToken'],
          fcmStatus['tokenPreview'],
        ),
        if (fcmStatus['platform'] == 'iOS')
          _buildTokenRow(
            'APNs Token',
            fcmStatus['hasApnsToken'],
            fcmStatus['apnsTokenPreview'],
          ),
        const SizedBox(height: 8),
        CommonButton.warning(
          label: AppTexts.printTokens,
          icon: Icons.token,
          onPressed: _printTokens,
        ),
      ],
    );
  }

  Widget _buildTokenRow(String label, bool? hasToken, String? tokenPreview) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          ),
          Text(
            hasToken == true ? '${tokenPreview ?? ''}...' : AppTexts.none,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionActions(Map<String, dynamic> fcmStatus) {
    final permissionGranted = fcmStatus['permissionGranted'] ?? false;
    final hasFullPermission = fcmStatus['hasFullPermission'] ?? false;
    final isSilentOnly = fcmStatus['isSilentOnly'] ?? false;

    if (hasFullPermission) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                AppTexts.fullPermissionActivated,
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return CommonCard(
      title: AppTexts.pushPermissions,
      children: [
        if (isSilentOnly)
          Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.orange.shade300),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.orange, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppTexts.silentNotificationWarning,
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        permissionGranted
            ? CommonButton.warning(
                label: AppTexts.requestFullPermission,
                icon: Icons.volume_up,
                onPressed: _requestNotificationPermission,
              )
            : CommonButton.danger(
                label: AppTexts.requestNotificationPermission,
                icon: Icons.notifications,
                onPressed: _requestNotificationPermission,
              ),
      ],
    );
  }

  Widget _buildStatusOverview(Map<String, dynamic> fcmStatus) {
    return CommonCard(
      title: '${AppTexts.fcmStatus} (${fcmStatus['platform'] ?? 'Unknown'})',
      icon: Icon(
        fcmStatus['initialized'] == true ? Icons.check_circle : Icons.error,
        color: fcmStatus['initialized'] == true ? Colors.green : Colors.red,
        size: 20,
      ),
      children: [
        Text(
          '${AppTexts.initialization}: ${fcmStatus['initialized'] == true ? AppTexts.completed : AppTexts.incomplete}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildFCMInfo() {
    return CommonCard(
      title: 'FCM Information',
      backgroundColor: Colors.deepPurple.shade50,
      icon: const Icon(Icons.info_outline, color: Colors.deepPurple, size: 16),
      children: [
        const Text(
          '• FCM (Firebase Cloud Messaging) handles push notifications\n'
          '• APNs token is required on iOS for push notifications\n'
          '• Full permissions allow sound, vibration, and badges\n'
          '• Silent notifications only show in notification center\n'
          '• ChannelTalk messages are automatically filtered',
          style: TextStyle(fontSize: 12, color: Colors.black87),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: const Icon(Icons.notifications, color: Colors.deepPurple),
      title: Text(
        AppTexts.fcmTest,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: const Text(AppTexts.pushNotificationsAndFCM),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<Map<String, dynamic>>(
            future: Future.value(_viewModel.getStatus()),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final fcmStatus = snapshot.data ?? {};

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // FCM Status Overview
                  _buildStatusOverview(fcmStatus),
                  const SizedBox(height: 16),

                  // Permission Status
                  _buildPermissionStatus(fcmStatus),
                  const SizedBox(height: 16),

                  // Permission Actions
                  _buildPermissionActions(fcmStatus),
                  const SizedBox(height: 16),

                  // Token Display
                  _buildTokenDisplay(fcmStatus),
                  const SizedBox(height: 16),

                  // FCM Information
                  _buildFCMInfo(),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
