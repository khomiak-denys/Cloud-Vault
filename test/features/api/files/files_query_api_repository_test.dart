import 'dart:typed_data';

import 'package:cloud_vault/api/api_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fake_api_client.dart';

void main() {
  group('ApiRepository Files Query', () {
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
      'recentFiles(), favoriteFiles(), dashboardSummaryRecentFiles() parse files',
      () async {
        client.getHandlers['/files/recent'] = (_, query) {
          expect(query?['pageSize'], '20');
          return <String, dynamic>{
            'items': <Map<String, dynamic>>[
              <String, dynamic>{
                'fileId': 'f1',
                'connectionId': 'c1',
                'fileName': 'doc.txt',
                'displayPath': '/doc.txt',
                'sizeBytes': 1,
                'modifiedAt': '2026-01-01T00:00:00.000Z',
                'providerId': 'dropbox',
                'providerName': 'Dropbox',
                'kind': 'file',
              },
            ],
          };
        };
        client.getHandlers['/files/favorites'] = (_, query) {
          expect(query?['pageSize'], '100');
          expect(query?['providerId'], 'google-drive');
          return <String, dynamic>{
            'items': <Map<String, dynamic>>[
              <String, dynamic>{
                'fileId': 'f2',
                'connectionId': 'c2',
                'fileName': 'fav.txt',
                'displayPath': '/fav.txt',
                'sizeBytes': 2,
                'modifiedAt': '2026-01-01T00:00:00.000Z',
                'providerId': 'google',
                'kind': 'file',
              },
            ],
          };
        };
        client.getHandlers['/dashboard/summary'] = (_, _) => <String, dynamic>{
          'connectionId': 'all',
          'recentFiles': <Map<String, dynamic>>[
            <String, dynamic>{
              'fileId': 'f3',
              'fileName': 'sum.txt',
              'displayPath': '/sum.txt',
              'sizeBytes': 3,
              'modifiedAt': '2026-01-01T00:00:00.000Z',
              'providerId': 'onedrive',
              'kind': 'file',
            },
          ],
        };

        final recent = await repository.recentFiles();
        final fav = await repository.favoriteFiles(
          pageSize: 1000,
          providerId: 'google',
        );
        final summary = await repository.dashboardSummaryRecentFiles(
          pageSize: 20,
        );

        expect(recent.single.name, 'doc.txt');
        expect(fav.single.providerId, 'google-drive');
        expect(summary.single.connectionId, '');
      },
    );

    test(
      'listFiles() normalizes id-based and path-based provider paths',
      () async {
        client.postHandlers['/files/list'] = (_, _) => <String, dynamic>{
          'items': <Map<String, dynamic>>[
            <String, dynamic>{
              'fileId': 'id1',
              'connectionId': 'c1',
              'fileName': 'x',
              'displayPath': '/x',
              'sizeBytes': 1,
              'modifiedAt': '2026-01-01T00:00:00.000Z',
              'providerId': 'mega',
              'kind': 'file',
            },
          ],
        };

        await repository.listFiles(
          connectionId: 'c1',
          providerId: 'mega',
          path: '/docs',
          pageSize: 999,
        );
        await repository.listFiles(
          connectionId: 'c1',
          providerId: 'google-drive',
          path: '/root/folderA',
        );
        await repository.listFiles(
          connectionId: 'c1',
          providerId: 'box',
          path: '/docs/sub',
        );

        expect(client.calls[0].body?['path'], 'docs');
        expect(client.calls[0].body?['pageSize'], 100);
        expect(client.calls[1].body?['path'], 'folderA');
        expect(client.calls[2].body?['path'], 'root/docs/sub');
      },
    );

    test('searchFiles() includes providerIds and extracts facets', () async {
      client.postHandlers['/files/search'] = (body, _) {
        expect(body?['query'], 'report');
        expect(body?['providerIds'], <String>['dropbox']);
        return <String, dynamic>{
          'items': <Map<String, dynamic>>[
            <String, dynamic>{
              'fileId': 's1',
              'connectionId': 'c1',
              'fileName': 'report.pdf',
              'displayPath': '/report.pdf',
              'sizeBytes': 12,
              'modifiedAt': '2026-01-01T00:00:00.000Z',
              'providerId': 'dropbox',
              'kind': 'file',
            },
          ],
          'facets': <String, dynamic>{
            'providers': <Map<String, dynamic>>[
              <String, dynamic>{
                'providerId': 'dropbox',
                'providerName': 'Dropbox',
                'count': 1,
              },
            ],
          },
        };
      };

      final result = await repository.searchFiles(
        'report',
        providerIds: <String>['dropbox'],
      );
      expect(result.items, hasLength(1));
      expect(result.providerFacets.single.count, 1);
    });

    test(
      'downloadUrl(), previewUrl(), shareLink() parse preferred fields',
      () async {
        client.postHandlers['/files/download-url'] = (_, _) =>
            <String, dynamic>{'url': 'https://download'};
        client.postHandlers['/files/preview-url'] = (_, _) => <String, dynamic>{
          'url': 'https://preview',
          'method': ' get ',
          'headers': <String, dynamic>{'Authorization': 'Bearer x'},
        };
        client.postHandlers['/files/share-link'] = (_, _) => <String, dynamic>{
          'shareUrl': 'https://share',
        };

        final download = await repository.downloadUrl(
          connectionId: 'c1',
          fileId: 'f1',
        );
        final preview = await repository.previewUrl(
          connectionId: 'c1',
          fileId: 'f1',
        );
        final share = await repository.shareLink(
          connectionId: 'c1',
          fileId: 'f1',
        );

        expect(download, 'https://download');
        expect(preview!.method, 'GET');
        expect(preview.headers['Authorization'], 'Bearer x');
        expect(share, 'https://share');
      },
    );

    test('previewStreamBytes() passes payload and caps', () async {
      client.postBytesCappedHandlers['/files/preview-stream'] =
          (body, _, maxBytes, timeout) {
            expect(body?['connectionId'], 'c1');
            expect(body?['fileName'], 'file.pdf');
            expect(maxBytes, 1024);
            expect(timeout, const Duration(seconds: 10));
            return Uint8List.fromList(<int>[1, 2, 3]);
          };

      final bytes = await repository.previewStreamBytes(
        connectionId: 'c1',
        fileId: 'f1',
        fileName: 'file.pdf',
        mimeType: 'application/pdf',
        maxBytes: 1024,
        timeout: const Duration(seconds: 10),
      );
      expect(bytes, Uint8List.fromList(<int>[1, 2, 3]));
    });
  });
}
