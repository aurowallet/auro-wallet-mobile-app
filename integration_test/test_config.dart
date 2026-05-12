/// Centralized test data configuration for all integration test flows (1–5).
///
/// All test mnemonics, private keys, keystores, addresses, and passwords
/// are defined here. Each flow test imports this file instead of defining
/// its own local TestData class.
///
/// When a value is unknown (e.g. derived private key not yet captured),
/// set it to `null`. Call [TestConfig.validate] at test startup to print
/// warnings about any missing values that specific tests may need.

// ---------------------------------------------------------------------------
// Data models
// ---------------------------------------------------------------------------

/// A single HD account derived from a mnemonic at a given hdIndex.
class AccountConfig {
  final int hdIndex;
  final String? address;
  final String? privateKey;

  const AccountConfig({
    required this.hdIndex,
    this.address,
    this.privateKey,
  });
}

/// An HD (mnemonic-based) wallet containing one or more derived accounts.
class HDWalletConfig {
  final String label;
  final String mnemonic;
  final List<AccountConfig> accounts;

  const HDWalletConfig({
    required this.label,
    required this.mnemonic,
    required this.accounts,
  });

  /// Shortcut: first account address
  String? get account1Address => accounts.isNotEmpty ? accounts[0].address : null;
  /// Shortcut: first account private key
  String? get account1PrivateKey => accounts.isNotEmpty ? accounts[0].privateKey : null;
  /// Shortcut: second account address (if exists)
  String? get account2Address => accounts.length > 1 ? accounts[1].address : null;
  /// Shortcut: second account private key (if exists)
  String? get account2PrivateKey => accounts.length > 1 ? accounts[1].privateKey : null;
}

/// A wallet imported via raw private key.
class PKWalletConfig {
  final String label;
  final String privateKey;
  final String address;

  const PKWalletConfig({
    required this.label,
    required this.privateKey,
    required this.address,
  });
}

/// A wallet imported via Keystore JSON.
class KSWalletConfig {
  final String label;
  final String keystoreJson;
  final String keystorePassword;
  final String privateKey;
  final String address;

  const KSWalletConfig({
    required this.label,
    required this.keystoreJson,
    required this.keystorePassword,
    required this.privateKey,
    required this.address,
  });
}

// ---------------------------------------------------------------------------
// Test configuration
// ---------------------------------------------------------------------------

class TestConfig {
  // ── Global ───────────────────────────────────────────────────────────────
  /// Wallet password used across all test flows
  static const String password = 'Test1234!';

  // ── HD Wallet 1 ─────────────────────────────────────────────────────────
  /// Created / restored in Flow 1 (create), Flow 2 (mnemonic restore), Flow 5 (multi-wallet)
  static const hdWallet1 = HDWalletConfig(
    label: 'HD Wallet 1',
    mnemonic: 'century love gravity defense upset peasant reform tenant access illegal double magic',
    accounts: [
      AccountConfig(
        hdIndex: 0,
        address: 'B62qoV35KayJT6D3MseTa8fEBNe4gEJLHGtfoFNhhQbv8JRxrKXntXj',
        privateKey: 'EKEA5e48Lcjc3JVHNpQrLcn9A83Bz9s2cV8D62FumkyRid6dL3X4',
      ),
      AccountConfig(
        hdIndex: 1,
        address: 'B62qkfKzmRJH9N7LEeMHYNgA3uAiD53rJqJvhNzrXr7UM78okmZjAc7',
        privateKey: 'EKEg84NGd1SfskVGUmryhGfxTwCyCqNvEEsR7KvExzxC67efY1qY',
      ),
    ],
  );

