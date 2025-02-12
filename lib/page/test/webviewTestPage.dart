import 'dart:convert';
import 'dart:math';

import 'package:auro_wallet/common/components/normalButton.dart';
import 'package:auro_wallet/common/consts/enums.dart';
import 'package:auro_wallet/page/test/testTransactionData.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:flutter/material.dart';

class WebviewBridgeTestPage extends StatefulWidget {
  WebviewBridgeTestPage();

  static final String route = '/webview/webviewBridgeTest';

  @override
  _WebviewBridgeTestPageState createState() => _WebviewBridgeTestPageState();
}

class _WebviewBridgeTestPageState extends State<WebviewBridgeTestPage> {
  _WebviewBridgeTestPageState();
  AppStore store = globalAppStore;

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

  String accountA = "B62qpjxUpgdjzwQfd8q2gzxi99wN7SCgmofpvw27MBkfNHfHoY2VH32";
  String accountB = "B62qr2zNMypNKXmzMYSVotChTBRfXzHRtshvbuEjAQZLq6aEa8RxLyD";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  @override
  void dispose() {
    super.dispose();
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
    var version = await webApi.bridge.getCurrentSDKVersion();
    print('sdk version = $version');
    showConfirmDialog("Version is: " + version);
  }

  void createWallet() async {
    setState(() {
      createWalletStatus = true;
    });
    var checkFailedCount = 0;

    Map seedType = {"mnemonic": "mnemonic", "priKey": "priKey"};

    var createWalletMneRes = await webApi.bridge
        .createWallet(testAccount["mnemonic"], seedType["mnemonic"]);

    if (createWalletMneRes["pubKey"] != testAccount["account0"]["pubKey"]) {
      checkFailedCount++;
      debugPrint(
          '\u001b[31m createWalletMneRes failed: ${jsonEncode(createWalletMneRes)} \u001b[0m');
    }

    var createWalletWithPrivateKey = await webApi.bridge
        .createWalletByMnemonic(testAccount["mnemonic"], 0, true);

    if (createWalletWithPrivateKey["priKey"] !=
        testAccount["account0"]["priKey"]) {
      checkFailedCount++;
      debugPrint(
          '\u001b[31m createWalletWithPrivateKey failed: ${jsonEncode(createWalletWithPrivateKey)} \u001b[0m');
    }

    var createWalletPriRes = await webApi.bridge
        .createWallet(testAccount["account0"]["priKey"], "priKey");

    if (createWalletPriRes["pubKey"] != testAccount["account0"]["pubKey"]) {
      checkFailedCount++;
      debugPrint(
          '\u001b[31m createWalletPriRes failed: ${jsonEncode(createWalletPriRes)} \u001b[0m');
    }

    var createAccountByPrivateKeyRes = await webApi.bridge
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
    var mainnetSignPaymentRes = await webApi.bridge
        .signPaymentTx(signPaymentData['mainnet']['signParams']);

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
    var testnetSignPaymentRes = await webApi.bridge
        .signPaymentTx(signPaymentData['testnet']['signParams']);

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
    var mainnetSignStakeTransactionRes = await webApi.bridge
        .signStakeDelegationTx(
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
    var testnetSignStakeTransactionRes = await webApi.bridge
        .signStakeDelegationTx(
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

    var testnetSignZkTransactionRes = await webApi.bridge
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
        await webApi.bridge.signMessage(signData['mainnet']['signParams']);
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

    var mainnetVerifyRes = await webApi.bridge.verifyMessage(mainnetVerifyData);
    print('mainnetVerifyRes${jsonEncode(mainnetVerifyRes)}');
    if (!mainnetVerifyRes) {
      checkFailedCount++;

      debugPrint(
          '\u001b[31m mainnetVerifyRes failed: ${jsonEncode(mainnetVerifyRes)} \u001b[0m');
    }

    /// testnetTest
    var testnetSignRes =
        await webApi.bridge.signMessage(signData['testnet']['signParams']);
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

    var testnetVerifyRes = await webApi.bridge.verifyMessage(testnetVerifyData);
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
        await webApi.bridge.signFields(signData['mainnet']['signParams']);
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

    var mainnetVerifyRes = await webApi.bridge.verifyFields(mainnetVerifyData);
    print('mainnetVerifyRes, ${jsonEncode(mainnetVerifyRes)}');
    if (!mainnetVerifyRes) {
      checkFailedCount++;

      debugPrint(
          '\u001b[31m mainnetVerifyRes failed: ${jsonEncode(mainnetVerifyRes)} \u001b[0m');
    }

    /// testnetTest
    var testnetSignRes =
        await webApi.bridge.signFields(signData['testnet']['signParams']);
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

    var testnetVerifyRes = await webApi.bridge.verifyFields(testnetVerifyData);
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

    var mainnetNullifierRes = await webApi.bridge
        .createNullifier(nullifierData['mainnet']['signParams']);

    if (mainnetNullifierRes["private"].isEmpty) {
      checkFailedCount++;

      debugPrint(
          '\u001b[31m mainnetNullifierRes failed: ${jsonEncode(mainnetNullifierRes)} \u001b[0m');
    }

    var testnetNullifierRes = await webApi.bridge
        .createNullifier(nullifierData['testnet']['signParams']);

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

  // 获取dapp链接
  Future<void> getConnect() async {
    // 获取当前本地存储的 授权链接
    List<String>? list = store.browser?.zkAppConnectingList;
    print('list===list=${list}');
  }

  String generateRandomString(int length) {
    const characters =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    Random random = Random();

    return String.fromCharCodes(Iterable.generate(
      length,
      (_) => characters.codeUnitAt(random.nextInt(characters.length)),
    ));
  }

  // 设置dapp 链接
  Future<void> setConnect() async {
    print('add connect');
    String address = store.wallet!.currentAddress;
    print('setConnect===setConnect__==,${address}');

    String url = "https://test.com/" +
        generateRandomString(5) +
        "_" +
        address.substring(address.length - 5);
    // 添加本地存储的授权链接，如果有就添加
    await store.browser?.addZkAppConnect(store.wallet!.currentAddress, url);
    print('add connect end');
  }

  int generateRandomInt(int max) {
    Random random = Random();
    return random.nextInt(max);
  }

  // 移除dapp链接
  Future<void> removeConnect() async {
    // 按照地址 + 账户移除授权链接 ，先找到当前地址
    // 获取 某一个
    String address = store.wallet!.currentAddress;
    int listLength = store.browser!.zkAppConnectingList.length;
    print('listLength,${listLength}');
    int removeNumber = generateRandomInt(listLength);
    print('removeNumber,${removeNumber}');
    String removeItem = store.browser!.zkAppConnectingList[removeNumber];
    print('removeItem,${removeItem}');
    await store.browser?.removeZkAppConnect(address, removeItem);
    print('remove connect end');
  }

  // 清空dapp链接
  Future<void> clearConnect() async {
    // 清除当前账户所有链接
    // 清除所有账户的所有链接
    String address = store.wallet!.currentAddress;
    await store.browser?.clearZkAppConnect(address);
  }

  // 还有切换账户后的展示
  Future<void> switchAccount() async {
    // 尝试切换账户。看看账户管理的账户，随机切换，并且显示出来
    // B62qpjxUpgdjzwQfd8q2gzxi99wN7SCgmofpvw27MBkfNHfHoY2VH32
// B62qkVs6zgN84e1KjFxurigqTQ57FqV3KnWubV3t77E9R6uBm4DmkPi
// 当前有这两个账户， 随机时候把这两个的后缀加上
    print('switchAccount===0,${store.wallet!.currentAddress}');
    String nextAddress =
        store.wallet!.currentAddress == accountA ? accountB : accountA;
    print('switchAccount===1,${nextAddress}');
    // 获取账户列表
    // 随机切换到 另一个账户，看看是否展示已添加数据
    // 这里就给2个账户，随机切换
    // 获取账户列表
    // webApi.assets.fetchBatchAccountsInfo(
    //       store.wallet!.accountListAll.map((acc) => acc.pubKey).toList());
    // _changeCurrentAccount(account.address != store.wallet!.currentAddress);
    await webApi.account
        .changeCurrentAccount(pubKey: nextAddress, fetchData: true);
    print('switchAccount===2,${store.wallet!.currentAddress}');
    await store.browser?.loadZkAppConnect(nextAddress);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF594AF1),
        title: Text(
          "Webview Bridge Test",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
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
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: NormalButton(
                text: "Create Wallet",
                onPressed: createWallet,
                submitting: createWalletStatus,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: NormalButton(
                text: "Sign Transaction",
                onPressed: signTransaction,
                submitting: signTransactionStatus,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: NormalButton(
                text: "Page test create wallet",
                onPressed: createWalletInDev,
                submitting: pageCreateWalletStatus,
              ),
            ),
            // Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            //   child: NormalButton(
            //     text: "GetConnect",
            //     onPressed: getConnect,
            //   ),
            // ),
            // Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            //   child: NormalButton(
            //     text: "AddConnect",
            //     onPressed: setConnect,
            //   ),
            // ),
            // Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            //   child: NormalButton(
            //     text: "RemoveConnect",
            //     onPressed: removeConnect,
            //   ),
            // ),
            // Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            //   child: NormalButton(
            //     text: "ClearConnect",
            //     onPressed: clearConnect,
            //   ),
            // ),
            // // Switch Account Button
            // Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            //   child: NormalButton(
            //     text: "SwitchAccount",
            //     onPressed: switchAccount,
            //   ),
            // ),
            // Observer to show the current account connections

            // Center(
            //   child: Container(
            //     constraints: BoxConstraints(
            //       minHeight: 200.0,
            //       maxHeight: 300.0,
            //     ),
            //     decoration: BoxDecoration(
            //       border: Border.all(color: Colors.blue, width: 2.0),
            //       borderRadius: BorderRadius.circular(8.0),
            //     ),
            //     child: Expanded(
            //       child: Observer(
            //         builder: (BuildContext context) {
            //           print(
            //               'test zk length=== ${store.browser?.zkAppConnectingList.length}');
            //           return ListView.builder(
            //             shrinkWrap: true,
            //             itemCount:
            //                 store.browser?.zkAppConnectingList.length ?? 0,
            //             itemBuilder: (context, index) {
            //               return Text((index + 1).toString() +
            //                   " : " +
            //                   (store.browser?.zkAppConnectingList[index] ??
            //                       ""));
            //             },
            //           );
            //         },
            //       ),
            //     ),
            //   ),
            // )
          ],
        ),
      ),
    );
  }
}
