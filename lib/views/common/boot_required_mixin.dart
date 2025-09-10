import 'package:flutter/material.dart';
import '../../constants/texts.dart';
import 'snackbar_helper.dart';

/// Mixin for boot status checking
mixin BootRequiredMixin {
  /// Execute function after checking boot status
  Future<void> executeIfBooted(
    BuildContext context,
    bool isBooted,
    Future<void> Function() action,
  ) async {
    if (!isBooted) {
      SnackBarHelper.showWarning(context, AppTexts.bootFirst);
      return;
    }

    await action();
  }

  /// Only perform boot status check
  bool checkBootStatus(BuildContext context, bool isBooted) {
    if (!isBooted) {
      SnackBarHelper.showWarning(context, AppTexts.bootFirst);
      return false;
    }
    return true;
  }

  /// Return color based on status
  Color getStatusColor(bool isBooted) {
    return isBooted ? Colors.blue : Colors.grey;
  }

  /// Return subtitle text based on status
  String getStatusSubtitle(bool isBooted) {
    return isBooted ? 'Available' : 'Boot required';
  }
}
