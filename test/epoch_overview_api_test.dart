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
