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
  });

  final List<Color> headerGradient;
  final String headerSubtitle;
  final String formTitle;
  final List<Widget> formChildren;
  final Widget bottomAction;
  final IconData badgeIcon;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              const SizedBox(height: 22),
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFFEDF2FC) : Colors.white,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Icon(
                  badgeIcon,
                  size: 52,
                  color: const Color(0xFFAAB7CC),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'CloudVault',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 56,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                headerSubtitle,
                style: const TextStyle(
                  color: Color(0xFFE2EAFF),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  decoration: BoxDecoration(
                    color: colors.cardBackground,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(34),
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
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: formChildren,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
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
