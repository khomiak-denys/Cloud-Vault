import 'package:flutter/material.dart';

import '../models/add_vault_option.dart';

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