  // ── HD Wallet 2 ─────────────────────────────────────────────────────────
  /// Added in Flow 5 (multi-wallet) via secondMnemonic import
  static const hdWallet2 = HDWalletConfig(
    label: 'HD Wallet 2',
    mnemonic: 'dove then garbage sponsor core observe replace miss north lunar asthma twice',
    accounts: [
      AccountConfig(
        hdIndex: 0,
        address: 'B62qqLzqPFKoyu4d1bwf33H4fo5XjySjpZC1WZYqjTxX5o5Rga3Ujx1',
        privateKey: 'EKFTDZnZCz75Q2zgfszwg6YfCR6wXyrbGegxuwj76dBGtNEzc3qL',
      ),
      AccountConfig(
        hdIndex: 1,
        address: 'B62qjXFMeiyHfz5XrACFpc1zbu2SLKho8NVwudqr2eSnAhN2kr4pXoS',
        privateKey: 'EKDspUyZkCuGjfkEPTgsv8MLsEMPEXeXSh6GeqKui2Di8qazmssp',
      ),
    ],
  );

  // ── Private Key Wallet ──────────────────────────────────────────────────
  /// Imported in Flow 3 (private key import), Flow 5 (multi-wallet)
  static const pkWallet = PKWalletConfig(
    label: 'PK Wallet',
    privateKey: 'EKEL888U1yKv1xveoxiBPYZcCQMQsaRNYc6ftKMKiFrXUmpuvjsW',
    address: 'B62qo1CwWp18WhM5toS9D76WL7NxXNxKx2biESNk68AGrqKjRaFf8ks',
  );

  // ── Keystore Wallet ─────────────────────────────────────────────────────
  /// Imported in Flow 4 (keystore import), Flow 5 (multi-wallet)
  static const ksWallet = KSWalletConfig(
    label: 'KS Wallet',
    keystoreJson:
        '{"box_primitive":"xsalsa20poly1305","pw_primitive":"argon2i","nonce":"49n6CriT6oYGcF9xp9MuVCFBJEU1wZ8YxMX3oqs","pwsalt":"65UZjZyPKdsNHnH2vdvSyeppXocg","pwdiff":[134217728,6],"ciphertext":"7395cfBPRrLWgQDiu9dfLLRuEuCh1WkS8vNw4oUXrutEnyAsAcPNE5iiXtu1YXS3YzvkTZq1s"}',
    keystorePassword: '123456',
    privateKey: 'EKEMqXWTFW11v8um8VnRzEwZUL2g9WuMWWCxeDrSsjrkbF75La89',
    address: 'B62qkSLnPzXsjRGn9V7rJqMCycQSaWcxqMrCgGv9Ff1tZ2mumnp1EJq',
  );

  // ── Validation ──────────────────────────────────────────────────────────
  /// Call at test startup. Prints warnings for any null / empty fields
  /// that specific tests may need.
  static void validate({String? flowLabel}) {
    final missing = <String>[];

    // HD Wallet 1
    if (hdWallet1.account1Address == null) missing.add('hdWallet1.account1Address');
    if (hdWallet1.account1PrivateKey == null) missing.add('hdWallet1.account1PrivateKey');
    if (hdWallet1.account2Address == null) missing.add('hdWallet1.account2Address');
    if (hdWallet1.account2PrivateKey == null) missing.add('hdWallet1.account2PrivateKey');

    // HD Wallet 2
    if (hdWallet2.account1Address == null) missing.add('hdWallet2.account1Address');
    if (hdWallet2.account1PrivateKey == null) missing.add('hdWallet2.account1PrivateKey');
    if (hdWallet2.account2Address == null) missing.add('hdWallet2.account2Address');
    if (hdWallet2.account2PrivateKey == null) missing.add('hdWallet2.account2PrivateKey');

    if (missing.isEmpty) {
      print('✅ TestConfig: All values present');
    } else {
      final flow = flowLabel != null ? ' [$flowLabel]' : '';
      print('⚠️ TestConfig$flow: ${missing.length} value(s) missing (related tests may show PARTIAL):');
      for (var m in missing) {
        print('   - $m');
      }
    }
  }
}
