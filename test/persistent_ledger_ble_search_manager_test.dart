import 'dart:async';
import 'dart:typed_data';

import 'package:auro_wallet/utils/persistentLedgerBleSearchManager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger_flutter/ledger_flutter.dart';

void main() {
  test('retries a synchronous native scan startup failure', () async {
    final source = StreamController<DiscoveredDevice>();
    var starts = 0;
    final manager = PersistentLedgerBleSearchManager(
      options: LedgerOptions(),
      statusProvider: () => BleStatus.ready,
      restartDelay: const Duration(milliseconds: 1),
      scanForDevices: (_, __, ___) {
        if (++starts == 1) throw StateError('scanner startup failed');
        return source.stream;
      },
    );
    final subscription = manager.scan().listen((_) {});
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(starts, 2);
    expect(source.hasListener, isTrue);
    await subscription.cancel();
    await manager.stop();
    await source.close();
  });

  test('old scan cancellation cannot stop a newly opened sheet', () async {
    final cancellation = Completer<void>();
    final first = StreamController<DiscoveredDevice>(
      onCancel: () => cancellation.future,
    );
    final second = StreamController<DiscoveredDevice>();
    var starts = 0;
    final manager = PersistentLedgerBleSearchManager(
      options: LedgerOptions(),
      statusProvider: () => BleStatus.ready,
      scanForDevices: (_, __, ___) =>
          ++starts == 1 ? first.stream : second.stream,
    );
    final oldSubscription = manager.scan().listen((_) {});
    await Future<void>.delayed(Duration.zero);
    final stopping = manager.stop();
    final nextSubscription = manager.scan().listen((_) {});
    await Future<void>.delayed(Duration.zero);
    expect(starts, 1);
    cancellation.complete();
    await stopping;
    await Future<void>.delayed(Duration.zero);
    expect(starts, 2);
    expect(second.hasListener, isTrue);
    await oldSubscription.cancel();
    expect(second.hasListener, isTrue);
    await nextSubscription.cancel();
    await manager.stop();
    await first.close();
    await second.close();
  });
  LedgerOptions options() => LedgerOptions(
    scanMode: ScanMode.lowLatency,
    requireLocationServicesEnabled: true,
  );

  DiscoveredDevice ledgerAdvertisement() => DiscoveredDevice(
    id: 'ledger-id',
    name: 'Nano X',
    serviceData: const {},
    manufacturerData: Uint8List(0),
    rssi: -42,
    serviceUuids: [Uuid.parse(PersistentLedgerBleSearchManager.serviceId)],
  );

  test('accepts a Ledger service carried as service data', () {
    final device = DiscoveredDevice(
      id: 'ledger-service-data',
      name: '',
      serviceData: {
        Uuid.parse(PersistentLedgerBleSearchManager.serviceId): Uint8List(0),
      },
      manufacturerData: Uint8List(0),
      rssi: -45,
      serviceUuids: const [],
    );

    expect(PersistentLedgerBleSearchManager.isLedgerCandidate(device), isTrue);
  });

  test('accepts a Ledger service carried in the service list', () {
    final device = DiscoveredDevice(
      id: 'ledger-service-list',
      name: '',
      serviceData: const {},
      manufacturerData: Uint8List(0),
      rssi: -45,
      serviceUuids: [Uuid.parse(PersistentLedgerBleSearchManager.serviceId)],
    );

    expect(PersistentLedgerBleSearchManager.isLedgerCandidate(device), isTrue);
  });

  test('does not identify a device from its advertised name', () {
    final device = DiscoveredDevice(
      id: 'nano-x-suffixed',
      name: 'Nano X A1B2',
      serviceData: const {},
      manufacturerData: Uint8List(0),
      rssi: -45,
      serviceUuids: const [],
    );

    expect(PersistentLedgerBleSearchManager.isLedgerCandidate(device), isFalse);
  });

  test('rejects unrelated BLE advertisements', () {
    final device = DiscoveredDevice(
      id: 'other-id',
      name: 'Headphones',
      serviceData: const {},
      manufacturerData: Uint8List(0),
      rssi: -50,
      serviceUuids: const [],
    );

    expect(PersistentLedgerBleSearchManager.isLedgerCandidate(device), isFalse);
  });

  test('does not emit unrelated BLE advertisements', () async {
    final source = StreamController<DiscoveredDevice>();
    final manager = PersistentLedgerBleSearchManager(
      options: options(),
      onPermissionRequest: (_) async => true,
      statusProvider: () => BleStatus.ready,
      scanForDevices: (_, __, ___) => source.stream,
    );
    final discovered = <LedgerDevice>[];
    final subscription = manager.scan().listen(discovered.add);

    await Future<void>.delayed(Duration.zero);
    source.add(
      DiscoveredDevice(
        id: 'other-id',
        name: 'Headphones',
        serviceData: const {},
        manufacturerData: Uint8List(0),
        rssi: -50,
        serviceUuids: const [],
      ),
    );
    source.add(ledgerAdvertisement());
    await Future<void>.delayed(Duration.zero);

    expect(discovered, hasLength(1));
    expect(discovered.single.id, 'ledger-id');
    await subscription.cancel();
    await manager.stop();
    await source.close();
  });

  test(
    'recreates a terminated native scan while the sheet remains open',
    () async {
      final first = StreamController<DiscoveredDevice>();
      final second = StreamController<DiscoveredDevice>();
      var scansStarted = 0;
      final restarted = Completer<void>();
      List<Uuid>? requestedServices;
      final manager = PersistentLedgerBleSearchManager(
        options: options(),
        onPermissionRequest: (_) async => true,
        statusProvider: () => BleStatus.ready,
        restartDelay: const Duration(milliseconds: 1),
        scanForDevices: (services, __, ___) {
          requestedServices = services;
          scansStarted++;
          if (scansStarted == 2) restarted.complete();
          return scansStarted == 1 ? first.stream : second.stream;
        },
      );
      final discovered = <LedgerDevice>[];
      final subscription = manager.scan().listen(discovered.add);

      await Future<void>.delayed(Duration.zero);
      expect(scansStarted, 1);
      expect(requestedServices, isEmpty);

      first.addError(StateError('scanner interrupted'));
      await restarted.future.timeout(const Duration(seconds: 1));
      expect(scansStarted, 2);

      second.add(ledgerAdvertisement());
      await Future<void>.delayed(Duration.zero);
      expect(discovered.single.name, 'Nano X');

      await subscription.cancel();
      await manager.stop();
      await first.close();
      await second.close();
    },
  );

  test('does not restart a scan after it is stopped', () async {
    final source = StreamController<DiscoveredDevice>();
    var scansStarted = 0;
    final manager = PersistentLedgerBleSearchManager(
      options: options(),
      onPermissionRequest: (_) async => true,
      statusProvider: () => BleStatus.ready,
      restartDelay: const Duration(milliseconds: 10),
      scanForDevices: (_, __, ___) {
        scansStarted++;
        return source.stream;
      },
    );
    final subscription = manager.scan().listen((_) {});

    await Future<void>.delayed(Duration.zero);
    source.addError(StateError('scanner interrupted'));
    await manager.stop();
    await Future<void>.delayed(const Duration(milliseconds: 30));

    expect(scansStarted, 1);
    await subscription.cancel();
    await source.close();
  });

  test('restarts when the native scan stream ends without a device', () async {
    final first = StreamController<DiscoveredDevice>();
    final second = StreamController<DiscoveredDevice>();
    var scansStarted = 0;
    final manager = PersistentLedgerBleSearchManager(
      options: options(),
      onPermissionRequest: (_) async => true,
      statusProvider: () => BleStatus.ready,
      restartDelay: const Duration(milliseconds: 1),
      scanForDevices: (_, __, ___) {
        scansStarted++;
        return scansStarted == 1 ? first.stream : second.stream;
      },
    );
    final subscription = manager.scan().listen((_) {});

    await Future<void>.delayed(Duration.zero);
    await first.close();
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(scansStarted, 2);
    await subscription.cancel();
    await manager.stop();
    await second.close();
  });

  test('waits for native scan cancellation before restarting', () async {
    final cancellation = Completer<void>();
    final first = StreamController<DiscoveredDevice>(
      onCancel: () => cancellation.future,
    );
    final second = StreamController<DiscoveredDevice>();
    var scansStarted = 0;
    final manager = PersistentLedgerBleSearchManager(
      options: options(),
      onPermissionRequest: (_) async => true,
      statusProvider: () => BleStatus.ready,
      restartDelay: const Duration(milliseconds: 1),
      scanForDevices: (_, __, ___) {
        scansStarted++;
        return scansStarted == 1 ? first.stream : second.stream;
      },
    );
    final subscription = manager.scan().listen((_) {});

    await Future<void>.delayed(Duration.zero);
    first.addError(StateError('scanner interrupted'));
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(scansStarted, 1);

    cancellation.complete();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(scansStarted, 2);

    await subscription.cancel();
    await manager.stop();
    await second.close();
  });

  test('does not restart twice while one native scan is cancelling', () async {
    final cancellation = Completer<void>();
    final first = StreamController<DiscoveredDevice>(
      onCancel: () => cancellation.future,
    );
    final second = StreamController<DiscoveredDevice>();
    var scansStarted = 0;
    final manager = PersistentLedgerBleSearchManager(
      options: options(),
      onPermissionRequest: (_) async => true,
      statusProvider: () => BleStatus.ready,
      restartDelay: const Duration(milliseconds: 1),
      scanForDevices: (_, __, ___) {
        scansStarted++;
        return scansStarted == 1 ? first.stream : second.stream;
      },
    );
    final subscription = manager.scan().listen((_) {});

    await Future<void>.delayed(Duration.zero);
    first.addError(StateError('first scanner interruption'));
    first.addError(StateError('duplicate scanner interruption'));
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(scansStarted, 1);

    cancellation.complete();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(scansStarted, 2);

    await subscription.cancel();
    await manager.stop();
    await second.close();
  });

  test('does not let a cancelled session restart a newer scan', () async {
    final cancellation = Completer<void>();
    final first = StreamController<DiscoveredDevice>(
      onCancel: () => cancellation.future,
    );
    final second = StreamController<DiscoveredDevice>();
    var scansStarted = 0;
    final manager = PersistentLedgerBleSearchManager(
      options: options(),
      onPermissionRequest: (_) async => true,
      statusProvider: () => BleStatus.ready,
      restartDelay: const Duration(milliseconds: 1),
      scanForDevices: (_, __, ___) {
        scansStarted++;
        return scansStarted == 1 ? first.stream : second.stream;
      },
    );
    final firstSubscription = manager.scan().listen((_) {});

    await Future<void>.delayed(Duration.zero);
    first.addError(StateError('scanner interrupted'));
    await Future<void>.delayed(Duration.zero);
    final stop = manager.stop();
    cancellation.complete();
    await stop;
    await firstSubscription.cancel();

    final secondSubscription = manager.scan().listen((_) {});
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(scansStarted, 2);

    await secondSubscription.cancel();
    await manager.stop();
    await second.close();
  });
}
