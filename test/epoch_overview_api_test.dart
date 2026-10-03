import 'dart:async';

import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/service/api/apiStaking.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/settings/settings.dart';
import 'package:auro_wallet/store/settings/types/customNode.dart';
import 'package:auro_wallet/store/staking/staking.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Api extends Fake implements Api {
  @override
  late GraphQLClient graphQLClient;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    globalAppStore.settings = SettingsStore(globalAppStore)
      ..currentNode = CustomNode(
        name: 'Mainnet',
        networkID: 'mina:mainnet',
        url: 'https://node.example',
      );
    globalAppStore.staking = StakingStore(globalAppStore);
  });

  for (final useStrings in [true, false]) {
    test(
      'overview accepts ${useStrings ? 'string' : 'numeric'} consensus fields',
      () async {
        final api = _Api()
          ..graphQLClient = GraphQLClient(
            link: Link.function((request, [_]) async* {
              yield Response(
                response: const {},
                data: request.variables.containsKey('stateHash')
                    ? {
                        'block': {
                          'protocolState': {
                            'consensusState': {
                              'epoch': useStrings ? '2' : 2,
                              'slot': useStrings ? '6' : 6,
                            },
                          },
                        },
                      }
                    : {
                        'daemonStatus': {
                          'stateHash': 'state',
                          'blockchainLength': '99',
                          'consensusConfiguration': {
                            'slotsPerEpoch': 7140,
                            'slotDuration': 90000,
                            'epochDuration': 642600000,
                          },
                        },
                      },
              );
            }),
            cache: GraphQLCache(),
          );
        await ApiStaking(api).fetchStakingOverview();
        final data = globalAppStore.staking!.overviewData;
        expect(data.epochDays, 7.5);
        expect(data.epoch, 2);
        expect(data.slot, 6);
        expect(data.blockchainLength, 99);
        expect(data.hasEpochInfo, isTrue);
      },
    );
  }

  for (final switchNetwork in [false, true]) {
    for (final outcome in ['success', 'missing', 'malformed']) {
      test('late block $outcome cannot replace or clear a newer overview (switch=$switchNetwork)', () async {
        final oldBlock = Completer<Response>();
        final blockStarted = Completer<void>();
        var refresh = 0;
        final api = _Api()
          ..graphQLClient = GraphQLClient(
            link: Link.function((request, [_]) async* {
              final hash = request.variables['stateHash'];
              if (hash == null) {
                yield Response(response: const {}, data: {
                  'daemonStatus': {
                    'stateHash': '${++refresh}',
                    'blockchainLength': '99',
                    'consensusConfiguration': {
                      'slotsPerEpoch': 7140,
                      'slotDuration': 90000,
                      'epochDuration': 642600000,
                    },
                  },
                });
              } else if (hash == '1') {
                blockStarted.complete();
                yield await oldBlock.future;
              } else {
                yield Response(response: const {}, data: {
                  'block': {'protocolState': {'consensusState': {'epoch': '99', 'slot': '6'}}},
                });
              }
            }),
            cache: GraphQLCache(),
          );
        final staking = ApiStaking(api);
        final pending = staking.fetchStakingOverview();
        await blockStarted.future;
        if (switchNetwork) {
          globalAppStore.settings!.currentNode = CustomNode(
            name: 'Devnet', networkID: 'mina:devnet', url: 'https://dev.example',
          );
        }
        await staking.fetchStakingOverview();
        final latest = globalAppStore.staking!.overviewData;
        expect(latest.epoch, 99);
        oldBlock.complete(Response(response: const {}, data: {
          'block': outcome == 'missing' ? null : {
            'protocolState': outcome == 'malformed' ? 'invalid' : {
              'consensusState': {'epoch': '1', 'slot': '0'},
            },
          },
        }));
        await pending;
        expect(identical(globalAppStore.staking!.overviewData, latest), isTrue);
        expect(latest.epochDays, 7.5);
      });
    }
  }

  for (final missingDaemon in [true, false]) {
    test(
      'missing ${missingDaemon ? 'daemon' : 'block'} clears stale overview without inventing epoch zero',
      () async {
        globalAppStore.staking!.setOverviewInfo({
          'epoch': 20,
          'slot': 1,
          'slotDuration': 90000,
          'slotsPerEpoch': 7140,
        }, shouldCache: false);
        final api = _Api()
          ..graphQLClient = GraphQLClient(
            link: Link.function((request, [_]) async* {
              yield Response(
                response: const {},
                data: request.variables.containsKey('stateHash')
                    ? {'block': null}
                    : {
                        'daemonStatus': missingDaemon
                            ? null
                            : {
                                'stateHash': 'state',
                                'blockchainLength': '99',
                                'consensusConfiguration': {
                                  'slotsPerEpoch': 7140,
                                  'slotDuration': 90000,
                                  'epochDuration': 642600000,
                                },
                              },
                      },
              );
            }),
            cache: GraphQLCache(),
          );
        await ApiStaking(api).fetchStakingOverview();
        expect(globalAppStore.staking!.overviewData.hasEpochInfo, isFalse);
      },
    );
  }
}
