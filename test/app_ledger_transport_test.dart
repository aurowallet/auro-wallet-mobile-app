import 'dart:async';
import 'dart:typed_data';

import 'package:auro_wallet/ledgerMina/ledger_error.dart';
import 'package:auro_wallet/ledgerMina/mina_transformer.dart';
import 'package:auro_wallet/ledgerMina/operations/mina_public_key_operation.dart';
import 'package:auro_wallet/ledgerMina/operations/mina_name_operation.dart';
import 'package:auro_wallet/ledgerMina/operations/mina_version_operation.dart';
import 'package:auro_wallet/utils/appLedgerBleConnectionManager.dart';
import 'package:auro_wallet/utils/appLedgerGattGateway.dart';
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
  final connections = <StreamController<ConnectionStateUpdate>>[];
  final packets = <List<int>>[];
  Future<void> Function()? onWrite;
  Future<List<DiscoveredService>> Function()? discovery;
  Object? mtuError;
  Object? subscribeError;
  int discoveries = 0;
  int serviceReads = 0;
  List<DiscoveredService>? discoveredServices;
  List<Uuid>? prescanFilter;

  @override
  BleStatus get status => BleStatus.ready;
  @override
  Stream<BleStatus> get statusStream => bluetoothStatuses.stream;
  @override
  Stream<ConnectionStateUpdate> connectToAdvertisingDevice({
    required String id,
    required List<Uuid> withServices,
    required Duration prescanDuration,
    Duration? connectionTimeout,
    Map<Uuid, List<Uuid>>? servicesWithCharacteristicsToDiscover,
  }) {
    prescanFilter = withServices;
    final source = StreamController<ConnectionStateUpdate>(sync: true);
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
  Future<void> writeCharacteristicWithResponse(
    QualifiedCharacteristic characteristic, {
    required List<int> value,
  }) async {
    packets.add(value);
    await onWrite?.call();
  }

  void respond(List<int> data) {
    for (final packet in LedgerPacker().pack(Uint8List.fromList(data), 23)) {
      notifications.add(packet);
    }
  }

  Future<void> close() async {
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
      'duplicate connect and connected events initialize only once',
      () async {
        final first = manager.connect(device);
        final second = manager.connect(device);
        await flush();
        expect(ble.connections, hasLength(1));
        expect(ble.prescanFilter, isEmpty);
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
