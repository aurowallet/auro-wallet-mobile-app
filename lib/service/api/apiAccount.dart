import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:auro_wallet/walletSdk/types.dart';
import 'package:biometric_storage/biometric_storage.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/common/consts/enums.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/store/wallet/wallet.dart';
import 'package:auro_wallet/store/wallet/types/walletData.dart';
import 'package:auro_wallet/store/assets/types/transferData.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:bs58check/bs58check.dart' as bs58check;
import 'package:convert/convert.dart';
import 'package:auro_wallet/walletSdk/minaSDK.dart';

class ApiAccount {
  ApiAccount(this.apiRoot);

  final Api apiRoot;
  final store = globalAppStore;

  final _biometricEnabledKey = 'biometric_enabled_';
  final _biometricPasswordKey = 'biometric_password_';
  final _watchModeWarnedKey = 'watch_mode_warned';

  Future<void> changeCurrentAccount({
    String? pubKey,
    bool fetchData = false,
  }) async {
    String? current = pubKey;
    if (pubKey == null) {
      if (store.wallet!.walletList.length > 0) {
        current = store.wallet!.walletList[0].pubKey;
      } else {
        current = '';
      }
    }
    store.wallet!.setCurrentAccount(current!);

    // refresh balance
    await store.assets!.clearTxs();
    await store.staking!.clearDelegatedValidator();
    await store.assets!.loadAccountCache();
    if (fetchData) {
      globalBalanceRefreshKey.currentState!.show();
    }
  }

  Future<TransferData?> sendTx(Map input, Map signature,
      {required BuildContext context}) async {
    String mutation = r'''
    mutation broadcastTx($fee:UInt64!, $amount:UInt64!, 
$to: PublicKey!, $from: PublicKey!, $nonce:UInt32, $memo: String!,
$validUntil: UInt32, $scalar: String!, $field: String!) {
      sendPayment(
        input: {
          fee: $fee,
          amount: $amount,
          to: $to,
          from: $from,
          memo: $memo,
          nonce: $nonce,
          validUntil: $validUntil
        }, 
        signature: {
           field: $field, scalar: $scalar
        }) {
        payment {
          amount
          fee
          feeToken
          from
          hash
          id
          isDelegation
          memo
          nonce
          kind
          to
        }
      }
    }
''';

    Map<String, dynamic> variables = {...input, ...signature};

    final MutationOptions _options = MutationOptions(
      document: gql(mutation),
      fetchPolicy: FetchPolicy.noCache,
      variables: variables,
    );
    GqlResult gqlResult = await apiRoot.gqlRequest(_options, context: context);
    if (gqlResult.error) {
      print('转账广播出错了：');
      UI.toast(gqlResult.errorMessage);
      return null;
    }
    Map paymentData = gqlResult.result!.data!['sendPayment']['payment'];
    var data = TransferData()
      ..hash = paymentData["hash"]
      ..paymentId = paymentData["id"]
      ..type = paymentData["kind"]
      ..fee = paymentData["fee"]
      ..amount = paymentData["amount"]
      ..nonce = paymentData["nonce"]
      ..sender = paymentData["from"]
      ..memo = input["memo"]
      ..status = 'pending'
      ..success = false
      ..receiver = paymentData["to"];
    return data;
  }

  Future<TransferData?> sendDelegationTx(Map input, Map signature,
      {required BuildContext context}) async {
    String mutation = r'''
    mutation broadcastTx($fee:UInt64!,
$to: PublicKey!, $from: PublicKey!, $nonce:UInt32!, $memo: String!,
$validUntil: UInt32,$scalar: String!, $field: String!) {
      sendDelegation(
        input: {
          fee: $fee,
          to: $to,
          from: $from,
          memo: $memo,
          nonce: $nonce,
          validUntil: $validUntil
        }, 
        signature: {
         field: $field, scalar: $scalar
        }) {
        delegation {
          amount
          fee
          feeToken
          from
          hash
          id
          isDelegation
          memo
          nonce
          kind
          to
        }
      }
    }
''';
    Map<String, dynamic> variables = {...input, ...signature};
    final MutationOptions _options = MutationOptions(
      document: gql(mutation),
      fetchPolicy: FetchPolicy.noCache,
      variables: variables,
    );
    GqlResult gqlResult = await apiRoot.gqlRequest(_options, context: context);
    if (gqlResult.error) {
      print('质押广播出错了');
      UI.toast(gqlResult.errorMessage);
      return null;
    }
    Map paymentData = gqlResult.result!.data!['sendDelegation']['delegation'];
    var data = TransferData()
      ..hash = paymentData["hash"]
      ..paymentId = paymentData["id"]
      ..type = paymentData["kind"]
      ..fee = paymentData["fee"]
      ..amount = paymentData["amount"]
      ..nonce = paymentData["nonce"]
      ..sender = paymentData["from"]
      ..status = 'pending'
      ..success = false
      ..receiver = paymentData["to"];
    return data;
  }

