/**
 * Multi-Wallet Functionality Tests
 * 
 * Tests multi-wallet scenario data structure behavior.
 * Verifies that the current structure supports multiple mnemonic wallets.
 * 
 * Based on React Chrome extension vault.test.ts and vaultMigration.test.ts
 * 
 * Test addresses from React extension:
 * - B62qkzCugh8u2Ez1vEs7i3UjW7iypA8ovwC88rBwLqZmdWFqh96M8rM (HD account)
 * - B62qkhhWkJdZx9MAZHd67VqBAX7FVbzSizqsFYqMKvQu4kPNyFxxCmB (Imported account)
 * - B62qjLVC7ryAwctX9tZimvgh4FBocUozL4VtCPvPJ9bYKRatb5NCRyy (HD account)
 */
import 'package:flutter_test/flutter_test.dart';
import 'package:auro_wallet/store/wallet/types/walletData.dart';
import 'package:auro_wallet/store/wallet/types/accountData.dart';
import 'package:auro_wallet/store/wallet/wallet.dart';

/// Real test addresses from React Chrome extension
class TestAddresses {
  static const String hdAccount1 = 'B62qkzCugh8u2Ez1vEs7i3UjW7iypA8ovwC88rBwLqZmdWFqh96M8rM';
  static const String importedAccount1 = 'B62qkhhWkJdZx9MAZHd67VqBAX7FVbzSizqsFYqMKvQu4kPNyFxxCmB';
  static const String hdAccount2 = 'B62qjLVC7ryAwctX9tZimvgh4FBocUozL4VtCPvPJ9bYKRatb5NCRyy';
  static const String ledgerAccount1 = 'B62qledger123456789';
}

