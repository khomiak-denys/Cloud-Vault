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

  });
}
