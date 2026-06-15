import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  PermissionUtils._();

  /// Request camera permission. Returns true if granted.
  static Future<bool> requestCamera(BuildContext context) async {
    final status = await Permission.camera.request();
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied && context.mounted) {
      _showSettingsSnackBar(context, 'Camera permission required');
    }
    return false;
  }

  /// Request photo library permission. Returns true if granted.
  static Future<bool> requestPhotos(BuildContext context) async {
    final status = await Permission.photos.request();
    if (status.isGranted || status.isLimited) return true;
    if (status.isPermanentlyDenied && context.mounted) {
      _showSettingsSnackBar(context, 'Photo library permission required');
    }
    return false;
  }

  /// Request contacts permission. Returns true if granted.
  static Future<bool> requestContacts(BuildContext context) async {
    final status = await Permission.contacts.request();
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied && context.mounted) {
      _showSettingsSnackBar(context, 'Contacts permission required');
    }
    return false;
  }

  static void _showSettingsSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: 'Open Settings',
          onPressed: () => openAppSettings(),
        ),
      ),
    );
  }
}
