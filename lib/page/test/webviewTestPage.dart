import 'dart:convert';

import 'package:auro_wallet/common/components/normalButton.dart';
import 'package:auro_wallet/common/consts/enums.dart';
import 'package:auro_wallet/page/test/testTransactionData.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/service/webview/bridgeService.dart';
import 'package:flutter/material.dart';

class WebviewBridgeTestPage extends StatefulWidget {
  WebviewBridgeTestPage();

  static final String route = '/webview/webviewBridgeTest';

  @override
  _WebviewBridgeTestPageState createState() => _WebviewBridgeTestPageState();
}

class _WebviewBridgeTestPageState extends State<WebviewBridgeTestPage> {
  _WebviewBridgeTestPageState();
  BridgeService _bridge = BridgeService();
  Map testAccount = {
    "mnemonic":
        "treat unique goddess bone spike inspire accident forum muffin boost drill draw",
    "account0": {
      "priKey": "EKEfKdYoaCeGy4aZoCSam6DdGejrL121HSwFGrckzkLcLqPTMUxW",
      "pubKey": "B62qkVs6zgN84e1KjFxurigqTQ57FqV3KnWubV3t77E9R6uBm4DmkPi",
      "hdIndex": 0,
    }
  };
  bool createWalletStatus = false;
  bool signTransactionStatus = false;
  bool pageCreateWalletStatus = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initWebview();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _initWebview() async {
    await _bridge.init();
  }

  void showConfirmDialog(
    String content,
  ) {
    showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Reminder"),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: Text("Confirm"),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  void getSdkVersion() async {
    // 1. get sdk version
    var version = await _bridge.getCurrentSDKVersion();
    print('sdk version = $version');
    showConfirmDialog("Version is: " + version);
  }

  void createWallet() async {
    setState(() {
      createWalletStatus = true;
    });
    var checkFailedCount = 0;

    Map seedType = {"mnemonic": "mnemonic", "priKey": "priKey"};

    var createWalletMneRes = await _bridge.createWallet(
        testAccount["mnemonic"], seedType["mnemonic"]);

    if (createWalletMneRes["pubKey"] != testAccount["account0"]["pubKey"]) {
      checkFailedCount++;
      debugPrint(
          '\u001b[31m createWalletMneRes failed: ${jsonEncode(createWalletMneRes)} \u001b[0m');
    }

    var createWalletWithPrivateKey =
        await _bridge.createWalletByMnemonic(testAccount["mnemonic"], 0, true);

    if (createWalletWithPrivateKey["priKey"] !=
        testAccount["account0"]["priKey"]) {
      checkFailedCount++;
      debugPrint(
          '\u001b[31m createWalletWithPrivateKey failed: ${jsonEncode(createWalletWithPrivateKey)} \u001b[0m');
    }

    var createWalletPriRes =
        await _bridge.createWallet(testAccount["account0"]["priKey"], "priKey");

    if (createWalletPriRes["pubKey"] != testAccount["account0"]["pubKey"]) {
      checkFailedCount++;
      debugPrint(
          '\u001b[31m createWalletPriRes failed: ${jsonEncode(createWalletPriRes)} \u001b[0m');
    }

    var createAccountByPrivateKeyRes = await _bridge
        .createAccountByPrivateKey(testAccount["account0"]["priKey"]);

    if (createAccountByPrivateKeyRes["pubKey"] !=
        testAccount["account0"]["pubKey"]) {
      checkFailedCount++;
      debugPrint(
          '\u001b[31m createAccountByPrivateKeyRes failed: ${jsonEncode(createAccountByPrivateKeyRes)} \u001b[0m');
    }
    setState(() {
      createWalletStatus = false;
    });
    if (checkFailedCount > 0) {
      showConfirmDialog(
          "CreateWallet have $checkFailedCount failed, Please check");
    } else {
      showConfirmDialog("CreateWallet all success");
    }
  }

