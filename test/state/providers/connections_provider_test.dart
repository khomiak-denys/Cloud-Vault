import 'package:flutter_test/flutter_test.dart';

import 'package:cloud_vault/api/api_exception.dart';
import 'package:cloud_vault/api/api_repository.dart';
import 'package:cloud_vault/state/providers/connections_provider.dart';

import '../../support/fake_api_client.dart';

void main() {
  group('ConnectionsProvider', () {
    late FakeApiClient client;
    late ApiRepository repository;
    late ConnectionsProvider provider;

    setUp(() {
      client = FakeApiClient();
      repository = ApiRepository(client);
      provider = ConnectionsProvider(
        repository: repository,
        ttl: const Duration(minutes: 2),
      );

      client.getHandlers['/me'] = (_, _) => <String, dynamic>{
        'uid': 'u1',
        'email': 'user@example.com',
        'name': 'User',
      };
      client.getHandlers['/connections'] = (_, _) => <String, dynamic>{
        'items': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'c1',
            'providerId': 'google-drive',
            'providerName': 'Google Drive',
            'usedBytes': 100,
            'totalBytes': 400,
          },
        ],
      };
      client.getHandlers['/analytics/storage-usage'] = (_, _) =>
          <String, dynamic>{
            'totals': <String, dynamic>{'usedBytes': 250, 'totalBytes': 500},
            'items': <Map<String, dynamic>>[
              <String, dynamic>{
                'connectionId': 'c1',
                'providerId': 'google-drive',
                'providerName': 'Google Drive',
                'usedBytes': 250,
                'totalBytes': 500,
              },
            ],
          };
    });

    tearDown(() {
      client.close();
    });

    test(
      'ensureLoaded() does not call API repeatedly while TTL is fresh',
      () async {
        await provider.ensureLoaded();
        await provider.ensureLoaded();

        expect(_getCalls(client, '/me'), 1);
        expect(_getCalls(client, '/connections'), 1);
        expect(_getCalls(client, '/analytics/storage-usage'), 1);
        expect(provider.connections, hasLength(1));
        expect(provider.totalUsedBytes, 250);
        expect(provider.totalBytes, 500);
      },
    );

    test('forceRefresh triggers API call even when state is fresh', () async {
      await provider.ensureLoaded();
      await provider.ensureLoaded(forceRefresh: true);

      expect(_getCalls(client, '/me'), 2);
      expect(_getCalls(client, '/connections'), 2);
      expect(_getCalls(client, '/analytics/storage-usage'), 2);
    });

    test('error keeps previous data and sets error message', () async {
      await provider.ensureLoaded();
      client.getHandlers['/connections'] = (_, _) {
        throw ApiException('boom', statusCode: 500);
      };

      await expectLater(
        provider.ensureLoaded(forceRefresh: true),
        throwsA(isA<ApiException>()),
      );

      expect(provider.connections, hasLength(1));
      expect(provider.totalUsedBytes, 250);
      expect(provider.error, contains('API error'));
      expect(provider.isLoading, isFalse);
    });

    test('reset clears all state', () async {
      await provider.ensureLoaded();

      provider.reset();

      expect(provider.me, isNull);
      expect(provider.connections, isEmpty);
      expect(provider.profileUsedBytes, 0);
      expect(provider.totalUsedBytes, 0);
      expect(provider.totalBytes, 0);
      expect(provider.lastLoadedAt, isNull);
      expect(provider.error, isNull);
      expect(provider.isLoading, isFalse);
      expect(provider.isStale, isTrue);
    });
  });
}

int _getCalls(FakeApiClient client, String path) {
  return client.calls
      .where((call) => call.method == 'GET' && call.path == path)
      .length;
}
