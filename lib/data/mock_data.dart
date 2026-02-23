import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/add_vault_option.dart';
import '../models/recent_file_item.dart';
import '../models/storage_usage_item.dart';
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
    storageName: 'Google Drive',
    sizeLabel: '5.2 МБ',
    modifiedLabel: '20 лютого 2026 р. о 11:15',
    pathLabel: '/Презентації',
    badgeIcon: Icons.star,
    badgeColor: Color(0xFFF6C215),
  ),
  RecentFileItem(
    title: 'Фото з відпустки',
    subtitle: 'Google Drive  •  15 лют.',
    icon: Icons.folder_outlined,
    iconColor: Color(0xFF2D89FF),
    storageName: 'Google Drive',
    sizeLabel: '74.8 МБ',
    modifiedLabel: '15 лютого 2026 р. о 09:42',
    pathLabel: '/Фото/Відпустка',
  ),
  RecentFileItem(
    title: 'Звіт_лютий_2026.xlsx',
    subtitle: 'OneDrive  •  Вчора  •  1.3 МБ',
    icon: Icons.description_outlined,
    iconColor: Color(0xFFFF7A00),
    storageName: 'OneDrive',
    sizeLabel: '1.3 МБ',
    modifiedLabel: '22 лютого 2026 р. о 16:08',
    pathLabel: '/Звіти/2026',
    badgeIcon: Icons.share_outlined,
    badgeColor: Color(0xFF2D89FF),
  ),
  RecentFileItem(
    title: 'Портфоліо.pdf',
    subtitle: 'Dropbox  •  5 дн. тому  •  8.7 МБ',
    icon: Icons.description_outlined,
    iconColor: Color(0xFFFF7A00),
    storageName: 'Dropbox',
    sizeLabel: '8.7 МБ',
    modifiedLabel: '18 лютого 2026 р. о 14:30',
    pathLabel: '/Документи',
  ),
  RecentFileItem(
    title: 'Відео_презентація.mp4',
    subtitle: 'Google Drive  •  10 лют.  •  125 МБ',
    icon: Icons.videocam_outlined,
    iconColor: Color(0xFFA84DFF),
    storageName: 'Google Drive',
    sizeLabel: '125 МБ',
    modifiedLabel: '10 лютого 2026 р. о 02:00',
    pathLabel: '/Медіа',
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

const storageUsageItems = <StorageUsageItem>[
  StorageUsageItem(
    id: 'gdrive-1',
    name: 'Google Drive',
    color: Color(0xFF4285F4),
    totalBytes: 15 * 1024 * 1024 * 1024,
    usedBytes: 12.3 * 1024 * 1024 * 1024,
  ),
  StorageUsageItem(
    id: 'onedrive-1',
    name: 'OneDrive',
    color: Color(0xFF0078D4),
    totalBytes: 5 * 1024 * 1024 * 1024,
    usedBytes: 2.1 * 1024 * 1024 * 1024,
  ),
  StorageUsageItem(
    id: 'dropbox-1',
    name: 'Dropbox',
    color: Color(0xFF0061FF),
    totalBytes: 2 * 1024 * 1024 * 1024,
    usedBytes: 1.8 * 1024 * 1024 * 1024,
  ),
  StorageUsageItem(
    id: 'icloud-1',
    name: 'iCloud',
    color: Color(0xFF3693F3),
    totalBytes: 5 * 1024 * 1024 * 1024,
    usedBytes: 0.8 * 1024 * 1024 * 1024,
  ),
];

String formatBytes(double bytes) {
  if (bytes == 0) return '0 Б';
  const k = 1024.0;
  const sizes = ['Б', 'КБ', 'МБ', 'ГБ', 'ТБ'];
  final i = (bytes == 0 ? 0 : (math.log(bytes) / math.log(k)).floor()).clamp(
    0,
    4,
  );
  final converted = bytes / (math.pow(k, i) as double);
  final rounded = converted.toStringAsFixed(2);
  return '${double.parse(rounded)} ${sizes[i]}';
}
