import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../modals/add_vault_modal.dart';
import '../utils/tab_navigation.dart';
import '../widgets/bottom_nav_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notifications = true;
  bool darkTheme = true;

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
    _showToast('$storageName відключено');
  }

  void _toggleNotifications() {
    setState(() => notifications = !notifications);
    _showToast(notifications ? 'Сповіщення увімкнено' : 'Сповіщення вимкнено');
  }

  void _toggleTheme() {
    setState(() => darkTheme = !darkTheme);
    _showToast(darkTheme ? 'Темну тему увімкнено' : 'Світлу тему увімкнено');
  }

  @override
  Widget build(BuildContext context) {
    final sections = [
      _SettingsSection(
        title: 'АКАУНТ',
        items: const [
          _SettingsItem(
            icon: Icons.person_outline,
            label: 'Профіль',
            value: 'Іван Петренко',
          ),
          _SettingsItem(
            icon: Icons.language,
            label: 'Мова',
            value: 'Українська',
          ),
        ],
      ),
      _SettingsSection(
        title: 'НАЛАШТУВАННЯ',
        items: [
          _SettingsItem(
            icon: Icons.notifications_none,
            label: 'Сповіщення',
            value: notifications ? 'Увімкнено' : 'Вимкнено',
            isToggle: true,
            isChecked: notifications,
            onTap: _toggleNotifications,
          ),
          _SettingsItem(
            icon: darkTheme ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
            label: 'Темна тема',
            value: darkTheme ? 'Увімкнено' : 'Вимкнено',
            isToggle: true,
            isChecked: darkTheme,
            onTap: _toggleTheme,
          ),
          _SettingsItem(
            icon: Icons.shield_outlined,
            label: 'Конфіденційність',
            onTap: () => _showToast('Конфіденційність'),
          ),
        ],
      ),
      _SettingsSection(
        title: 'ІНШЕ',
        items: [
          _SettingsItem(
            icon: Icons.help_outline,
            label: 'Довідка та підтримка',
            onTap: () => _showToast('Довідка та підтримка'),
          ),
          _SettingsItem(
            icon: Icons.logout,
            label: 'Вийти',
            isDanger: true,
            onTap: () => _showToast('Вихід із акаунту'),
          ),
        ],
      ),
    ];

    return Scaffold(
      body: Container(
        color: const Color(0xFF2D2D2D),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF00081C),
                  borderRadius: BorderRadius.circular(36),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(36),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
                        decoration: const BoxDecoration(
                          color: Color(0xFF0F1D36),
                          border: Border(
                            bottom: BorderSide(color: Color(0xFF1E2E46)),
                          ),
                        ),
                        child: const Text(
                          'Налаштування',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
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
                                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF2654E8), Color(0xFF2446B8)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  children: [
                                    const Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 42,
                                          backgroundColor: Color(0xFF4A6DD8),
                                          child: Text('👤', style: TextStyle(fontSize: 36)),
                                        ),
                                        SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Іван Петренко',
                                                style: TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                'ivan.petrenko@email.com',
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
                                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.14),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Преміум план',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                SizedBox(height: 3),
                                                Text(
                                                  'Дійсний до 23 лютого 2027',
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
                                              borderRadius: BorderRadius.all(Radius.circular(999)),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                              child: Text(
                                                'PRO',
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
                                  color: const Color(0xFF0F1D36),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: const Color(0xFF20344F)),
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Підключені сховища',
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          TextButton.icon(
                                            onPressed: () => showAddVaultModal(context),
                                            style: TextButton.styleFrom(
                                              overlayColor: Colors.transparent,
                                              padding: const EdgeInsets.symmetric(horizontal: 4),
                                            ),
                                            icon: const Icon(Icons.add, color: Color(0xFF4BA2FF)),
                                            label: const Text(
                                              'Додати',
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
                                    const Divider(height: 1, color: Color(0xFF1E2E46)),
                                    ...vaultItems.asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final storage = entry.value;

                                      return Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 58,
                                                  height: 58,
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFF18345E),
                                                    borderRadius: BorderRadius.circular(16),
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
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        storage.title,
                                                        style: const TextStyle(
                                                          fontSize: 19,
                                                          fontWeight: FontWeight.w700,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 2),
                                                      const Text(
                                                        'Підключено',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Color(0xFF97A5BC),
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                IconButton(
                                                  onPressed: () => _handleDisconnect(storage.title),
                                                  icon: const Icon(
                                                    Icons.delete_outline,
                                                    color: Color(0xFFFF626D),
                                                    size: 28,
                                                  ),
                                                  style: IconButton.styleFrom(
                                                    overlayColor: Colors.transparent,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (index != vaultItems.length - 1)
                                            const Divider(height: 1, color: Color(0xFF1E2E46)),
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
                                  child: _SettingsSectionCard(section: section),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 6),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'CloudVault v1.0.0',
                                    style: TextStyle(
                                      color: Color(0xFF7F90A8),
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
  const _SettingsSectionCard({required this.section});

  final _SettingsSection section;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 8),
          child: Text(
            section.title,
            style: const TextStyle(
              color: Color(0xFF93A1B7),
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0F1D36),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF20344F)),
          ),
          child: Column(
            children: section.items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final rowColor = item.isDanger ? const Color(0xFFFF626D) : Colors.white;

              return Column(
                children: [
                  InkWell(
                    onTap: item.onTap,
                    overlayColor: const WidgetStatePropertyAll(Colors.transparent),
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
                          if (item.value != null && item.value!.isNotEmpty && !item.isToggle)
                            Text(
                              item.value!,
                              style: const TextStyle(
                                color: Color(0xFF9AA7BC),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          if (item.isToggle)
                            _SwitchChip(isChecked: item.isChecked)
                          else
                            const Icon(
                              Icons.chevron_right,
                              color: Color(0xFF5F6F87),
                              size: 24,
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (index != section.items.length - 1)
                    const Divider(height: 1, color: Color(0xFF1E2E46)),
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
  const _SwitchChip({required this.isChecked});

  final bool isChecked;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 48,
      height: 26,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isChecked ? const Color(0xFF2662E7) : const Color(0xFF44546D),
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
