import 'dart:async';

import 'package:cloud_vault/l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/auth_session.dart';
import '../api/api_exception.dart';
import '../data/api_mappers.dart';
import '../data/app_services.dart';
import '../data/oauth_callback_handler.dart';
import '../data/oauth_deep_link_service.dart';
import '../modals/add_vault_modal.dart';
import '../modals/language_modal.dart';
import '../models/vault_item.dart';
import '../screens/profile_screen.dart';
import '../state/locale_controller.dart';
import '../state/providers/analytics_provider.dart';
import '../state/providers/connections_provider.dart';
import '../state/providers/favorites_provider.dart';
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
  bool notifications = true;
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
    final connectionsProvider = context.read<ConnectionsProvider>();
    try {
      await connectionsProvider.ensureLoaded(forceRefresh: forceRefresh);
    } on ApiException catch (e) {
      if (!mounted) return;
      _showToast('API error: ${e.statusCode ?? ''} ${e.message}'.trim());
    } catch (_) {
      if (!mounted) return;
      _showToast('Failed to load settings data');
    }
  }

  Future<void> _prefetchProfileUsage({bool forceRefresh = false}) async {
    try {
      await context.read<ConnectionsProvider>().ensureLoaded(
        forceRefresh: forceRefresh,
      );
    } catch (_) {
      // Silent prefetch: settings UI should not fail if usage is unavailable.
    }
  }

  Future<bool> _refreshConnectionsOnly() async {
    try {
      await context.read<ConnectionsProvider>().ensureLoaded(
        forceRefresh: true,
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
      hasConnection: (connectionId) => context
          .read<ConnectionsProvider>()
          .connections
          .any((item) => item.id == connectionId),
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
    final l10n = AppLocalizations.of(context)!;
    final connectionsProvider = context.read<ConnectionsProvider>();
    final favoritesProvider = context.read<FavoritesProvider>();
    final analyticsProvider = context.read<AnalyticsProvider>();
    Object? signOutError;
    try {
      await FirebaseAuth.instance.signOut();
    } catch (error) {
      signOutError = error;
    } finally {
      try {
        await AuthSession.instance.clearTokens();
      } catch (_) {
        // Keep logout flow resilient even when local persistence is unavailable.
      }
      connectionsProvider.reset();
      favoritesProvider.reset();
      analyticsProvider.reset();
    }

    if (!mounted) return;
    if (signOutError != null) {
      _showToast(l10n.logoutLocalOnlyToast);
    }

    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppThemeColors.of(context);
    final darkTheme = appThemeController.isDarkMode;
    final languageValue = appLocaleController.locale.languageCode == 'uk'
        ? l10n.languageUkrainian
        : l10n.languageEnglish;
    final connectionsProvider = context.watch<ConnectionsProvider>();
    final me = connectionsProvider.me;
    final vaultItems = connectionsProvider.connections
        .map(mapConnectionToVaultItem)
        .toList();
    final isLoading = connectionsProvider.isLoading;

    final sections = [
      SettingsSectionData(
        title: l10n.account,
        items: [
          SettingsItemData(
            icon: Icons.person_outline,
            label: l10n.profile,
            value: me?.name ?? '',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
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
              child: isLoading
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
                              name: me?.name ?? '',
                              email: me?.email ?? '',
                            ),
                            const SizedBox(height: 18),
                            ConnectedStoragesCard(
                              title: l10n.connectedStorages,
                              addLabel: l10n.add,
                              connectedLabel: l10n.connected,
                              items: vaultItems,
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
