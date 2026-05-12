/**
 * Wallet Data Structure Unit Tests
 * 
 * These tests verify WalletData and AccountData basic functionality.
 * They do not require full AppStore initialization.
 * 
 * Test addresses from React extension test data:
 * - B62qkzCugh8u2Ez1vEs7i3UjW7iypA8ovwC88rBwLqZmdWFqh96M8rM (HD account from mnemonic)
 * - B62qkhhWkJdZx9MAZHd67VqBAX7FVbzSizqsFYqMKvQu4kPNyFxxCmB (Imported account)
 * - B62qjLVC7ryAwctX9tZimvgh4FBocUozL4VtCPvPJ9bYKRatb5NCRyy (HD account)
 */
import 'package:flutter_test/flutter_test.dart';
import 'package:auro_wallet/store/wallet/types/walletData.dart';
import 'package:auro_wallet/store/wallet/types/accountData.dart';
import 'package:auro_wallet/store/wallet/wallet.dart';

/// Real test addresses from React Chrome extension
class TestAddresses {
  // HD account derived from test mnemonic at index 0
  static const String hdAccount1 = 'B62qkzCugh8u2Ez1vEs7i3UjW7iypA8ovwC88rBwLqZmdWFqh96M8rM';
  // Imported account from private key
  static const String importedAccount1 = 'B62qkhhWkJdZx9MAZHd67VqBAX7FVbzSizqsFYqMKvQu4kPNyFxxCmB';
  // Another HD account
  static const String hdAccount2 = 'B62qjLVC7ryAwctX9tZimvgh4FBocUozL4VtCPvPJ9bYKRatb5NCRyy';
  // Ledger account placeholder
  static const String ledgerAccount1 = 'B62qledger123456789';
}

