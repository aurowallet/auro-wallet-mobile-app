# Auro Wallet Integration Tests

## Overview

Flow-based integration test suite using Flutter's `integration_test` package, executed via `flutter drive` on real devices or simulators with full UI visualization.

## File Structure

```
integration_test/
├── flow1_create_test.dart       # Create wallet via mnemonic
├── flow2_mnemonic_test.dart     # Restore/import wallet via mnemonic
├── flow3_privatekey_test.dart   # Import wallet via private key
├── flow4_keystore_test.dart     # Import wallet via Keystore
├── flow5_multiwallet_test.dart  # Multi-wallet management (requires existing wallet)
├── run_tests.sh                 # Test runner script
├── test_utils.dart              # Shared utilities (screenshots, i18n, helpers)
├── test-issue.md                # Issue tracking & test checklist
├── TEST_KEYS_RECORD.md          # TestKeys implementation record
└── README.md                    # This document

test_driver/
└── integration_test.dart        # flutter drive entry point

lib/common/consts/testKeys.dart  # TestKeys definitions
```

## Quick Start

```bash
# 1. List available devices
flutter devices

# 2. Run all tests (flow 1-4)
./integration_test/run_tests.sh <device_id>

# 3. Run a specific flow
./integration_test/run_tests.sh <device_id> 2        # Mnemonic restore only

# 4. Run multi-wallet tests (requires existing wallet on device)
./integration_test/run_tests.sh <device_id> 5

# 5. Run a single test directly via flutter drive
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/flow2_mnemonic_test.dart \
  -d <device_id>
```

## Test Flows

| # | File | Description | Prerequisite |
|---|------|-------------|-------------|
| 1 | `flow1_create_test.dart` | Create wallet, reach mnemonic verification page | Clean install (no wallet) |
| 2 | `flow2_mnemonic_test.dart` | Import via mnemonic, reach home page | Clean install |
| 3 | `flow3_privatekey_test.dart` | Import via private key, reach home page | Clean install |
| 4 | `flow4_keystore_test.dart` | Import via Keystore, reach home page | Clean install |
| 5 | `flow5_multiwallet_test.dart` | Multi-wallet management (add, switch, rename, etc.) | Existing wallet on device |

- **Flow 1-4** uninstall the app before running to ensure a clean state
- **Flow 5** preserves existing data since it requires an existing wallet

## run_tests.sh Usage

```
Usage: ./run_tests.sh [options] [device_id] [test_order]

Options:
  --no-pub        Skip flutter pub get (faster for repeated runs)
  --no-uninstall  Don't uninstall app between flow 1-4

Arguments:
  device_id   Device/simulator ID (auto-detected if omitted, or read from .test_config)
  test_order  Test order string, e.g. 1234, 5, 12345 (interactive menu if omitted)
```

### Config File `.test_config`

Create `.test_config` in the project root; the script reads it automatically:

```bash
# Default device ID (auto-detected if omitted)
DEVICE_ID=B7BC91AB-F24B-4666-B3BC-980BDECE7D17

# Default test order (used when pressing Enter in the interactive menu)
DEFAULT_ORDER=1234

# Skip pub get (equivalent to --no-pub)
# NO_PUB=true
```

### Examples

```bash
./run_tests.sh                     # Interactive menu, auto-detect device
./run_tests.sh 2                   # Run flow2 (if device ID is in config)
./run_tests.sh DEVICE_ID 1234      # Specify device, flow 1-4
./run_tests.sh --no-pub 5          # Skip pub get, run flow5
```

## Why `flutter drive` Instead of `flutter test`?

`flutter test integration_test/...` frequently times out or disconnects on real devices. `flutter drive` is more stable:

```bash
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/flow2_mnemonic_test.dart \
  -d <device_id>
```

> **Note:** `flutter drive` uninstalls the debug APK after tests complete by default. Use the `--no-uninstall` flag to keep it.

## Test Data

Test data is embedded directly in each flow file via `TestData` classes. Standard test values:

| Item | Value |
|------|-------|
| **Password** | `Test1234!` |
| **Mnemonic** | `century love gravity defense upset peasant reform tenant access illegal double magic` |
| **Private Key** | `EKEL888U1yKv1xveoxiBPYZcCQMQsaRNYc6ftKMKiFrXUmpuvjsW` |
| **Keystore** | See `flow4_keystore_test.dart` |
| **Keystore Password** | `123456` |

