import 'dart:async';
import 'dart:typed_data';

import 'package:auro_wallet/ledgerMina/ledger_error.dart';
import 'package:auro_wallet/ledgerMina/mina_transformer.dart';
import 'package:auro_wallet/ledgerMina/operations/mina_public_key_operation.dart';
import 'package:auro_wallet/ledgerMina/operations/mina_name_operation.dart';
import 'package:auro_wallet/ledgerMina/operations/mina_sign_message_operation.dart';
import 'package:auro_wallet/ledgerMina/operations/mina_version_operation.dart';
import 'package:auro_wallet/utils/appLedgerBleConnectionManager.dart';
import 'package:auro_wallet/utils/appLedgerGattGateway.dart';
import 'package:auro_wallet/utils/persistentLedgerBleSearchManager.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger_flutter/ledger_flutter.dart';

final device = LedgerDevice(
  id: 'nano-x',
  name: '689C',
  connectionType: ConnectionType.ble,
);
final serviceId = Uuid.parse('13d63400-2c97-0004-0000-4c6564676572');
const ledgerAddress = 'B62qkzCugh8u2Ez1vEs7i3UjW7iypA8ovwC88rBwLqZmdWFqh96M8rM';
final characteristics = [1, 2]
    .map(
      (index) => DiscoveredCharacteristic(
        characteristicId: Uuid.parse(
          '13d63400-2c97-0004-000$index-4c6564676572',
        ),
        characteristicInstanceId: '$index',
        serviceId: serviceId,
        isReadable: false,
        isWritableWithResponse: index == 2,
        isWritableWithoutResponse: false,
        isNotifiable: index == 1,
        isIndicatable: false,
      ),
    )
    .toList();
final services = [
  DiscoveredService(
    serviceId: serviceId,
    serviceInstanceId: '1',
    characteristicIds: characteristics.map((c) => c.characteristicId).toList(),
    characteristics: characteristics,
  ),
];

Future<void> flush() => Future<void>.delayed(Duration.zero);
final ledgerError = isA<LedgerException>();
final bondingInProgress = PlatformException(
  code: 'service_discovery_failure',
  message: 'java.lang.Exception: Bonding is in progress wait for bonding to be '
      'finished before executing more operations on the device',
);

class FakeWriteCharacteristic extends Fake implements Characteristic {
  final FakeBle ble;
  FakeWriteCharacteristic(this.ble);

  @override
  Future<void> write(List<int> value, {bool withResponse = true}) async {
    expect(withResponse, isTrue);
    ble.packets.add(value);
    await ble.onWrite?.call();
  }
}

class FakeService extends Fake implements Service {
  final DiscoveredService source;
  FakeService(this.source);

  @override
  Uuid get id => source.serviceId;
  @override
  List<Characteristic> get characteristics =>
      source.characteristics.map(FakeCharacteristic.new).toList();
}

class FakeCharacteristic extends Fake implements Characteristic {
  final DiscoveredCharacteristic source;
  FakeCharacteristic(this.source);

  @override
  Uuid get id => source.characteristicId;
  @override
  bool get isReadable => source.isReadable;
  @override
  bool get isWritableWithResponse => source.isWritableWithResponse;
  @override
  bool get isWritableWithoutResponse => source.isWritableWithoutResponse;
  @override
  bool get isNotifiable => source.isNotifiable;
  @override
  bool get isIndicatable => source.isIndicatable;
}

class FakeBle extends Fake implements FlutterReactiveBle {
  final bluetoothStatuses = StreamController<BleStatus>.broadcast(sync: true);
  final notifications = StreamController<List<int>>.broadcast(sync: true);
  int nativeEventTeardowns = 0;
  late final nativeConnectionUpdates = StreamController<ConnectionStateUpdate>.broadcast(
    onCancel: () => nativeEventTeardowns++,
  );
  final connections = <StreamController<ConnectionStateUpdate>>[];
  final packets = <List<int>>[];
  Future<void> Function()? onWrite;
  Future<void> Function()? onResolveWrite;
  int writeLookups = 0;
  Future<List<DiscoveredService>> Function()? discovery;
  Object? mtuError;
  Object? subscribeError;
  int discoveries = 0;
  int serviceReads = 0;
  List<DiscoveredService>? discoveredServices;
  int directConnects = 0;
  Future<void>? disconnectGate;
  Duration? nativeConnectionTimeout;

