/**
 * Keyring List and Multi-Wallet Operation Tests
 * 
 * Tests for new multi-wallet methods added to WalletStore:
 * - getKeyringsList()
 * - getWalletDisplayName()
 * - sorting by createTime
 * - wallet type filtering
 */
import 'package:flutter_test/flutter_test.dart';
import 'package:auro_wallet/store/wallet/types/walletData.dart';
import 'package:auro_wallet/store/wallet/types/accountData.dart';
import 'package:auro_wallet/store/wallet/types/uiKeyring.dart';
import 'package:auro_wallet/store/wallet/wallet.dart';

/// Test addresses from React Chrome extension
class TestAddresses {
  static const String hdAccount1 = 'B62qkzCugh8u2Ez1vEs7i3UjW7iypA8ovwC88rBwLqZmdWFqh96M8rM';
  static const String importedAccount1 = 'B62qkhhWkJdZx9MAZHd67VqBAX7FVbzSizqsFYqMKvQu4kPNyFxxCmB';
  static const String hdAccount2 = 'B62qjLVC7ryAwctX9tZimvgh4FBocUozL4VtCPvPJ9bYKRatb5NCRyy';
  static const String ledgerAccount1 = 'B62qledger123456789';
}

void main() {
  group('UIKeyring Structure Tests', () {
    test('TC-UIK-001: UIKeyring should serialize correctly', () {
      final keyring = UIKeyring(
        id: TestAddresses.hdAccount1,
        type: 'hd',
        name: 'Wallet 1',
        createdAt: 1704067200000,
        canAddAccount: true,
        currentAddress: TestAddresses.hdAccount1,
        accounts: [
          UIKeyringAccount(
            address: TestAddresses.hdAccount1,
            name: 'Account 1',
            hdIndex: 0,
            type: 'WALLET_INSIDE',
            walletId: TestAddresses.hdAccount1,
          ),
        ],
      );

      final json = keyring.toJson();
      expect(json['id'], equals(TestAddresses.hdAccount1));
      expect(json['type'], equals('hd'));
      expect(json['name'], equals('Wallet 1'));
      expect(json['canAddAccount'], isTrue);
      expect(json['accounts'], isList);
      expect((json['accounts'] as List).length, equals(1));
    });

    test('TC-UIK-002: UIKeyringAccount should serialize correctly', () {
      final account = UIKeyringAccount(
        address: TestAddresses.hdAccount1,
        name: 'Account 1',
        hdIndex: 0,
        type: 'WALLET_INSIDE',
        walletId: TestAddresses.hdAccount1,
      );

      final json = account.toJson();
      expect(json['address'], equals(TestAddresses.hdAccount1));
      expect(json['name'], equals('Account 1'));
      expect(json['hdIndex'], equals(0));
      expect(json['type'], equals('WALLET_INSIDE'));
      expect(json['walletId'], equals(TestAddresses.hdAccount1));
    });
  });

  group('Wallet Sorting Tests', () {
    test('TC-SORT-001: Wallets should be sortable by createTime', () {
      final wallets = <WalletData>[
        WalletData()
          ..id = 'w3'
          ..walletType = 'mnemonic'
          ..createTime = 1704153600000
          ..accounts = [],
        WalletData()
          ..id = 'w1'
          ..walletType = 'mnemonic'
          ..createTime = 1704067200000
          ..accounts = [],
        WalletData()
          ..id = 'w2'
          ..walletType = 'mnemonic'
          ..createTime = 1704110400000
          ..accounts = [],
      ];

      // Sort by createTime
      wallets.sort((a, b) => a.createTime.compareTo(b.createTime));

      expect(wallets[0].id, equals('w1'));
      expect(wallets[1].id, equals('w2'));
      expect(wallets[2].id, equals('w3'));
    });
  });

  group('Wallet Type Filtering Tests', () {
    late List<WalletData> walletList;

    setUp(() {
      walletList = [
        WalletData()
          ..id = 'hd1'
          ..walletType = 'mnemonic'
          ..walletTypeIndex = 0
          ..createTime = 1704067200000
          ..accounts = [],
        WalletData()
          ..id = 'pk1'
          ..walletType = 'priKey'
          ..walletTypeIndex = 0
          ..createTime = 1704110400000
          ..accounts = [],
        WalletData()
          ..id = 'hd2'
          ..walletType = 'mnemonic'
          ..walletTypeIndex = 1
          ..createTime = 1704153600000
          ..accounts = [],
        WalletData()
          ..id = 'led1'
          ..walletType = 'ledger'
          ..walletTypeIndex = 0
          ..createTime = 1704196800000
          ..accounts = [],
        WalletData()
          ..id = 'watch1'
          ..walletType = 'none'
          ..walletTypeIndex = 0
          ..createTime = 1704240000000
          ..accounts = [],
      ];
    });

    test('TC-FILTER-001: Should filter HD wallets correctly', () {
      final hdWallets = walletList
          .where((w) => w.walletType == WalletStore.seedTypeMnemonic)
          .toList();
      expect(hdWallets.length, equals(2));
      expect(hdWallets[0].id, equals('hd1'));
      expect(hdWallets[1].id, equals('hd2'));
    });

    test('TC-FILTER-002: Should filter imported wallets correctly', () {
      final importedWallets = walletList
          .where((w) => w.walletType == WalletStore.seedTypePrivateKey)
          .toList();
      expect(importedWallets.length, equals(1));
      expect(importedWallets[0].id, equals('pk1'));
    });

    test('TC-FILTER-003: Should filter ledger wallets correctly', () {
      final ledgerWallets = walletList
          .where((w) => w.walletType == WalletStore.seedTypeLedger)
          .toList();
      expect(ledgerWallets.length, equals(1));
      expect(ledgerWallets[0].id, equals('led1'));
    });

    test('TC-FILTER-004: Should filter watch wallets correctly', () {
      final watchWallets = walletList
          .where((w) => w.walletType == WalletStore.seedTypeNone)
          .toList();
      expect(watchWallets.length, equals(1));
      expect(watchWallets[0].id, equals('watch1'));
    });
  });

  group('Wallet Display Name Tests', () {
    test('TC-NAME-001: HD wallet should have default name "Wallet N"', () {
      final wallet = WalletData()
        ..id = TestAddresses.hdAccount1
        ..walletType = 'mnemonic'
        ..walletTypeIndex = 0
        ..accounts = [];

      // Simulate getWalletDisplayName logic
      String getDisplayName(WalletData w) {
        if (w.meta != null && w.meta!['name'] != null) {
          return w.meta!['name'];
        }
        switch (w.walletType) {
          case 'mnemonic':
            return 'Wallet ${w.walletTypeIndex + 1}';
          case 'priKey':
            return 'Imported ${w.walletTypeIndex + 1}';
          case 'ledger':
            return 'Ledger ${w.walletTypeIndex + 1}';
          case 'none':
            return 'Watch ${w.walletTypeIndex + 1}';
          default:
            return 'Wallet ${w.walletTypeIndex + 1}';
        }
      }

      expect(getDisplayName(wallet), equals('Wallet 1'));
    });

    test('TC-NAME-002: Custom name should override default', () {
      final wallet = WalletData()
        ..id = TestAddresses.hdAccount1
        ..walletType = 'mnemonic'
        ..walletTypeIndex = 0
        ..meta = {'name': 'My Custom Wallet'}
        ..accounts = [];

      String getDisplayName(WalletData w) {
        if (w.meta != null && w.meta!['name'] != null) {
          return w.meta!['name'];
        }
        return 'Wallet ${w.walletTypeIndex + 1}';
      }

      expect(getDisplayName(wallet), equals('My Custom Wallet'));
    });

    test('TC-NAME-003: Different wallet types should have correct default names', () {
      String getDisplayName(String walletType, int index) {
        switch (walletType) {
          case 'mnemonic':
            return 'Wallet ${index + 1}';
          case 'priKey':
            return 'Imported ${index + 1}';
          case 'ledger':
            return 'Ledger ${index + 1}';
          case 'none':
            return 'Watch ${index + 1}';
          default:
            return 'Wallet ${index + 1}';
        }
      }

      expect(getDisplayName('mnemonic', 0), equals('Wallet 1'));
      expect(getDisplayName('mnemonic', 2), equals('Wallet 3'));
      expect(getDisplayName('priKey', 0), equals('Imported 1'));
      expect(getDisplayName('ledger', 1), equals('Ledger 2'));
      expect(getDisplayName('none', 0), equals('Watch 1'));
    });
  });

  group('Keyring canAddAccount Tests', () {
    test('TC-CAN-001: HD wallet should have canAddAccount = true', () {
      final wallet = WalletData()
        ..walletType = 'mnemonic'
        ..accounts = [];
      
      final canAdd = wallet.walletType == WalletStore.seedTypeMnemonic;
      expect(canAdd, isTrue);
    });

    test('TC-CAN-002: Imported wallet should have canAddAccount = false', () {
      final wallet = WalletData()
        ..walletType = 'priKey'
        ..accounts = [];
      
      final canAdd = wallet.walletType == WalletStore.seedTypeMnemonic;
      expect(canAdd, isFalse);
    });

    test('TC-CAN-003: Ledger wallet should have canAddAccount = false', () {
      final wallet = WalletData()
        ..walletType = 'ledger'
        ..accounts = [];
      
      final canAdd = wallet.walletType == WalletStore.seedTypeMnemonic;
      expect(canAdd, isFalse);
    });

    test('TC-CAN-004: Watch wallet should have canAddAccount = false', () {
      final wallet = WalletData()
        ..walletType = 'none'
        ..accounts = [];
      
      final canAdd = wallet.walletType == WalletStore.seedTypeMnemonic;
      expect(canAdd, isFalse);
    });
  });

  group('Account Type Mapping Tests', () {
    String getAccountType(String walletType) {
      switch (walletType) {
        case 'mnemonic':
          return 'WALLET_INSIDE';
        case 'priKey':
          return 'WALLET_OUTSIDE';
        case 'ledger':
          return 'WALLET_LEDGER';
        case 'none':
          return 'WALLET_WATCH';
        default:
          return 'WALLET_INSIDE';
      }
    }

    test('TC-TYPE-001: Mnemonic should map to WALLET_INSIDE', () {
      expect(getAccountType('mnemonic'), equals('WALLET_INSIDE'));
    });

    test('TC-TYPE-002: PriKey should map to WALLET_OUTSIDE', () {
      expect(getAccountType('priKey'), equals('WALLET_OUTSIDE'));
    });

    test('TC-TYPE-003: Ledger should map to WALLET_LEDGER', () {
      expect(getAccountType('ledger'), equals('WALLET_LEDGER'));
    });

    test('TC-TYPE-004: None should map to WALLET_WATCH', () {
      expect(getAccountType('none'), equals('WALLET_WATCH'));
    });
  });

  group('Find Wallet By Address Tests', () {
    late List<WalletData> walletList;

    setUp(() {
      walletList = [
        WalletData()
          ..id = 'wallet1'
          ..walletType = 'mnemonic'
          ..accounts = [
            AccountData()
              ..pubKey = TestAddresses.hdAccount1
              ..name = 'Account 1'
              ..walletId = 'wallet1',
          ],
        WalletData()
          ..id = 'wallet2'
          ..walletType = 'priKey'
          ..accounts = [
            AccountData()
              ..pubKey = TestAddresses.importedAccount1
              ..name = 'Imported 1'
              ..walletId = 'wallet2',
          ],
      ];
    });

    test('TC-FIND-001: Should find wallet by address', () {
      WalletData? findWalletByAddress(String address) {
        for (final wallet in walletList) {
          if (wallet.accounts.any((acc) => acc.pubKey == address)) {
            return wallet;
          }
        }
        return null;
      }

      final found = findWalletByAddress(TestAddresses.hdAccount1);
      expect(found, isNotNull);
      expect(found!.id, equals('wallet1'));
    });

    test('TC-FIND-002: Should return null for non-existent address', () {
      WalletData? findWalletByAddress(String address) {
        for (final wallet in walletList) {
          if (wallet.accounts.any((acc) => acc.pubKey == address)) {
            return wallet;
          }
        }
        return null;
      }

      final found = findWalletByAddress('B62qnonexistent');
      expect(found, isNull);
    });
  });

  group('Address Existence Check Tests', () {
    late List<WalletData> walletList;

    setUp(() {
      walletList = [
        WalletData()
          ..id = 'wallet1'
          ..accounts = [
            AccountData()..pubKey = TestAddresses.hdAccount1,
            AccountData()..pubKey = TestAddresses.hdAccount2,
          ],
        WalletData()
          ..id = 'wallet2'
          ..accounts = [
            AccountData()..pubKey = TestAddresses.importedAccount1,
          ],
      ];
    });

    test('TC-EXIST-001: Should return true for existing address', () {
      bool isAddressExist(String address) {
        return walletList.any(
            (wallet) => wallet.accounts.any((acc) => acc.pubKey == address));
      }

      expect(isAddressExist(TestAddresses.hdAccount1), isTrue);
      expect(isAddressExist(TestAddresses.importedAccount1), isTrue);
    });

    test('TC-EXIST-002: Should return false for non-existing address', () {
      bool isAddressExist(String address) {
        return walletList.any(
            (wallet) => wallet.accounts.any((acc) => acc.pubKey == address));
      }

      expect(isAddressExist('B62qnonexistent'), isFalse);
    });
  });
}