### Expected Addresses

| Import Method | Expected Address |
|---------------|-----------------|
| Mnemonic | `B62qoV35KayJT6D3MseTa8fEBNe4gEJLHGtfoFNhhQbv8JRxrKXntXj` |
| Private Key | `B62qo1CwWp18WhM5toS9D76WL7NxXNxKx2biESNk68AGrqKjRaFf8ks` |
| Keystore | `B62qkhhWkJdZx9MAZHd67VqBAX7FVbzSizqsFYqMKvQu4kPNyFxxCmB` |

## TestKeys

UI elements are located via `Key` constants defined in `lib/common/consts/testKeys.dart`. See `TEST_KEYS_RECORD.md` for details.

### Implemented Keys

| Key | Widget | File |
|-----|--------|------|
| `createWalletButton` | Create wallet button | `createAccountEntryPage.dart` |
| `restoreWalletButton` | Restore wallet button | `createAccountEntryPage.dart` |
| `termsAgreeButton` | Agree button | `termsDialog.dart` |
| `passwordInput` | Password input field | `setNewWalletPasswordPage.dart` |
| `confirmPasswordInput` | Confirm password input | `setNewWalletPasswordPage.dart` |
| `nextButton` | Next button | `setNewWalletPasswordPage.dart` |
| `backupTipsCheckbox1/2` | Backup tips checkboxes | `backupMnemonicTipsPage.dart` |
| `backupTipsNextButton` | Backup tips next button | `backupMnemonicTipsPage.dart` |
| `mnemonicSavedButton` | "I have saved" button | `backupMnemonicPage.dart` |
| `mnemonicInput` | Mnemonic input field | `importMnemonicPage.dart` |
| `privateKeyInput` | Private key input field | `importPrivateKeyPage.dart` |
| `keystoreInput` | Keystore input field | `importKeyStorePage.dart` |
| `keystorePasswordInput` | Keystore password field | `importKeyStorePage.dart` |
| `importButton` | Import button | Multiple import pages |
| `startHomeButton` | "Start" button | `importSuccessPage.dart` |
| `walletManageIcon` | Wallet manage icon | `assets/index.dart` |
| `walletMoreButton` | Wallet more button | `keyringSection.dart` |
| `addAccountButton` | Add account button | `keyringSection.dart` |
| `accountMoreButton` | Account more button | `keyringSection.dart` |

### Pending Keys

`sendButton`, `balanceDisplay`, `walletSwitcher`, `accountSwitcher`, `receiveButton`, etc. See `TEST_KEYS_RECORD.md`.

## Known Limitations

- **Mnemonic verification page** requires tapping words in the correct order; skipped in automated tests, requires manual testing
- **Ledger / Biometrics / WalletConnect** not yet automated
- **Transfer tests** require real network or mock; currently placeholder only
- **`pumpAndSettle` timeout** on continuous animations handled via `safePumpAndSettle` wrapper

## Dependencies

```yaml
# pubspec.yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
```

> **Note:** Both `flutter_test` and `integration_test` use `sdk: flutter` — no version number is needed since they are bundled with the Flutter SDK and automatically match the installed SDK version.

## Debugging Tips

- **Print widget tree:** `debugDumpApp()`
- **Increase wait time:** `await tester.pumpAndSettle(const Duration(seconds: 10));`
- **Take screenshot:** `IntegrationTestWidgetsFlutterBinding.takeScreenshot()`
- **Console output:** All flow tests use `print()` with emoji markers to track progress

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Integration Tests
on:
  push:
    branches: [ main, develop ]

jobs:
  integration_test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
      - run: flutter pub get
      - name: Run integration tests
        run: |
          flutter drive \
            --driver=test_driver/integration_test.dart \
            --target=integration_test/flow2_mnemonic_test.dart
```

## Maintenance

- **UI changes:** Update corresponding `TestKeys` and `TEST_KEYS_RECORD.md`
- **New flow:** Add `flowN_*.dart`, update the `run_tests.sh` case statement, and document here
- **Issue tracking:** Record new findings in `test-issue.md`
