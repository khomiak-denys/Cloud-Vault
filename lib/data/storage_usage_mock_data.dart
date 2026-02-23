import 'package:flutter/material.dart';

import '../models/storage_usage_item.dart';

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
