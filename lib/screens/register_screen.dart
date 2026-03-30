import 'package:cloud_vault/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme_colors.dart';
import '../widgets/auth_form_field.dart';
import '../widgets/auth_screen_frame.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  static const routeName = '/register';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _accepted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppThemeColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AuthScreenFrame(
      headerGradient: isDark
          ? const [Color(0xFF5B21B6), Color(0xFFBE185D)]
          : const [Color(0xFF8B2CF5), Color(0xFFEC008C)],
      headerSubtitle: l10n.authRegisterSubtitle,
      formTitle: l10n.authRegisterTitle,
      extraCompactHeader: true,
      formChildren: [
        Text(
          l10n.authName,
          style: TextStyle(
            color: colors.primaryText,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        AuthFormField(
          controller: _nameController,
          hintText: l10n.profileName,
          prefixIcon: Icons.person_outline,
        ),
        const SizedBox(height: 10),
        Text(
          l10n.authEmail,
          style: TextStyle(
            color: colors.primaryText,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        AuthFormField(
          controller: _emailController,
          hintText: 'example@email.com',
          prefixIcon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 10),
        Text(
          l10n.authPassword,
          style: TextStyle(
            color: colors.primaryText,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        AuthFormField(
          controller: _passwordController,
          hintText: '••••••••',
          prefixIcon: Icons.lock_outline,
          obscureText: true,
        ),
        const SizedBox(height: 10),
        Text(
          l10n.authConfirmPassword,
          style: TextStyle(
            color: colors.primaryText,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        AuthFormField(
          controller: _confirmController,
          hintText: '••••••••',
          prefixIcon: Icons.lock_outline,
          obscureText: true,
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: _accepted,
              onChanged: (value) => setState(() => _accepted = value ?? false),
              activeColor: colors.accent,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: colors.secondaryText,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                    children: [
                      TextSpan(text: '${l10n.authAgreeWith} '),
                      TextSpan(
                        text: l10n.authTerms,
                        style: TextStyle(
                          color: colors.accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(text: ' ${l10n.authAnd} '),
                      TextSpan(
                        text: l10n.authPrivacyPolicy,
                        style: TextStyle(
                          color: colors.accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B2CF5), Color(0xFFEC008C)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                overlayColor: Colors.transparent,
              ),
              child: Text(
                l10n.authSignUp,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
      bottomAction: TextButton(
        onPressed: () => Navigator.of(context).pop(),
        style: TextButton.styleFrom(overlayColor: Colors.transparent),
        child: Text(
          l10n.authGoLogin,
          style: TextStyle(
            color: colors.secondaryText,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  void _submit() {
    final allFilled =
        _nameController.text.trim().isNotEmpty &&
        _emailController.text.trim().isNotEmpty &&
        _passwordController.text.trim().isNotEmpty &&
        _confirmController.text.trim().isNotEmpty;

    if (!allFilled ||
        _passwordController.text != _confirmController.text ||
        !_accepted) {
      return;
    }

    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(LoginScreen.routeName, (route) => false);
  }
}
