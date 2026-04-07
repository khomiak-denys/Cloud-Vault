import 'dart:async';

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

    test(
      'reset() during in-flight load ignores stale result and allows fresh load',
      () async {
        final delayedClient = FakeApiClient();
        final delayedRepository = _DelayedConnectionsRepository(delayedClient);
        final delayedProvider = ConnectionsProvider(
          repository: delayedRepository,
          ttl: const Duration(minutes: 2),
        );
        addTearDown(delayedClient.close);

        final firstLoad = delayedProvider.ensureLoaded(forceRefresh: true);
        await Future<void>.delayed(Duration.zero);
        delayedProvider.reset();
        final secondLoad = delayedProvider.ensureLoaded(forceRefresh: true);

        expect(delayedRepository.meCalls, 2);
        expect(delayedRepository.connectionsCalls, 2);
        expect(delayedRepository.usageCalls, 2);

        delayedRepository.complete(
          index: 0,
          me: const ApiUser(uid: 'old', email: 'old@x', name: 'Old User'),
          connections: const <ApiConnection>[
            ApiConnection(
              id: 'old-c1',
              providerId: 'google-drive',
              providerName: 'Old Drive',
              usedBytes: 1,
              totalBytes: 2,
            ),
          ],
          usageReport: const ApiStorageUsageReport(
            connections: <ApiConnection>[
              ApiConnection(
                id: 'old-c1',
                providerId: 'google-drive',
                providerName: 'Old Drive',
                usedBytes: 1,
                totalBytes: 2,
              ),
            ],
            usedBytes: 1,
            totalBytes: 2,
          ),
        );
        delayedRepository.complete(
          index: 1,
          me: const ApiUser(uid: 'new', email: 'new@x', name: 'New User'),
          connections: const <ApiConnection>[
            ApiConnection(
              id: 'new-c1',
              providerId: 'google-drive',
              providerName: 'New Drive',
              usedBytes: 3,
              totalBytes: 4,
            ),
          ],
          usageReport: const ApiStorageUsageReport(
            connections: <ApiConnection>[
              ApiConnection(
                id: 'new-c1',
                providerId: 'google-drive',
                providerName: 'New Drive',
                usedBytes: 3,
                totalBytes: 4,
              ),
            ],
            usedBytes: 3,
            totalBytes: 4,
          ),
        );

        await Future.wait<void>(<Future<void>>[firstLoad, secondLoad]);

        expect(delayedProvider.me?.uid, 'new');
        expect(delayedProvider.connections.single.id, 'new-c1');
        expect(delayedProvider.totalUsedBytes, 3);
      },
    );
  });
}

int _getCalls(FakeApiClient client, String path) {
  return client.calls
      .where((call) => call.method == 'GET' && call.path == path)
      .length;
}

class _DelayedConnectionsRepository extends ApiRepository {
  // ignore: use_super_parameters
  _DelayedConnectionsRepository(FakeApiClient client) : super(client);

  int meCalls = 0;
  int connectionsCalls = 0;
  int usageCalls = 0;

  final List<Completer<ApiUser?>> _meCompleters = <Completer<ApiUser?>>[
    Completer<ApiUser?>(),
    Completer<ApiUser?>(),
  ];
  final List<Completer<List<ApiConnection>>> _connectionsCompleters =
      <Completer<List<ApiConnection>>>[
        Completer<List<ApiConnection>>(),
        Completer<List<ApiConnection>>(),
      ];
  final List<Completer<ApiStorageUsageReport>> _usageCompleters =
      <Completer<ApiStorageUsageReport>>[
        Completer<ApiStorageUsageReport>(),
        Completer<ApiStorageUsageReport>(),
      ];

  @override
  Future<ApiUser?> me() {
    final completer = _meCompleters[meCalls];
    meCalls += 1;
    return completer.future;
  }

  @override
  Future<List<ApiConnection>> connections() {
    final completer = _connectionsCompleters[connectionsCalls];
    connectionsCalls += 1;
    return completer.future;
  }

  @override
  Future<ApiStorageUsageReport> storageUsageReport() {
    final completer = _usageCompleters[usageCalls];
    usageCalls += 1;
    return completer.future;
  }

  void complete({
    required int index,
    required ApiUser? me,
    required List<ApiConnection> connections,
    required ApiStorageUsageReport usageReport,
  }) {
    _meCompleters[index].complete(me);
    _connectionsCompleters[index].complete(connections);
    _usageCompleters[index].complete(usageReport);
  }
}
