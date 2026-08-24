import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/core/resources/app_text_style.dart';

enum PhotoPermissionResult {
  granted,
  denied,
  permanentlyDenied,
}

class PhotoPermissionHelper {
  /// Returns `null` when the picker may proceed without blocking.
  /// On Android 13+ the system photo picker needs no runtime permission.
  static Future<PhotoPermissionResult?> ensureGalleryAccessIfNeeded() async {
    if (!Platform.isIOS) {
      return null;
    }

    var status = await Permission.photos.status;

    if (_isGranted(status)) {
      return null;
    }

    if (status.isPermanentlyDenied || status.isRestricted) {
      return PhotoPermissionResult.permanentlyDenied;
    }

    status = await Permission.photos.request();

    if (_isGranted(status)) {
      return null;
    }

    if (status.isPermanentlyDenied || status.isRestricted) {
      return PhotoPermissionResult.permanentlyDenied;
    }

    return PhotoPermissionResult.denied;
  }

  static bool _isGranted(PermissionStatus status) {
    return status.isGranted || status.isLimited;
  }

  static Future<void> showPermissionDialog(
    BuildContext context,
    PhotoPermissionResult result,
  ) async {
    final isPermanent = result == PhotoPermissionResult.permanentlyDenied;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            AppTexts.photoPermissionRequired,
            style: AppTextStyle.style14W300.copyWith(fontWeight: FontWeight.bold),
          ),
          content: Text(
            isPermanent
                ? AppTexts.photoPermissionDeniedSettings
                : AppTexts.photoPermissionDenied,
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
