import 'package:flutter/material.dart';

import '../models/add_vault_option.dart';
import '../models/recent_file_item.dart';
import '../models/vault_item.dart';

const vaultItems = <VaultItem>[
  VaultItem(
    title: 'Google Drive',
    usageText: '12.3 ГБ / 15 ГБ',
    percentLabel: '82%',
    progress: 0.82,
    progressColor: Color(0xFF4A90FF),
    icon: Icons.folder,
  ),
  VaultItem(
    title: 'OneDrive',
    usageText: '2.1 ГБ / 5 ГБ',
    percentLabel: '42%',
    progress: 0.42,
    progressColor: Color(0xFF1B8FE7),
    icon: Icons.cloud,
  ),
  VaultItem(
    title: 'Dropbox',
    usageText: '1.8 ГБ / 2 ГБ',
    percentLabel: '90%',
    progress: 0.90,
    progressColor: Color(0xFFFF7B1B),
    icon: Icons.inventory_2,
    hasWarning: true,
  ),
  VaultItem(
    title: 'iCloud',
    usageText: '819.2 МБ / 5 ГБ',
    percentLabel: '16%',
    progress: 0.16,
    progressColor: Color(0xFF4AA2FF),
    icon: Icons.cloud,
  ),
];

const recentFileItems = <RecentFileItem>[
  RecentFileItem(
    title: 'Презентація проекту.pptx',
    subtitle: 'Google Drive  •  3 дн. тому  •  5.2 МБ',
    icon: Icons.description_outlined,
    iconColor: Color(0xFFFF7A00),
    badgeIcon: Icons.star,
    badgeColor: Color(0xFFF6C215),
  ),
  RecentFileItem(
    title: 'Фото з відпустки',
    subtitle: 'Google Drive  •  15 лют.',
    icon: Icons.folder_outlined,
    iconColor: Color(0xFF2D89FF),
  ),
  RecentFileItem(
    title: 'Звіт_лютий_2026.xlsx',
    subtitle: 'OneDrive  •  Вчора  •  1.3 МБ',
    icon: Icons.description_outlined,
    iconColor: Color(0xFFFF7A00),
    badgeIcon: Icons.share_outlined,
    badgeColor: Color(0xFF2D89FF),
  ),
  RecentFileItem(
    title: 'Портфоліо.pdf',
    subtitle: 'Dropbox  •  5 дн. тому  •  8.7 МБ',
    icon: Icons.description_outlined,
    iconColor: Color(0xFFFF7A00),
  ),
  RecentFileItem(
    title: 'Відео_презентація.mp4',
    subtitle: 'Google Drive  •  10 лют.  •  125 МБ',
    icon: Icons.videocam_outlined,
    iconColor: Color(0xFFA84DFF),
  ),
];

const addVaultOptions = <AddVaultOption>[
  AddVaultOption(title: 'Google Drive', icon: Icons.folder),
  AddVaultOption(title: 'OneDrive', icon: Icons.cloud),
  AddVaultOption(title: 'Dropbox', icon: Icons.inventory_2),
  AddVaultOption(title: 'iCloud', icon: Icons.cloud),
  AddVaultOption(
    title: 'MEGA',
    icon: Icons.circle,
    iconColor: Color(0xFFE61D21),
    iconBackground: Color(0xFF34203A),
  ),
  AddVaultOption(title: 'Box', icon: Icons.inbox),
];
