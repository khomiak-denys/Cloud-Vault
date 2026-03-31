import 'package:cloud_vault/api/api_exception.dart';
import 'package:cloud_vault/api/api_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fake_api_client.dart';

void main() {
  group('ApiRepository Auth/Connections', () {
    late FakeApiClient client;
    late ApiRepository repository;

    setUp(() {
      client = FakeApiClient();
      repository = ApiRepository(client);
    });

    test('me() parses user from nested data', () async {
      client.getHandlers['/me'] = (_, __) => <String, dynamic>{
        'data': <String, dynamic>{
          'uid': 'u1',
          'email': 'u@example.com',
          'displayName': 'User One',
        },
      };

      final user = await repository.me();
      expect(user, isNotNull);
      expect(user!.uid, 'u1');
      expect(user.name, 'User One');
    });

    test('connections() normalizes provider id and usage fields', () async {
      client.getHandlers['/connections'] = (_, __) => <String, dynamic>{
        'items': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'c1',
            'provider': 'google',
            'displayName': 'Drive',
            'usage': <String, dynamic>{'usedBytes': 10, 'totalBytes': 100},
          },
        ],
      };

      final result = await repository.connections();
      expect(result, hasLength(1));
      expect(result.first.providerId, 'google-drive');
      expect(result.first.usedBytes, 10);
      expect(result.first.totalBytes, 100);
    });

    test('startProviderConnect() sends prompt and redirectUri', () async {
      client
          .postHandlers['/providers/google-drive/connect/start'] = (body, __) {
        expect(body?['prompt'], 'consent');
        expect(
          body?['redirectUri'],
          'http://localhost:3000/v1/providers/google-drive/connect/callback',
        );
        return <String, dynamic>{'authorizeUrl': 'https://auth.url'};
      };

      final url = await repository.startProviderConnect(
        'google-drive',
        redirectUri:
            'http://localhost:3000/v1/providers/google-drive/connect/callback',
      );
      expect(url, 'https://auth.url');
    });

    test(
      'startMegaConnect() parses result and throws on invalid response',
      () async {
        client.postHandlers['/providers/mega/connect/start'] = (body, __) {
          expect(body?['email'], 'a@b.com');
          expect(body?['password'], 'p');
          expect(body?['secondFactorCode'], '123456');
          return <String, dynamic>{
            'connectionId': 'conn1',
            'providerId': 'mega',
            'accountEmail': 'a@b.com',
          };
        };

        final ok = await repository.startMegaConnect(
          email: 'a@b.com',
          password: 'p',
          secondFactorCode: '123456',
        );
        expect(ok.connectionId, 'conn1');

        client.postHandlers['/providers/mega/connect/start'] = (_, __) =>
            <String, dynamic>{'providerId': 'mega'};
        expect(
          () => repository.startMegaConnect(email: 'a@b.com', password: 'p'),
          throwsA(isA<ApiException>()),
        );
      },
    );

    test('disconnectConnection() calls delete endpoint', () async {
      client.deleteHandlers['/connections/c1'] = (_, __) => <String, dynamic>{};
      await repository.disconnectConnection('c1');
      expect(client.calls.last.method, 'DELETE');
      expect(client.calls.last.path, '/connections/c1');
    });
  });
}