void main() {
  group('WalletData Structure Tests', () {
    
    test('TC-DS-001: WalletData should serialize and deserialize correctly', () {
      // Given: Create a WalletData with real test address
      final wallet = WalletData()
        ..id = TestAddresses.hdAccount1
        ..walletType = 'mnemonic'
        ..walletTypeIndex = 0
        ..source = 'inside'
        ..createTime = 1704067200000
        ..currentAccountIndex = 0
        ..accounts = [];
      
      // When: Convert to JSON and back
      final json = WalletData.toJson(wallet);
      final restored = WalletData.fromJson(json);
      
      // Then: Data should match
      expect(restored.id, equals(TestAddresses.hdAccount1));
      expect(restored.walletType, equals('mnemonic'));
      expect(restored.walletTypeIndex, equals(0));
      expect(restored.source, equals('inside'));
      expect(restored.createTime, equals(1704067200000));
    });
    
    test('TC-DS-002: WalletData should support multiple walletType=mnemonic', () {
      // Given: Create multiple mnemonic type wallets
      final wallet1 = WalletData()
        ..id = TestAddresses.hdAccount1
        ..walletType = 'mnemonic'
        ..walletTypeIndex = 0
        ..accounts = [];
      
      final wallet2 = WalletData()
        ..id = TestAddresses.hdAccount2
        ..walletType = 'mnemonic'
        ..walletTypeIndex = 1
        ..accounts = [];
      
      final wallet3 = WalletData()
        ..id = TestAddresses.importedAccount1
        ..walletType = 'priKey'
        ..walletTypeIndex = 0
        ..accounts = [];
      
      // When: Put into list
      final walletList = [wallet1, wallet2, wallet3];
      
      // Then: Should correctly filter multiple mnemonic wallets
      final mnemonicWallets = walletList.where(
        (w) => w.walletType == 'mnemonic'
      ).toList();
      
      expect(mnemonicWallets.length, equals(2));
      expect(mnemonicWallets[0].id, equals(TestAddresses.hdAccount1));
      expect(mnemonicWallets[1].id, equals(TestAddresses.hdAccount2));
    });
    
    test('TC-DS-003: AccountData should serialize and deserialize correctly', () {
      // Given: Create an AccountData with real test address
      final account = AccountData()
        ..pubKey = TestAddresses.hdAccount1
        ..name = 'Account 1'
        ..accountIndex = 0
        ..createTime = 1704067200000
        ..walletId = TestAddresses.hdAccount1;
      
      // When: Convert to JSON and back
      final json = account.toJson();
      final restored = AccountData.fromJson(json);
      
      // Then: Data should match
      expect(restored.pubKey, equals(TestAddresses.hdAccount1));
      expect(restored.name, equals('Account 1'));
      expect(restored.accountIndex, equals(0));
      expect(restored.walletId, equals(TestAddresses.hdAccount1));
      expect(restored.address, equals(TestAddresses.hdAccount1));
    });
    
    test('TC-DS-004: WalletData.currentAccount should return correct account', () {
      // Given: Create wallet with multiple accounts
      final account1 = AccountData()
        ..pubKey = TestAddresses.hdAccount1
        ..name = 'Account 1'
        ..accountIndex = 0
        ..walletId = TestAddresses.hdAccount1;
      
      final account2 = AccountData()
        ..pubKey = TestAddresses.hdAccount2
        ..name = 'Account 2'
        ..accountIndex = 1
        ..walletId = TestAddresses.hdAccount1;
      
      final wallet = WalletData()
        ..id = TestAddresses.hdAccount1
        ..walletType = 'mnemonic'
        ..currentAccountIndex = 1
        ..accounts = [account1, account2];
      
      // When: Get currentAccount
      final current = wallet.currentAccount;
      
      // Then: Should return account with accountIndex = 1
      expect(current.pubKey, equals(TestAddresses.hdAccount2));
      expect(current.name, equals('Account 2'));
    });
    
    test('TC-DS-005: WalletData.address should return current account address', () {
      // Given: Create wallet with account
      final account = AccountData()
        ..pubKey = TestAddresses.hdAccount1
        ..name = 'Test Account'
        ..accountIndex = 0
        ..walletId = TestAddresses.hdAccount1;
      
      final wallet = WalletData()
        ..id = TestAddresses.hdAccount1
        ..walletType = 'mnemonic'
        ..currentAccountIndex = 0
        ..accounts = [account];
      
      // When: Get wallet.address
      final address = wallet.address;
      
      // Then: Should return current account's pubKey
      expect(address, equals(TestAddresses.hdAccount1));
    });
    
    test('TC-DS-006: Empty wallet currentAccount should return empty AccountData', () {
      // Given: Create wallet without accounts
      final wallet = WalletData()
        ..id = TestAddresses.hdAccount1
        ..walletType = 'mnemonic'
        ..accounts = [];
      
      // When: Get currentAccount
      final current = wallet.currentAccount;
      
      // Then: Should return empty AccountData (no exception)
      expect(current.pubKey, isEmpty);
    });
    
  });
  
  group('Multi-Wallet Data Structure Validation', () {
    
    test('TC-MW-001: Multiple wallets should manage accounts independently', () {
      // Given: Create two HD wallets with different accounts
      final wallet1Account1 = AccountData()
        ..pubKey = TestAddresses.hdAccount1
        ..name = 'W1-A1'
        ..accountIndex = 0
        ..walletId = 'wallet1';
      
      final wallet1Account2 = AccountData()
        ..pubKey = TestAddresses.hdAccount2
        ..name = 'W1-A2'
        ..accountIndex = 1
        ..walletId = 'wallet1';
      
      final wallet2Account1 = AccountData()
        ..pubKey = TestAddresses.importedAccount1
        ..name = 'W2-A1'
        ..accountIndex = 0
        ..walletId = 'wallet2';
      
      final wallet1 = WalletData()
        ..id = 'wallet1'
        ..walletType = 'mnemonic'
        ..walletTypeIndex = 0
        ..currentAccountIndex = 0
        ..accounts = [wallet1Account1, wallet1Account2];
      
      final wallet2 = WalletData()
        ..id = 'wallet2'
        ..walletType = 'mnemonic'
        ..walletTypeIndex = 1
        ..currentAccountIndex = 0
        ..accounts = [wallet2Account1];
      
      // Then: Wallet1 should have 2 accounts, Wallet2 should have 1
      expect(wallet1.accounts.length, equals(2));
      expect(wallet2.accounts.length, equals(1));
      expect(wallet1.currentAccount.pubKey, equals(TestAddresses.hdAccount1));
      expect(wallet2.currentAccount.pubKey, equals(TestAddresses.importedAccount1));
    });
    
    test('TC-MW-002: walletTypeIndex should distinguish same-type wallets', () {
      // Given: Create multiple wallets of different types
      final wallets = <WalletData>[
        WalletData()..id = 'hd1'..walletType = 'mnemonic'..walletTypeIndex = 0..accounts = [],
        WalletData()..id = 'hd2'..walletType = 'mnemonic'..walletTypeIndex = 1..accounts = [],
        WalletData()..id = 'pk1'..walletType = 'priKey'..walletTypeIndex = 0..accounts = [],
        WalletData()..id = 'hd3'..walletType = 'mnemonic'..walletTypeIndex = 2..accounts = [],
        WalletData()..id = 'pk2'..walletType = 'priKey'..walletTypeIndex = 1..accounts = [],
      ];
      
      // When: Calculate next mnemonic wallet index
      int nextMnemonicIndex = 0;
      wallets.where((w) => w.walletType == 'mnemonic').forEach((w) {
        if (w.walletTypeIndex >= nextMnemonicIndex) {
          nextMnemonicIndex = w.walletTypeIndex + 1;
        }
      });
      
      // Then: Next index should be 3
      expect(nextMnemonicIndex, equals(3));
    });
    
    test('TC-MW-003: Find wallet by ID should return correct result', () {
      // Given: Wallet list
      final wallets = <WalletData>[
        WalletData()..id = TestAddresses.hdAccount1..walletType = 'mnemonic'..accounts = [],
        WalletData()..id = TestAddresses.importedAccount1..walletType = 'priKey'..accounts = [],
        WalletData()..id = TestAddresses.hdAccount2..walletType = 'mnemonic'..accounts = [],
      ];
      
      // When: Find by ID
      WalletData? findById(String id) {
        try {
          return wallets.firstWhere((w) => w.id == id);
        } catch (e) {
          return null;
        }
      }
      
      // Then: Should return correct wallet
      expect(findById(TestAddresses.importedAccount1)?.walletType, equals('priKey'));
      expect(findById(TestAddresses.hdAccount2)?.walletType, equals('mnemonic'));
      expect(findById('nonexistent'), isNull);
    });
    
  });
  
  group('WalletStore Constants Tests', () {
    
    test('TC-CONST-001: Seed type constants should be correctly defined', () {
      expect(WalletStore.seedTypeMnemonic, equals('mnemonic'));
      expect(WalletStore.seedTypePrivateKey, equals('priKey'));
      expect(WalletStore.seedTypeLedger, equals('ledger'));
      expect(WalletStore.seedTypeNone, equals('none'));
    });
    
  });
}
