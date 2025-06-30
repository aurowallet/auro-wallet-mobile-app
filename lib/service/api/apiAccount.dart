import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:auro_wallet/common/consts/enums.dart';
import 'package:auro_wallet/common/consts/network.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/ledgerMina/mina_ledger_application.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/assets/types/transferData.dart';
import 'package:auro_wallet/store/wallet/types/walletData.dart';
import 'package:auro_wallet/store/wallet/wallet.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/utils/index.dart';
import 'package:auro_wallet/walletSdk/minaSDK.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:bs58check/bs58check.dart' as bs58check;
import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:ledger_flutter/ledger_flutter.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:sodium_libs/sodium_libs_sumo.dart';

class ApiAccount {
  ApiAccount(this.apiRoot);

  final Api apiRoot;
  final store = globalAppStore;

  final LocalAuthentication auth = LocalAuthentication();
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  final _biometricEnabledKey = 'biometric_enabled_v1';
  final _biometricEnabledKey_v2 = 'biometric_enabled_v2';
  final _biometricPasswordKey = 'biometric_password_';
  final _watchModeWarnedKey = 'watch_mode_warned';

  final _appAccessPasswordKey = 'app_access_password_';
  final _transactionsPasswordKey = 'transaction_password_';

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
    await store.wallet!.setCurrentAccount(current!);