void main() {
  group('Multi-Wallet Core Functionality', () {
    
    late List<WalletData> walletList;
    
    setUp(() {
      // Create mock multi-wallet environment
      walletList = [];
    });
    
    /// Simulate WalletStore.addWallet core logic
    WalletData addWallet({
      required String pubKey,
      required String walletType,
      required String name,
    }) {
      final walletTypeIndex = walletList
          .where((w) => w.walletType == walletType)
          .toList()
          .length;
      
      final account = AccountData()
        ..pubKey = pubKey
        ..name = name
        ..accountIndex = 0
        ..walletId = pubKey
        ..createTime = DateTime.now().millisecondsSinceEpoch;
      
      final wallet = WalletData()
        ..id = pubKey
        ..walletType = walletType
        ..walletTypeIndex = walletTypeIndex
        ..source = 'inside'
        ..createTime = DateTime.now().millisecondsSinceEpoch
        ..currentAccountIndex = 0
        ..accounts = [account];
      
      walletList.add(wallet);
      return wallet;
    }
    
    /// Simulate getting all mnemonic wallets
    List<WalletData> getMnemonicWallets() {
      return walletList.where(
        (w) => w.walletType == WalletStore.seedTypeMnemonic
      ).toList();
    }
    
    /// Simulate getting next wallet index of type
    int getNextWalletIndexOfType(String walletType) {
      int index = 0;
      walletList.where((w) => w.walletType == walletType).forEach((w) {
        if (w.walletTypeIndex >= index) {
          index = w.walletTypeIndex + 1;
        }
      });
      return index;
    }
    
    test('TC-CORE-001: Should create first mnemonic wallet', () {
      // When: Create first mnemonic wallet
      final wallet = addWallet(
        pubKey: TestAddresses.hdAccount1,
        walletType: WalletStore.seedTypeMnemonic,
        name: 'Wallet 1',
      );
      
      // Then
      expect(walletList.length, equals(1));
      expect(wallet.walletType, equals('mnemonic'));
      expect(wallet.walletTypeIndex, equals(0));
      expect(getMnemonicWallets().length, equals(1));
    });
    
    test('TC-CORE-002: Should create second mnemonic wallet', () {
      // Given: Already have one mnemonic wallet
      addWallet(
        pubKey: TestAddresses.hdAccount1,
        walletType: WalletStore.seedTypeMnemonic,
        name: 'Wallet 1',
      );
      
      // When: Create second mnemonic wallet
      final wallet2 = addWallet(
        pubKey: TestAddresses.hdAccount2,
        walletType: WalletStore.seedTypeMnemonic,
        name: 'Wallet 2',
      );
      
      // Then
      expect(walletList.length, equals(2));
      expect(wallet2.walletTypeIndex, equals(1));
      expect(getMnemonicWallets().length, equals(2));
    });
    
    test('TC-CORE-003: Should create multiple wallet types', () {
      // When: Create wallets of different types
      addWallet(
        pubKey: TestAddresses.hdAccount1,
        walletType: WalletStore.seedTypeMnemonic,
        name: 'HD Wallet 1',
      );
      addWallet(
        pubKey: TestAddresses.importedAccount1,
        walletType: WalletStore.seedTypePrivateKey,
        name: 'Private Key 1',
      );
      addWallet(
        pubKey: TestAddresses.hdAccount2,
        walletType: WalletStore.seedTypeMnemonic,
        name: 'HD Wallet 2',
      );
      addWallet(
        pubKey: TestAddresses.ledgerAccount1,
        walletType: WalletStore.seedTypeNone,
        name: 'Watch 1',
      );
      
      // Then
      expect(walletList.length, equals(4));
      expect(getMnemonicWallets().length, equals(2));
      expect(
        walletList.where((w) => w.walletType == WalletStore.seedTypePrivateKey).length,
        equals(1)
      );
      expect(
        walletList.where((w) => w.walletType == WalletStore.seedTypeNone).length,
        equals(1)
      );
    });
    
    test('TC-CORE-004: walletTypeIndex should increment correctly', () {
      // When: Create multiple mnemonic wallets
      final w1 = addWallet(pubKey: TestAddresses.hdAccount1, walletType: 'mnemonic', name: 'W1');
      final w2 = addWallet(pubKey: TestAddresses.hdAccount2, walletType: 'mnemonic', name: 'W2');
      final w3 = addWallet(pubKey: TestAddresses.importedAccount1, walletType: 'mnemonic', name: 'W3');
      
      // Then
      expect(w1.walletTypeIndex, equals(0));
      expect(w2.walletTypeIndex, equals(1));
      expect(w3.walletTypeIndex, equals(2));
      expect(getNextWalletIndexOfType('mnemonic'), equals(3));
    });
    
    test('TC-CORE-005: Different wallet types should have independent walletTypeIndex', () {
      // When: Create wallets of different types
      final hd1 = addWallet(pubKey: TestAddresses.hdAccount1, walletType: 'mnemonic', name: 'HD1');
      final pk1 = addWallet(pubKey: TestAddresses.importedAccount1, walletType: 'priKey', name: 'PK1');
      final hd2 = addWallet(pubKey: TestAddresses.hdAccount2, walletType: 'mnemonic', name: 'HD2');
      final pk2 = addWallet(pubKey: TestAddresses.ledgerAccount1, walletType: 'priKey', name: 'PK2');
      
      // Then: Each type index should be independent
      expect(hd1.walletTypeIndex, equals(0));
      expect(hd2.walletTypeIndex, equals(1));
      expect(pk1.walletTypeIndex, equals(0));
      expect(pk2.walletTypeIndex, equals(1));
    });
    
    test('TC-CORE-006: Each wallet should have unique ID', () {
      // When: Create multiple wallets
      addWallet(pubKey: TestAddresses.hdAccount1, walletType: 'mnemonic', name: 'A');
      addWallet(pubKey: TestAddresses.hdAccount2, walletType: 'mnemonic', name: 'B');
      addWallet(pubKey: TestAddresses.importedAccount1, walletType: 'priKey', name: 'C');
      
      // Then: All IDs should be unique
      final ids = walletList.map((w) => w.id).toSet();
      expect(ids.length, equals(3));
    });
    
  });
  
  group('Multi-Wallet Account Management Tests', () {
    
    test('TC-ACC-001: Should add account to specific wallet', () {
      // Given: Two mnemonic wallets
      final account1 = AccountData()
        ..pubKey = TestAddresses.hdAccount1..name = 'A1'..accountIndex = 0..walletId = 'wallet1';
      
      final wallet1 = WalletData()
        ..id = 'wallet1'
        ..walletType = 'mnemonic'
        ..accounts = [account1];
      
      final account2 = AccountData()
        ..pubKey = TestAddresses.hdAccount2..name = 'B1'..accountIndex = 0..walletId = 'wallet2';
      
      final wallet2 = WalletData()
        ..id = 'wallet2'
        ..walletType = 'mnemonic'
        ..accounts = [account2];
      
      // When: Add new account to wallet1
      final newAccount = AccountData()
        ..pubKey = TestAddresses.importedAccount1..name = 'A2'..accountIndex = 1..walletId = 'wallet1';
      wallet1.accounts.add(newAccount);
      
      // Then
      expect(wallet1.accounts.length, equals(2));
      expect(wallet2.accounts.length, equals(1)); // wallet2 not affected
    });
    
    test('TC-ACC-002: Removing account should not affect other wallets', () {
      // Given: Two wallets with accounts
      final wallet1 = WalletData()
        ..id = 'w1'
        ..walletType = 'mnemonic'
        ..accounts = [
          AccountData()..pubKey = TestAddresses.hdAccount1..accountIndex = 0..walletId = 'w1',
          AccountData()..pubKey = TestAddresses.hdAccount2..accountIndex = 1..walletId = 'w1',
        ];
      
      final wallet2 = WalletData()
        ..id = 'w2'
        ..walletType = 'mnemonic'
        ..accounts = [
          AccountData()..pubKey = TestAddresses.importedAccount1..accountIndex = 0..walletId = 'w2',
        ];
      
      // When: Remove one account from wallet1
      wallet1.accounts.removeWhere((a) => a.pubKey == TestAddresses.hdAccount2);
      
      // Then
      expect(wallet1.accounts.length, equals(1));
      expect(wallet2.accounts.length, equals(1));
    });
    
    test('TC-ACC-003: Should calculate next HD account index correctly', () {
      // Given: Wallet with multiple accounts, indices may not be consecutive
      final wallet = WalletData()
        ..id = 'w1'
        ..walletType = 'mnemonic'
        ..accounts = [
          AccountData()..pubKey = 'a0'..accountIndex = 0..walletId = 'w1',
          AccountData()..pubKey = 'a2'..accountIndex = 2..walletId = 'w1', // skipped 1
          AccountData()..pubKey = 'a5'..accountIndex = 5..walletId = 'w1', // skipped 3,4
        ];
      
      // When: Calculate next account index (simulate getNextWalletAccountIndex)
      int nextIndex = 0;
      for (var account in wallet.accounts) {
        if (account.accountIndex > nextIndex) {
          nextIndex = account.accountIndex;
        }
      }
      nextIndex++;
      
      // Then: Should return 6 (max index 5 + 1)
      expect(nextIndex, equals(6));
    });
    
  });
  
  group('Wallet Switching Tests', () {
    
    test('TC-SW-001: Should switch current account between wallets', () {
      // Given: Multiple wallets
      final walletList = <WalletData>[
        WalletData()
          ..id = 'w1'
          ..walletType = 'mnemonic'
          ..currentAccountIndex = 0
          ..accounts = [AccountData()..pubKey = TestAddresses.hdAccount1..accountIndex = 0..walletId = 'w1'],
        WalletData()
          ..id = 'w2'
          ..walletType = 'mnemonic'
          ..currentAccountIndex = 0
          ..accounts = [AccountData()..pubKey = TestAddresses.hdAccount2..accountIndex = 0..walletId = 'w2'],
      ];
      
      String currentWalletId = 'w1';
      
      // When: Switch to wallet2
      WalletData getCurrentWallet() {
        return walletList.firstWhere((w) => w.id == currentWalletId);
      }
      
      expect(getCurrentWallet().id, equals('w1'));
      
      currentWalletId = 'w2';
      
      // Then
      expect(getCurrentWallet().id, equals('w2'));
      expect(getCurrentWallet().currentAccount.pubKey, equals(TestAddresses.hdAccount2));
    });
    
  });
  
  group('JSON Serialization Integrity Tests', () {
    
    test('TC-JSON-001: Complete wallet data should serialize and deserialize correctly', () {
      // Given: Complete wallet data with real addresses
      final originalWallet = WalletData()
        ..id = TestAddresses.hdAccount1
        ..walletType = 'mnemonic'
        ..walletTypeIndex = 2
        ..source = 'outside'
        ..createTime = 1704067200000
        ..currentAccountIndex = 1
        ..meta = {'customKey': 'customValue'}
        ..accounts = [
          AccountData()
            ..pubKey = TestAddresses.hdAccount1
            ..name = 'Account 1'
            ..accountIndex = 0
            ..createTime = 1704067200000
            ..walletId = TestAddresses.hdAccount1,
          AccountData()
            ..pubKey = TestAddresses.hdAccount2
            ..name = 'Account 2'
            ..accountIndex = 1
            ..createTime = 1704153600000
            ..walletId = TestAddresses.hdAccount1,
        ];
      
      // When: Serialize and deserialize
      final json = WalletData.toJson(originalWallet);
      final restored = WalletData.fromJson(json);
      
      // Then: All fields should be correctly restored
      expect(restored.id, equals(originalWallet.id));
      expect(restored.walletType, equals(originalWallet.walletType));
      expect(restored.walletTypeIndex, equals(originalWallet.walletTypeIndex));
      expect(restored.source, equals(originalWallet.source));
      expect(restored.createTime, equals(originalWallet.createTime));
      expect(restored.currentAccountIndex, equals(originalWallet.currentAccountIndex));
      expect(restored.accounts.length, equals(2));
      expect(restored.accounts[0].pubKey, equals(TestAddresses.hdAccount1));
      expect(restored.accounts[1].pubKey, equals(TestAddresses.hdAccount2));
      expect(restored.currentAccount.pubKey, equals(TestAddresses.hdAccount2)); // index 1
    });
    
  });
  
  group('Edge Cases (from React vaultMigration.test.ts)', () {
    
    test('TC-EDGE-001: Should handle wallet with only imported accounts', () {
      // Given: Wallet list with only imported account
      final walletList = <WalletData>[
        WalletData()
          ..id = TestAddresses.importedAccount1
          ..walletType = 'priKey'
          ..walletTypeIndex = 0
          ..accounts = [
            AccountData()
              ..pubKey = TestAddresses.importedAccount1
              ..name = 'Imported 1'
              ..accountIndex = 0
              ..walletId = TestAddresses.importedAccount1,
          ],
      ];
      
      // Then: Should have 1 wallet with correct type
      expect(walletList.length, equals(1));
      expect(walletList[0].walletType, equals('priKey'));
      expect(walletList[0].accounts.length, equals(1));
    });
    
    test('TC-EDGE-002: Should handle wallet with 10 HD accounts', () {
      // Given: HD wallet with 10 accounts (matching React test case 2)
      final accounts = List.generate(10, (i) => 
        AccountData()
          ..pubKey = 'B62qHD_${i}_address'
          ..name = 'Account ${i + 1}'
          ..accountIndex = i
          ..walletId = TestAddresses.hdAccount1
      );
      
      final wallet = WalletData()
        ..id = TestAddresses.hdAccount1
        ..walletType = 'mnemonic'
        ..walletTypeIndex = 0
        ..currentAccountIndex = 0
        ..accounts = accounts;
      
      // Then
      expect(wallet.accounts.length, equals(10));
      expect(wallet.accounts[9].accountIndex, equals(9));
    });
    
    test('TC-EDGE-003: Should handle mixed wallet types (10 HD + 5 imported + 5 ledger)', () {
      // Given: Multiple wallet types matching React test case 4
      final walletList = <WalletData>[];
      
      // Add HD wallet with 10 accounts
      final hdAccounts = List.generate(10, (i) => 
        AccountData()..pubKey = 'B62qHD_$i'..name = 'HD ${i + 1}'..accountIndex = i..walletId = 'hd1'
      );
      walletList.add(WalletData()
        ..id = 'hd1'
        ..walletType = 'mnemonic'
        ..walletTypeIndex = 0
        ..accounts = hdAccounts);
      
      // Add 5 imported wallets
      for (int i = 0; i < 5; i++) {
        walletList.add(WalletData()
          ..id = 'imp_$i'
          ..walletType = 'priKey'
          ..walletTypeIndex = i
          ..accounts = [AccountData()..pubKey = 'B62qIMP_$i'..name = 'Imported ${i + 1}'..accountIndex = 0..walletId = 'imp_$i']);
      }
      
      // Add 5 ledger wallets
      for (int i = 0; i < 5; i++) {
        walletList.add(WalletData()
          ..id = 'led_$i'
          ..walletType = 'ledger'
          ..walletTypeIndex = i
          ..accounts = [AccountData()..pubKey = 'B62qLED_$i'..name = 'Ledger ${i + 1}'..accountIndex = i..walletId = 'led_$i']);
      }
      
      // Then
      expect(walletList.length, equals(11)); // 1 HD + 5 imported + 5 ledger
      expect(walletList.where((w) => w.walletType == 'mnemonic').length, equals(1));
      expect(walletList.where((w) => w.walletType == 'priKey').length, equals(5));
      expect(walletList.where((w) => w.walletType == 'ledger').length, equals(5));
      
      // Total accounts: 10 HD + 5 imported + 5 ledger = 20
      final totalAccounts = walletList.fold<int>(0, (sum, w) => sum + w.accounts.length);
      expect(totalAccounts, equals(20));
    });
    
    test('TC-EDGE-004: Round-trip migration should preserve data', () {
      // Given: Original wallet structure
      final originalWallets = <WalletData>[
        WalletData()
          ..id = TestAddresses.hdAccount1
          ..walletType = 'mnemonic'
          ..walletTypeIndex = 0
          ..source = 'inside'
          ..createTime = 1704067200000
          ..accounts = [
            AccountData()..pubKey = TestAddresses.hdAccount1..name = 'HD 1'..accountIndex = 0..walletId = TestAddresses.hdAccount1,
            AccountData()..pubKey = TestAddresses.hdAccount2..name = 'HD 2'..accountIndex = 1..walletId = TestAddresses.hdAccount1,
          ],
        WalletData()
          ..id = TestAddresses.importedAccount1
          ..walletType = 'priKey'
          ..walletTypeIndex = 0
          ..source = 'outside'
          ..createTime = 1704153600000
          ..accounts = [
            AccountData()..pubKey = TestAddresses.importedAccount1..name = 'Imported'..accountIndex = 0..walletId = TestAddresses.importedAccount1,
          ],
      ];
      
      // When: Serialize all wallets
      final serialized = originalWallets.map((w) => WalletData.toJson(w)).toList();
      final restored = serialized.map((json) => WalletData.fromJson(json)).toList();
      
      // Then: All data should be preserved
      expect(restored.length, equals(originalWallets.length));
      expect(restored[0].accounts.length, equals(2));
      expect(restored[1].accounts.length, equals(1));
      expect(restored[0].id, equals(TestAddresses.hdAccount1));
      expect(restored[1].id, equals(TestAddresses.importedAccount1));
    });
    
  });
}
