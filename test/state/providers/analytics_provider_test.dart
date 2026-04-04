import 'package:flutter_test/flutter_test.dart';

import 'package:cloud_vault/api/api_exception.dart';
import 'package:cloud_vault/api/api_repository.dart';
import 'package:cloud_vault/state/providers/analytics_provider.dart';

import '../../support/fake_api_client.dart';

void main() {
  group('AnalyticsProvider', () {
    late FakeApiClient client;
    late ApiRepository repository;
    late AnalyticsProvider provider;

    setUp(() {
      client = FakeApiClient();
      repository = ApiRepository(client);
      provider = AnalyticsProvider(
        repository: repository,
        ttl: const Duration(minutes: 3),
      );

      client.getHandlers['/analytics/storage-usage'] = (_, _) =>
          <String, dynamic>{
            'totals': <String, dynamic>{'usedBytes': 100, 'totalBytes': 400},
            'items': <Map<String, dynamic>>[
              <String, dynamic>{
                'connectionId': 'c1',
                'providerId': 'google-drive',
                'providerName': 'Google Drive',
                'usedBytes': 100,
                'totalBytes': 400,
              },
            ],
          };
      client.getHandlers['/analytics/storage-optimization-recommendations'] =
          (_, _) => <String, dynamic>{
            'items': <Map<String, dynamic>>[
              <String, dynamic>{
                'title': 'Tip',
                'description': 'Delete old backups',
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

        expect(_getCalls(client, '/analytics/storage-usage'), 1);
        expect(
          _getCalls(client, '/analytics/storage-optimization-recommendations'),
          1,
        );
        expect(provider.usageItems, hasLength(1));
        expect(provider.recommendations, hasLength(1));
      },
    );

    test('forceRefresh triggers API call even when state is fresh', () async {
      await provider.ensureLoaded();
      await provider.ensureLoaded(forceRefresh: true);

      expect(_getCalls(client, '/analytics/storage-usage'), 2);
      expect(
        _getCalls(client, '/analytics/storage-optimization-recommendations'),
        2,
      );
    });

    test('error keeps previous data and sets error message', () async {
      await provider.ensureLoaded();
      client.getHandlers['/analytics/storage-optimization-recommendations'] =
          (_, _) {
            throw ApiException('recommendations failed', statusCode: 503);
          };

      await expectLater(
        provider.ensureLoaded(forceRefresh: true),
        throwsA(isA<ApiException>()),
      );

      expect(provider.usageItems, hasLength(1));
      expect(provider.recommendations, hasLength(1));
      expect(provider.error, contains('API error'));
      expect(provider.isLoading, isFalse);
    });

    test('reset clears all state', () async {
      await provider.ensureLoaded();

      provider.reset();

      expect(provider.usageItems, isEmpty);
      expect(provider.recommendations, isEmpty);
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
