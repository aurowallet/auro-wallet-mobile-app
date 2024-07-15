import 'dart:async';
import 'dart:convert';
import 'package:auro_wallet/service/webview/bridgeWebView.dart';

class BridgeService {
  BridgeService();

  // final SubstrateService serviceRoot;
  BridgeWebView? _runner;

  ///For multiple use at the same time
  int _retainCount = 0;

  Future<void> init({String? jsCode}) async {
    final c = Completer();
    if (_runner == null) {
      _runner = BridgeWebView();
      await _runner?.launch(() {
        if (!c.isCompleted) c.complete();
      }, jsCode: jsCode);
    } else {
      await _runner?.reload();
      if (!c.isCompleted) c.complete();
    }
    _retainCount++;
    return c.future;
  }

  Future<void> dispose() async {
    _retainCount--;
    if (_retainCount > 0) return;
    _runner?.dispose();
    _runner = null;
  }

  Future<String> getCurrentSDKVersion() async {
    assert(_runner != null, 'bridge not init');
    String res = await _runner?.evalJavascript('minaSignerVersion()');
    return res;
  }

  Future<Map<String, dynamic>> createWallet(
      String seed, String seedType) async {
    switch (seedType) {
      case 'priKey':
        return await createAccountByPrivateKey(seed);
      case 'mnemonic':
      default:
        return await createWalletByMnemonic(seed, 0, false);
    }
  }

  Future<Map<String, dynamic>> createAccountByPrivateKey(
      String privateKey) async {
    assert(_runner != null, 'bridge not init');
    Map<String, dynamic> params = {'privateKey': privateKey};
    var paramsStr = json.encode(params);
    final res = await _runner
        ?.evalJavascript('account.importWalletByPrivateKey($paramsStr)');
    return res;
  }

  Future<dynamic> createWalletByMnemonic(
      String mnemonic, int accountIndex, bool needPrivateKey) async {
    assert(_runner != null, 'bridge not init');
    assert(mnemonic.isNotEmpty, 'mnemonic not init');

    Map<dynamic, dynamic> params = {
      'mnemonic': mnemonic,
      'accountIndex': accountIndex,
      'needPrivateKey': needPrivateKey,
    };
    var paramsStr = json.encode(params);
    Map<String, dynamic> res = await _runner?.evalJavascript(
        'account.importWalletByMnemonic($paramsStr)',
        allowRepeat: true);
    return res;
  }

  Future<Map<String, dynamic>> signPaymentTx(Map txInfo) async {
    assert(_runner != null, 'bridge not init');
    Map<String, dynamic> res = await _runner?.evalJavascript(
        'auroSignLib.signTransaction(${jsonEncode(txInfo)})',
        allowRepeat: true);
    return res;
  }

  // signStakeDelegationTx
  Future<Map<String, dynamic>> signStakeDelegationTx(Map txInfo) async {
    assert(_runner != null, 'bridge not init');
    Map<String, dynamic> res = await _runner?.evalJavascript(
        'auroSignLib.signTransaction(${jsonEncode(txInfo)})',
        allowRepeat: true);
    return res;
  }

  // signZkTransaction
  Future<Map<String, dynamic>> signZkTransaction(Map txInfo) async {
    assert(_runner != null, 'bridge not init');
    Map<String, dynamic> res = await _runner?.evalJavascript(
        'auroSignLib.signTransaction(${jsonEncode(txInfo)})',
        allowRepeat: true);
    return res;
  }

// signMessage
  Future<Map<String, dynamic>> signMessage(Map messageInfo) async {
    assert(_runner != null, 'bridge not init');
    Map<String, dynamic> res = await _runner?.evalJavascript(
        'auroSignLib.signTransaction(${jsonEncode(messageInfo)})',
        allowRepeat: true);
    return res;
  }

  Future<bool> verifyMessage(Map messageInfo) async {
    assert(_runner != null, 'bridge not init');
    bool res = await _runner?.evalJavascript(
        'auroSignLib.verifyMessage(${jsonEncode(messageInfo)})',
        allowRepeat: true);
    return res;
  }

  Future<Map<String, dynamic>> signFields(Map fieldsInfo) async {
    assert(_runner != null, 'bridge not init');
    Map<String, dynamic> res = await _runner?.evalJavascript(
        'auroSignLib.signFields(${jsonEncode(fieldsInfo)})',
        allowRepeat: true);
    return res;
  }

  Future<bool> verifyFields(Map fieldsInfo) async {
    assert(_runner != null, 'bridge not init');
    bool res = await _runner?.evalJavascript(
        'auroSignLib.verifyFieldsMessage(${jsonEncode(fieldsInfo)})',
        allowRepeat: true);
    return res;
  }

  Future<Map<String, dynamic>> createNullifier(Map info) async {
    assert(_runner != null, 'bridge not init');
    Map<String, dynamic> res = await _runner?.evalJavascript(
        'auroSignLib.createNullifier(${jsonEncode(info)})',
        allowRepeat: true);
    return res;
  }

  Future<Map<String, dynamic>> encryptData(String info, String pubKey) async {
    assert(_runner != null, 'bridge not init');
    Map<String, dynamic> res = await _runner?.evalJavascript(
        'webEncryption.encryptData(${jsonEncode({
              "targetData": info,
              "pubKey": pubKey
            })})',
        allowRepeat: true);
    return res;
  }

  Future<Map<String, dynamic>> decryptData(
      Map info, String privateKey) async {
    assert(_runner != null, 'bridge not init');
    Map<String, dynamic> res = await _runner?.evalJavascript(
        'webEncryption.decryptData(${
          jsonEncode({
              "targetData": info,
              "privateKey": privateKey
            })
        })',
        allowRepeat: true);
    return res;
  }

  int getEvalJavascriptUID() {
    return _runner?.getEvalJavascriptUID() ?? 0;
  }

  Future<void> reload() async {
    return _runner?.reload();
  }

  Future<dynamic> evalJavascript(String code) async {
    return await _runner?.evalJavascript(code);
  }
}