  @override
  BleStatus get status => BleStatus.ready;
  @override
  Stream<BleStatus> get statusStream => bluetoothStatuses.stream;
  @override
  Stream<ConnectionStateUpdate> get connectedDeviceStream => nativeConnectionUpdates.stream;
  @override
  Stream<ConnectionStateUpdate> connectToDevice({
    required String id,
    Duration? connectionTimeout,
    Map<Uuid, List<Uuid>>? servicesWithCharacteristicsToDiscover,
  }) {
    directConnects++;
    nativeConnectionTimeout = connectionTimeout;
    final source = StreamController<ConnectionStateUpdate>(
      sync: true, onCancel: () {
        return disconnectGate;
      },
    );
    connections.add(source);
    return source.stream;
  }

  void state(DeviceConnectionState state, [int? index]) {
    connections[index ?? connections.length - 1].add(
      ConnectionStateUpdate(
        deviceId: device.id,
        connectionState: state,
        failure: null,
      ),
    );
  }

  @override
  Future<void> discoverAllServices(String deviceId) async {
    discoveries++;
    discoveredServices = discovery == null ? services : await discovery!();
  }

  @override
  Future<List<Service>> getDiscoveredServices(String deviceId) async {
    serviceReads++;
    return discoveredServices!.map(FakeService.new).toList();
  }

  @override
  Future<int> requestMtu({required String deviceId, required int mtu}) async {
    if (mtuError != null) throw mtuError!;
    return mtu;
  }

  @override
  Stream<List<int>> subscribeToCharacteristic(
    QualifiedCharacteristic characteristic,
  ) {
    if (subscribeError != null) return Stream.error(subscribeError!);
    return notifications.stream;
  }

  @override
  Future<Characteristic> resolveSingle(QualifiedCharacteristic characteristic) async {
    writeLookups++;
    await onResolveWrite?.call();
    return FakeWriteCharacteristic(this);
  }

  @override
  Future<void> writeCharacteristicWithResponse(
    QualifiedCharacteristic characteristic, {
    required List<int> value,
  }) async {
    // The plugin convenience method resolves services before it writes.
    await (await resolveSingle(characteristic)).write(value, withResponse: true);
  }

  void respond(List<int> data) {
    for (final packet in LedgerPacker().pack(Uint8List.fromList(data), 23)) {
      notifications.add(packet);
    }
  }

  Future<void> close() async {
    await nativeConnectionUpdates.close();
    await bluetoothStatuses.close();
    await notifications.close();
    for (final source in connections) {
      await source.close();
    }
  }
}

class Probe extends LedgerOperation<int> {
  final Completer<void>? preparing;
  final Completer<int>? decoding;
  final int bytes;
  Probe({this.preparing, this.decoding, this.bytes = 1});
  @override
  Future<List<Uint8List>> write(ByteDataWriter writer) async {
    await preparing?.future;
    return [Uint8List(bytes)];
  }

  @override
  Future<int> read(ByteDataReader reader) async =>
      decoding == null ? reader.readUint8() : await decoding!.future;
}

