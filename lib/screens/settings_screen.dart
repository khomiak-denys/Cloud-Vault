import 'dart:async';

import 'package:cloud_vault/l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../api/auth_session.dart';
import '../api/api_exception.dart';
import '../api/api_repository.dart';
import '../data/api_mappers.dart';
import '../data/app_services.dart';
import '../data/cache_keys.dart';
import '../data/oauth_callback_handler.dart';
import '../data/oauth_deep_link_service.dart';
import '../modals/add_vault_modal.dart';
import '../modals/language_modal.dart';
import '../models/vault_item.dart';
import '../screens/login_screen.dart';
import '../screens/profile_screen.dart';
import '../state/locale_controller.dart';
import '../state/theme_controller.dart';
import '../theme/app_theme_colors.dart';
import '../utils/tab_navigation.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/loading_skeletons.dart';
import '../widgets/mobile_screen_shell.dart';
import '../widgets/settings/connected_storages_card.dart';
import '../widgets/settings/settings_models.dart';
import '../widgets/settings/settings_profile_card.dart';
import '../widgets/settings/settings_section_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _cacheKey = 'settings_bundle_v1';
  static const _cacheTtl = Duration(minutes: 2);
  static const _profileUsageCacheTtl = Duration(minutes: 2);

  bool notifications = true;
  bool _isLoading = true;
  List<VaultItem> _vaultItems = const [];
  List<ApiConnection> _connections = const [];
  ApiUser? _me;
  StreamSubscription<OAuthCallbackEvent>? _oauthCallbackSubscription;

  @override
  void initState() {
    super.initState();
    _load();
    _prefetchProfileUsage();
    _oauthCallbackSubscription = appOAuthDeepLinkService.events.listen(
      _handleOAuthCallback,
    );
  }

  @override
  void dispose() {
    _oauthCallbackSubscription?.cancel();
    super.dispose();
  }

  Future<void> _load({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = appCacheStore.get<_SettingsBundle>(_cacheKey);
      if (cached != null) {
        setState(() {
          _me = cached.me;
          _vaultItems = cached.vaultItems;
          _connections = cached.connections;
          _isLoading = false;
        });
        _prefetchProfileUsage();
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        appApiRepository.me(),
        appApiRepository.connections(),
      ]);

      final me = results[0] as ApiUser?;
      final connections = results[1] as List<ApiConnection>;
      final mappedVaultItems = connections
          .map(mapConnectionToVaultItem)
          .toList();

      appCacheStore.set<_SettingsBundle>(
        _cacheKey,
        _SettingsBundle(
          me: me,
          connections: connections,
          vaultItems: mappedVaultItems,
        ),
        ttl: _cacheTtl,
      );

      if (!mounted) return;
      setState(() {
        _me = me;
        _connections = connections;
        _vaultItems = mappedVaultItems;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      _showToast('API error: ${e.statusCode ?? ''} ${e.message}'.trim());
      setState(() => _isLoading = false);
    } catch (_) {
      if (!mounted) return;
      _showToast('Failed to load settings data');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _prefetchProfileUsage({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cachedUsedBytes = appCacheStore.get<double>(kProfileUsageCacheKey);
      if (cachedUsedBytes != null) return;
    }

    try {
      final usage = await appApiRepository.storageUsage();
      final usedBytes = usage.fold<double>(
        0,
        (acc, item) => acc + item.usedBytes,
      );
      appCacheStore.set<double>(
        kProfileUsageCacheKey,
        usedBytes,
        ttl: _profileUsageCacheTtl,
      );
    } catch (_) {
      // Silent prefetch: settings UI should not fail if usage is unavailable.
    }
  }

  Future<bool> _refreshConnectionsOnly() async {
    try {
      final connections = await appApiRepository.connections();
      final mappedVaultItems = connections
          .map(mapConnectionToVaultItem)
          .toList();

      if (!mounted) return false;
      setState(() {
        _connections = connections;
        _vaultItems = mappedVaultItems;
      });

      appCacheStore.set<_SettingsBundle>(
        _cacheKey,
        _SettingsBundle(
          me: _me,
          connections: connections,
          vaultItems: mappedVaultItems,
        ),
        ttl: _cacheTtl,
      );
      return true;
    } on ApiException catch (e) {
      if (!mounted) return false;
      _showToast('API error: ${e.statusCode ?? ''} ${e.message}'.trim());
      return false;
    } catch (_) {
      if (!mounted) return false;
      _showToast('Failed to refresh connected storages');
      return false;
    }
  }

  Future<void> _handleOAuthCallback(OAuthCallbackEvent event) async {
    if (!mounted) return;
    await handleOAuthCallbackEvent(
      event: event,
      refreshOnSuccess: _refreshConnectionsOnly,
      hasConnection: (connectionId) =>
          _connections.any((item) => item.id == connectionId),
      showMessage: _showToast,
      showErrorWithRetry: _showOAuthErrorWithRetry,
      onRetry: _startAddProviderFlow,
    );
  }

  void _showOAuthErrorWithRetry(
    String message,
    Future<void> Function() onRetry,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () async {
              if (!mounted) return;
              await onRetry();
            },
          ),
        ),
      );
  }

  Future<void> _startAddProviderFlow() async {
    final result = await showAddVaultModal(context);
    if (!result.didStartConnect) return;

    if (!result.expectsAppCallback) {
      await _refreshConnectionsOnly();
    }
  }

  void _showToast(String message) {
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

  Future<void> _handleDisconnect(VaultItem storage) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      await appApiRepository.disconnectConnection(storage.id);
      _showToast(l10n.disconnectedToast(storage.title));
      await _load(forceRefresh: true);
    } on ApiException catch (e) {
      _showToast('API error: ${e.statusCode ?? ''} ${e.message}'.trim());
    } catch (_) {
      _showToast('Disconnect failed');
    }
  }

  void _toggleNotifications() {
    setState(() => notifications = !notifications);
    final l10n = AppLocalizations.of(context)!;
    _showToast(
      notifications
          ? l10n.notificationsEnabledToast
          : l10n.notificationsDisabledToast,
    );
  }

  Future<void> _toggleTheme() async {
    await appThemeController.toggleTheme();
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    _showToast(
      appThemeController.isDarkMode
          ? l10n.themeEnabledToast
          : l10n.themeDisabledToast,
    );
  }

  Future<void> _openLanguageModal() async {
    final selectedCode = await showLanguageModal(context);
    if (selectedCode == null) return;
    await appLocaleController.setLocale(selectedCode);
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _logout() async {
    Object? signOutError;
    try {
      await FirebaseAuth.instance.signOut();
    } catch (error) {
      signOutError = error;
    } finally {
      await AuthSession.instance.clearTokens();
      appCacheStore.clear();
    }

    if (!mounted) return;
    await Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(LoginScreen.routeName, (route) => false);

    if (signOutError != null && mounted) {
      _showToast('Signed out locally');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppThemeColors.of(context);
    final darkTheme = appThemeController.isDarkMode;
    final languageValue = appLocaleController.locale.languageCode == 'uk'
        ? l10n.languageUkrainian
        : l10n.languageEnglish;

    final sections = [
      SettingsSectionData(
        title: l10n.account,
        items: [
          SettingsItemData(
            icon: Icons.person_outline,
            label: l10n.profile,
            value: _me?.name ?? '',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ProfileScreen(
                    initialUser: _me,
                    initialConnections: _connections,
                  ),
                ),
              );
            },
          ),
          SettingsItemData(
            icon: Icons.language,
            label: l10n.language,
            value: languageValue,
            onTap: _openLanguageModal,
          ),
        ],
      ),
      SettingsSectionData(
        title: l10n.preferences,
        items: [
          SettingsItemData(
            icon: Icons.notifications_none,
            label: l10n.notifications,
            value: notifications ? l10n.enabled : l10n.disabled,
            isToggle: true,
            isChecked: notifications,
            onTap: _toggleNotifications,
          ),
          SettingsItemData(
            icon: darkTheme
                ? Icons.dark_mode_outlined
                : Icons.light_mode_outlined,
            label: l10n.darkTheme,
            value: darkTheme ? l10n.enabled : l10n.disabled,
            isToggle: true,
            isChecked: darkTheme,
            onTap: _toggleTheme,
          ),
          SettingsItemData(
            icon: Icons.shield_outlined,
            label: l10n.privacy,
            onTap: () => _showToast(l10n.privacy),
          ),
        ],
      ),
      SettingsSectionData(
        title: l10n.other,
        items: [
          SettingsItemData(
            icon: Icons.help_outline,
            label: l10n.helpSupport,
            onTap: () => _showToast(l10n.helpSupport),
          ),
          SettingsItemData(
            icon: Icons.logout,
            label: l10n.logout,
            isDanger: true,
            onTap: _logout,
          ),
        ],
      ),
    ];

    return Scaffold(
      body: MobileScreenShell(
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: const SettingsLoadingSkeleton(),
                    )
                  : RefreshIndicator(
                      onRefresh: () => _load(forceRefresh: true),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SettingsProfileCard(
                              name: _me?.name ?? '',
                              email: _me?.email ?? '',
                            ),
                            const SizedBox(height: 18),
                            ConnectedStoragesCard(
                              title: l10n.connectedStorages,
                              addLabel: l10n.add,
                              connectedLabel: l10n.connected,
                              items: _vaultItems,
                              onAddTap: () async {
                                await _startAddProviderFlow();
                              },
                              onDisconnect: _handleDisconnect,
                            ),
                            const SizedBox(height: 20),
                            ...sections.map(
                              (section) => Padding(
                                padding: const EdgeInsets.only(bottom: 18),
                                child: SettingsSectionCard(section: section),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  l10n.appVersion,
                                  style: TextStyle(
                                    color: colors.mutedText,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
            BottomNavBar(
              activeIndex: 3,
              onTap: (index) => handleBottomNavTap(context, 3, index),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsBundle {
  const _SettingsBundle({
    required this.me,
    required this.connections,
    required this.vaultItems,
  });

  final ApiUser? me;
  final List<ApiConnection> connections;
  final List<VaultItem> vaultItems;
}
