import 'package:intl/intl.dart';

class FormatUtils {
  FormatUtils._();

  /// Formats an Indian mobile number: +91-XXXXX-XXXXX
  static String formatIndianMobile(String digits) {
    if (digits.length == 10) {
      return '+91-${digits.substring(0, 5)}-${digits.substring(5)}';
    }
    return digits;
  }

  /// Formats a phone number for display, auto-detecting format.
  static String formatPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (digits.startsWith('+')) return digits;
    if (digits.length == 10 && RegExp(r'^[6789]').hasMatch(digits)) {
      return formatIndianMobile(digits);
    }
    return phone;
  }

  /// Format a date as "12 Jun 2025".
  static String formatDate(DateTime date) {
    return DateFormat('d MMM yyyy').format(date);
  }

  /// Format a date as relative time (e.g., "2 hours ago", "Yesterday").
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return formatDate(date);
  }

  /// Extract initials from a name (max 2 characters).
  static String initials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  /// Capitalize first letter of each word.
  static String titleCase(String text) {
    return text
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }
}
