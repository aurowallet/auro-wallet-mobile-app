# Wallet Unit Test Guide

This directory contains unit tests for the Auro Wallet Flutter application.

## Test Files

| File | Description |
|------|-------------|
| `wallet_store_test.dart` | Wallet data structure basic tests |
| `wallet_multi_wallet_test.dart` | Multi-wallet functionality tests |
| `wallet_seed_storage_test.dart` | Seed storage structure tests |

---

## Test Data

Tests use real addresses from the React Chrome extension test data:

| Address | Type | Source |
|---------|------|--------|
| `B62qkzCugh8u2Ez1vEs7i3UjW7iypA8ovwC88rBwLqZmdWFqh96M8rM` | HD Account | Test mnemonic |
| `B62qkhhWkJdZx9MAZHd67VqBAX7FVbzSizqsFYqMKvQu4kPNyFxxCmB` | Imported Account | Private key |
| `B62qjLVC7ryAwctX9tZimvgh4FBocUozL4VtCPvPJ9bYKRatb5NCRyy` | HD Account | Vault test |

---

## Running Tests

### Run All Tests

```bash
# In project root directory
flutter test
```

### Run Individual Test Files

```bash
# Run wallet data structure tests
flutter test test/wallet_store_test.dart

# Run multi-wallet functionality tests
flutter test test/wallet_multi_wallet_test.dart

# Run seed storage tests
flutter test test/wallet_seed_storage_test.dart
```

### Run Specific Test Groups

```bash
# Run tests containing specific description
flutter test --name="Multi-Wallet"
```

### Run Tests with Coverage Report

```bash
# Generate coverage data
flutter test --coverage

# View coverage report (requires lcov)
# macOS: brew install lcov
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Using Helper Script

```bash
# Run wallet tests
./scripts/run_tests.sh wallet

# Run with coverage
./scripts/run_tests.sh coverage
```

---

## Test Case Reference

### 1. Data Structure Tests (wallet_store_test.dart)

Verifies `WalletData` and `AccountData` basic functionality:

| Test ID | Description |
|---------|-------------|
| TC-DS-001 | WalletData serialization/deserialization |
| TC-DS-002 | Support multiple mnemonic type wallets |
| TC-DS-003 | AccountData serialization/deserialization |
| TC-DS-004 | currentAccount returns correct account |
| TC-DS-005 | wallet.address returns correct address |
| TC-DS-006 | Empty wallet handling |
| TC-MW-001 | Multiple wallets manage accounts independently |
| TC-MW-002 | walletTypeIndex distinguishes same-type wallets |
| TC-MW-003 | Find wallet by ID |
| TC-CONST-001 | Seed type constants verification |

### 2. Multi-Wallet Tests (wallet_multi_wallet_test.dart)

Verifies multi-wallet scenario core logic (based on React `vault.test.ts` and `vaultMigration.test.ts`):

| Test ID | Description |
|---------|-------------|
| TC-CORE-001 | Create first mnemonic wallet |
| TC-CORE-002 | Create second mnemonic wallet |
| TC-CORE-003 | Create multiple wallet types |
| TC-CORE-004 | walletTypeIndex increments correctly |
| TC-CORE-005 | Different wallet types have independent indices |
| TC-CORE-006 | Each wallet has unique ID |
| TC-ACC-001 | Add account to specific wallet |
| TC-ACC-002 | Remove account doesn't affect other wallets |
| TC-ACC-003 | Calculate next HD account index |
| TC-SW-001 | Switch between wallets |
| TC-JSON-001 | Complete JSON serialization |
| TC-EDGE-001 | Handle wallet with only imported accounts |
| TC-EDGE-002 | Handle wallet with 10 HD accounts |
| TC-EDGE-003 | Handle mixed wallet types (10 HD + 5 imported + 5 ledger) |
| TC-EDGE-004 | Round-trip migration preserves data |

### 3. Seed Storage Tests (wallet_seed_storage_test.dart)

Verifies seed storage isolation (based on React `encryptUtils` and vault storage patterns):

| Test ID | Description |
|---------|-------------|
| TC-SEED-001 | Encrypted seed data format validation |
| TC-MSEED-001 | Multiple wallet seeds stored independently |
| TC-MSEED-002 | Adding new seed doesn't affect existing |
| TC-MSEED-003 | Removing seed doesn't affect others |
| TC-TYPE-001 | Different seed types stored separately |
| TC-ENC-001 | Encrypted vault format validation |
| TC-ENC-002 | Multiple encrypted seeds distinguishable |

---

## Expected Results

All tests should pass. If tests fail, check:

1. Code changes that may have broken existing functionality
2. Data structure changes
3. Serialization/deserialization format changes

---

## Adding New Tests

When adding new tests, follow these guidelines:

1. Use `TC-{Category}-{Number}` format for test case naming
2. Each test should run independently, not depend on other tests' state
3. Use Given-When-Then pattern to organize tests
4. Add clear comments explaining the test purpose

Example:

```dart
test('TC-NEW-001: Describe test purpose', () {
  // Given: Initial state
  final wallet = WalletData()...;
  
  // When: Execute operation
  final result = someOperation(wallet);
  
  // Then: Verify result
  expect(result, equals(expectedValue));
});
```

---

## Multi-Wallet Support Verification

These tests verify that the current Flutter wallet data structure **already supports multi-wallet**:

1. ✅ `WalletData` can create multiple instances with `walletType = 'mnemonic'`
2. ✅ `walletTypeIndex` correctly tracks count of same-type wallets
3. ✅ Each wallet has independent `id`
4. ✅ Seeds stored independently by wallet ID
5. ✅ Accounts managed in isolation per wallet

**No data migration required** to support multi-wallet functionality.
