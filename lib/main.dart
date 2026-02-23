import 'package:flutter/material.dart';
import 'dart:ui';

void main() {
  runApp(const CloudVaultApp());
}

WidgetStateProperty<Color?> _pressOnlyOverlay(Color color) {
  return WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.pressed)) {
      return color;
    }
    return Colors.transparent;
  });
}

class CloudVaultApp extends StatelessWidget {
  const CloudVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CloudVault',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF00071A),
        fontFamily: 'SF Pro Display',
      ),
      home: const CloudVaultScreen(),
    );
  }
}

class CloudVaultScreen extends StatelessWidget {
  const CloudVaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vaults = <VaultItem>[
      const VaultItem(
        title: 'Google Drive',
        usageText: '12.3 ГБ / 15 ГБ',
        percentLabel: '82%',
        progress: 0.82,
        progressColor: Color(0xFF4A90FF),
        icon: Icons.folder,
      ),
      const VaultItem(
        title: 'OneDrive',
        usageText: '2.1 ГБ / 5 ГБ',
        percentLabel: '42%',
        progress: 0.42,
        progressColor: Color(0xFF1B8FE7),
        icon: Icons.cloud,
      ),
      const VaultItem(
        title: 'Dropbox',
        usageText: '1.8 ГБ / 2 ГБ',
        percentLabel: '90%',
        progress: 0.90,
        progressColor: Color(0xFFFF7B1B),
        icon: Icons.inventory_2,
        hasWarning: true,
      ),
      const VaultItem(
        title: 'iCloud',
        usageText: '819.2 МБ / 5 ГБ',
        percentLabel: '16%',
        progress: 0.16,
        progressColor: Color(0xFF4AA2FF),
        icon: Icons.cloud,
      ),
    ];
    final recentFiles = <RecentFileItem>[
      const RecentFileItem(
        title: 'Презентація проекту.pptx',
        subtitle: 'Google Drive  •  3 дн. тому  •  5.2 МБ',
        icon: Icons.description_outlined,
        iconColor: Color(0xFFFF7A00),
        badgeIcon: Icons.star,
        badgeColor: Color(0xFFF6C215),
      ),
      const RecentFileItem(
        title: 'Фото з відпустки',
        subtitle: 'Google Drive  •  15 лют.',
        icon: Icons.folder_outlined,
        iconColor: Color(0xFF2D89FF),
      ),
      const RecentFileItem(
        title: 'Звіт_лютий_2026.xlsx',
        subtitle: 'OneDrive  •  Вчора  •  1.3 МБ',
        icon: Icons.description_outlined,
        iconColor: Color(0xFFFF7A00),
        badgeIcon: Icons.share_outlined,
        badgeColor: Color(0xFF2D89FF),
      ),
      const RecentFileItem(
        title: 'Портфоліо.pdf',
        subtitle: 'Dropbox  •  5 дн. тому  •  8.7 МБ',
        icon: Icons.description_outlined,
        iconColor: Color(0xFFFF7A00),
      ),
      const RecentFileItem(
        title: 'Відео_презентація.mp4',
        subtitle: 'Google Drive  •  10 лют.  •  125 МБ',
        icon: Icons.videocam_outlined,
        iconColor: Color(0xFFA84DFF),
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
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              _TopSummaryCard(),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Expanded(
                                      child: Text(
                                        'Мої сховища',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    TextButton.icon(
                                      onPressed: () => _showAddVaultModal(context),
                                      style: TextButton.styleFrom(
                                        foregroundColor: const Color(0xFF4BA2FF),
                                        padding: const EdgeInsets.symmetric(horizontal: 6),
                                        minimumSize: const Size(0, 0),
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        overlayColor: Colors.transparent,
                                      ),
                                      icon: const Icon(Icons.add, size: 22),
                                      label: const Text(
                                        'Додати',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: Column(
                                  children: vaults
                                      .map(
                                        (item) => Padding(
                                          padding: const EdgeInsets.only(bottom: 2),
                                          child: _VaultCard(item: item),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.fromLTRB(24, 28, 24, 14),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Нещодавні файли',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: Column(
                                  children: recentFiles
                                      .map(
                                        (file) => Padding(
                                          padding: const EdgeInsets.only(bottom: 12),
                                          child: _RecentFileCard(
                                            item: file,
                                            onMoreTap: () => _showFileActionsModal(context, file),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                      const _BottomNavBar(),
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

Future<void> _showAddVaultModal(BuildContext context) async {
  final options = <AddVaultOption>[
    const AddVaultOption(title: 'Google Drive', icon: Icons.folder),
    const AddVaultOption(title: 'OneDrive', icon: Icons.cloud),
    const AddVaultOption(title: 'Dropbox', icon: Icons.inventory_2),
    const AddVaultOption(title: 'iCloud', icon: Icons.cloud),
    const AddVaultOption(
      title: 'MEGA',
      icon: Icons.circle,
      iconColor: Color(0xFFE61D21),
      iconBackground: Color(0xFF34203A),
    ),
    const AddVaultOption(title: 'Box', icon: Icons.inbox),
  ];

  await showGeneralDialog<void>(
    context: context,
    barrierLabel: 'Add vault',
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    pageBuilder: (context, animation, secondaryAnimation) {
      int? selectedIndex;

      return StatefulBuilder(
        builder: (context, setModalState) {
          return Material(
            type: MaterialType.transparency,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(color: Colors.black.withValues(alpha: 0.2)),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 390,
                        maxHeight: MediaQuery.sizeOf(context).height * 0.72,
                      ),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D1B35),
                          borderRadius: BorderRadius.circular(34),
                          border: Border.all(color: const Color(0xFF243859)),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Додати сховище',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                IconButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  style: ButtonStyle(
                                    overlayColor: _pressOnlyOverlay(
                                      const Color(0x3397A5BD),
                                    ),
                                  ),
                                  icon: const Icon(Icons.close, color: Color(0xFF96A4BF)),
                                ),
                                ],
                              ),
                              const Divider(color: Color(0xFF263A59), height: 30),
                              const Text(
                                'Виберіть хмарне сховище, яке ви хочете\nпідключити',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF94A2BB),
                                  height: 1.35,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 20),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: options.length,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  mainAxisExtent: 132,
                                ),
                                itemBuilder: (context, index) {
                                  final option = options[index];
                                  final isSelected = selectedIndex == index;
                                  return _AddVaultOptionTile(
                                    option: option,
                                    isSelected: isSelected,
                                    onTap: () => setModalState(() => selectedIndex = index),
                                  );
                                },
                              ),
                              const SizedBox(height: 22),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: selectedIndex == null ? null : () => Navigator.of(context).pop(),
                                  style: ButtonStyle(
                                    backgroundColor: const WidgetStatePropertyAll(
                                      Color(0xFF2448A3),
                                    ),
                                    foregroundColor: const WidgetStatePropertyAll(
                                      Colors.white,
                                    ),
                                    overlayColor: _pressOnlyOverlay(
                                      const Color(0x33FFFFFF),
                                    ),
                                    shape: WidgetStatePropertyAll(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                    ),
                                    padding: const WidgetStatePropertyAll(
                                      EdgeInsets.symmetric(vertical: 16),
                                    ),
                                  ),
                                  child: const Text(
                                    'Підключити',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Future<void> _showFileActionsModal(BuildContext context, RecentFileItem file) async {
  final isStarred = file.badgeIcon == Icons.star;
  final actions = <FileActionOption>[
    FileActionOption(
      icon: isStarred ? Icons.star_border : Icons.star_outline,
      label: isStarred ? 'Прибрати зірочку' : 'Додати зірочку',
    ),
    const FileActionOption(icon: Icons.download_outlined, label: 'Завантажити'),
    const FileActionOption(icon: Icons.share_outlined, label: 'Поділитися'),
    const FileActionOption(icon: Icons.copy_outlined, label: 'Копіювати в...'),
    const FileActionOption(icon: Icons.edit_outlined, label: 'Перейменувати'),
    const FileActionOption(icon: Icons.info_outline, label: 'Інформація'),
    const FileActionOption(
      icon: Icons.delete_outline,
      label: 'Видалити',
      color: Color(0xFFFF626D),
    ),
  ];

  await showGeneralDialog<void>(
    context: context,
    barrierLabel: 'File actions',
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.40),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                  child: Container(color: Colors.black.withValues(alpha: 0.2)),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 430,
                    maxHeight: MediaQuery.sizeOf(context).height * 0.62,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(22, 20, 22, 14),
                    decoration: const BoxDecoration(
                      color: Color(0xFF0D1B35),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  file.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: ButtonStyle(
                                  overlayColor: _pressOnlyOverlay(
                                    const Color(0x3397A5BD),
                                  ),
                                ),
                                icon: const Icon(Icons.close, color: Color(0xFF97A5BD)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ...actions.map(
                            (action) => _FileActionRow(
                              action: action,
                              onTap: () => Navigator.of(context).pop(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: TextButton.styleFrom(
                                backgroundColor: const Color(0xFF22314A),
                                foregroundColor: const Color(0xFFCDD6E5),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                overlayColor: Colors.transparent,
                              ),
                              child: const Text(
                                'Скасувати',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _TopSummaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2550E8), Color(0xFF203FAF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(34, 34, 34, 44),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CloudVault',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.8,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Керуйте всіма хмарами',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFD4DEFF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                  child: const Icon(
                    Icons.notifications_none,
                    size: 26,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Всього використано',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFD7E2FF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        '63%',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  _ProgressTrack(value: 0.63, color: Color(0xFFE7EEFF)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VaultCard extends StatelessWidget {
  const _VaultCard({required this.item});

  final VaultItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2D44),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF32435C)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: const Color(0xFF22406A),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(item.icon, color: Colors.white, size: 36),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.usageText,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFA8B0C0),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (item.hasWarning)
                const Icon(
                  Icons.error_outline,
                  color: Color(0xFFFF7B1B),
                  size: 30,
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Використано',
                style: TextStyle(
                  color: Color(0xFF94A1B8),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                item.percentLabel,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ProgressTrack(value: item.progress, color: item.progressColor),
        ],
      ),
    );
  }
}

class _RecentFileCard extends StatelessWidget {
  const _RecentFileCard({required this.item, required this.onMoreTap});

  final RecentFileItem item;
  final VoidCallback onMoreTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2D44),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF31435C)),
      ),
      child: Row(
        children: [
          Icon(item.icon, size: 30, color: item.iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (item.badgeIcon != null) ...[
                      const SizedBox(width: 8),
                      Icon(item.badgeIcon, size: 20, color: item.badgeColor),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF97A5BB),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onMoreTap,
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.more_vert, color: Color(0xFF95A4BE)),
            ),
          ),
        ],
      ),
    );
  }
}

class _FileActionRow extends StatelessWidget {
  const _FileActionRow({required this.action, required this.onTap});

  final FileActionOption action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      splashColor: const Color(0x33FFFFFF),
      highlightColor: const Color(0x22000000),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          children: [
            Icon(action.icon, size: 28, color: action.color ?? Colors.white),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                action.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: action.color ?? Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddVaultOptionTile extends StatelessWidget {
  const _AddVaultOptionTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final AddVaultOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      splashColor: const Color(0x334A90FF),
      highlightColor: const Color(0x22000000),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0D1D38),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF4A90FF) : const Color(0xFF334866),
            width: isSelected ? 1.6 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: option.iconBackground ?? const Color(0xFF16325E),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                option.icon,
                color: option.iconColor ?? Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              option.title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressTrack extends StatelessWidget {
  const _ProgressTrack({required this.value, required this.color});

  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 14,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: LinearProgressIndicator(
          value: value,
          backgroundColor: const Color(0xFF45526B),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: const BoxDecoration(
        color: Color(0xFF0A1730),
        border: Border(top: BorderSide(color: Color(0xFF1D2C44))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: _NavItem(icon: Icons.home_outlined, label: 'Головна', isActive: true),
          ),
          Expanded(
            child: _NavItem(icon: Icons.search, label: 'Пошук'),
          ),
          Expanded(
            child: _NavItem(icon: Icons.bar_chart, label: 'Аналітика'),
          ),
          Expanded(
            child: _NavItem(icon: Icons.settings, label: 'Налаштування'),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, required this.label, this.isActive = false});

  final IconData icon;
  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? const Color(0xFF4BA2FF) : const Color(0xFF95A4BE);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 29),
        const SizedBox(height: 5),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class VaultItem {
  const VaultItem({
    required this.title,
    required this.usageText,
    required this.percentLabel,
    required this.progress,
    required this.progressColor,
    required this.icon,
    this.hasWarning = false,
  });

  final String title;
  final String usageText;
  final String percentLabel;
  final double progress;
  final Color progressColor;
  final IconData icon;
  final bool hasWarning;
}

class RecentFileItem {
  const RecentFileItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    this.badgeIcon,
    this.badgeColor,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final IconData? badgeIcon;
  final Color? badgeColor;
}

class AddVaultOption {
  const AddVaultOption({
    required this.title,
    required this.icon,
    this.iconColor,
    this.iconBackground,
  });

  final String title;
  final IconData icon;
  final Color? iconColor;
  final Color? iconBackground;
}

class FileActionOption {
  const FileActionOption({
    required this.icon,
    required this.label,
    this.color,
  });

  final IconData icon;
  final String label;
  final Color? color;
}