  Future<int> signPayment() async {
    var checkFailedCount = 0;

    /// mainnetTest
    Map signPaymentData = testTransactionData['signPayment'];
    var mainnetSignPaymentRes =
        await _bridge.signPaymentTx(signPaymentData['mainnet']['signParams']);

    Map expectMainnetSignPaymentData = signPaymentData["mainnet"]["signResult"];
    if (mainnetSignPaymentRes["signature"]['field'] !=
            expectMainnetSignPaymentData['signature']['field'] ||
        mainnetSignPaymentRes["signature"]['scalar'] !=
            expectMainnetSignPaymentData['signature']['scalar']) {
      checkFailedCount++;

      debugPrint(
          '\u001b[31m mainnetSignPaymentRes failed: ${jsonEncode(mainnetSignPaymentRes)} \u001b[0m');
    }

    /// testnetTest
    var testnetSignPaymentRes =
        await _bridge.signPaymentTx(signPaymentData['testnet']['signParams']);

    Map expectTestnetSignPaymentData = signPaymentData["testnet"]["signResult"];
    if (testnetSignPaymentRes["signature"]['field'] !=
            expectTestnetSignPaymentData['signature']['field'] ||
        testnetSignPaymentRes["signature"]['scalar'] !=
            expectTestnetSignPaymentData['signature']['scalar']) {
      checkFailedCount++;

      debugPrint(
          '\u001b[31m testnetSignPaymentRes failed: ${jsonEncode(testnetSignPaymentRes)} \u001b[0m');
    }

    return checkFailedCount;
  }

  Future<int> signStakeDelegation() async {
    var checkFailedCount = 0;

    /// mainnetTest
    Map signStakeTransactionData = testTransactionData['signStakeTransaction'];
    var mainnetSignStakeTransactionRes = await _bridge.signStakeDelegationTx(
        signStakeTransactionData['mainnet']['signParams']);
    print('mainnetSignPaymentRes${jsonEncode(mainnetSignStakeTransactionRes)}');

    Map expectMainnetSignStakeTransactionData =
        signStakeTransactionData["mainnet"]["signResult"];
    if (mainnetSignStakeTransactionRes["signature"]['field'] !=
            expectMainnetSignStakeTransactionData['signature']['field'] ||
        mainnetSignStakeTransactionRes["signature"]['scalar'] !=
            expectMainnetSignStakeTransactionData['signature']['scalar']) {
      checkFailedCount++;

      debugPrint(
          '\u001b[31m mainnetSignStakeTransactionRes failed: ${jsonEncode(mainnetSignStakeTransactionRes)} \u001b[0m');
    }

    /// testnetTest
    var testnetSignStakeTransactionRes = await _bridge.signStakeDelegationTx(
        signStakeTransactionData['testnet']['signParams']);

    Map expectTestnetSignStakeTransactionData =
        signStakeTransactionData["testnet"]["signResult"];
    if (testnetSignStakeTransactionRes["signature"]['field'] !=
            expectTestnetSignStakeTransactionData['signature']['field'] ||
        testnetSignStakeTransactionRes["signature"]['scalar'] !=
            expectTestnetSignStakeTransactionData['signature']['scalar']) {
      checkFailedCount++;

      debugPrint(
          '\u001b[31m testnetSignStakeTransactionRes failed: ${jsonEncode(testnetSignStakeTransactionRes)} \u001b[0m');
    }

    return checkFailedCount;
  }

  Future<int> signZkTransaction() async {
    var checkFailedCount = 0;
    Map signZkTransactionData = testTransactionData['signZkTransaction'];

    var testnetSignZkTransactionRes = await _bridge
        .signZkTransaction(signZkTransactionData['testnet']['signParams']);

    Map expectTestnetSignZkTransactionData =
        signZkTransactionData["testnet"]["signResult"];
    if (testnetSignZkTransactionRes["signature"] !=
        expectTestnetSignZkTransactionData['signature']) {
      checkFailedCount++;

      debugPrint(
          '\u001b[31m testnetSignZkTransactionRes failed: ${jsonEncode(testnetSignZkTransactionRes)} \u001b[0m');
    }

    return checkFailedCount;
  }

