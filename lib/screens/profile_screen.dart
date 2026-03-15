import 'package:cloud_vault/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../api/api_exception.dart';
import '../api/api_repository.dart';
import '../data/app_services.dart';
import '../data/storage_formatters.dart';
import '../theme/app_theme_colors.dart';
import '../widgets/loading_skeletons.dart';
import '../widgets/mobile_screen_shell.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _cacheKey = 'profile_bundle_v1';
  static const _cacheTtl = Duration(minutes: 2);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController(
    text: '********',
  );

  bool _isEditing = false;
  bool _isLoading = true;

  int _storagesCount = 0;
  double _usedBytes = 0;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = appCacheStore.get<_ProfileBundle>(_cacheKey);
      if (cached != null) {
        setState(() {
          _nameController.text = cached.name;
          _emailController.text = cached.email;
          _storagesCount = cached.storagesCount;
          _usedBytes = cached.usedBytes;
          _isLoading = false;
        });
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        appApiRepository.me(),
        appApiRepository.connections(),
        appApiRepository.storageUsage(),
      ]);

      final me = results[0] as ApiUser?;
      final connections = results[1] as List<ApiConnection>;
      final storageUsage = results[2] as List<ApiConnection>;
      final name = me?.name ?? '';
      final email = me?.email ?? '';
      final storagesCount = connections.length;
      final usedBytes = storageUsage.fold<double>(
        0,
        (acc, item) => acc + item.usedBytes,
      );

      appCacheStore.set<_ProfileBundle>(
        _cacheKey,
        _ProfileBundle(
          name: name,
          email: email,
          storagesCount: storagesCount,
          usedBytes: usedBytes,
        ),
        ttl: _cacheTtl,
      );

      if (!mounted) return;
      setState(() {
        _nameController.text = name;
        _emailController.text = email;
        _storagesCount = storagesCount;
        _usedBytes = usedBytes;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      _showSnack('API error: ${e.statusCode ?? ''} ${e.message}'.trim());
    } catch (_) {
      if (!mounted) return;
      _showSnack('Failed to load profile');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnack(String message) {
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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppThemeColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: MobileScreenShell(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 18),
              decoration: BoxDecoration(
                color: colors.headerBackground,
                border: Border(bottom: BorderSide(color: colors.headerBorder)),
              ),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: colors.primaryText,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        l10n.profile,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colors.primaryText,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const ProfileLoadingSkeleton()
                  : RefreshIndicator(
                      onRefresh: () => _loadProfileData(forceRefresh: true),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: colors.cardBackground,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(color: colors.cardBorder),
                              ),
                              child: Column(
                                children: [
                                  Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Container(
                                        width: 168,
                                        height: 168,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: const LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Color(0xFF4D7FFF),
                                              Color(0xFF7D3EFF),
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.12,
                                              ),
                                              blurRadius: 24,
                                              offset: const Offset(0, 10),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            _nameController.text.isNotEmpty
                                                ? _nameController.text[0]
                                                    .toUpperCase()
                                                : '?',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 66,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 22),
                                  Text(
                                    _nameController.text,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: colors.primaryText,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _emailController.text,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: colors.secondaryText,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  if (_emailController.text.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 7,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? const Color(0xFF1F3A65)
                                            : const Color(0xFFD9E8FF),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: const Text(
                                        'Verified',
                                        style: TextStyle(
                                          color: Color(0xFF2563EB),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                _StatTile(
                                  value: '$_storagesCount',
                                  label: l10n.profileStoragesStat,
                                  colors: colors,
                                ),
                                const SizedBox(width: 10),
                                _StatTile(
                                  value: formatBytes(_usedBytes),
                                  label: l10n.used,
                                  colors: colors,
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: colors.cardBackground,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(color: colors.cardBorder),
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      14,
                                      16,
                                      14,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            l10n.profilePersonalInfo,
                                            style: TextStyle(
                                              color: colors.primaryText,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            setState(
                                              () => _isEditing = !_isEditing,
                                            );
                                          },
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                            overlayColor: Colors.transparent,
                                          ),
                                          child: Text(
                                            _isEditing
                                                ? l10n.cancel
                                                : l10n.profileEdit,
                                            style: TextStyle(
                                              color: colors.accent,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Divider(height: 1, color: colors.headerBorder),
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      children: [
                                        _ProfileField(
                                          label: l10n.authName,
                                          icon: Icons.person_outline,
                                          controller: _nameController,
                                          enabled: _isEditing,
                                          colors: colors,
                                        ),
                                        const SizedBox(height: 12),
                                        _ProfileField(
                                          label: l10n.authEmail,
                                          icon: Icons.mail_outline,
                                          controller: _emailController,
                                          enabled: false,
                                          colors: colors,
                                        ),
                                        const SizedBox(height: 12),
                                        _ProfileField(
                                          label: l10n.authPassword,
                                          icon: Icons.lock_outline,
                                          controller: _passwordController,
                                          enabled: false,
                                          colors: colors,
                                        ),
                                        if (_isEditing) ...[
                                          const SizedBox(height: 14),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                setState(
                                                  () => _isEditing = false,
                                                );
                                                ScaffoldMessenger.of(context)
                                                  ..hideCurrentSnackBar()
                                                  ..showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        l10n.profileSaved,
                                                      ),
                                                      behavior: SnackBarBehavior
                                                          .floating,
                                                      duration:
                                                          const Duration(
                                                            seconds: 2,
                                                          ),
                                                    ),
                                                  );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(
                                                  0xFF2563EB,
                                                ),
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 14,
                                                    ),
                                                overlayColor:
                                                    Colors.transparent,
                                              ),
                                              child: Text(
                                                l10n.profileSave,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.value,
    required this.label,
    required this.colors,
  });

  final String value;
  final String label;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 108,
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.cardBorder),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.primaryText,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.secondaryText,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.label,
    required this.icon,
    required this.controller,
    required this.enabled,
    required this.colors,
  });

  final String label;
  final IconData icon;
  final TextEditingController controller;
  final bool enabled;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 22, color: colors.secondaryText),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: colors.primaryText,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          style: TextStyle(
            color: colors.primaryText,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: colors.inputBackground,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colors.inputBorder),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colors.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colors.accent, width: 1.4),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileBundle {
  const _ProfileBundle({
    required this.name,
    required this.email,
    required this.storagesCount,
    required this.usedBytes,
  });

  final String name;
  final String email;
  final int storagesCount;
  final double usedBytes;
}
