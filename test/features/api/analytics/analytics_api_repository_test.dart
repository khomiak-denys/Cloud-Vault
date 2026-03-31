import 'package:cloud_vault/api/api_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fake_api_client.dart';

void main() {
  group('ApiRepository Analytics', () {
    late FakeApiClient client;
    late ApiRepository repository;

    setUp(() {
      client = FakeApiClient();
      repository = ApiRepository(client);
    });

    tearDown(() {
      client.close();
    });

    test(
      'storageUsageReport() and storageUsage() parse totals and items',
      () async {
        client.getHandlers['/analytics/storage-usage'] = (_, _) =>
            <String, dynamic>{
              'totals': <String, dynamic>{
                'usedBytes': 50,
                'totalBytes': 100,
                'usagePercent': 50,
              },
              'items': <Map<String, dynamic>>[
                <String, dynamic>{
                  'connectionId': 'c1',
                  'providerId': 'google',
                  'providerName': 'Google Drive',
                  'usedBytes': 50,
                  'totalBytes': 100,
                },
              ],
            };

        final report = await repository.storageUsageReport();
        final usage = await repository.storageUsage();

        expect(report.usedBytes, 50);
        expect(report.connections.single.providerId, 'google-drive');
        expect(usage, hasLength(1));
      },
    );

    test('recommendations() maps description/body and filters empty', () async {
      client.getHandlers['/analytics/storage-optimization-recommendations'] =
          (_, _) => <String, dynamic>{
            'recommendations': <Map<String, dynamic>>[
              <String, dynamic>{'title': 'T1', 'description': 'D1'},
              <String, dynamic>{'title': 'T2', 'body': ''},
            ],
          };

      final result = await repository.recommendations();
      expect(result, hasLength(1));
      expect(result.single.title, 'T1');
      expect(result.single.body, 'D1');
    });
  });
}