  Future<int> signMessage() async {
    var checkFailedCount = 0;

    /// mainnetTest
    Map signData = testTransactionData['signMessageTransaction'];
    var mainnetSignRes =
        await _bridge.signMessage(signData['mainnet']['signParams']);
    print('mainnetSignRes${jsonEncode(mainnetSignRes)}');

    Map expectMainnetSignData = signData["mainnet"]["signResult"];
    if (mainnetSignRes["signature"]['field'] !=
            expectMainnetSignData['signature']['field'] ||
        mainnetSignRes["signature"]['scalar'] !=
            expectMainnetSignData['signature']['scalar']) {
      checkFailedCount++;

      debugPrint(
          '\u001b[31m mainnetSignRes failed: ${jsonEncode(mainnetSignRes)} \u001b[0m');
    }

    /// verifyMessage
    Map mainnetVerifyData = {
      "network": "mainnet",
      "publicKey": mainnetSignRes["publicKey"],
      "signature": mainnetSignRes['signature'],
      "verifyMessage": mainnetSignRes["data"],
    };

    var mainnetVerifyRes = await _bridge.verifyMessage(mainnetVerifyData);
    print('mainnetVerifyRes${jsonEncode(mainnetVerifyRes)}');
    if (!mainnetVerifyRes) {
      checkFailedCount++;

      debugPrint(
          '\u001b[31m mainnetVerifyRes failed: ${jsonEncode(mainnetVerifyRes)} \u001b[0m');
    }

    /// testnetTest
    var testnetSignRes =
        await _bridge.signMessage(signData['testnet']['signParams']);
    print('testnetSignRes, ${jsonEncode(testnetSignRes)}');

    Map expectTestnetSignData = signData["testnet"]["signResult"];
    if (testnetSignRes["signature"]['field'] !=
            expectTestnetSignData['signature']['field'] ||
        testnetSignRes["signature"]['scalar'] !=
            expectTestnetSignData['signature']['scalar']) {
      checkFailedCount++;

      debugPrint(
          '\u001b[31m testnetSignRes failed: ${jsonEncode(testnetSignRes)} \u001b[0m');
    }

    /// verifyMessage
    Map testnetVerifyData = {
      "network": "testnet",
      "publicKey": testnetSignRes["publicKey"],
      "signature": testnetSignRes['signature'],
      "verifyMessage": testnetSignRes["data"],
    };

    var testnetVerifyRes = await _bridge.verifyMessage(testnetVerifyData);
    print('testnetVerifyRes, ${jsonEncode(testnetVerifyRes)}');
    if (!testnetVerifyRes) {
      checkFailedCount++;

      debugPrint(
          '\u001b[31m testnetVerifyRes failed: ${jsonEncode(testnetVerifyRes)} \u001b[0m');
    }

    return checkFailedCount;
  }

  Future<int> signFields() async {
    var checkFailedCount = 0;

    /// mainnetTest
    Map signData = testTransactionData['signFiledsData'];
    var mainnetSignRes =
        await _bridge.signFields(signData['mainnet']['signParams']);
    print('mainnetSignRes${jsonEncode(mainnetSignRes)}');

    Map expectMainnetSignData = signData["mainnet"]["signResult"];
    if (mainnetSignRes["signature"] != expectMainnetSignData['signature']) {
      checkFailedCount++;

      debugPrint(
          '\u001b[31m mainnetSignRes failed: ${jsonEncode(mainnetSignRes)} \u001b[0m');
    }

    /// verifyFields
    Map mainnetVerifyData = {
      "network": "mainnet",
      "publicKey": mainnetSignRes["publicKey"],
      "signature": mainnetSignRes['signature'],
      "fields": mainnetSignRes["data"],
    };

    var mainnetVerifyRes = await _bridge.verifyFields(mainnetVerifyData);
    print('mainnetVerifyRes, ${jsonEncode(mainnetVerifyRes)}');
    if (!mainnetVerifyRes) {
      checkFailedCount++;

      debugPrint(
          '\u001b[31m mainnetVerifyRes failed: ${jsonEncode(mainnetVerifyRes)} \u001b[0m');
    }

    /// testnetTest
    var testnetSignRes =
        await _bridge.signFields(signData['testnet']['signParams']);
    print('testnetSignRes${jsonEncode(testnetSignRes)}');

    Map expectTestnetSignData = signData["testnet"]["signResult"];
    if (testnetSignRes["signature"] != expectTestnetSignData['signature']) {
      checkFailedCount++;

      debugPrint(
          '\u001b[31m testnetSignRes failed: ${jsonEncode(testnetSignRes)} \u001b[0m');
    }

    /// verifyMessage
    Map testnetVerifyData = {
      "network": "testnet",
      "publicKey": testnetSignRes["publicKey"],
      "signature": testnetSignRes['signature'],
      "fields": testnetSignRes["data"],
    };

    var testnetVerifyRes = await _bridge.verifyFields(testnetVerifyData);
    print('testnetVerifyRes, ${jsonEncode(testnetVerifyRes)}');
    if (!testnetVerifyRes) {
      checkFailedCount++;

      debugPrint(
          '\u001b[31m testnetVerifyRes failed: ${jsonEncode(testnetVerifyRes)} \u001b[0m');
    }

    return checkFailedCount;
  }

