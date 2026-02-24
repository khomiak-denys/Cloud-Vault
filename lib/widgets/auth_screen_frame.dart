import 'package:flutter/material.dart';

import '../theme/app_theme_colors.dart';
import 'mobile_screen_shell.dart';

class AuthScreenFrame extends StatelessWidget {
  const AuthScreenFrame({
    super.key,
    required this.headerGradient,
    required this.headerSubtitle,
    required this.formTitle,
    required this.formChildren,
    required this.bottomAction,
    this.badgeIcon = Icons.cloud_outlined,
    this.extraCompactHeader = false,
  });

  final List<Color> headerGradient;
  final String headerSubtitle;
  final String formTitle;
  final List<Widget> formChildren;
  final Widget bottomAction;
  final IconData badgeIcon;
  final bool extraCompactHeader;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mediaSize = MediaQuery.sizeOf(context);
    final compact = mediaSize.height < 850 || mediaSize.width < 390;
    final ultraCompact = compact && extraCompactHeader;

    return Scaffold(
      body: MobileScreenShell(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: headerGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: ultraCompact ? 4 : (compact ? 8 : 16)),
              Container(
                width: ultraCompact ? 64 : (compact ? 74 : 96),
                height: ultraCompact ? 64 : (compact ? 74 : 96),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFFEDF2FC) : Colors.white,
                  borderRadius: BorderRadius.circular(ultraCompact ? 18 : (compact ? 20 : 24)),
                ),
                child: Icon(
                  badgeIcon,
                  size: ultraCompact ? 28 : (compact ? 34 : 44),
                  color: const Color(0xFFAAB7CC),
                ),
              ),
              SizedBox(height: ultraCompact ? 4 : (compact ? 6 : 10)),
              Text(
                'CloudVault',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ultraCompact ? 24 : (compact ? 28 : 38),
                  fontWeight: FontWeight.w800,
                  letterSpacing: ultraCompact ? -0.4 : (compact ? -0.6 : -1),
                ),
              ),
              SizedBox(height: ultraCompact ? 0 : (compact ? 1 : 4)),
              Text(
                headerSubtitle,
                style: TextStyle(
                  color: Color(0xFFE2EAFF),
                  fontSize: ultraCompact ? 11 : (compact ? 12 : 14),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: ultraCompact ? 6 : (compact ? 8 : 14)),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(
                    compact ? 16 : 22,
                    compact ? 16 : 20,
                    compact ? 16 : 22,
                    compact ? 10 : 14,
                  ),
                  decoration: BoxDecoration(
                    color: colors.cardBackground,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(compact ? 22 : 28),
                    ),
                    border: Border(top: BorderSide(color: colors.cardBorder)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formTitle,
                        style: TextStyle(
                          color: colors.primaryText,
                          fontSize: compact ? 20 : 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: compact ? 8 : 12),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: formChildren,
                          ),
                        ),
                      ),
                      SizedBox(height: compact ? 2 : 6),
                      Center(child: bottomAction),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
