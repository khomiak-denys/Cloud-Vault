import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../api/api_repository.dart';
import '../models/recent_file_item.dart';
import '../models/storage_usage_item.dart';
import '../models/vault_item.dart';
import 'storage_formatters.dart';

VaultItem mapConnectionToVaultItem(ApiConnection connection) {
  final total = connection.totalBytes;
  final used = connection.usedBytes;
  final progress = total <= 0 ? 0.0 : (used / total).clamp(0.0, 1.0);
  final percent = (progress * 100).round();

  return VaultItem(
    id: connection.id,
    providerId: connection.providerId,
    title: connection.providerName,
    usageText: '${formatBytes(used)} / ${formatBytes(total)}',
    percentLabel: '$percent%',
    progress: progress,
    progressColor: _providerColor(connection.providerId),
    icon: _providerIcon(connection.providerId),
    hasWarning: percent >= 90,
  );
}

StorageUsageItem mapConnectionToStorageUsageItem(ApiConnection connection) {
  return StorageUsageItem(
    id: connection.id,
    name: connection.providerName,
    color: _providerColor(connection.providerId),
    totalBytes: connection.totalBytes,
    usedBytes: connection.usedBytes,
  );
}

RecentFileItem mapApiFileToRecentFileItem(ApiFileItem file) {
  final formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(file.modifiedAt);
  final sizeLabel = formatBytes(file.sizeBytes);

  return RecentFileItem(
    id: file.id,
    connectionId: file.connectionId,
    title: file.name,
    subtitle: '${file.providerName} - $formattedDate - $sizeLabel',
    icon: _fileIcon(file.name, file.mimeType, file.kind),
    iconColor: _fileIconColor(file.name, file.mimeType, file.kind),
    storageName: file.providerName,
    sizeLabel: sizeLabel,
    modifiedLabel: formattedDate,
    pathLabel: file.path,
    isFavorite: file.isFavorite,
    kind: file.kind,
    mimeType: file.mimeType,
    badgeIcon: file.isFavorite ? Icons.star : null,
    badgeColor: file.isFavorite ? const Color(0xFFF6C215) : null,
  );
}

IconData _providerIcon(String providerId) {
  switch (providerId.toLowerCase()) {
    case 'google-drive':
      return Icons.folder;
    case 'dropbox':
      return Icons.inventory_2;
    case 'onedrive':
      return Icons.cloud;
    case 'mega':
      return Icons.circle;
    default:
      return Icons.cloud_outlined;
  }
}

Color _providerColor(String providerId) {
  switch (providerId.toLowerCase()) {
    case 'google-drive':
      return const Color(0xFF4285F4);
    case 'dropbox':
      return const Color(0xFF0061FF);
    case 'onedrive':
      return const Color(0xFF0078D4);
    case 'mega':
      return const Color(0xFFE61D21);
    default:
      return const Color(0xFF4A90FF);
  }
}

IconData _fileIcon(String name, String? mimeType, String kind) {
  if (kind.toLowerCase() == 'folder') return Icons.folder_outlined;

  final ext = _extension(name);
  if (mimeType != null && mimeType.startsWith('image/')) {
    return Icons.image_outlined;
  }
  if (mimeType != null && mimeType.startsWith('video/')) {
    return Icons.videocam_outlined;
  }

  if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext)) {
    return Icons.image_outlined;
  }
  if (['mp4', 'mov', 'avi', 'mkv'].contains(ext)) {
    return Icons.videocam_outlined;
  }
  return Icons.description_outlined;
}

Color _fileIconColor(String name, String? mimeType, String kind) {
  final icon = _fileIcon(name, mimeType, kind);
  if (icon == Icons.image_outlined) return const Color(0xFF22C55E);
  if (icon == Icons.videocam_outlined) return const Color(0xFFA84DFF);
  if (icon == Icons.folder_outlined) return const Color(0xFF2D89FF);
  return const Color(0xFFFF7A00);
}

String _extension(String fileName) {
  final parts = fileName.toLowerCase().split('.');
  return parts.length > 1 ? parts.last : '';
}