  Future<TransferData?> signAndSendTx(Map txInfo,
      {required BuildContext context}) async {
    final signedTx = await signPayment(
        privateKey: txInfo['privateKey'],
        amount: txInfo['amount'],
        to: txInfo['toAddress'],
        from: txInfo['fromAddress'],
        fee: txInfo['fee'],
        nonce: txInfo['nonce'],
        memo: txInfo['memo'],
        networkId: store.settings!.isMainnet ? 1 : 0);
    TransferData? transferData = await sendTx(
        signedTx['payload'], signedTx['signature'],
        context: context);
    return transferData;
  }

  Future<TransferData?> signAndSendDelegationTx(Map txInfo,
      {required BuildContext context}) async {
    final signedTx = await signDelegation(
        privateKey: txInfo['privateKey'],
        to: txInfo['toAddress'],
        from: txInfo['fromAddress'],
        fee: txInfo['fee'],
        nonce: txInfo['nonce'],
        memo: txInfo['memo'],
        networkId: store.settings!.isMainnet ? 1 : 0);
    TransferData? transferData = await sendDelegationTx(
        signedTx['payload'], signedTx['signature'],
        context: context);
    return transferData;
  }

  Uint8List _getUint8ListFromString(String str) {
    List<int> list = str.codeUnits;
    Uint8List bytes = Uint8List.fromList(list);
    return bytes;
  }

  Future<String?> getPrivateKeyFromKeyStore(
      String keyStore, String keyStorePassword,
      {required BuildContext context}) async {
    try {
      Sodium.init();
      Map keystoreMap = jsonDecode(keyStore);
      var salt = bs58check.decode(keystoreMap['pwsalt']).sublist(1);
      Uint8List key = Sodium.cryptoPwhash(
          32,
          _getUint8ListFromString(keyStorePassword),
          salt,
          keystoreMap['pwdiff'][1],
          keystoreMap['pwdiff'][0],
          Sodium.cryptoPwhashAlgArgon2i13);
      Uint8List privateKey = Sodium.cryptoSecretboxOpenEasy(
          bs58check.decode(keystoreMap['ciphertext']).sublist(1),
          bs58check.decode(keystoreMap['nonce']).sublist(1),
          key);
      var privateKeStr = bs58check
          .encode(hex.decode('5a' + hex.encode(privateKey)) as Uint8List);
      return privateKeStr;
    } catch (e) {
      final dic = I18n.of(context).main;
      UI.toast(dic['keystoreError']!);
      return null;
    }
  }

  Future<bool> createExternalWallet(String accountName, String address,
      {required BuildContext context,
      String source = WalletSource.outside,
      String seedType = WalletStore.seedTypeNone}) async {
    Map<String, dynamic> acc = {"name": accountName, "pubKey": address};
    WalletResult res = await store.wallet!.addWallet(acc, null,
        seedType: seedType,
        context: context,
        walletSource: WalletSource.outside);
    if (res != WalletResult.success) {
      if (res == WalletResult.addressExisted) {
        final dic = I18n.of(context).main;
        UI.toast(dic['urlError_2']!);
        return false;
      }
    }

    store.assets!.loadAccountCache();

    try {
      // fetch info for the imported account
      String pubKey = acc['pubKey'];
      webApi.assets.fetchAccountInfo();
      webApi.assets.fetchTransactions(pubKey);
      webApi.assets.fetchPendingTransactions(pubKey);
      return true;
    } catch (e) {
      return false;
      print('network may not connected');
    }
  }

  Future<bool> createWalletByPrivateKey(
      String accountName, String privateKey, String password,
      {required BuildContext context,
      String source = WalletSource.outside}) async {
    Map<String, dynamic> acc = await createAccountByPrivateKey(privateKey);
    acc['name'] = accountName;
    return await _addWalletBgPrivateKey(acc, password, context, source);
  }

  Future<bool> _addWalletBgPrivateKey(Map<String, dynamic> acc, String password,
      context, String walletSource) async {
    WalletResult res = await store.wallet!.addWallet(acc, password,
        seedType: WalletStore.seedTypePrivateKey,
        context: context,
        walletSource: WalletSource.outside);
    if (res != WalletResult.success) {
      if (res == WalletResult.addressExisted) {
        final dic = I18n.of(context).main;
        UI.toast(dic['urlError_2']!);
        return false;
      }
    }

    store.assets!.loadAccountCache();

    try {
      // fetch info for the imported account
      String pubKey = acc['pubKey'];
      webApi.assets.fetchAccountInfo();
      webApi.assets.fetchTransactions(pubKey);
      webApi.assets.fetchPendingTransactions(pubKey);
      return true;
    } catch (e) {
      return false;
      print('network may not connected');
    }
  }

