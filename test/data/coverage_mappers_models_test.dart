import 'package:cloud_vault/api/api_repository.dart';
import 'package:cloud_vault/data/api_mappers.dart';
import 'package:cloud_vault/models/file_action_option.dart';
import 'package:cloud_vault/models/recent_file_item.dart';
import 'package:cloud_vault/models/storage_usage_item.dart';
import 'package:cloud_vault/models/vault_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('api_mappers', () {
    test('mapConnectionToVaultItem maps provider metadata and warning state', () {
      final ApiConnection connection = ApiConnection(
        id: 'c1',
        providerId: 'google-drive',
        providerName: 'Google Drive',
        usedBytes: 90,
        totalBytes: 100,
      );

      final VaultItem item = mapConnectionToVaultItem(connection);

      expect(item.id, 'c1');
      expect(item.providerId, 'google-drive');
      expect(item.title, 'Google Drive');
      expect(item.progress, 0.9);
      expect(item.percentLabel, '90%');
      expect(item.hasWarning, isTrue);
      expect(item.icon, Icons.folder);
      expect(item.progressColor, const Color(0xFF4285F4));
    });

    test('mapConnectionToVaultItem maps known and fallback providers', () {
      final Map<String, IconData> expectedIcons = <String, IconData>{
        'dropbox': Icons.inventory_2,
        'onedrive': Icons.cloud,
        'mega': Icons.circle,
        'unknown-provider': Icons.cloud_outlined,
      };

      final Map<String, Color> expectedColors = <String, Color>{
        'dropbox': const Color(0xFF0061FF),
        'onedrive': const Color(0xFF0078D4),
        'mega': const Color(0xFFE61D21),
        'unknown-provider': const Color(0xFF4A90FF),
      };

      for (final String providerId in expectedIcons.keys) {
        final VaultItem item = mapConnectionToVaultItem(
          ApiConnection(
            id: providerId,
            providerId: providerId,
            providerName: providerId,
            usedBytes: 10,
            totalBytes: 20,
          ),
        );

        expect(item.icon, expectedIcons[providerId]);
        expect(item.progressColor, expectedColors[providerId]);
      }
    });

    test('mapConnectionToStorageUsageItem maps bytes and color', () {
      final StorageUsageItem usage = mapConnectionToStorageUsageItem(
        const ApiConnection(
          id: 'c2',
          providerId: 'mega',
          providerName: 'MEGA',
          usedBytes: 10,
          totalBytes: 50,
        ),
      );

      expect(usage.id, 'c2');
      expect(usage.name, 'MEGA');
      expect(usage.totalBytes, 50);
      expect(usage.usedBytes, 10);
      expect(usage.color, const Color(0xFFE61D21));
    });

    test('mapApiFileToRecentFileItem maps image/video/folder/default icon branches', () {
      final DateTime modifiedAt = DateTime.parse('2026-01-01T00:00:00.000Z');

      final RecentFileItem image = mapApiFileToRecentFileItem(
        ApiFileItem(
          id: 'f1',
          connectionId: 'c1',
          name: 'photo.unknown',
          path: '/photo.unknown',
          displayPath: '/photo.unknown',
          sizeBytes: 100,
          modifiedAt: modifiedAt,
          providerId: 'dropbox',
          providerName: 'Dropbox',
          isFavorite: true,
          kind: 'file',
          mimeType: 'image/jpeg',
        ),
      );

      final RecentFileItem video = mapApiFileToRecentFileItem(
        ApiFileItem(
          id: 'f2',
          connectionId: 'c1',
          name: 'movie.mp4',
          path: '/movie.mp4',
          displayPath: '/movie.mp4',
          sizeBytes: 200,
          modifiedAt: modifiedAt,
          providerId: 'dropbox',
          providerName: 'Dropbox',
          isFavorite: false,
          kind: 'file',
          mimeType: 'video/mp4',
        ),
      );

      final RecentFileItem folder = mapApiFileToRecentFileItem(
        ApiFileItem(
          id: 'f3',
          connectionId: 'c1',
          name: 'docs',
          path: '/docs',
          displayPath: '/docs',
          sizeBytes: 0,
          modifiedAt: modifiedAt,
          providerId: 'dropbox',
          providerName: 'Dropbox',
          isFavorite: false,
          kind: 'folder',
          mimeType: null,
        ),
      );

      final RecentFileItem defaultFile = mapApiFileToRecentFileItem(
        ApiFileItem(
          id: 'f4',
          connectionId: 'c1',
          name: 'report.bin',
          path: '/report.bin',
          displayPath: '/report.bin',
          sizeBytes: 1,
          modifiedAt: modifiedAt,
          providerId: 'dropbox',
          providerName: 'Dropbox',
          isFavorite: false,
          kind: 'file',
          mimeType: null,
        ),
      );

      expect(image.icon, Icons.image_outlined);
      expect(image.iconColor, const Color(0xFF22C55E));
      expect(image.badgeIcon, Icons.star);
      expect(image.badgeColor, const Color(0xFFF6C215));

      expect(video.icon, Icons.videocam_outlined);
      expect(video.iconColor, const Color(0xFFA84DFF));

      expect(folder.icon, Icons.folder_outlined);
      expect(folder.iconColor, const Color(0xFF2D89FF));

      expect(defaultFile.icon, Icons.description_outlined);
      expect(defaultFile.iconColor, const Color(0xFFFF7A00));
    });
  });

  group('models', () {
    test('StorageUsageItem computes freeBytes and usagePercent', () {
      const StorageUsageItem item = StorageUsageItem(
        id: 's1',
        name: 'Drive',
        color: Colors.blue,
        totalBytes: 100,
        usedBytes: 25,
      );

      expect(item.freeBytes, 75);
      expect(item.usagePercent, 25);
    });

    test('FileActionOption stores fields', () {
      const FileActionOption option = FileActionOption(
        icon: Icons.share_outlined,
        label: 'Share',
        actionId: 'share',
        color: Colors.green,
      );

      expect(option.icon, Icons.share_outlined);
      expect(option.label, 'Share');
      expect(option.actionId, 'share');
      expect(option.color, Colors.green);
    });

    test('VaultItem stores fields', () {
      const VaultItem item = VaultItem(
        id: 'v1',
        providerId: 'dropbox',
        title: 'Dropbox',
        usageText: '10 MB / 100 MB',
        percentLabel: '10%',
        progress: 0.1,
        progressColor: Colors.blue,
        icon: Icons.cloud,
        hasWarning: false,
      );

      expect(item.id, 'v1');
      expect(item.providerId, 'dropbox');
      expect(item.title, 'Dropbox');
      expect(item.usageText, '10 MB / 100 MB');
      expect(item.percentLabel, '10%');
      expect(item.progress, 0.1);
      expect(item.progressColor, Colors.blue);
      expect(item.icon, Icons.cloud);
      expect(item.hasWarning, isFalse);
    });
  });
}
