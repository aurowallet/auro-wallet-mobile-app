import 'dart:async';

import 'package:auro_wallet/utils/screenAwake.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _channel =
    'dev.flutter.pigeon.wakelock_plus_platform_interface.WakelockPlusApi.toggle';
const _codec = StandardMessageCodec();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() => messenger.setMockMessageHandler(_channel, null));

  testWidgets('releasing one owner keeps the other owner awake', (tester) async {
    var calls = 0;
    messenger.setMockMessageHandler(_channel, (_) async {
      calls++;
      return _codec.encodeMessage([null]);
    });
    final connection = ScreenAwakeHandle('test_connection');
    final signing = ScreenAwakeHandle('test_signing');
    await connection.activate();
    await signing.activate();
    expect(calls, 2);
    await connection.deactivate();
    expect(calls, 2);
    await signing.deactivate();
    expect(calls, 3);
    await signing.activate();
    await signing.activate();
    expect(calls, 4);
    await signing.deactivate();
    await signing.deactivate();
    expect(calls, 5);
  });

  testWidgets('platform errors do not escape or prevent subsequent use', (tester) async {
    var calls = 0;
    messenger.setMockMessageHandler(_channel, (_) async {
      calls++;
      return _codec.encodeMessage(['WAKELOCK_FAILED', 'Native failure', null]);
    });
    final handle = ScreenAwakeHandle('test_error');
    await handle.activate();
    await handle.deactivate();
    expect(calls, 2);
    messenger.setMockMessageHandler(_channel, (_) async {
      calls++;
      return _codec.encodeMessage([null]);
    });
    await handle.activate();
    await handle.deactivate();
    expect(calls, 4);
    expect(tester.takeException(), isNull);
  });

  for (final enabling in [true, false]) {
    testWidgets('${enabling ? 'enable' : 'disable'} times out and tolerates a late reply', (tester) async {
      messenger.setMockMessageHandler(
        _channel, (_) async => _codec.encodeMessage([null]),
      );
      final handle = ScreenAwakeHandle('test_timeout_$enabling');
      if (!enabling) await handle.activate();
      final nativeReply = Completer<ByteData?>();
      messenger.setMockMessageHandler(_channel, (_) => nativeReply.future);
      var completed = false;
      final pending = handle.setActive(enabling).then((_) => completed = true);
      await tester.pump(const Duration(milliseconds: 4999));
      expect(completed, isFalse);
      await tester.pump(const Duration(milliseconds: 1));
      await pending;
      expect(completed, isTrue);
      nativeReply.complete(_codec.encodeMessage([null]));
      await tester.pump();
      messenger.setMockMessageHandler(
        _channel, (_) async => _codec.encodeMessage([null]),
      );
      await handle.deactivate();
      await handle.activate();
      await handle.deactivate();
      expect(tester.takeException(), isNull);
    });
  }
}
