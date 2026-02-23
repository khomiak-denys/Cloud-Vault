import 'package:flutter/material.dart';
import 'package:cloud_vault/l10n/app_localizations.dart';

import '../data/mock_data.dart';
import '../modals/add_vault_modal.dart';
import '../modals/language_modal.dart';
import '../state/locale_controller.dart';
import '../state/theme_controller.dart';
import '../utils/tab_navigation.dart';
import '../widgets/bottom_nav_bar.dart';

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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final outerBg = isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE7ECF4);
    final shellBg = isDark ? const Color(0xFF00081C) : Colors.white;
    final headerBg = isDark ? const Color(0xFF0F1D36) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF1E2E46)
        : const Color(0xFFDCE5F2);
    final cardBg = isDark ? const Color(0xFF0F1D36) : Colors.white;
    final cardBorder = isDark
        ? const Color(0xFF20344F)
        : const Color(0xFFDCE5F2);
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryColor = isDark
        ? const Color(0xFF97A5BC)
        : const Color(0xFF64748B);
    final sectionLabelColor = isDark
        ? const Color(0xFF93A1B7)
        : const Color(0xFF64748B);
    final iconTileBg = isDark
        ? const Color(0xFF18345E)
        : const Color(0xFFE6EEFC);
    final darkTheme = appThemeController.isDarkMode;
    final languageValue = appLocaleController.locale.languageCode == 'uk'
        ? l10n.languageUkrainian
        : l10n.languageEnglish;
    final sections = [
      _SettingsSection(
        title: l10n.account,
        items: [
          _SettingsItem(
            icon: Icons.person_outline,
            label: l10n.profile,
            value: l10n.profileName,
          ),
          _SettingsItem(
            icon: Icons.language,
            label: l10n.language,
            value: languageValue,
            onTap: _openLanguageModal,
          ),
        ],
      ),
      _SettingsSection(
        title: l10n.preferences,
        items: [
          _SettingsItem(
            icon: Icons.notifications_none,
            label: l10n.notifications,
            value: notifications ? l10n.enabled : l10n.disabled,
            isToggle: true,
            isChecked: notifications,
            onTap: _toggleNotifications,
          ),
          _SettingsItem(
            icon: darkTheme
                ? Icons.dark_mode_outlined
                : Icons.light_mode_outlined,
            label: l10n.darkTheme,
            value: darkTheme ? l10n.enabled : l10n.disabled,
            isToggle: true,
            isChecked: darkTheme,
            onTap: _toggleTheme,
          ),
          _SettingsItem(
            icon: Icons.shield_outlined,
            label: l10n.privacy,
            onTap: () => _showToast(l10n.privacy),
          ),
        ],
      ),
      _SettingsSection(
        title: l10n.other,
        items: [
          _SettingsItem(
            icon: Icons.help_outline,
            label: l10n.helpSupport,
            onTap: () => _showToast(l10n.helpSupport),
          ),
          _SettingsItem(
            icon: Icons.logout,
            label: l10n.logout,
            isDanger: true,
            onTap: () => _showToast(l10n.logout),
          ),
        ],
      ),
    ];

    return Scaffold(
      body: Container(
        color: outerBg,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Container(
                decoration: BoxDecoration(
                  color: shellBg,
                  borderRadius: BorderRadius.circular(36),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(36),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
                        decoration: BoxDecoration(
                          color: headerBg,
                          border: Border(
                            bottom: BorderSide(color: borderColor),
                          ),
                        ),
                        child: Text(
                          l10n.settings,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: titleColor,
                          ),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  16,
                                  16,
                                  16,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF2654E8),
                                      Color(0xFF2446B8),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        const CircleAvatar(
                                          radius: 42,
                                          backgroundColor: Color(0xFF4A6DD8),
                                          child: Text(
                                            '👤',
                                            style: TextStyle(fontSize: 36),
                                          ),
                                        ),
                                        SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                l10n.profileName,
                                                style: TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                l10n.profileEmail,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Color(0xFFD6E2FF),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.fromLTRB(
                                        14,
                                        12,
                                        14,
                                        12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.14,
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  l10n.premiumPlan,
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                SizedBox(height: 3),
                                                Text(
                                                  l10n.premiumValidUntil,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFFD6E2FF),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          DecoratedBox(
                                            decoration: BoxDecoration(
                                              color: Color(0xFFFACD0A),
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(999),
                                              ),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 5,
                                              ),
                                              child: Text(
                                                l10n.pro,
                                                style: TextStyle(
                                                  color: Color(0xFF6B4D00),
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 18),
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: cardBorder),
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        16,
                                        14,
                                        16,
                                        12,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            l10n.connectedStorages,
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w700,
                                              color: titleColor,
                                            ),
                                          ),
                                          TextButton.icon(
                                            onPressed: () =>
                                                showAddVaultModal(context),
                                            style: TextButton.styleFrom(
                                              overlayColor: Colors.transparent,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 4,
                                                  ),
                                            ),
                                            icon: const Icon(
                                              Icons.add,
                                              color: Color(0xFF4BA2FF),
                                            ),
                                            label: Text(
                                              l10n.add,
                                              style: TextStyle(
                                                color: Color(0xFF4BA2FF),
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Divider(height: 1, color: borderColor),
                                    ...vaultItems.asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final storage = entry.value;

                                      return Column(
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
                                                Container(
                                                  width: 58,
                                                  height: 58,
                                                  decoration: BoxDecoration(
                                                    color: iconTileBg,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          16,
                                                        ),
                                                  ),
                                                  child: Icon(
                                                    storage.icon,
                                                    color: Colors.white,
                                                    size: 30,
                                                  ),
                                                ),
                                                const SizedBox(width: 14),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        storage.title,
                                                        style: const TextStyle(
                                                          fontSize: 19,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 2),
                                                      Text(
                                                        l10n.connected,
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: secondaryColor,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                IconButton(
                                                  onPressed: () =>
                                                      _handleDisconnect(
                                                        storage.title,
                                                      ),
                                                  icon: const Icon(
                                                    Icons.delete_outline,
                                                    color: Color(0xFFFF626D),
                                                    size: 28,
                                                  ),
                                                  style: IconButton.styleFrom(
                                                    overlayColor:
                                                        Colors.transparent,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (index != vaultItems.length - 1)
                                            Divider(
                                              height: 1,
                                              color: borderColor,
                                            ),
                                        ],
                                      );
                                    }),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              ...sections.map(
                                (section) => Padding(
                                  padding: const EdgeInsets.only(bottom: 18),
                                  child: _SettingsSectionCard(
                                    section: section,
                                    isDark: isDark,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 6),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    l10n.appVersion,
                                    style: TextStyle(
                                      color: sectionLabelColor,
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsSection {
  const _SettingsSection({required this.title, required this.items});

  final String title;
  final List<_SettingsItem> items;
}

class _SettingsItem {
  const _SettingsItem({
    required this.icon,
    required this.label,
    this.value,
    this.isDanger = false,
    this.isToggle = false,
    this.isChecked = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? value;
  final bool isDanger;
  final bool isToggle;
  final bool isChecked;
  final VoidCallback? onTap;
}

class _SettingsSectionCard extends StatelessWidget {
  const _SettingsSectionCard({required this.section, required this.isDark});

  final _SettingsSection section;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 8),
          child: Text(
            section.title,
            style: TextStyle(
              color: isDark ? const Color(0xFF93A1B7) : const Color(0xFF64748B),
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F1D36) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF20344F) : const Color(0xFFDCE5F2),
            ),
          ),
          child: Column(
            children: section.items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final rowColor = item.isDanger
                  ? const Color(0xFFFF626D)
                  : (isDark ? Colors.white : const Color(0xFF0F172A));

              return Column(
                children: [
                  InkWell(
                    onTap: item.onTap,
                    overlayColor: const WidgetStatePropertyAll(
                      Colors.transparent,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                      child: Row(
                        children: [
                          Icon(item.icon, color: rowColor, size: 25),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.label,
                              style: TextStyle(
                                color: rowColor,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (item.value != null &&
                              item.value!.isNotEmpty &&
                              !item.isToggle)
                            Text(
                              item.value!,
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          if (item.isToggle)
                            _SwitchChip(
                              isChecked: item.isChecked,
                              isDark: isDark,
                            )
                          else
                            Icon(
                              Icons.chevron_right,
                              color: isDark
                                  ? const Color(0xFF5F6F87)
                                  : const Color(0xFF94A3B8),
                              size: 24,
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (index != section.items.length - 1)
                    Divider(
                      height: 1,
                      color: isDark
                          ? const Color(0xFF1E2E46)
                          : const Color(0xFFDCE5F2),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SwitchChip extends StatelessWidget {
  const _SwitchChip({required this.isChecked, required this.isDark});

  final bool isChecked;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 48,
      height: 26,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isChecked
            ? const Color(0xFF2662E7)
            : (isDark ? const Color(0xFF44546D) : const Color(0xFFCBD5E1)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Align(
        alignment: isChecked ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
