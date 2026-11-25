import 'dart:async';
import 'dart:convert';

import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/service/minaExchanges.dart';
import 'package:auro_wallet/service/api/apiSetting.dart';
import 'package:auro_wallet/utils/localStorage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, dynamic> config({bool enabled = true}) => {
  'schemaVersion': 1,
  'enabled': enabled,
  'exchanges': [
    {
      'id': 'test',
      'enabled': true,
      'name': 'Exchange',
      'iconUrl': '/exchange.png',
      'url': 'https://example.com/mina',
      'description': {'en': 'English', 'zh_CN': '中文', 'tr': 'Türkçe'},
    },
  ],
};

class DelayedStorage extends LocalStorage {
  final result = Completer<Object?>();
  int reads = 0;
  @override
  Future<Object?> getObject(String key) {
    reads++;
    return result.future;
  }
}

MinaExchanges _service(LocalStorage storage, {
  required Future<http.Response> Function(Uri) fetch,
}) => MinaExchanges(
  storage,
  fetchConfig: () => ApiSetting.fetchMinaExchanges(fetch: fetch),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('API uses the config endpoint and decodes UTF-8 without a charset', () async {
    final parsed = await http.runWithClient(
      () => ApiSetting.fetchMinaExchanges(),
      () => MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.toString(), '$BASE_INFO_URL/v1/config/mina-exchanges');
        return http.Response.bytes(utf8.encode(jsonEncode(config())), 200);
      }),
    );
    expect(parsed!.available.single.descriptionFor('zh-CN'), '中文');
    expect(parsed.available.single.descriptionFor('tr'), 'Türkçe');
  });

  testWidgets('API times out after 30 seconds', (tester) async {
    final response = Completer<http.Response>();
    final pending = ApiSetting.fetchMinaExchanges(fetch: (_) => response.future);
    final checked = expectLater(pending, throwsA(isA<TimeoutException>()));
    await tester.pump(const Duration(seconds: 30));
    await checked;
    response.complete(http.Response('{}', 200));
    await tester.pump();
  });

  for (final statusCode in [200, 503]) {
    test('initializes once even after a $statusCode response', () async {
      final storage = DelayedStorage();
      storage.result.complete({'config': config()});
      final response = Completer<http.Response>();
      var requests = 0;
      final service = _service(
        storage,
        fetch: (_) {
          requests++;
          return response.future;
        },
      );
      addTearDown(service.dispose);
      final first = service.initialize();
      final second = service.initialize();
      expect(identical(first, second), isTrue);
      response.complete(
        http.Response(
          jsonEncode(config()),
          statusCode,
          headers: {'content-type': 'application/json; charset=utf-8'},
        ),
      );
      await Future.wait([first, second]);
      await service.initialize();
      expect(service.value!.available, hasLength(1));
      expect(requests, 1);
      expect(storage.reads, 1);

      // A new app session must still refresh the persisted configuration.
      final nextSession = _service(
        storage,
        fetch: (_) async {
          requests++;
          return http.Response(
            jsonEncode(config(enabled: false)),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        },
      );
      addTearDown(nextSession.dispose);
      await nextSession.initialize();
      expect(requests, 2);
      expect(nextSession.value!.enabled, isFalse);
    });
  }

  test('parses providers, resolves icons and falls back across locales', () {
    final parsed = MinaExchangesConfig.parse(config())!;
    final exchange = parsed.available.single;
    expect(
      exchange.iconUrl,
      Uri.parse(BASE_INFO_URL).resolve('/exchange.png').toString(),
    );
    expect(exchange.descriptionFor('zh-TW'), '中文');
    expect(exchange.descriptionFor('tr-TR'), 'Türkçe');
    expect(exchange.descriptionFor('fr'), 'English');
    expect(
      MinaExchangesConfig.parse(config(enabled: false))!.available,
      isEmpty,
    );
    final disabled = config();
    disabled['exchanges'][0]['enabled'] = false;
    expect(MinaExchangesConfig.parse(disabled)!.available, isEmpty);
  });

  test('rejects unsupported, malformed configs and non-web provider links', () {
    for (final value in [
      null,
      [],
      {},
      {...config(), 'schemaVersion': 2},
      {...config(), 'enabled': 'true'},
      {
        ...config(),
        'exchanges': [null],
      },
    ]) {
      expect(MinaExchangesConfig.parse(value), isNull);
    }
    final value = config();
    value['exchanges'][0]['url'] = 'javascript:alert(1)';
    expect(MinaExchangesConfig.parse(value), isNull);
  });

  test(
    'cache loads immediately and a valid remote disable replaces it',
    () async {
      final storage = LocalStorage();
      await storage.setObject(MinaExchanges.cacheKey, {'config': config()});
      final response = Completer<http.Response>();
      final service = _service(
        storage,
        fetch: (uri) {
          expect(uri.toString(), '$BASE_INFO_URL/v1/config/mina-exchanges');
          return response.future;
        },
      );
      addTearDown(service.dispose);
      final initialized = service.initialize();
      await Future<void>.delayed(Duration.zero);
      expect(service.value!.enabled, isTrue);
      response.complete(
        http.Response(
          jsonEncode(config(enabled: false)),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        ),
      );
      await initialized;
      expect(service.value!.enabled, isFalse);
      final cached = await storage.getObject(MinaExchanges.cacheKey) as Map;
      expect(cached['config']['enabled'], isFalse);
    },
  );

  test('failed or invalid refresh preserves a valid cache', () async {
    for (final response in [
      http.Response('error', 503),
      http.Response('{}', 200),
      http.Response('invalid json', 200),
    ]) {
      final storage = LocalStorage();
      await storage.setObject(MinaExchanges.cacheKey, {'config': config()});
      final service = _service(storage, fetch: (_) async => response);
      await service.initialize();
      expect(service.value!.available, hasLength(1));
      service.dispose();
    }
  });

  test('transport failure retains cache and does not retry initialization', () async {
    final storage = LocalStorage();
    await storage.setObject(MinaExchanges.cacheKey, {'config': config()});
    var calls = 0;
    final service = _service(storage, fetch: (_) async {
      calls++;
      throw http.ClientException('offline');
    });
    addTearDown(service.dispose);
    await service.initialize();
    await service.initialize();
    expect(calls, 1);
    expect(service.value!.available, hasLength(1));
    final cached = await storage.getObject(MinaExchanges.cacheKey) as Map;
    expect(cached['config'], config());
  });

  test(
    'late cache cannot overwrite remote data, even after disposal',
    () async {
      final storage = DelayedStorage();
      final service = _service(
        storage,
        fetch: (_) async => http.Response(
          jsonEncode(config(enabled: false)),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        ),
      );
      final initialized = service.initialize();
      await Future<void>.delayed(Duration.zero);
      expect(service.value!.enabled, isFalse);
      storage.result.complete({'config': config()});
      await initialized;
      expect(service.value!.enabled, isFalse);
      service.dispose();

      final response = Completer<http.Response>();
      final disposed = _service(
        LocalStorage(),
        fetch: (_) => response.future,
      );
      final pending = disposed.initialize();
      disposed.dispose();
      response.complete(
        http.Response(
          jsonEncode(config()),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        ),
      );
      await pending;
      expect(disposed.value, isNull);
    },
  );
}
