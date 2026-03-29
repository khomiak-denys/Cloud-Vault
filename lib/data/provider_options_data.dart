import 'package:flutter/material.dart';

import '../models/add_vault_option.dart';

const addVaultOptions = <AddVaultOption>[
  AddVaultOption(
    providerId: 'google-drive',
    title: 'Google Drive',
    icon: Icons.folder,
  ),
  AddVaultOption(
    providerId: 'onedrive',
    title: 'OneDrive',
    icon: Icons.cloud,
  ),
  AddVaultOption(
    providerId: 'dropbox',
    title: 'Dropbox',
    icon: Icons.inventory_2,
  ),
  AddVaultOption(
    providerId: 'mega',
    title: 'MEGA',
    icon: Icons.circle,
    iconColor: Color(0xFFE61D21),
    iconBackground: Color(0xFF34203A),
  ),
];