  Future<int> createNullifier() async {
    var checkFailedCount = 0;
    Map nullifierData = testTransactionData['nullifierData'];

    var mainnetNullifierRes =
        await _bridge.createNullifier(nullifierData['mainnet']['signParams']);

    if (mainnetNullifierRes["private"].isEmpty) {
      checkFailedCount++;

      debugPrint(
          '\u001b[31m mainnetNullifierRes failed: ${jsonEncode(mainnetNullifierRes)} \u001b[0m');
    }

    var testnetNullifierRes =
        await _bridge.createNullifier(nullifierData['testnet']['signParams']);

    if (testnetNullifierRes["private"].isEmpty) {
      checkFailedCount++;

      debugPrint(
          '\u001b[31m testnetNullifierRes failed: ${jsonEncode(testnetNullifierRes)} \u001b[0m');
    }

    return checkFailedCount;
  }

  /// sign all transaction
  void signTransaction() async {
    setState(() {
      signTransactionStatus = true;
    });
    int checkFailedCount = 0;
    int paymentFailedCount = await signPayment();
    checkFailedCount = checkFailedCount + paymentFailedCount;
    int stakeDelegationFailedCount = await signStakeDelegation();
    checkFailedCount = checkFailedCount + stakeDelegationFailedCount;
    int zkFailedCount = await signZkTransaction();
    checkFailedCount = checkFailedCount + zkFailedCount;
    int messageFailedCount = await signMessage();
    checkFailedCount = checkFailedCount + messageFailedCount;
    int fieldsFailedCount = await signFields();
    checkFailedCount = checkFailedCount + fieldsFailedCount;

    int createNullifierFailedCount = await createNullifier();
    checkFailedCount = checkFailedCount + createNullifierFailedCount;

    setState(() {
      signTransactionStatus = false;
    });

    if (checkFailedCount > 0) {
      showConfirmDialog(
          "signTransaction have $checkFailedCount failed, Please check");
    } else {
      showConfirmDialog("signTransaction all success");
    }
  }

  Future<void> createWalletInDev() async {
    setState(() {
      pageCreateWalletStatus = true;
    });
    var isSuccess = await webApi.account.createWalletByPrivateKey("accountName",
        "EKEfKdYoaCeGy4aZoCSam6DdGejrL121HSwFGrckzkLcLqPTMUxW", "Qw1skjaas",
        context: context, source: WalletSource.outside);
    setState(() {
      pageCreateWalletStatus = false;
    });
    print('createWalletInDev: $isSuccess');
    if (isSuccess) {
      showConfirmDialog("Wallet create success");
    } else {
      showConfirmDialog("Wallet create failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF594AF1),
        title: Text("Webview Bridge Test",
            style: TextStyle(
              color: Colors.white,
            )),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: NormalButton(
                  text: "Get Version",
                  onPressed: getSdkVersion,
                )),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: NormalButton(
                  text: "Create Wallet",
                  onPressed: createWallet,
                  submitting: createWalletStatus,
                )),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: NormalButton(
                    text: "Sign Transaction",
                    onPressed: signTransaction,
                    submitting: signTransactionStatus)),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: NormalButton(
                  text: "Page test create wallet",
                  onPressed: createWalletInDev,
                  submitting: pageCreateWalletStatus,
                ))
          ],
        ),
      ),
    );
  }
}
