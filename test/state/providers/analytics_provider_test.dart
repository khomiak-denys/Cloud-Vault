import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:cloud_vault/api/api_exception.dart';
import 'package:cloud_vault/api/api_repository.dart';
import 'package:cloud_vault/state/providers/analytics_provider.dart';

import '../../support/fake_api_client.dart';

typedef _RecommendationsCompleter = Completer<List<ApiStorageRecommendation>>;

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

    test(
      'reset() during in-flight load ignores stale result and allows fresh load',
      () async {
        final delayedClient = FakeApiClient();
        final delayedRepository = _DelayedAnalyticsRepository(delayedClient);
        final delayedProvider = AnalyticsProvider(
          repository: delayedRepository,
          ttl: const Duration(minutes: 3),
        );
        addTearDown(delayedClient.close);

        final firstLoad = delayedProvider.ensureLoaded(forceRefresh: true);
        await Future<void>.delayed(Duration.zero);
        delayedProvider.reset();
        final secondLoad = delayedProvider.ensureLoaded(forceRefresh: true);

        expect(delayedRepository.usageCalls, 2);
        expect(delayedRepository.recommendationsCalls, 2);

        delayedRepository.complete(
          index: 0,
          usage: const <ApiConnection>[
            ApiConnection(
              id: 'old-c1',
              providerId: 'google-drive',
              providerName: 'Old Drive',
              usedBytes: 1,
              totalBytes: 2,
            ),
          ],
          recommendations: const <ApiStorageRecommendation>[
            ApiStorageRecommendation(title: 'Old tip', body: 'Old body'),
          ],
        );
        delayedRepository.complete(
          index: 1,
          usage: const <ApiConnection>[
            ApiConnection(
              id: 'new-c1',
              providerId: 'google-drive',
              providerName: 'New Drive',
              usedBytes: 3,
              totalBytes: 4,
            ),
          ],
          recommendations: const <ApiStorageRecommendation>[
            ApiStorageRecommendation(title: 'New tip', body: 'New body'),
          ],
        );

        await Future.wait<void>(<Future<void>>[firstLoad, secondLoad]);

        expect(delayedProvider.usageItems.single.id, 'new-c1');
        expect(delayedProvider.recommendations.single.title, 'New tip');
      },
    );

    test(
      'invalidate() during in-flight load resets loading state and ignores stale result',
      () async {
        final delayedClient = FakeApiClient();
        final delayedRepository = _DelayedAnalyticsRepository(delayedClient);
        final delayedProvider = AnalyticsProvider(
          repository: delayedRepository,
          ttl: const Duration(minutes: 3),
        );
        addTearDown(delayedClient.close);

        final firstLoad = delayedProvider.ensureLoaded(forceRefresh: true);
        await Future<void>.delayed(Duration.zero);
        expect(delayedProvider.isLoading, isTrue);

        delayedProvider.invalidate();

        expect(delayedProvider.isLoading, isFalse);
        expect(delayedProvider.error, isNull);

        delayedRepository.complete(
          index: 0,
          usage: const <ApiConnection>[
            ApiConnection(
              id: 'old-c1',
              providerId: 'google-drive',
              providerName: 'Old Drive',
              usedBytes: 1,
              totalBytes: 2,
            ),
          ],
          recommendations: const <ApiStorageRecommendation>[
            ApiStorageRecommendation(title: 'Old tip', body: 'Old body'),
          ],
        );
        await firstLoad;

        expect(delayedProvider.usageItems, isEmpty);
        expect(delayedProvider.recommendations, isEmpty);
      },
    );
  });
}

int _getCalls(FakeApiClient client, String path) {
  return client.calls
      .where((call) => call.method == 'GET' && call.path == path)
      .length;
}

class _DelayedAnalyticsRepository extends ApiRepository {
  // ignore: use_super_parameters
  _DelayedAnalyticsRepository(FakeApiClient client) : super(client);

  int usageCalls = 0;
  int recommendationsCalls = 0;

  final List<Completer<List<ApiConnection>>> _usageCompleters =
      <Completer<List<ApiConnection>>>[
        Completer<List<ApiConnection>>(),
        Completer<List<ApiConnection>>(),
      ];
  final List<_RecommendationsCompleter> _recommendationsCompleters =
      <_RecommendationsCompleter>[
        Completer<List<ApiStorageRecommendation>>(),
        Completer<List<ApiStorageRecommendation>>(),
      ];

  @override
  Future<List<ApiConnection>> storageUsage() {
    final completer = _usageCompleters[usageCalls];
    usageCalls += 1;
    return completer.future;
  }

  @override
  Future<List<ApiStorageRecommendation>> recommendations() {
    final completer = _recommendationsCompleters[recommendationsCalls];
    recommendationsCalls += 1;
    return completer.future;
  }

  void complete({
    required int index,
    required List<ApiConnection> usage,
    required List<ApiStorageRecommendation> recommendations,
  }) {
    _usageCompleters[index].complete(usage);
    _recommendationsCompleters[index].complete(recommendations);
  }
}
