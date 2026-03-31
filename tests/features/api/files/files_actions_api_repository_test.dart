import 'package:cloud_vault/api/api_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fake_api_client.dart';

void main() {
  group('ApiRepository Files Actions', () {
    late FakeApiClient client;
    late ApiRepository repository;

    setUp(() {
      client = FakeApiClient();
      repository = ApiRepository(client);
    });

    test('setFavorite() and unsetFavorite() normalize kind', () async {
      client.postHandlers['/files/favorites/set'] = (body, __) {
        expect(body?['kind'], 'file');
        return <String, dynamic>{};
      };
      client.postHandlers['/files/favorites/unset'] = (body, __) {
        expect(body?['kind'], 'folder');
        return <String, dynamic>{};
      };

      await repository.setFavorite(
        connectionId: 'c1',
        fileId: 'f1',
        fileName: 'n',
        kind: 'unknown',
      );
      await repository.unsetFavorite(
        connectionId: 'c1',
        fileId: 'f1',
        fileName: 'n',
        kind: 'folder',
      );
    });

    test(
      'renameFile(), deleteFile(), createFolder(), fileProperties()',
      () async {
        client.postHandlers['/files/rename'] = (_, __) => <String, dynamic>{};
        client.postHandlers['/files/delete'] = (_, __) => <String, dynamic>{};
        client.postHandlers['/files/create-folder'] = (body, __) {
          expect(body?['parentId'], 'folderA');
          return <String, dynamic>{};
        };
        client.postHandlers['/files/properties'] = (_, __) => <String, dynamic>{
          'size': 100,
        };

        await repository.renameFile(
          connectionId: 'c1',
          fileId: 'f1',
          newName: 'new.txt',
        );
        await repository.deleteFile(connectionId: 'c1', fileId: 'f1');
        await repository.createFolder(
          connectionId: 'c1',
          providerId: 'google-drive',
          parentId: '/root/folderA',
          folderName: 'newFolder',
        );
        final properties = await repository.fileProperties(
          connectionId: 'c1',
          fileId: 'f1',
        );

        expect(properties['size'], 100);
      },
    );

    test(
      'uploadFile() normalizes payload and derives file name from path',
      () async {
        client.multipartHandlers['/files/upload'] =
            ({
              required fields,
              required fileField,
              fileBytes,
              filePath,
              fileStream,
              fileLength,
              required fileName,
              required timeout,
            }) {
              expect(fields['parentId'], 'docs');
              expect(fields['connectionId'], 'c1');
              expect(fields['allowFallback'], 'true');
              expect(fileField, 'file');
              expect(fileName, 'report.pdf');
              expect(filePath, 'C:\\tmp\\report.pdf');
              return <String, dynamic>{'ok': true};
            };

        final result = await repository.uploadFile(
          filePath: 'C:\\tmp\\report.pdf',
          parentId: '/docs',
          providerId: 'mega',
          connectionId: 'c1',
          allowFallback: true,
        );
        expect(result['ok'], true);
      },
    );
  });
}
