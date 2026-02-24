import 'package:flutter/material.dart';

class AppThemeColors {
  const AppThemeColors({
    required this.outerBackground,
    required this.shellBackground,
    required this.headerBackground,
    required this.headerBorder,
    required this.cardBackground,
    required this.cardBorder,
    required this.softCardBackground,
    required this.inputBackground,
    required this.inputBorder,
    required this.iconTileBackground,
    required this.primaryText,
    required this.secondaryText,
    required this.mutedText,
    required this.hintText,
    required this.navBackground,
    required this.navBorder,
    required this.trackBackground,
    required this.modalBackground,
    required this.modalBorder,
    required this.modalDivider,
    required this.modalMutedText,
    required this.modalCloseIcon,
    required this.secondaryButtonBackground,
    required this.secondaryButtonForeground,
    required this.accent,
  });

  final Color outerBackground;
  final Color shellBackground;
  final Color headerBackground;
  final Color headerBorder;
  final Color cardBackground;
  final Color cardBorder;
  final Color softCardBackground;
  final Color inputBackground;
  final Color inputBorder;
  final Color iconTileBackground;
  final Color primaryText;
  final Color secondaryText;
  final Color mutedText;
  final Color hintText;
  final Color navBackground;
  final Color navBorder;
  final Color trackBackground;
  final Color modalBackground;
  final Color modalBorder;
  final Color modalDivider;
  final Color modalMutedText;
  final Color modalCloseIcon;
  final Color secondaryButtonBackground;
  final Color secondaryButtonForeground;
  final Color accent;

  static const dark = AppThemeColors(
    outerBackground: Color(0xFF2D2D2D),
    shellBackground: Color(0xFF00081C),
    headerBackground: Color(0xFF0F1D36),
    headerBorder: Color(0xFF1E2E46),
    cardBackground: Color(0xFF1F2D44),
    cardBorder: Color(0xFF31435C),
    softCardBackground: Color(0xFF22314A),
    inputBackground: Color(0xFF24344B),
    inputBorder: Color(0xFF34547A),
    iconTileBackground: Color(0xFF18345E),
    primaryText: Colors.white,
    secondaryText: Color(0xFF97A5BB),
    mutedText: Color(0xFF93A1B7),
    hintText: Color(0xFF95A4BE),
    navBackground: Color(0xFF0A1730),
    navBorder: Color(0xFF1D2C44),
    trackBackground: Color(0xFF45526B),
    modalBackground: Color(0xFF0D1B35),
    modalBorder: Color(0xFF243859),
    modalDivider: Color(0xFF263A59),
    modalMutedText: Color(0xFF94A2BB),
    modalCloseIcon: Color(0xFF97A5BD),
    secondaryButtonBackground: Color(0xFF22314A),
    secondaryButtonForeground: Color(0xFFCDD6E5),
    accent: Color(0xFF4BA2FF),
  );

  static const light = AppThemeColors(
    outerBackground: Color(0xFFE7ECF4),
    shellBackground: Color(0xFFF8FBFF),
    headerBackground: Colors.white,
    headerBorder: Color(0xFFDCE5F2),
    cardBackground: Colors.white,
    cardBorder: Color(0xFFDCE5F2),
    softCardBackground: Color(0xFFEAF0FA),
    inputBackground: Color(0xFFEFF3FA),
    inputBorder: Color(0xFFDCE5F2),
    iconTileBackground: Color(0xFFE6EEFC),
    primaryText: Color(0xFF0F172A),
    secondaryText: Color(0xFF64748B),
    mutedText: Color(0xFF64748B),
    hintText: Color(0xFF64748B),
    navBackground: Colors.white,
    navBorder: Color(0xFFDCE5F2),
    trackBackground: Color(0xFFD6DEEA),
    modalBackground: Color(0xFFF7FAFF),
    modalBorder: Color(0xFFD8E2F1),
    modalDivider: Color(0xFFD8E2F1),
    modalMutedText: Color(0xFF64748B),
    modalCloseIcon: Color(0xFF7A8AA3),
    secondaryButtonBackground: Color(0xFFE8EEF8),
    secondaryButtonForeground: Color(0xFF3F4F67),
    accent: Color(0xFF4BA2FF),
  );

  static AppThemeColors of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? dark : light;
  }
}
