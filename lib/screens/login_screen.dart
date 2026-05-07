import 'package:cloud_vault/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../api/auth_token_store.dart';
import '../theme/app_theme_colors.dart';
import '../widgets/auth_form_field.dart';
import '../widgets/auth_screen_frame.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, FirebaseAuth? auth, AuthTokenStore? tokenStore})
    : _auth = auth,
      _tokenStore = tokenStore;

  static const routeName = '/login';
  final FirebaseAuth? _auth;
  final AuthTokenStore? _tokenStore;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppThemeColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AuthScreenFrame(
      headerGradient: isDark
          ? const [Color(0xFF163A8A), Color(0xFF5B21B6)]
          : const [Color(0xFF2557E6), Color(0xFF5F2FD9)],
      headerSubtitle: l10n.authAllCloudsOnePlace,
      formTitle: l10n.authLoginTitle,
      formChildren: [
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
        const SizedBox(height: 8),
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: (value) =>
                  setState(() => _rememberMe = value ?? false),
              activeColor: colors.accent,
            ),
            Expanded(
              child: Text(
                l10n.authRememberMe,
                style: TextStyle(
                  color: colors.secondaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(overlayColor: Colors.transparent),
              child: Text(
                l10n.authForgotPassword,
                style: TextStyle(
                  color: colors.accent,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
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
              gradient: isDark
                  ? const LinearGradient(
                      colors: [Color(0xFF2557E6), Color(0xFF8D24FF)],
                    )
                  : const LinearGradient(
                      colors: [Color(0xFF2557E6), Color(0xFF8D24FF)],
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
                l10n.authSignIn,
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
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const RegisterScreen()),
          );
        },
        style: TextButton.styleFrom(overlayColor: Colors.transparent),
        child: Text(
          l10n.authGoRegister,
          style: TextStyle(
            color: colors.secondaryText,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      return;
    }

    try {
      final credentials = await (widget._auth ?? FirebaseAuth.instance)
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
      final idToken = await credentials.user?.getIdToken();

      if (idToken == null || idToken.isEmpty) {
        if (!mounted) return;
        _showError('Failed to get Firebase ID token');
        return;
      }

      await (widget._tokenStore ?? const AuthSessionTokenStore())
          .setBearerToken(idToken);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showError('[${e.code}] ${e.message ?? 'Login failed'}');
      return;
    } catch (_) {
      if (!mounted) return;
      _showError('Login failed');
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }
}
