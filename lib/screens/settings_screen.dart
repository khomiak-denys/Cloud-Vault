import 'package:cloud_vault/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../data/vault_mock_data.dart';
import '../modals/add_vault_modal.dart';
import '../modals/language_modal.dart';
import '../screens/login_screen.dart';
import '../screens/profile_screen.dart';
import '../state/locale_controller.dart';
import '../state/theme_controller.dart';
import '../theme/app_theme_colors.dart';
import '../utils/tab_navigation.dart';
import '../widgets/bottom_nav_bar.dart';
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

  void _handleDisconnect(String storageName) {
    final l10n = AppLocalizations.of(context)!;
    _showToast(l10n.disconnectedToast(storageName));
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

  void _logout() {
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(LoginScreen.routeName, (route) => false);
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
            value: l10n.profileName,
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SettingsProfileCard(
                      name: l10n.profileName,
                      email: l10n.profileEmail,
                      planTitle: l10n.premiumPlan,
                      planSubtitle: l10n.premiumValidUntil,
                      proLabel: l10n.pro,
                    ),
                    const SizedBox(height: 18),
                    ConnectedStoragesCard(
                      title: l10n.connectedStorages,
                      addLabel: l10n.add,
                      connectedLabel: l10n.connected,
                      items: vaultItems,
                      onAddTap: () => showAddVaultModal(context),
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
