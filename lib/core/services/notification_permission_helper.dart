import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/core/resources/app_text_style.dart';

enum NotificationPermissionResult {
  granted,
  denied,
  permanentlyDenied,
}

class NotificationPermissionHelper {
  /// Checks current status and requests permission when still allowed.
  static Future<NotificationPermissionResult> ensureGranted() async {
    var status = await Permission.notification.status;

    if (_isGranted(status)) {
      return NotificationPermissionResult.granted;
    }

    if (status.isPermanentlyDenied || status.isRestricted) {
      return NotificationPermissionResult.permanentlyDenied;
    }

    status = await Permission.notification.request();

    if (_isGranted(status)) {
      return NotificationPermissionResult.granted;
    }

    if (status.isPermanentlyDenied || status.isRestricted) {
      return NotificationPermissionResult.permanentlyDenied;
    }

    return NotificationPermissionResult.denied;
  }

  static Future<bool> isGranted() async {
    final status = await Permission.notification.status;
    return _isGranted(status);
  }

  static bool _isGranted(PermissionStatus status) {
    return status.isGranted || status.isLimited || status.isProvisional;
  }

  static Future<void> showPermissionDialog(
    BuildContext context,
    NotificationPermissionResult result,
  ) async {
    final isPermanent = result == NotificationPermissionResult.permanentlyDenied;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            AppTexts.notificationPermissionRequired,
            style: AppTextStyle.style14W300.copyWith(fontWeight: FontWeight.bold),
          ),
          content: Text(
            isPermanent
                ? AppTexts.notificationPermissionDeniedSettings
                : AppTexts.notificationPermissionDenied,
            style: AppTextStyle.style12W300,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(AppTexts.cancel, style: AppTextStyle.style12W300),
            ),
            if (isPermanent)
              TextButton(
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  await openAppSettings();
                },
                child: Text(
                  AppTexts.openSettings,
                  style: AppTextStyle.style12W300.copyWith(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
