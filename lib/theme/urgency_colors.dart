import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Theme-aware urgency colors utility.
/// Returns appropriate colors based on urgency level and current theme brightness.
class UrgencyColors {
  UrgencyColors._();

  /// Returns the appropriate urgency color based on level and theme.
  ///
  /// [urgencyLevel] can be 'critical', 'warning', or 'safe'.
  /// Returns theme-appropriate color for light or dark mode.
  static Color getColor(BuildContext context, String urgencyLevel) {
    final brightness = Theme.of(context).brightness;
    switch (urgencyLevel) {
      case 'critical':
        return brightness == Brightness.light
            ? AppTheme.errorLight
            : AppTheme.errorDark;
      case 'warning':
        return brightness == Brightness.light
            ? AppTheme.warningLight
            : AppTheme.warningDark;
      case 'safe':
      default:
        return brightness == Brightness.light
            ? AppTheme.successLight
            : AppTheme.successDark;
    }
  }

  /// Returns the critical/error color for the current theme.
  static Color critical(BuildContext context) => getColor(context, 'critical');

  /// Returns the warning color for the current theme.
  static Color warning(BuildContext context) => getColor(context, 'warning');

  /// Returns the safe/success color for the current theme.
  static Color safe(BuildContext context) => getColor(context, 'safe');
}
