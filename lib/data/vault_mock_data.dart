import 'package:flutter/material.dart';

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