void main() {
  late FakeBle ble;
  late AppLedgerGattGateway gateway;
  setUp(() {
    ble = FakeBle();
    gateway = AppLedgerGattGateway(
      bleManager: ble,
      ledger: DiscoveredLedger(
        device: device,
        subscription: null,
        services: services,
      ),
      probeTimeout: const Duration(milliseconds: 30),
    );
  });
  tearDown(() async {
    await gateway.disconnect();
    await ble.close();
  });

  test('an error with version-shaped data preserves its status and allows retry', () async {
    await gateway.start();
    ble.onWrite = () async => ble.respond([1, 2, 3, 0x65, 0x11]);
    await expectLater(
      gateway.sendOperation(MinaVersionOperation(), transformer: const MinaTransformer()),
      throwsA(ledgerError.having(
        (e) => classifyLedgerErrorCode(e.errorCode),
        'failure',
        LedgerFailureType.appNotOpen,
      )),
    );
    ble.onWrite = () async => ble.respond([1, 2, 3, 0x90, 0]);
    final version = await gateway.sendOperation(
      MinaVersionOperation(), transformer: const MinaTransformer(),
    );
    expect(version.versionMajor, 1);
    expect(version.versionMinor, 2);
    expect(version.versionPatch, 3);
  });

  test('receives a response before the native write completes', () async {
    await gateway.start();
    final ack = Completer<void>();
    ble.onWrite = () {
      ble.respond([7, 0x90, 0]);
      return ack.future;
    };
    final response = gateway.sendOperation<int>(Probe());
    await flush();
    ack.complete();
    expect(await response, 7);
  });

  test('bonding before first APDU preserves notifications and waits beyond probe timeout', () async {
    await gateway.start();
    var bonding = true;
    ble.onResolveWrite = () async {
      if (bonding) throw bondingInProgress;
    };
    ble.onWrite = () async => ble.respond([1, 2, 3, 0x90, 0]);
    final response = gateway.sendOperation(
      MinaVersionOperation(), transformer: const MinaTransformer(),
    );
    // Failures are observed immediately so the regression has no unhandled error.
    final checked = expectLater(response, completion(isNotNull));
    await Future<void>.delayed(const Duration(milliseconds: 80));
    expect(ble.packets, isEmpty);
    expect(ble.notifications.hasListener, isTrue);
    bonding = false;
    await checked;
    expect((await response).versionMajor, 1);
    expect(ble.packets, hasLength(1));
  });

  for (final pairing in [false, true]) {
    test('CCCD failure includes pairing context only after observed bonding: $pairing', () async {
      await gateway.disconnect();
      final progress = <bool>[];
      gateway = AppLedgerGattGateway(
        bleManager: ble,
        ledger: DiscoveredLedger(device: device, subscription: null, services: services),
        onPairingChanged: progress.add,
      );
      await gateway.start();
      final lookup = Completer<void>();
      ble.onResolveWrite = () async {
        if (pairing) throw bondingInProgress;
        await lookup.future;
      };
      final failure = Exception('Cannot write client characteristic config descriptor (code 3)');
      final pending = gateway.sendOperation<int>(Probe());
      final checked = expectLater(pending, throwsA(pairing
          ? isA<LedgerPairingIncompleteException>().having((e) => e.cause, 'cause', same(failure))
          : same(failure)));
      await flush();
      expect(progress, pairing ? [true] : isEmpty);
      ble.notifications.addError(failure);
      await checked;
      lookup.complete();
      await Future<void>.delayed(const Duration(milliseconds: 550));
      expect(progress, pairing ? [true, false] : isEmpty);
      expect(ble.packets, isEmpty);
      expect(ble.notifications.hasListener, isFalse);
    });
  }

  test('pairing progress clears before write and never replays an APDU', () async {
    await gateway.disconnect();
    final progress = <bool>[];
    gateway = AppLedgerGattGateway(
      bleManager: ble,
      ledger: DiscoveredLedger(device: device, subscription: null, services: services),
      onPairingChanged: progress.add,
    );
    await gateway.start();
    ble.onResolveWrite = () async {
      if (ble.writeLookups == 1) throw bondingInProgress;
    };
    ble.onWrite = () async {
      expect(progress, [true, false]);
      ble.respond([7, 0x90, 0]);
    };
    expect(await gateway.sendOperation<int>(Probe()), 7);
    expect(ble.packets, hasLength(1));
  });

  test('cancelling while bonding clears progress without claiming pairing failure', () async {
    await gateway.disconnect();
    final progress = <bool>[];
    gateway = AppLedgerGattGateway(
      bleManager: ble,
      ledger: DiscoveredLedger(device: device, subscription: null, services: services),
      onPairingChanged: progress.add,
    );
    await gateway.start();
    ble.onResolveWrite = () async => throw bondingInProgress;
    final checked = expectLater(gateway.sendOperation<int>(Probe()), throwsA(ledgerError));
    await flush();
    await gateway.disconnect();
    await checked;
    expect(progress, [true, false]);
    expect(ble.packets, isEmpty);
  });

  test('fragmented APDU resolves once and never retries a failed native write', () async {
    await gateway.start();
    ble.onWrite = () async {
      if (ble.packets.length == 2) throw bondingInProgress;
    };
    await expectLater(gateway.sendOperation<int>(Probe(bytes: 50)),
        throwsA(same(bondingInProgress)));
    await Future<void>.delayed(const Duration(milliseconds: 550));
    expect(ble.writeLookups, 1);
    expect(ble.packets, hasLength(2));
    expect(ble.notifications.hasListener, isFalse);
  });

  test('a real pairing failure is not retried as bonding in progress', () async {
    await gateway.start();
    final failure = PlatformException(
      code: 'service_discovery_failure', message: 'Bonding failed',
    );
    ble.onResolveWrite = () async => throw failure;
    await expectLater(gateway.sendOperation<int>(Probe()), throwsA(same(failure)));
    expect(ble.writeLookups, 1);
    expect(ble.packets, isEmpty);
    expect(ble.notifications.hasListener, isFalse);
  });

  test('preparation timeout releases queued work and ignores a late lookup', () async {
    await gateway.disconnect();
    gateway = AppLedgerGattGateway(
      bleManager: ble,
      ledger: DiscoveredLedger(device: device, subscription: null, services: services),
      preparationTimeout: const Duration(milliseconds: 30),
    );
    await gateway.start();
    final lookup = Completer<void>();
    ble.onResolveWrite = () => lookup.future;
    final failed = expectLater(gateway.sendOperation<int>(Probe()), throwsA(isA<TimeoutException>()));
    final queued = expectLater(gateway.sendOperation<int>(Probe()), throwsA(ledgerError));
    await Future.wait([failed, queued]);
    lookup.complete();
    await flush();
    expect(ble.packets, isEmpty);
    expect(ble.writeLookups, 1);
    expect(ble.notifications.hasListener, isFalse);
  });

  test('repeated bonding errors cannot renew the preparation deadline', () async {
    await gateway.disconnect();
    gateway = AppLedgerGattGateway(
      bleManager: ble,
      ledger: DiscoveredLedger(device: device, subscription: null, services: services),
      preparationTimeout: const Duration(milliseconds: 650),
    );
    await gateway.start();
    ble.onResolveWrite = () async => throw bondingInProgress;
    await expectLater(gateway.sendOperation<int>(Probe()).timeout(const Duration(seconds: 2)),
        throwsA(isA<LedgerPairingIncompleteException>()));
    expect(ble.writeLookups, 2);
    expect(ble.notifications.hasListener, isFalse);
    expect(ble.packets, isEmpty);
  });

  for (final end in ['cancel', 'notification failure']) {
    test('$end interrupts preparation and cannot write after a late lookup', () async {
      await gateway.start();
      final lookup = Completer<void>();
      final failure = StateError('CCCD transport failed');
      ble.onResolveWrite = () => lookup.future;
      final pending = expectLater(gateway.sendOperation<int>(Probe()),
          throwsA(end == 'cancel' ? ledgerError : same(failure)));
      await flush();
      if (end == 'cancel') {
        await gateway.disconnect();
      } else {
        ble.notifications.addError(failure);
      }
      await pending;
      lookup.complete();
      await flush();
      expect(ble.packets, isEmpty);
      expect(ble.writeLookups, 1);
      expect(ble.notifications.hasListener, isFalse);
    });
  }

  test('early 0x6511 is caught and preserves the session for retry', () async {
    await gateway.start();
    final ack = Completer<void>();
    ble.onWrite = () {
      ble.respond([0x65, 0x11]);
      return ack.future;
    };
    final failed = expectLater(
      gateway.sendOperation<int>(Probe()),
      throwsA(
        ledgerError.having(
          (e) => classifyLedgerErrorCode(e.errorCode),
          'status',
          LedgerFailureType.appNotOpen,
        ),
      ),
    );
    await flush();
    ack.complete();
    await failed;
    ble.onWrite = () async {
      ble.respond([8, 0x90, 0]);
    };
    expect(await gateway.sendOperation<int>(Probe()), 8);
  });

  test('missing native write acknowledgement fails signing and releases queued work', () async {
    await gateway.disconnect();
    gateway = AppLedgerGattGateway(
      bleManager: ble,
      ledger: DiscoveredLedger(device: device, subscription: null, services: services),
      writeTimeout: const Duration(milliseconds: 30),
    );
    await gateway.start();
    final ack = Completer<void>();
    ble.onWrite = () {
      ble.respond([7, 0x90, 0]);
      return ack.future;
    };
    final signing = expectLater(gateway.sendOperation<int>(Probe()),
        throwsA(isA<TimeoutException>()));
    final queued = expectLater(gateway.sendOperation<int>(Probe()), throwsA(ledgerError));
    await Future.wait([signing, queued]);
    expect(ble.packets, hasLength(1));
    ack.complete();
    await flush();
    expect(ble.packets, hasLength(1));
  });

  test('serializes APDUs until the first response is received', () async {
    await gateway.start();
    final first = gateway.sendOperation<int>(Probe());
    final second = gateway.sendOperation<int>(Probe());
    await flush();
    expect(ble.packets, hasLength(1));
    ble.respond([1, 0x90, 0]);
    expect(await first, 1);
    await flush();
    expect(ble.packets, hasLength(2));
    ble.respond([2, 0x90, 0]);
    expect(await second, 2);
  });

  test(
    'late decoding after disconnect cannot complete another request',
    () async {
      await gateway.start();
      final decoding = Completer<int>();
      final first = expectLater(
        gateway.sendOperation<int>(Probe(decoding: decoding)),
        throwsA(ledgerError),
      );
      final second = expectLater(
        gateway.sendOperation<int>(Probe()),
        throwsA(ledgerError),
      );
      await flush();
      ble.respond([1, 0x90, 0]);
      await flush();
      await gateway.disconnect();
      decoding.complete(1);
      await Future.wait([first, second]);
      expect(ble.packets, hasLength(1));
    },
  );

  test('does not write after disconnect during APDU preparation', () async {
    await gateway.start();
    final preparing = Completer<void>();
    final response = expectLater(
      gateway.sendOperation<int>(Probe(preparing: preparing)),
      throwsA(ledgerError),
    );
    await flush();
    await gateway.disconnect();
    preparing.complete();
    await response;
    expect(ble.packets, isEmpty);
  });

  test('subscription failure before an APDU fails initialization', () async {
    ble.subscribeError = StateError('CCCD failed');
    await expectLater(gateway.start(), throwsStateError);
    expect(ble.packets, isEmpty);
  });

  test(
    'notification channel ending completes an outstanding request',
    () async {
      await gateway.start();
      final response = expectLater(
        gateway.sendOperation<int>(Probe()),
        throwsA(ledgerError),
      );
      await flush();
      await ble.notifications.close();
      await response;
    },
  );

  test('app readiness has a timeout and releases queued operations', () async {
    await gateway.start();
    final silent = expectLater(
      gateway.sendOperation<LedgerAppName>(MinaNameOperation()),
      throwsA(isA<TimeoutException>()),
    );
    final queued = expectLater(
      gateway.sendOperation<int>(Probe()),
      throwsA(ledgerError),
    );
    await Future.wait([silent, queued]);
    expect(ble.packets, hasLength(1));
  });

  test('silent key derivation can outlast the readiness timeout', () async {
    await gateway.start();
    final response = gateway.sendOperation<List<String>>(
      MinaPublicKeyOperation(showAddressInDevice: false),
      transformer: const MinaTransformer(),
    );
    await Future<void>.delayed(const Duration(milliseconds: 60));
    ble.respond([...ledgerAddress.codeUnits, 0x90, 0]);
    expect(await response, [ledgerAddress]);
  });

  test('message signing waits beyond probe timeout and parses the complete BLE response', () async {
    await gateway.start();
    final response = gateway.sendOperation(
      MinaSignMessageOperation(accountIndex: 7, networkId: 1, message: 'hello'),
      transformer: const MinaTransformer(),
    );
    await Future<void>.delayed(const Duration(milliseconds: 60));
    final message = 'Message : hello'.codeUnits;
    ble.respond([
      ...List.filled(31, 0), 1, ...List.filled(31, 0), 2,
      message.length, ...message, 0x90, 0,
    ]);
    expect(await response, {
      'data': 'Message : hello', 'signature': {'field': '1', 'scalar': '2'},
    });
  });

  test(
    'key derivation timeout closes the channel and fails queued probes',
    () async {
      await gateway.disconnect();
      gateway = AppLedgerGattGateway(
        bleManager: ble,
        ledger: DiscoveredLedger(
          device: device,
          subscription: null,
          services: services,
        ),
        publicKeyTimeout: const Duration(milliseconds: 30),
      );
      await gateway.start();
      final key = expectLater(
        gateway.sendOperation<List<String>>(
          MinaPublicKeyOperation(showAddressInDevice: false),
        ),
        throwsA(isA<TimeoutException>()),
      );
      final queued = expectLater(
        gateway.sendOperation(MinaVersionOperation()),
        throwsA(ledgerError),
      );
      await Future.wait([key, queued]);
      expect(ble.packets, hasLength(1));
    },
  );

  test(
    'address confirmation is not subject to silent readiness timeout',
    () async {
      await gateway.start();
      final response = gateway.sendOperation<List<String>>(
        MinaPublicKeyOperation(),
        transformer: const MinaTransformer(),
      );
      await Future<void>.delayed(const Duration(milliseconds: 60));
      ble.respond([...ledgerAddress.codeUnits, 0, 0x90, 0]);
      expect(await response, [ledgerAddress]);
    },
  );

  test(
    'failed MTU negotiation falls back to 23 rather than requested 156',
    () async {
      await gateway.disconnect();
      ble.mtuError = StateError('MTU failed');
      gateway = AppLedgerGattGateway(
        bleManager: ble,
        mtu: 156,
        ledger: DiscoveredLedger(
          device: device,
          subscription: null,
          services: services,
        ),
      );
      await gateway.start();
      final response = gateway.sendOperation<int>(Probe(bytes: 50));
      await flush();
      expect(ble.packets.length, greaterThan(1));
      expect(ble.packets.every((p) => p.length <= 20), isTrue);
      ble.respond([1, 0x90, 0]);
      expect(await response, 1);
    },
  );

  group('connection ownership', () {
    late AppLedgerBleConnectionManager manager;
    setUp(() {
      manager = AppLedgerBleConnectionManager(
        bleManager: ble,
        options: LedgerOptions(connectionTimeout: const Duration(seconds: 2)),
      );
    });
    tearDown(() async {
      await manager.dispose();
    });

    Future<void> connect() async {
      final pending = manager.connect(device);
      await flush();
      ble.state(DeviceConnectionState.connected);
      await pending;
    }

    test('audit: cancelling a retry during cleanup prevents a later connection', () async {
      await connect();
      final gate = Completer<void>();
      ble.disconnectGate = gate.future;
      final stopping = manager.disconnect(device);
      await flush();
      final retry = manager.connect(device);
      Object? retryError;
      var retryFinished = false;
      final observed = retry.then((_) { retryFinished = true; },
        onError: (Object error) { retryError = error; retryFinished = true; });
      final cancelling = manager.disconnect(device);
      gate.complete();
      await Future.wait([stopping, cancelling]);
      await flush();
      final starts = ble.directConnects;
      // Clean up even on the pre-fix path so failure cannot leave a timer.
      await manager.dispose();
      await observed;
      expect(starts, 1);
      expect(retryFinished, isTrue);
      expect(retryError, isA<LedgerException>());
    });

    test('audit: session close callback can immediately request a new connection', () async {
      await manager.dispose();
      Future<void>? retry;
      Object? callbackError;
      var requested = false;
      manager = AppLedgerBleConnectionManager(bleManager: ble,
        options: LedgerOptions(connectionTimeout: const Duration(seconds: 2)),
        onSessionClosed: (device, _) {
          if (requested) return;
          requested = true;
          try { retry = manager.connect(device); } catch (error) { callbackError = error; }
        });
      await connect();
      await manager.disconnect(device);
      await flush();
      expect(callbackError, isNull);
      expect(ble.directConnects, 2);
      ble.state(DeviceConnectionState.connected);
      await retry;
      expect(manager.devices, [device]);
    });

    test('audit: local disconnect invalidates replay without a native callback', () async {
      await connect();
      ble.nativeConnectionUpdates.add(ConnectionStateUpdate(deviceId: device.id,
        connectionState: DeviceConnectionState.connected, failure: null));
      await flush();
      await manager.disconnect(device);
      final replay = <ConnectionStateUpdate>[];
      final sub = manager.deviceStateChanges.listen(replay.add);
      await flush();
      expect(replay.where((s) => s.connectionState == DeviceConnectionState.connected), isEmpty);
      await sub.cancel();
    });

    test('stopping discovery must not tear down the native connection event channel', () async {
      // Android DeviceConnectionHandler.onCancel calls disconnectAllDevices;
      // its CompositeDisposable.dispose is terminal for the native client.
      final advertisements = StreamController<DiscoveredDevice>.broadcast();
      final scanner = PersistentLedgerBleSearchManager(
        options: LedgerOptions(), statusProvider: () => BleStatus.ready,
        scanForDevices: (_, __, ___) => advertisements.stream,
        connectedDeviceUpdates: ble.connectedDeviceStream,
      );
      for (var retry = 0; retry < 2; retry++) {
        final sub = scanner.scan().listen((_) {});
        await flush();
        await sub.cancel(); await scanner.stop();
        expect(ble.nativeEventTeardowns, 0,
          reason: 'scan cancellation must not call native disconnectAll');
      }
      await connect();
      await manager.disconnect(device);
      expect(ble.nativeEventTeardowns, 0);
      await connect();
      expect(manager.devices, [device]);
      await scanner.dispose();
      await advertisements.close();
      await manager.dispose();
      expect(ble.nativeEventTeardowns, 1);
    });

    test('unknown native state waits for a named advertisement without connecting', () async {
      final advertisements = StreamController<DiscoveredDevice>();
      final scanner = PersistentLedgerBleSearchManager(
        options: LedgerOptions(), statusProvider: () => BleStatus.ready,
        scanForDevices: (_, __, ___) => advertisements.stream,
        connectedDeviceUpdates: manager.deviceStateChanges,
        prepareConnectedDevice: (candidate) async {
          await manager.connect(candidate, nativeConnectionEstablished: true);
          return manager.devices.contains(candidate);
        },
      );
      // The native snapshot predates scanning and has no advertised name.
      ble.nativeConnectionUpdates.add(ConnectionStateUpdate(deviceId: device.id,
        connectionState: DeviceConnectionState.connected, failure: null));
      await flush();
      final found = <LedgerDevice>[];
      final subscription = scanner.scan().listen(found.add);
      await flush();
      await flush();
      expect(ble.directConnects, 0);
      expect(ble.discoveries, 0);
      expect(ble.nativeEventTeardowns, 0);
      expect(found, isEmpty);
      expect(ble.notifications.hasListener, isFalse);
      expect(ble.packets, isEmpty);
      advertisements.add(DiscoveredDevice(
        id: device.id, name: '689C', serviceData: const {},
        manufacturerData: Uint8List(0), rssi: -42, serviceUuids: [serviceId],
      ));
      await flush();
      expect(found.single.name, '689C');
      expect(found.single.id, device.id);
      await subscription.cancel(); await scanner.stop();
      final connecting = manager.connect(found.single);
      await flush();
      ble.state(DeviceConnectionState.connected);
      await connecting;
      expect(manager.devices.single, same(found.single));
      await advertisements.close();
    });

    test('retry after cleanup requires a fresh connection and retains selected metadata', () async {
      await connect();
      final gate = Completer<void>();
      ble.disconnectGate = gate.future;
      final stopping = manager.disconnect(device);
      await flush();
      final selected = LedgerDevice(id: device.id, name: 'Updated 689C',
        connectionType: ConnectionType.ble);
      final connecting = manager.connect(selected, nativeConnectionEstablished: true);
      expect(manager.devices, isEmpty);
      expect(ble.directConnects, 1);
      gate.complete();
      await stopping;
      await flush();
      expect(ble.connections.first.hasListener, isFalse);
      expect(ble.directConnects, 2);
      expect(manager.devices, isEmpty);
      expect(ble.discoveries, 1); // The old connected snapshot cannot initialize this link.
      ble.state(DeviceConnectionState.connected);
      await connecting;
      expect(manager.devices.single, same(selected));
      expect(ble.connections.last.hasListener, isTrue);
    });

    test('adopts an existing native connection without waiting for a duplicate connected event', () async {
      await manager.connect(device, nativeConnectionEstablished: true);
      expect(ble.directConnects, 1);
      expect(manager.devices, [device]);
      expect(ble.discoveries, 1);
      ble.state(DeviceConnectionState.connected);
      await flush();
      expect(ble.discoveries, 1);
      ble.onWrite = () async => ble.respond([7, 0x90, 0]);
      expect(await manager.sendOperation<int>(device, Probe(), null), 7);
      await manager.disconnect(device);
      expect(ble.connections.single.hasListener, isFalse);
      expect(ble.notifications.hasListener, isFalse);
    });

    test('native connected state cannot bypass Ledger service verification', () async {
      ble.discovery = () async => [];
      await expectLater(manager.connect(device, nativeConnectionEstablished: true),
          throwsA(ledgerError));
      await flush();
      expect(manager.devices, isEmpty);
      expect(ble.packets, isEmpty);
      expect(ble.connections.single.hasListener, isFalse);
    });

    test('bonding during APDU preparation retains the same native connection', () async {
      await connect();
      ble.onResolveWrite = () async {
        if (ble.writeLookups == 1) throw bondingInProgress;
      };
      ble.onWrite = () async => ble.respond([7, 0x90, 0]);
      final pending = manager.sendOperation<int>(device, Probe(), null);
      await flush();
      expect(ble.connections.single.hasListener, isTrue);
      expect(ble.notifications.hasListener, isTrue);
      expect(ble.packets, isEmpty);
      expect(await pending, 7);
      expect(ble.connections, hasLength(1));
      expect(ble.connections.single.hasListener, isTrue);
      expect(ble.packets, hasLength(1));
    });

    test(
      'Bluetooth off reports session loss once and releases the native link',
      () async {
        await manager.dispose();
        final closed = <LedgerDevice>[];
        manager = AppLedgerBleConnectionManager(
          bleManager: ble,
          options: LedgerOptions(),
          onSessionClosed: (device, error) => closed.add(device),
        );
        await connect();
        ble.bluetoothStatuses.add(BleStatus.poweredOff);
        await flush();
        expect(closed, [device]);
        expect(manager.devices, isEmpty);
        expect(ble.connections.single.hasListener, isFalse);
        await manager.disconnect(device);
        expect(closed, [device]);
      },
    );

    test(
      'pending APDU activity and protocol failure are reported without closing session',
      () async {
        await manager.dispose();
        final activity = <bool>[];
        final errors = <Object>[];
        final closed = <LedgerDevice>[];
        manager = AppLedgerBleConnectionManager(
          bleManager: ble,
          options: LedgerOptions(),
          onActivityChanged: (_, pending) => activity.add(pending),
          onOperationError: (_, error) => errors.add(error),
          onSessionClosed: (device, _) => closed.add(device),
        );
        await connect();
        final pending = expectLater(
          manager.sendOperation<int>(device, Probe(), const MinaTransformer()),
          throwsA(ledgerError),
        );
        await flush();
        expect(activity, [true]);
        ble.respond([0x55, 0x15]);
        await pending;
        expect(activity, [true, false]);
        expect((errors.single as LedgerException).errorCode, 0x5515);
        expect(closed, isEmpty);
        expect(manager.devices, [device]);
      },
    );

    for (final end in [false, true]) {
      test(
        'Bluetooth status stream ${end ? "end" : "error"} invalidates active sessions',
        () async {
          await manager.dispose();
          final closed = <LedgerDevice>[];
          manager = AppLedgerBleConnectionManager(
            bleManager: ble,
            options: LedgerOptions(),
            onSessionClosed: (device, _) => closed.add(device),
          );
          await connect();
          if (end) {
            await ble.bluetoothStatuses.close();
          } else {
            ble.bluetoothStatuses.addError(
              StateError('Bluetooth status failed'),
            );
          }
          await flush();
          expect(closed, [device]);
          expect(manager.devices, isEmpty);
          expect(ble.connections.single.hasListener, isFalse);
        },
      );
    }

    test('notification error also clears the native connection', () async {
      await connect();
      ble.notifications.addError(StateError('notification transport failed'));
      await flush();
      expect(manager.devices, isEmpty);
      expect(ble.connections.single.hasListener, isFalse);
    });

    test(
      'initialization timeout cancels native subscription and ignores late discovery',
      () async {
        await manager.dispose();
        manager = AppLedgerBleConnectionManager(
          bleManager: ble,
          options: LedgerOptions(
            connectionTimeout: const Duration(milliseconds: 30),
          ),
        );
        final discovery = Completer<List<DiscoveredService>>();
        ble.discovery = () => discovery.future;
        final failed = expectLater(
          manager.connect(device),
          throwsA(ledgerError),
        );
        await flush();
        ble.state(DeviceConnectionState.connected);
        await failed;
        await flush();
        expect(ble.connections.single.hasListener, isFalse);
        discovery.complete(services);
        await flush();
        expect(ble.serviceReads, 0);
        expect(manager.devices, isEmpty);
        expect(ble.notifications.hasListener, isFalse);
      },
    );

    test(
      'bonding discovery retry remains within the same native session',
      () async {
        ble.discovery = () async {
          if (ble.discoveries == 1) throw StateError('bonding in progress');
          return services;
        };
        await connect();
        expect(ble.discoveries, 2);
        expect(ble.serviceReads, 1);
        expect(ble.connections, hasLength(1));
        expect(manager.devices, [device]);
      },
    );

    test(
      'disconnect after successful connect fails pending APDU and removes device',
      () async {
        await connect();
        final response = expectLater(
          manager.sendOperation<int>(device, Probe(), null),
          throwsA(ledgerError),
        );
        await flush();
        ble.state(DeviceConnectionState.disconnected);
        await response;
        expect(manager.devices, isEmpty);
        expect(ble.notifications.hasListener, isFalse);
      },
    );

    test(
      'known device connects without advertising and duplicate events initialize only once',
      () async {
        final first = manager.connect(device);
        final second = manager.connect(device);
        await flush();
        expect(ble.connections, hasLength(1));
        expect(ble.directConnects, 1);
        expect(ble.nativeConnectionTimeout, const Duration(seconds: 2));
        ble.state(DeviceConnectionState.connected);
        ble.state(DeviceConnectionState.connected);
        await Future.wait([first, second]);
        expect(ble.discoveries, 1);
        expect(ble.serviceReads, 1);
      },
    );

    test(
      'cancel while requesting permission prevents late native connection',
      () async {
        await manager.dispose();
        final permission = Completer<bool>();
        manager = AppLedgerBleConnectionManager(
          bleManager: ble,
          options: LedgerOptions(),
          onPermissionRequest: (_) => permission.future,
        );
        final pending = expectLater(
          manager.connect(device),
          throwsA(ledgerError),
        );
        await manager.disconnect(device);
        permission.complete(true);
        await pending;
        await flush();
        expect(ble.connections, isEmpty);
      },
    );

    test(
      'late service discovery from cancelled connection cannot affect replacement',
      () async {
        final oldDiscovery = Completer<List<DiscoveredService>>();
        ble.discovery = () => oldDiscovery.future;
        final old = expectLater(manager.connect(device), throwsA(ledgerError));
        await flush();
        ble.state(DeviceConnectionState.connected);
        await manager.disconnect(device);
        await old;
        ble.discovery = null;
        await connect();
        oldDiscovery.complete(services);
        await flush();
        expect(manager.devices, [device]);
        ble.onWrite = () async {
          ble.respond([3, 0x90, 0]);
        };
        expect(await manager.sendOperation<int>(device, Probe(), null), 3);
      },
    );

    test(
      'native stream ending before connect completes releases the request',
      () async {
        final pending = expectLater(
          manager.connect(device),
          throwsA(ledgerError),
        );
        await flush();
        await ble.connections.single.close();
        await pending;
        expect(manager.devices, isEmpty);
      },
    );
  });
}
