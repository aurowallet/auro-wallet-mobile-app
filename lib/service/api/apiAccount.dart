import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/ledgerMina/mina_ledger_application.dart';
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
import 'package:auro_wallet/utils/UI.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:bs58check/bs58check.dart' as bs58check;
import 'package:convert/convert.dart';
import 'package:auro_wallet/walletSdk/minaSDK.dart';
import 'package:ledger_flutter/ledger_flutter.dart';

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
      {required BuildContext context, isRawSignature = false}) async {
    String? mutation;
    if (isRawSignature) {
      mutation = r'''
    mutation broadcastTx($fee:UInt64!, $amount:UInt64!, 
$to: PublicKey!, $from: PublicKey!, $nonce:UInt32, $memo: String!,
$validUntil: UInt32, $rawSignature: String!) {
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
           rawSignature: $rawSignature
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
    } else {
      mutation = r'''
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
    }

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
      {required BuildContext context, isRawSignature = false}) async {
    String? mutation;
    if (isRawSignature) {
      mutation = r'''
    mutation broadcastTx($fee:UInt64!,
$to: PublicKey!, $from: PublicKey!, $nonce:UInt32!, $memo: String!,
$validUntil: UInt32, $rawSignature: String!) {
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
          rawSignature: $rawSignature
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
    } else {
      mutation = r'''
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
    }
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

  Future<TransferData?> sendTxBody(Map prepareBody,
      {required BuildContext context, isDelegation = false}) async {
    TransferData? transferData;
    if (isDelegation) {
      transferData = await sendDelegationTx(
          prepareBody['payload'], prepareBody['signature'],
          context: context, isRawSignature: true);
    } else {
      transferData = await sendTx(
          prepareBody['payload'], prepareBody['signature'],
          context: context, isRawSignature: true);
    }
    return transferData;
  }

  Future<Map?> ledgerSign(Map txInfo,
      {required BuildContext context, isDelegation = false}) async {
    final minaApp = MinaLedgerApp(store.ledger!.ledgerInstance!,
        accountIndex: txInfo["accountIndex"]);
    final feeLarge =
        BigInt.from(pow(10, COIN.decimals) * txInfo['fee']).toInt();
    final amountLarge = isDelegation
        ? 0
        : BigInt.from(pow(10, COIN.decimals) * txInfo['amount']).toInt();
    final validUntil = "4294967295";
    try {
      // final rawSignature = "8c6e8717bb6b60405446b722031c99a052a3f377ef4fbc83faf6f46fcbc36610e2f8455a3b64ce66b4dd9bc91541a126caae34140a941b5a7e1b24d3d3223420";
      final rawSignature = await minaApp.signTransfer(
          store.ledger!.ledgerDevice!,
          txType: isDelegation ? TxType.DELEGATION.value : TxType.PAYMENT.value,
          senderAccount: txInfo["accountIndex"],
          senderAddress: txInfo['fromAddress'],
          receiverAddress: txInfo['toAddress'],
          amount: amountLarge,
          fee: feeLarge,
          nonce: txInfo['nonce'],
          memo: txInfo['memo'],
          validUntil: validUntil,
          networkId: store.settings!.isMainnet
              ? Networks.MAINNET.value
              : Networks.DEVNET.value);
      final prepareBody = prepareBroadcastBody(
          from: txInfo['fromAddress'],
          to: txInfo['toAddress'],
          fee: feeLarge,
          amount: amountLarge,
          nonce: txInfo['nonce'],
          memo: txInfo['memo'],
          validUntil: validUntil,
          rawSignature: rawSignature);
      return prepareBody;
    } on LedgerException catch (e) {
      print('ledger fail');
      AppLocalizations dic = AppLocalizations.of(context)!;
      print(e);
      UI.toast(dic.ledgerReject);
      return null;
    }
  }

  Future<TransferData?> signAndSendTx(Map txInfo,
      {required BuildContext context}) async {
    String network = store.settings!.isMainnet ? "mainnet" : "testnet";
    final feeLarge =
        BigInt.from(pow(10, COIN.decimals) * txInfo['fee']).toInt();
    final amountLarge =
        BigInt.from(pow(10, COIN.decimals) * txInfo['amount']).toInt();

    final signedTx = await apiRoot.bridge.signPaymentTx({
      "network": network,
      "type": "payment",
      "privateKey": txInfo['privateKey'],
      "fromAddress": txInfo['fromAddress'],
      "toAddress": txInfo['toAddress'],
      "amount": txInfo['amount'],
      "fee": txInfo['fee'],
      "nonce": txInfo['nonce'],
      "memo": txInfo['memo']
    });

    final signedData = signedTx['data'];
    final broadcastBody = prepareBroadcastBody(
        field: signedTx['signature']["field"],
        scalar: signedTx['signature']["scalar"],
        from: signedData["from"],
        to: signedData["to"],
        fee: feeLarge,
        amount: amountLarge,
        nonce: txInfo['nonce'],
        memo: signedData["memo"],
        validUntil: signedData["validUntil"]);
    TransferData? transferData = await sendTx(
        broadcastBody['payload'], broadcastBody['signature'],
        context: context);
    return transferData;
  }

  Future<TransferData?> signAndSendDelegationTx(Map txInfo,
      {required BuildContext context}) async {
    String network = store.settings!.isMainnet ? "mainnet" : "testnet";
    final feeLarge =
        BigInt.from(pow(10, COIN.decimals) * txInfo['fee']).toInt();
    final signedTx = await apiRoot.bridge.signStakeDelegationTx({
      "network": network,
      "type": "delegation",
      "privateKey": txInfo['privateKey'],
      "fee": txInfo['fee'],
      "fromAddress": txInfo['fromAddress'],
      "toAddress": txInfo['toAddress'],
      "nonce": txInfo['nonce'],
      "memo": txInfo['memo']
    });
    final signedData = signedTx['data'];
    final broadcastBody = prepareBroadcastBody(
        field: signedTx['signature']["field"],
        scalar: signedTx['signature']["scalar"],
        from: signedData["from"],
        to: signedData["to"],
        fee: feeLarge,
        amount: 0,
        nonce: txInfo['nonce'],
        memo: signedData["memo"],
        validUntil: signedData["validUntil"]);
    TransferData? transferData = await sendDelegationTx(
        broadcastBody['payload'], broadcastBody['signature'],
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
      AppLocalizations dic = AppLocalizations.of(context)!;
      UI.toast(dic.keystoreError);
      return null;
    }
  }

  Future<bool> createExternalWallet(String accountName, String address,
      {required BuildContext context,
      String source = WalletSource.outside,
      String seedType = WalletStore.seedTypeNone,
      int hdIndex = 0}) async {
    Map<String, dynamic> acc = {
      "name": accountName,
      "pubKey": address,
      "hdIndex": hdIndex
    };
    WalletResult res = await store.wallet!.addWallet(acc, null,
        seedType: seedType,
        context: context,
        walletSource: WalletSource.outside);
    if (res != WalletResult.success) {
      if (res == WalletResult.addressExisted) {
        AppLocalizations dic = AppLocalizations.of(context)!;
        UI.toast(dic.urlError_2);
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
      webApi.assets.fetchPendingZkTransactions(store.wallet!.currentAddress);
      webApi.assets.fetchZkTransactions(store.wallet!.currentAddress);
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
    Map<String, dynamic> acc =
        await apiRoot.bridge.createAccountByPrivateKey(privateKey);
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
        AppLocalizations dic = AppLocalizations.of(context)!;
        UI.toast(dic.urlError_2);
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
      webApi.assets.fetchPendingTransactions(store.wallet!.currentAddress);
      webApi.assets.fetchZkTransactions(store.wallet!.currentAddress);
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
    Map<String, dynamic> acc = await apiRoot.bridge
        .createWalletByMnemonic(mnemonic, nextAccountIndex, false);
    return acc;
  }

  Future<String?> getPrivateKey(
      WalletData wallet, int accountIndex, String password) async {
    if (wallet.walletType == WalletStore.seedTypeMnemonic) {
      String? mnemonic = await store.wallet!.getMnemonic(wallet, password);
      if (mnemonic == null) {
        return null;
      }
      Map<String, dynamic> acc = await apiRoot.bridge
          .createWalletByMnemonic(mnemonic, accountIndex, true);
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
    Map<String, dynamic> acc = await apiRoot.bridge.createWallet(key, seedType);
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
    AppLocalizations dic = AppLocalizations.of(context)!;
    return BiometricStorage().getStorage(
      '$_biometricPasswordKey',
      options:
          StorageFileInitOptions(authenticationValidityDurationSeconds: -1),
      promptInfo: PromptInfo(
          androidPromptInfo: AndroidPromptInfo(
            title: dic.unlockBio,
            negativeButton: dic.cancel,
          ),
          iosPromptInfo: IosPromptInfo(
            saveTitle: dic.unlockBio,
            accessTitle: dic.unlockBio,
          )),
    );
  }

  Future<Map<String, dynamic>> signMessage(Map signInfo,
      {required BuildContext context}) async {
    String network = store.settings!.isMainnet ? "mainnet" : "testnet";
    Map<String, dynamic> signed = await apiRoot.bridge.signMessage({
      "network": network,
      ...signInfo,
    });
    return signed;
  }

  Future<bool> verifyMessage(Map signedInfo,
      {required BuildContext context}) async {
    String network = store.settings!.isMainnet ? "mainnet" : "testnet";
    bool verifyRes = await apiRoot.bridge.verifyMessage({
      "network": network,
      ...signedInfo,
    });
    return verifyRes;
  }

  Future<Map<String, dynamic>> signFields(Map signInfo,
      {required BuildContext context}) async {
    String network = store.settings!.isMainnet ? "mainnet" : "testnet";
    Map<String, dynamic> signed = await apiRoot.bridge.signFields({
      "network": network,
      ...signInfo,
    });
    return signed;
  }

  Future<bool> verifyFields(Map signedInfo,
      {required BuildContext context}) async {
    String network = store.settings!.isMainnet ? "mainnet" : "testnet";
    bool verifyRes = await apiRoot.bridge.verifyFields({
      "network": network,
      ...signedInfo,
    });
    return verifyRes;
  }

  Future<Map<String, dynamic>> createNullifier(Map signInfo,
      {required BuildContext context}) async {
    String network = store.settings!.isMainnet ? "mainnet" : "testnet";
    Map<String, dynamic> signed = await apiRoot.bridge.createNullifier({
      "network": network,
      ...signInfo,
    });
    return signed;
  }

  Future<TransferData?> sendZkTx(Map zkappCommandInput,
      {required BuildContext context}) async {
    String? mutation;
    mutation = r'''
    mutation sendZkapp($zkappCommandInput: ZkappCommandInput!) {
  sendZkapp(input: {zkappCommand: $zkappCommandInput}) {
    zkapp {
      hash
      id
      zkappCommand {
        memo
        accountUpdates {
          body {
            publicKey
          }
        }
        feePayer {
          body {
            fee
            nonce
            publicKey
          }
        }
      }
    }
  }
}

''';

    Map<String, dynamic> variables = {"zkappCommandInput": zkappCommandInput};

    final MutationOptions _options = MutationOptions(
      document: gql(mutation),
      fetchPolicy: FetchPolicy.noCache,
      variables: variables,
    );

    GqlResult gqlResult = await apiRoot.gqlRequest(_options, context: context);
    if (gqlResult.error) {
      print('zk broadcaset error：');
      UI.toast(gqlResult.errorMessage);
      return null;
    }
    Map paymentData = gqlResult.result!.data!['sendZkapp']['zkapp'];

    var accountUpdates =
        paymentData['zkappCommand']['accountUpdates'] as List<dynamic>?;
    var firstUpdate = accountUpdates?.isNotEmpty == true
        ? accountUpdates!.first as Map<String, dynamic>
        : null;
    var receiver =
        firstUpdate != null ? firstUpdate['body']['publicKey'] : null;
    var feePayerBody =
        paymentData['zkappCommand']['feePayer']['body'] as Map<String, dynamic>;
    var fee = feePayerBody['fee'].toString();
    var data = TransferData()
      ..hash = paymentData["hash"]
      ..paymentId = paymentData["id"]
      ..type = "zkApp"
      ..fee = fee
      ..amount = "0"
      ..nonce = int.parse(feePayerBody['nonce'])
      ..sender = feePayerBody['publicKey']
      ..status = 'pending'
      ..success = false
      ..receiver = receiver;
    return data;
  }

  Future<TransferData?> signAndSendZkTx(Map txInfo,
      {required BuildContext context}) async {
    String network = store.settings!.isMainnet ? "mainnet" : "testnet";
    final signedTx = await apiRoot.bridge.signZkTransaction({
      "network": network,
      "type": "zk",
      "privateKey": txInfo['privateKey'],
      "fromAddress": txInfo['fromAddress'],
      "fee": txInfo['fee'],
      "nonce": txInfo['nonce'],
      "memo": "",
      "transaction": txInfo["transaction"]
    });
    final signedData = signedTx['data'];
    TransferData? transferData =
        await sendZkTx(signedData['zkappCommand'], context: context);
    return transferData;
  }
}