    // refresh balance
    await store.assets!.clearAccountAssestCache();
    await store.assets!.loadAccountCache();
    // refresh zkConnect
    await store.browser!.loadZkAppConnect(current);
    if (fetchData) {
      store.triggerBalanceRefresh();
    }
  }

  Future<TransferData?> sendTx(Map input, Map signature,
      {required BuildContext context,
      isRawSignature = false,
      String? gqlUrl}) async {
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
    GraphQLClient? customClient;
    if (gqlUrl != null) {
      final link = HttpLink(gqlUrl);
      customClient = GraphQLClient(link: link, cache: GraphQLCache());
    }
    GqlResult gqlResult = await apiRoot.gqlRequest(_options,
        context: context, customClient: customClient);
    if (gqlResult.error) {
      print('payment broadcast error source: ${gqlResult.errorMessage}');
      String msg = getRealErrorMsg(gqlResult.errorMessage);
      print('[aurowallet] payment broadcast error: ${msg}');
      String nextMsg = msg.isEmpty ? gqlResult.errorMessage : msg;
      UI.toast(nextMsg);
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
      {required BuildContext context,
      isRawSignature = false,
      String? gqlUrl}) async {
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
    GraphQLClient? customClient;
    if (gqlUrl != null) {
      final link = HttpLink(gqlUrl);
      customClient = GraphQLClient(link: link, cache: GraphQLCache());
    }
    GqlResult gqlResult = await apiRoot.gqlRequest(_options,
        context: context, customClient: customClient);
    if (gqlResult.error) {
      print('质押广播出错了');
      String msg = getRealErrorMsg(gqlResult.errorMessage);
      String nextMsg = msg.isEmpty ? gqlResult.errorMessage : msg;
      UI.toast(nextMsg);
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
      {required BuildContext context,
      isDelegation = false,
      String? gqlUrl}) async {
    TransferData? transferData;
    if (isDelegation) {
      transferData = await sendDelegationTx(
          prepareBody['payload'], prepareBody['signature'],
          context: context, isRawSignature: true, gqlUrl: gqlUrl);
    } else {
      transferData = await sendTx(
          prepareBody['payload'], prepareBody['signature'],
          context: context, isRawSignature: true, gqlUrl: gqlUrl);
    }
    return transferData;
  }

  Future<Map?> ledgerSign(Map txInfo,
      {required BuildContext context,
      isDelegation = false,
      String? networkId}) async {
    final minaApp = MinaLedgerApp(store.ledger!.ledgerInstance!,
        accountIndex: txInfo["accountIndex"]);
    final feeLarge =
        BigInt.from(pow(10, COIN.decimals) * txInfo['fee']).toInt();
    final amountLarge = isDelegation
        ? 0
        : BigInt.from(pow(10, COIN.decimals) * txInfo['amount']).toInt();
    final validUntil = "4294967295";
    try {
      int nextNetwork = -1;
      if (networkId != null) {
        nextNetwork = networkId == networkIDMap['mainnet']
            ? Networks.MAINNET.value
            : Networks.DEVNET.value;
      }
      if (nextNetwork == -1) {
        nextNetwork = store.settings!.isMainnet
            ? Networks.MAINNET.value
            : Networks.DEVNET.value;
      }
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
          networkId: nextNetwork);
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
      {required BuildContext context,
      String? networkId,
      String? gqlUrl}) async {
    final feeLarge =
        BigInt.from(pow(10, COIN.decimals) * txInfo['fee']).toInt();
    final amountLarge =
        BigInt.from(pow(10, COIN.decimals) * txInfo['amount']).toInt();

    final signedTx = await apiRoot.bridge.signPaymentTx({
      "network": getNextNetwork(networkId),
      "type": "payment",
      "privateKey": txInfo['privateKey'],
      "fromAddress": txInfo['fromAddress'],
      "toAddress": txInfo['toAddress'],
      "amount": txInfo['amount'],
      "fee": txInfo['fee'],
      "nonce": txInfo['nonce'],
      "memo": txInfo['memo']
    });
    dynamic errorData = signedTx['error'];
    if (errorData != null) {
      UI.toast(errorData['message']);
      return null;
    }
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
        context: context, gqlUrl: gqlUrl);
    return transferData;
  }

  Future<TransferData?> signAndSendDelegationTx(Map txInfo,
      {required BuildContext context,
      String? networkId,
      String? gqlUrl}) async {
    final feeLarge =
        BigInt.from(pow(10, COIN.decimals) * txInfo['fee']).toInt();
    final signedTx = await apiRoot.bridge.signStakeDelegationTx({
      "network": getNextNetwork(networkId),
      "type": "delegation",
      "privateKey": txInfo['privateKey'],
      "fee": txInfo['fee'],
      "fromAddress": txInfo['fromAddress'],
      "toAddress": txInfo['toAddress'],
      "nonce": txInfo['nonce'],
      "memo": txInfo['memo']
    });
    dynamic errorData = signedTx['error'];
    if (errorData != null) {
      UI.toast(errorData['message']);
      return null;
    }
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
        context: context, gqlUrl: gqlUrl);
    return transferData;
  }

  Int8List _getUint8ListFromString(String str) {
    List<int> list = str.codeUnits;
    Int8List bytes = Int8List.fromList(list);
    return bytes;
  }

  Future<String?> getPrivateKeyFromKeyStore(
      String keyStore, String keyStorePassword,
      {required BuildContext context}) async {
    try {
      SodiumSumo sodium = await SodiumSumoInit.init();
      Map keystoreMap = jsonDecode(keyStore);
      var salt = bs58check.decode(keystoreMap['pwsalt']).sublist(1);
      SecureKey key = sodium.crypto.pwhash(
        outLen: 32,
        password: _getUint8ListFromString(keyStorePassword),
        salt: salt,
        opsLimit: keystoreMap['pwdiff'][1],
        memLimit: keystoreMap['pwdiff'][0],
        alg: CryptoPwhashAlgorithm.argon2i13,
      );
      Uint8List privateKey = sodium.crypto.secretBox.openEasy(
        cipherText: bs58check.decode(keystoreMap['ciphertext']).sublist(1),
        nonce: bs58check.decode(keystoreMap['nonce']).sublist(1),
        key: key,
      );
      var privateKeStr = bs58check
          .encode(hex.decode('5a' + hex.encode(privateKey)) as Uint8List);
      key.dispose();
      return privateKeStr;
    } catch (e) {
      AppLocalizations dic = AppLocalizations.of(context)!;
      UI.toast(dic.keystoreError);
      return null;
    }
  }

  Future<bool> createExternalWallet(
    String accountName,
    String address, {
    required BuildContext context,
    String source = WalletSource.outside,
    String seedType = WalletStore.seedTypeNone,
    int hdIndex = 0,
    String password = "",
  }) async {
    Map<String, dynamic> acc = {
      "name": accountName,
      "pubKey": address,
      "hdIndex": hdIndex
    };
    WalletResult res = await store.wallet!.addWallet(acc, password,
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
      store.assets!.setAssetsLoading(true);
      // fetch info for the imported account
      String pubKey = acc['pubKey'];
      store.walletConnectService?.emitAccountsChanged(pubKey);
      webApi.assets.fetchAllTokenAssets();
      webApi.assets.fetchPendingTransactions(pubKey);
      webApi.assets.fetchPendingZkTransactions(pubKey);
      webApi.assets.fetchFullTransactions(pubKey);
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
    if (acc['error'] != null) {
      UI.toast(acc['error']['message']);
      return false;
    }
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
      store.walletConnectService?.emitAccountsChanged(pubKey);
      store.assets!.setAssetsLoading(true);
      webApi.assets.fetchAllTokenAssets();
      webApi.assets.fetchPendingTransactions(pubKey);
      webApi.assets.fetchPendingTransactions(pubKey);
      webApi.assets.fetchFullTransactions(pubKey);
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
      store.assets!.setAssetsLoading(true);
      webApi.assets.fetchAllTokenAssets();
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
    apiRoot.configStorage.write('$_biometricEnabledKey_v2', "enable");
  }

  void setBiometricDisabled() {
    apiRoot.configStorage.write('$_biometricEnabledKey_v2', "disable");
  }

  bool getBiometricEnabled() {
    final enableStatus = apiRoot.configStorage.read('$_biometricEnabledKey_v2');
    final timestamp = apiRoot.configStorage.read('$_biometricEnabledKey');
    if (enableStatus != null || timestamp != null) {
      return enableStatus == "enable";
    }
    return false;
  }

  void setAppAccessEnabled() {
    apiRoot.configStorage.write('$_appAccessPasswordKey', "enable");
  }

  void setAppAccessDisabled() {
    apiRoot.configStorage.write('$_appAccessPasswordKey', "disable");
  }

  bool getAppAccessEnabled() {
    final enableStatus = apiRoot.configStorage.read('$_appAccessPasswordKey');
    if (enableStatus != null) {
      return enableStatus == "enable";
    }
    return false;
  }

  void setTransactionPwdEnabled() {
    apiRoot.configStorage.write('$_transactionsPasswordKey', "enable");
  }

  void setTransactionPwdDisabled() {
    apiRoot.configStorage.write('$_transactionsPasswordKey', "disable");
  }

  bool getTransactionPwdEnabled() {
    final enableStatus =
        apiRoot.configStorage.read('$_transactionsPasswordKey');
    if (enableStatus != null) {
      return enableStatus == "enable";
    }
    return true; // default ture
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

  Future<bool> saveBiometricPass(BuildContext context, String password) async {
    try {
      bool isAuth = await authenticate();
      if (isAuth) {
        await secureStorage.write(
            key: '$_biometricPasswordKey', value: password);
      }
      return isAuth;
    } catch (e) {
      print('saveBiometricPass==err,${e.toString()}');
      return false;
    }
  }

  Future<String?> getBiometricPassStoreFile(
    BuildContext context,
  ) async {
    try {
      bool isAuth = await authenticate();
      if (isAuth) {
        final data = await secureStorage.read(key: '$_biometricPasswordKey');
        return data;
      }
    } catch (e) {
      print("getBiometricPassStoreFile===${e.toString()}");
    }
    return null;
  }

  Future<bool> canAuthenticateWithBiometrics() async {
    final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    return canAuthenticateWithBiometrics;
  }

  Future<void> replaceBiometricData(String newValue) async {
    await secureStorage.write(key: '$_biometricPasswordKey', value: newValue);
    print('Data replaced successfully');
  }

  Future<bool> authenticate() async {
    try {
      return await auth.authenticate(
        localizedReason: " ",
        authMessages: [
          const AndroidAuthMessages(
            biometricHint: "Auro Wallet",
          ),
        ],
        options: AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } on PlatformException catch (e) {
      print("authenticate==failed=${e.toString()}");
      String? showMsg = e.message != null ? e.message : e.toString();
      UI.toast(showMsg ?? "Verify Failed");
      return false;
    }
  }

  Future<Map<String, dynamic>> signMessage(Map signInfo,
      {required BuildContext context, String? networkId}) async {
    Map<String, dynamic> signed = await apiRoot.bridge.signMessage({
      "network": getNextNetwork(networkId),
      ...signInfo,
    });
    return signed;
  }

  String getNextNetwork(String? networkId) {
    String network = "";
    if (networkId != null) {
      network = networkId == networkIDMap['mainnet'] ? "mainnet" : "testnet";
    }
    if (network.isEmpty) {
      network = store.settings!.isMainnet ? "mainnet" : "testnet";
    }
    return network;
  }

  Future<bool> verifyMessage(Map signedInfo,
      {required BuildContext context, String? networkId}) async {
    bool verifyRes = await apiRoot.bridge.verifyMessage({
      "network": getNextNetwork(networkId),
      ...signedInfo,
    });
    return verifyRes;
  }

  Future<Map<String, dynamic>> signFields(Map signInfo,
      {required BuildContext context, String? networkId}) async {
    Map<String, dynamic> signed = await apiRoot.bridge.signFields({
      "network": getNextNetwork(networkId),
      ...signInfo,
    });
    return signed;
  }

  Future<bool> verifyFields(Map signedInfo,
      {required BuildContext context, String? networkId}) async {
    bool verifyRes = await apiRoot.bridge.verifyFields({
      "network": getNextNetwork(networkId),
      ...signedInfo,
    });
    return verifyRes;
  }

  Future<Map<String, dynamic>> createNullifier(Map signInfo,
      {required BuildContext context, String? networkId}) async {
    Map<String, dynamic> signed = await apiRoot.bridge.createNullifier({
      "network": getNextNetwork(networkId),
      ...signInfo,
    });
    return signed;
  }

  Future<TransferData?> sendZkTx(Map zkappCommandInput,
      {required BuildContext context, String? gqlUrl}) async {
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

    GraphQLClient? customClient;
    if (gqlUrl != null) {
      final link = HttpLink(gqlUrl);
      customClient = GraphQLClient(
        link: link,
        cache: GraphQLCache(),
      );
    }

    GqlResult gqlResult = await apiRoot.gqlRequest(_options,
        context: context, customClient: customClient);
    if (gqlResult.error) {
      print('zk broadcaset error：');
      String msg = getRealErrorMsg(gqlResult.errorMessage);
      String nextMsg = msg.isEmpty ? gqlResult.errorMessage : msg;
      UI.toast(nextMsg);
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

  FutureOr<dynamic> signAndSendZkTx(Map txInfo,
      {required BuildContext context,
      String? networkId,
      String? gqlUrl}) async {
    final signedTx = await apiRoot.bridge.signZkTransaction({
      "network": getNextNetwork(networkId),
      "type": "zk",
      "privateKey": txInfo['privateKey'],
      "fromAddress": txInfo['fromAddress'],
      "fee": txInfo['fee'],
      "nonce": txInfo['nonce'],
      "memo": txInfo['memo'],
      "transaction": txInfo["transaction"]
    });
    final errorData = signedTx['error'];
    if (errorData != null) {
      UI.toast(errorData['message']);
      return null;
    }
    final signedData = signedTx['data'];
    bool zkOnlySign = txInfo["zkOnlySign"] ?? false;
    if (zkOnlySign) {
      return {"signedData": jsonEncode(signedData)};
    }
    TransferData? transferData = await sendZkTx(signedData['zkappCommand'],
        context: context, gqlUrl: gqlUrl);
    return transferData;
  }

  Future<dynamic> buildTokenBody(Map prepareBody) async {
    String requestUrl = TokenBuildUrlv2 + "/buildzkv2";
    try {
      var response = await http.post(
        Uri.parse(requestUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(prepareBody),
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        return null;
      }
    } catch (e) {
      UI.toast(e.toString());
      print('buildTokenBody Exception: $e');
      return null;
    }
  }

  Future<dynamic> postTokenResult(Map prepareBody) async {
    String requestUrl = TokenBuildUrlv2 + "/sendzkv2";
    try {
      var response = await http.post(
        Uri.parse(requestUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(prepareBody),
      );
      if (response.statusCode == 200) {
        return response.body;
      } else {
        try {
          // Parse the response body into a Map
          var responseBody = jsonDecode(response.body);

          // Check if the 'message' field exists
          if (responseBody['message'] != null) {
            UI.toast(responseBody['message'].toString());
          } else {
            UI.toast(responseBody.toString());
          }
        } catch (e) {
          // If parsing fails, treat the body as raw text
          UI.toast(response.body.toString());
        }
        return null;
      }
    } catch (e) {
      UI.toast(e.toString());
      print('postTokenResult Exception: $e');
      return null;
    }
  }
}