  Future<Map<String, dynamic>?> createAccountByAccountIndex(
      WalletData wallet, accountName, String password) async {
    int nextAccountIndex = store.wallet!.getNextWalletAccountIndex(wallet);
    String? mnemonic = await store.wallet!.getMnemonic(wallet, password);
    if (mnemonic == null) {
      return null;
    }
    Map<String, dynamic> acc =
        await createWalletByMnemonic(mnemonic, nextAccountIndex, false);
    return acc;
  }

  Future<String?> getPrivateKey(
      WalletData wallet, int accountIndex, String password) async {
    if (wallet.walletType == WalletStore.seedTypeMnemonic) {
      String? mnemonic = await store.wallet!.getMnemonic(wallet, password);
      if (mnemonic == null) {
        return null;
      }
      Map<String, dynamic> acc =
          await createWalletByMnemonic(mnemonic, accountIndex, true);
      return acc["priKey"] as String;
    } else {
      String? privateKey = await store.wallet!.getPrivateKey(wallet, password);
      if (privateKey == null) {
        return null;
      }
      return privateKey;
    }
  }

  bool isMnemonicValid(String mnemonic) {
    final words = mnemonic.trim().split(RegExp(r"(\s)"));
    if (words.length < 12) {
      return false;
    }
    return bip39.validateMnemonic(words.join(' '));
  }

  Future<bool> isAddressValid(String publicKey) async {
    bool isValid = ifAddressValid(publicKey);
    return isValid;
  }

  Future<bool> isPrivateKeyValid(String privateKey) async {
    bool isValid = ifPrivateKeyValid(privateKey);
    return isValid;
  }

  Future<void> generateMnemonic() async {
    String randomMnemonic = generateRandMnemonic();
    store.wallet!
        .setNewWalletSeed(randomMnemonic, WalletStore.seedTypeMnemonic);
  }

  Future<Map<String, dynamic>> importWalletByWalletParams() async {
    String key = store.wallet!.newWalletParams.seed;
    String seedType = store.wallet!.newWalletParams.seedType;
    Map<String, dynamic> acc = await createWallet(key, seedType);
    return acc;
  }

  Future<void> saveWallet(Map<String, dynamic> acc,
      {required BuildContext context,
      required String seedType,
      required String walletSource}) async {
    await store.wallet!.addWallet(
      acc,
      store.wallet!.newWalletParams.password,
      seedType: seedType,
      walletSource: walletSource,
      context: context,
    );

    store.assets!.loadAccountCache();

    try {
      String pubKey = acc['pubKey'];
      webApi.assets.fetchAccountInfo();
    } catch (e) {
      print('network may not connected');
    }
  }

  Future<bool> checkAccountPassword(WalletData wallet, String pass) async {
    String pubKey = wallet.id;
    bool isCorrect =
        await store.wallet!.checkPassword(pubKey, wallet.walletType, pass);
    return isCorrect;
  }

  void setBiometricEnabled() {
    apiRoot.configStorage
        .write('$_biometricEnabledKey', DateTime.now().millisecondsSinceEpoch);
  }

  void setBiometricDisabled() {
    apiRoot.configStorage.write('$_biometricEnabledKey',
        DateTime.now().millisecondsSinceEpoch - SECONDS_OF_DAY * 7000);
  }

  bool getBiometricEnabled() {
    final timestamp = apiRoot.configStorage.read('$_biometricEnabledKey');
    // we cache user's password with biometric for 7 days.
    if (timestamp != null &&
        timestamp + SECONDS_OF_DAY * 7000 >
            DateTime.now().millisecondsSinceEpoch) {
      return true;
    }
    return false;
  }

  void setWatchModeWarned() {
    apiRoot.configStorage.write(_watchModeWarnedKey, true);
  }

  bool getWatchModeWarned() {
    final warned = apiRoot.configStorage.read(_watchModeWarnedKey);
    if (warned != null && warned) {
      return true;
    }
    return false;
  }

  Future saveBiometricPass(BuildContext context, String password) async {
    final storeFile = await webApi.account.getBiometricPassStoreFile(
      context,
    );
    await storeFile.write(password);
  }

  Future<BiometricStorageFile> getBiometricPassStoreFile(
    BuildContext context,
  ) async {
    final dic = I18n.of(context).main;
    return BiometricStorage().getStorage(
      '$_biometricPasswordKey',
      options:
          StorageFileInitOptions(authenticationValidityDurationSeconds: -1),
      promptInfo: PromptInfo(
          androidPromptInfo: AndroidPromptInfo(
            title: dic['unlock.bio']!,
            negativeButton: dic['cancel']!,
          ),
          iosPromptInfo: IosPromptInfo(
            saveTitle: dic['unlock.bio']!,
            accessTitle: dic['unlock.bio']!,
          )),
    );
  }
}
