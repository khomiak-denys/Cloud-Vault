import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:cloud_vault/api/api_exception.dart';
import 'package:cloud_vault/api/api_repository.dart';
import 'package:cloud_vault/state/providers/favorites_provider.dart';

import '../../support/fake_api_client.dart';

void main() {
  group('FavoritesProvider', () {
    late FakeApiClient client;
    late ApiRepository repository;
    late FavoritesProvider provider;

    setUp(() {
      client = FakeApiClient();
      repository = ApiRepository(client);
      provider = FavoritesProvider(
        repository: repository,
        ttl: const Duration(minutes: 2),
      );

      client.getHandlers['/files/favorites'] = (_, _) => <String, dynamic>{
        'items': <Map<String, dynamic>>[
          <String, dynamic>{
            'fileId': 'f1',
            'connectionId': 'c1',
            'fileName': 'doc.pdf',
            'providerId': 'google-drive',
            'providerName': 'Google Drive',
            'sizeBytes': 1000,
            'updatedAt': '2026-04-01T00:00:00Z',
            'isFavorite': true,
            'kind': 'file',
            'path': '/root/doc.pdf',
            'displayPath': '/root/doc.pdf',
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

        expect(_getCalls(client, '/files/favorites'), 1);
        expect(provider.favoriteFiles, hasLength(1));
      },
    );

    test('forceRefresh triggers API call even when state is fresh', () async {
      await provider.ensureLoaded();
      await provider.ensureLoaded(forceRefresh: true);

      expect(_getCalls(client, '/files/favorites'), 2);
    });

    test('error keeps previous data and sets error message', () async {
      await provider.ensureLoaded();
      client.getHandlers['/files/favorites'] = (_, _) {
        throw ApiException('favorites failed', statusCode: 502);
      };

      await expectLater(
        provider.ensureLoaded(forceRefresh: true),
        throwsA(isA<ApiException>()),
      );

      expect(provider.favoriteFiles, hasLength(1));
      expect(provider.error, contains('API error'));
      expect(provider.isLoading, isFalse);
    });

    test('reset clears all state', () async {
      await provider.ensureLoaded();

      provider.reset();

      expect(provider.favoriteFiles, isEmpty);
      expect(provider.lastLoadedAt, isNull);
      expect(provider.error, isNull);
      expect(provider.isLoading, isFalse);
      expect(provider.isStale, isTrue);
    });

    test(
      'reset() during in-flight load ignores stale result and allows fresh load',
      () async {
        final delayedClient = FakeApiClient();
        final delayedRepository = _DelayedFavoritesRepository(delayedClient);
        final delayedProvider = FavoritesProvider(
          repository: delayedRepository,
          ttl: const Duration(minutes: 2),
        );
        addTearDown(delayedClient.close);

        final firstLoad = delayedProvider.ensureLoaded(forceRefresh: true);
        await Future<void>.delayed(Duration.zero);
        delayedProvider.reset();
        final secondLoad = delayedProvider.ensureLoaded(forceRefresh: true);

        expect(delayedRepository.favoriteCalls, 2);

        delayedRepository.complete(
          index: 0,
          files: <ApiFileItem>[
            ApiFileItem(
              id: 'old-f1',
              connectionId: 'c1',
              name: 'old.pdf',
              path: '/root/old.pdf',
              displayPath: '/root/old.pdf',
              sizeBytes: 10,
              modifiedAt: DateTime.utc(2026, 4, 1),
              providerId: 'google-drive',
              providerName: 'Google Drive',
              isFavorite: true,
              kind: 'file',
            ),
          ],
        );
        delayedRepository.complete(
          index: 1,
          files: <ApiFileItem>[
            ApiFileItem(
              id: 'new-f1',
              connectionId: 'c1',
              name: 'new.pdf',
              path: '/root/new.pdf',
              displayPath: '/root/new.pdf',
              sizeBytes: 20,
              modifiedAt: DateTime.utc(2026, 4, 2),
              providerId: 'google-drive',
              providerName: 'Google Drive',
              isFavorite: true,
              kind: 'file',
            ),
          ],
        );

        await Future.wait<void>(<Future<void>>[firstLoad, secondLoad]);

        expect(delayedProvider.favoriteFiles.single.id, 'new-f1');
      },
    );
  });
}

int _getCalls(FakeApiClient client, String path) {
  return client.calls
      .where((call) => call.method == 'GET' && call.path == path)
      .length;
}

class _DelayedFavoritesRepository extends ApiRepository {
  // ignore: use_super_parameters
  _DelayedFavoritesRepository(FakeApiClient client) : super(client);

  int favoriteCalls = 0;

  final List<Completer<List<ApiFileItem>>> _favoriteCompleters =
      <Completer<List<ApiFileItem>>>[
        Completer<List<ApiFileItem>>(),
        Completer<List<ApiFileItem>>(),
      ];

  @override
  Future<List<ApiFileItem>> favoriteFiles({
    int? pageSize,
    String? cursor,
    String? connectionId,
    String? providerId,
  }) {
    final completer = _favoriteCompleters[favoriteCalls];
    favoriteCalls += 1;
    return completer.future;
  }

  void complete({required int index, required List<ApiFileItem> files}) {
    _favoriteCompleters[index].complete(files);
  }
}
