import 'dart:convert';
import 'package:auro_wallet/common/components/AddressSelect/AddressDropdownButton.dart';
import 'package:auro_wallet/common/components/AddressSelect/AddressSelectionDropdown.dart';
import 'package:auro_wallet/common/components/TimerManager.dart';
import 'package:auro_wallet/common/components/networkFeeDisplay.dart';
import 'package:auro_wallet/common/components/inputItem.dart';
import 'package:auro_wallet/common/components/normalButton.dart';
import 'package:auro_wallet/common/components/txConfirmDialog.dart';
import 'package:auro_wallet/common/consts/index.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/account/scanPage.dart';
import 'package:auro_wallet/page/assets/token/TokenDetail.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/assets/types/fees.dart';
import 'package:auro_wallet/store/assets/types/token.dart';
import 'package:auro_wallet/store/assets/types/tokenPendingTx.dart';
import 'package:auro_wallet/store/settings/types/contactData.dart';
import 'package:auro_wallet/store/wallet/wallet.dart';
import 'package:auro_wallet/store/wallet/types/walletData.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/utils/camera.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:auro_wallet/utils/index.dart';
import 'package:collection/collection.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobx/mobx.dart';

class TransferPage extends StatefulWidget {
  const TransferPage(this.store);

  static final String route = '/assets/transfer';
  final AppStore store;

  @override
  _TransferPageState createState() => _TransferPageState(store);
}

class _TransferPageState extends State<TransferPage> {
  _TransferPageState(this.store);

  final AppStore store;
  TimerManager? timerManager;

  final TextEditingController _amountCtrl = TextEditingController();
  final TextEditingController _toAddressCtrl = TextEditingController();
  final TextEditingController _memoCtrl = TextEditingController();
  final TextEditingController _nonceCtrl = TextEditingController();
  final TextEditingController _feeCtrl = TextEditingController();
  ReactionDisposer? _monitorFeeDisposer;
  final addressFocusNode = FocusNode();
  bool submitDisabled = true;
  bool submitting = false;
  double? currentFee;
  bool inputDirty = false;
  String? contactName;
  ContactData? _contactData;
  List<DropdownAddressItem> addressList = [];

  var _loading = Observable(true);
  late Token token;
  late String _initAddress;
  late WalletData _initWallet;
  late int _initAccountIndex;
  int _loadedNonce = 0;
  bool _nonceLoaded = false;

  String tokenSymbol = '';
  bool isSendMainToken = false;
  double? availableBalance;
  String? availableDecimals;
  String? tokenPublicKey;
  String tokenId = "";
  bool isFromModal = false;
  double? zekoNetFee;
  int feeWeight = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _onFeeLoaded(store.assets!.transferFees);
      _monitorFeeDisposer =
          reaction((_) => store.assets!.transferFees, _onFeeLoaded);
      _amountCtrl.addListener(_monitorSummitStatus);
      _toAddressCtrl.addListener(_monitorSummitStatus);
      _toAddressCtrl.addListener(_onAddressChange);
      _feeCtrl.addListener(_onFeeInputChange);

      _initAddress = store.wallet!.currentAddress;
      _initWallet = store.wallet!.currentWallet;
      _initAccountIndex = _initWallet.currentAccountIndex;

      dynamic params = ModalRoute.of(context)!.settings.arguments;
      token = store.assets!.nextToken;
      isFromModal = params?['isFromModal'] ?? false;
      String? scanAddress = params?['address'];

      if (scanAddress != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            _toAddressCtrl.text = scanAddress;
          });
        });
      }

      TokenAssetInfo? tokenAssestInfo = token.tokenAssestInfo;
      TokenNetInfo? tokenNetInfo = token.tokenNetInfo;
      TokenBaseInfo? tokenBaseInfo = token.tokenBaseInfo;

      isSendMainToken = tokenBaseInfo?.isMainToken ?? false;
      if (isSendMainToken) {
        tokenSymbol = COIN.coinSymbol;
        availableDecimals = COIN.decimals.toString();
      } else {
        feeWeight = 3;
        tokenSymbol = getTokenSymbol(tokenNetInfo);
        availableDecimals = tokenBaseInfo?.decimals;
        tokenPublicKey = tokenNetInfo?.publicKey;
      }
      availableBalance = tokenBaseInfo?.showBalance;
      tokenId = tokenAssestInfo?.tokenId ?? "";

      int intervalTime = _feeCtrl.text.isNotEmpty
          ? 0
          : (store.settings!.isZekoNet ? ZEKO_FEE_LOOP_TIME : 0);
      timerManager = TimerManager(
        intervalTime: intervalTime,
        onCountdownEnd: () async {
          if (store.settings!.isZekoNet && _feeCtrl.text.isEmpty) {
            dynamic zekoFee =
                await webApi.assets.getZekoNetFee(weight: feeWeight + 1);
            if (_feeCtrl.text.isEmpty) {
              setState(() {
                zekoNetFee = Fmt.parsedZekoFee(zekoFee);
                currentFee = zekoNetFee;
              });
            }
          }
          print('Refresh completed');
        },
      );
      _loadData();
      _loadAddressData();
    });
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _toAddressCtrl.dispose();
    _memoCtrl.dispose();
    _nonceCtrl.dispose();
    _feeCtrl.dispose();
    _monitorFeeDisposer?.call();
    timerManager?.dispose();
    super.dispose();
  }

  void _onFeeInputChange() {
    setState(() {
      if (_feeCtrl.text.isNotEmpty) {
        inputDirty = true;
        try {
          currentFee = double.parse(Fmt.parseNumber(_feeCtrl.text));
        } catch (e) {
          currentFee = zekoNetFee != null ? zekoNetFee : store.assets?.transferFees.medium;
        }
        timerManager?.setIntervalTime(0);
      } else {
        inputDirty = false;
        currentFee =
            zekoNetFee != null ? zekoNetFee : store.assets?.transferFees.medium;
        timerManager?.setIntervalTime(
            store.settings!.isZekoNet ? ZEKO_FEE_LOOP_TIME : 0);
      }
    });
  }

  void _onAddressChange() {
    if (_contactData != null) {
      if (_toAddressCtrl.text == _contactData!.address) {
        setState(() {
          contactName = _contactData!.name;
        });
      } else if (contactName != null) {
        setState(() {
          contactName = null;
        });
      }
    }
  }

  void _monitorSummitStatus() {
    if (_toAddressCtrl.text.isEmpty || _amountCtrl.text.isEmpty) {
      if (!submitDisabled) {
        setState(() {
          submitDisabled = true;
        });
      }
    } else if (submitDisabled) {
      setState(() {
        submitDisabled = false;
      });
    }
  }

  Future<void> _onScan() async {
    var canOpen = await CameraUtils.canOpenCamera();
    if (!canOpen) {
      return;
    }
    addressFocusNode.unfocus();
    addressFocusNode.canRequestFocus = false;
    Future.delayed(Duration(milliseconds: 100), () {
      addressFocusNode.canRequestFocus = true;
    });
    var to = await Navigator.of(context).pushNamed(ScanPage.route);
    if (to == null) return;
    String address = (to as QRCodeAddressResult).address;
    _toAddressCtrl.text = address;
  }

  Future<bool> _validate() async {
    String? amountError = _validateAmount();
    if (amountError != null) {
      UI.toast(amountError);
      return false;
    }
    String? addressError = await _validateAddress();
    if (addressError != null) {
      UI.toast(addressError);
      return false;
    }
    return true;
  }

  bool _isAllTransfer() {
    if (availableBalance != null) {
      double amount = double.parse(Fmt.parseNumber(_amountCtrl.text));
      if (amount == availableBalance) {
        return true;
      }
    }
    return false;
  }

  Future<Map<String, dynamic>?> getTokenBuildBody(
      Map txInfo, String privateKey) async {
    AppLocalizations dic = AppLocalizations.of(context)!;
    dynamic res =
        await webApi.assets.getTokenState(txInfo['toAddress'], tokenId);

    bool fundNewAccountStatus = res == null;
    final amountDec = Decimal.parse(txInfo['amount'].toString());
    final multiplier = Decimal.parse('1' + '0' * int.parse(availableDecimals ?? "0"));
    final amountLarge = (amountDec * multiplier).toBigInt().toInt();
    Map<String, dynamic> buildInfo = {
      "sender": txInfo['fromAddress'],
      "receiver": txInfo['toAddress'],
      "tokenAddress": tokenPublicKey,
      "amount": amountLarge,
      "isNewAccount": fundNewAccountStatus.toString(),
      "gqlUrl": store.settings!.currentNode?.url ?? '',
      "networkID": store.settings!.currentNode?.networkID ?? '',
      "nonce": txInfo['nonce'],
      "memo": txInfo['memo'],
    };
    Map<String, dynamic> encrypRes = await webApi.bridge
        .encryptData(jsonEncode(buildInfo), center_public_keys);
    dynamic data = await webApi.account.buildTokenBody(encrypRes);
    if (data == null) {
      return null;
    }
    Map nextData = jsonDecode(data);
    if (nextData['data'] == null) {
      UI.toast(nextData['message'] ?? nextData.toString());
      return null;
    }
    Map<String, dynamic> realUnSignTxStr =
        await webApi.bridge.decryptData(nextData['data'], app_private_keys);

    Map transaction = realUnSignTxStr['decryptedData'];
    if (transaction['transaction'] != null &&
        transaction['buildHash'] != null) {
      Map<String, dynamic> transactionBody =
          jsonDecode(transaction['transaction']);
      bool checkRes = verifyTokenCommand(buildInfo, tokenId, transactionBody);
      if (!checkRes) {
        UI.toast(dic.buildFailed);
        return null;
      }
      return {
        "zkCommand": transaction['transaction'],
        "buildHash": transaction['buildHash']
      };
    } else {
      UI.toast(data.toString());
      return null;
    }
  }

  void _handleSubmit() async {
    if (submitting) return;
    setState(() { submitting = true; });
    _unFocus();
    if (_nonceCtrl.text.isEmpty) {
      if (_loading.value) {
        await asyncWhen((r) => _loading.value == false);
        if (!mounted) return;
      }
    }
    List<TokenPendingTx>? tempTxList = widget
        .store.assets!.tokenPendingTxList[_initAddress];

    if (isSendMainToken && (tempTxList != null && tempTxList.length > 0)) {
      bool? isAgree =
          await UI.showTokenTxDialog(context: context, txList: tempTxList);
      if (isAgree == null || !isAgree) {
        if (mounted) setState(() { submitting = false; });
        return;
      }
      if (!mounted) return;
    }
    if (await _validate()) {
      double amount = double.parse(Fmt.parseNumber(_amountCtrl.text));
      String toAddress = _toAddressCtrl.text.trim();
      String memo = _memoCtrl.text.trim();
      double fee;
      int inferredNonce;
      bool shouldShowNonce = false;
      if (_nonceCtrl.text.isNotEmpty) {
        shouldShowNonce = true;
        inferredNonce = int.parse(_nonceCtrl.text);
      } else {
        int freshNonce = await webApi.assets.fetchAccountNonceWithRetry(
          _initAddress,
        );
        if (!mounted) return;
        if (freshNonce >= 0) {
          inferredNonce = freshNonce;
        } else if (_nonceLoaded) {
          inferredNonce = _loadedNonce;
        } else {
          setState(() { submitting = false; });
          return;
        }
        List<TokenPendingTx>? freshTxList = widget
            .store.assets!.tokenPendingTxList[_initAddress];
        if (!isSendMainToken && (freshTxList != null && freshTxList.length > 0)) {
          int pendingNonce = freshTxList[0].nonce + 1;
          if (pendingNonce > inferredNonce) {
            inferredNonce = pendingNonce;
          }
          shouldShowNonce = true;
        }
      }
      fee = currentFee ?? store.assets!.transferFees.medium;
      double amountToTransfer = amount;
      if (isSendMainToken && _isAllTransfer()) {
        amountToTransfer =
            (Decimal.parse(amount.toString()) - Decimal.parse(fee.toString()))
                .toDouble();
      }
      AppLocalizations dic = AppLocalizations.of(context)!;
      bool showTimer = false;
      if (timerManager != null && timerManager!.getIntervalTime() > 0) {
        showTimer = true;
      }
      var txItems = [
        TxItem(label: dic.toAddress, value: toAddress),
        TxItem(
          label: dic.fromAddress,
          value: _initAddress,
        ),
        TxItem(
            label: dic.fee,
            value: '${fee.toString()} ${COIN.coinSymbol}',
            showTimer: showTimer),
      ];
      if (shouldShowNonce) {
        txItems.add(TxItem(label: "Nonce ", value: '$inferredNonce'));
      }
      if (memo.isNotEmpty) {
        txItems.add(TxItem(label: dic.memo2, value: memo));
      }
      final isWatchMode =
          _initWallet.walletType == WalletStore.seedTypeNone;
      final isLedger =
          _initWallet.walletType == WalletStore.seedTypeLedger;
      if (isLedger && !isSendMainToken) {
        UI.toast(dic.notSupportNow);
        setState(() { submitting = false; });
        return;
      }
      await UI.showTxConfirm(
          context: context,
          title: dic.sendDetail,
          isLedger: isLedger,
          items: txItems,
          disabled: isWatchMode,
          buttonText: isWatchMode ? dic.watchMode : dic.confirm,
          headLabel: dic.amount,
          timerManager: timerManager,
          headValue: Row(
            textBaseline: TextBaseline.alphabetic,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                Fmt.priceFloor(amountToTransfer,
                    lengthFixed: 2,
                    lengthMax: int.parse(availableDecimals ?? "0")),
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 6),
              Text(
                tokenSymbol,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          onConfirm: () async {
            String? privateKey;
            if (!isLedger) {
              String? password = await UI.showPasswordDialog(
                  context: context,
                  wallet: _initWallet,
                  inputPasswordRequired: false,
                  isTransaction: true,
                  store: store);
              if (password == null) {
                return false;
              }
              privateKey = await webApi.account.getPrivateKey(
                  _initWallet,
                  _initAccountIndex,
                  password);
              if (privateKey == null) {
                store.wallet!.clearRuntimePwd();
                password = await UI.showPasswordDialog(
                    context: context,
                    wallet: _initWallet,
                    inputPasswordRequired: true,
                    isTransaction: true,
                    store: store);
                if (password == null) {
                  return false;
                }
                privateKey = await webApi.account.getPrivateKey(
                    _initWallet,
                    _initAccountIndex,
                    password);
                if (privateKey == null) {
                  store.wallet!.clearRuntimePwd();
                  UI.toast(dic.passwordError);
                  return false;
                }
              }
            }
            Map txInfo = {
              "privateKey": privateKey,
              "accountIndex": _initAccountIndex,
              "fromAddress": _initAddress,
              "toAddress": toAddress,
              "amount": amountToTransfer,
              "fee": fee,
              "nonce": inferredNonce,
              "memo": memo,
            };
            dynamic data;
            if (isLedger) {
              print('start sign ledger');
              final tx = await webApi.account
                  .ledgerSign(txInfo, context: context, isDelegation: false);
              if (tx == null) {
                return false;
              }
              if (mounted) {
                data = await webApi.account
                    .sendTxBody(tx, context: context, isDelegation: false);
              }
            } else {
              if (isSendMainToken) {
                data = await webApi.account
                    .signAndSendTx(txInfo, context: context);
              } else {
                Map<String, dynamic>? buildBody =
                    await getTokenBuildBody(txInfo, privateKey ?? "");
                if (buildBody == null) {
                  return false;
                }
                txInfo["transaction"] = buildBody['zkCommand'];
                txInfo["zkOnlySign"] = true;
                dynamic signedRes = await webApi.account
                    .signAndSendZkTx(txInfo, context: context);
                if (signedRes == null) {
                  return false;
                }
                dynamic signedData = signedRes["signedData"];
                Map<String, dynamic> nextData = {
                  "buildHash": buildBody['buildHash'],
                  "signedData": signedData,
                  'sender': txInfo['fromAddress'],
                  'receiver': txInfo['toAddress'],
                  'tokenAddress': tokenPublicKey,
                  'networkID': store.settings!.currentNode?.networkID ?? '',
                };
                Map<String, dynamic> realUnSignTxStr = await webApi.bridge
                    .encryptData(jsonEncode(nextData), center_public_keys);
                data = await webApi.account.postTokenResult(realUnSignTxStr);
                if (data == null) {
                  return false;
                }
                dynamic parsedData = jsonDecode(data);
                if (parsedData['error'] != null) {
                  String msg = parsedData['error'] != null
                      ? parsedData['error'].toString()
                      : data;
                  UI.toast(msg);
                  return false;
                }
              }
            }
            if (data == null) {
              return false;
            }
            if (mounted) {
              if (isFromModal) {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(
                  context,
                  TokenDetailPage.route,
                );
              } else {
                Navigator.popUntil(context, ModalRoute.withName(TokenDetailPage.route));
                widget.store.triggerTokenRefresh();
              }
              return true;
            }
            return false;
          });
      if (mounted) setState(() { submitting = false; });
      return;
    }
    if (mounted) setState(() { submitting = false; });
  }

  void _updateAvailableBalance() {
    Token? freshToken;
    if (isSendMainToken) {
      freshToken = store.assets!.mainTokenNetInfo;
    } else {
      freshToken = store.assets!.tokenList.firstWhereOrNull(
          (t) => t.tokenAssestInfo?.tokenId == tokenId);
    }
    if (freshToken != null && freshToken.tokenBaseInfo?.showBalance != null) {
      setState(() {
        availableBalance = freshToken!.tokenBaseInfo!.showBalance;
      });
      store.assets!.setNextToken(freshToken);
    }
  }

  Future<void> _loadData() async {
    List data = await Future.wait([
      webApi.assets.fetchAllTokenAssets(),
      webApi.assets.queryTxFees(),
      webApi.assets
          .getZekoNetFee(weight: store.settings!.isZekoNet ? feeWeight + 1 : 0)
    ]);
    if (!mounted) return;
    _updateAvailableBalance();
    int freshNonce = int.tryParse(store.assets!.mainTokenNetInfo.tokenAssestInfo?.inferredNonce ?? '0') ?? 0;
    await webApi.assets.fetchPendingTokenList(_initAddress, freshNonce.toString());
    if (!mounted) return;
    if (store.settings!.isZekoNet && data[2] != null) {
      setState(() {
        zekoNetFee = Fmt.parsedZekoFee(data[2]);
        currentFee = zekoNetFee;
      });
    }
    _loadedNonce = freshNonce;
    _nonceLoaded = true;
    runInAction(() {
      _loading.value = false;
    });
  }

  Future<void> onSelect(ContactData addressInfo) async {
    _toAddressCtrl.text = addressInfo.address;
    setState(() {
      _contactData = addressInfo;
      contactName = addressInfo.name;
    });
  }

  Future<void> _loadAddressData() async {
    var currentAddress = _initAddress;
    var accountList = store.wallet!.accountListAll
        .map((accountItem) => {
              "name": Fmt.accountName(accountItem),
              "address": accountItem.pubKey,
              "type": AddressItemTypes.account
            })
        .toList();
    var contactsList = store.settings!.contactList
        .map((addressBookItem) => {
              "name": addressBookItem.name,
              "address": addressBookItem.address,
              "type": AddressItemTypes.addressbook
            })
        .toList();
    List<Map<String, dynamic>> tempList = [...contactsList, ...accountList];
    List<DropdownAddressItem> convertedList = tempList
        .where((element) => element["address"] != currentAddress)
        .map((data) {
      return DropdownAddressItem(
          name: data["name"],
          address: data["address"],
          type: data["type"],
          addressKey: data["name"] +
              data["address"] +
              data["type"].toString().split('.')[1]);
    }).toList();
    if (convertedList.isEmpty) {
      addressList.add(DropdownAddressItem(
          name: "",
          address: "",
          type: AddressItemTypes.empty,
          addressKey: AddressItemTypes.empty.toString().split('.')[1]));
    } else {
      addressList.addAll(convertedList);
    }
  }

  void _onFeeLoaded(Fees fees) {
    if (inputDirty) {
      return;
    }
    print('_onFeeLoaded');
    setState(() {
      if (_feeCtrl.text.isEmpty) {
        currentFee = zekoNetFee != null ? zekoNetFee : fees.medium;
      }
    });
  }

  Future<String?> _validateAddress() async {
    AppLocalizations dic = AppLocalizations.of(context)!;
    String toAddress = _toAddressCtrl.text.trim();
    bool isValid = await webApi.account.isAddressValid(toAddress);
    if (!isValid) {
      return dic.sendAddressError;
    }
    return null;
  }

  void _unFocus() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  String? _validateAmount() {
    bool isAllTransferFlag = _isAllTransfer();
    AppLocalizations dic = AppLocalizations.of(context)!;
    double availableBalanceStr =
        (availableBalance != null ? availableBalance : 0) as double;
    Decimal available = Decimal.parse(availableBalanceStr.toString());
    double fee = currentFee ?? store.assets!.transferFees.medium;
    Decimal transferFee = Decimal.parse(fee.toString());
    if (_amountCtrl.text.isEmpty) {
      return dic.amountError;
    }
    Decimal transferAmount = Decimal.parse(Fmt.parseNumber(_amountCtrl.text));
    if (isSendMainToken) {
      if (isAllTransferFlag) {
        if ((transferAmount - transferFee) < Decimal.zero) {
          return dic.balanceNotEnough;
        }
      } else {
        if (transferAmount > (available - transferFee)) {
          return dic.balanceNotEnough;
        }
      }
    } else {
      if (transferAmount > available) {
        return dic.balanceNotEnough;
      }
    }
    return null;
  }

  void _onAdvanceConfirm(String fee, String nonce) {
    if (fee.isNotEmpty) {
      _feeCtrl.text = fee;
    } else {
      _feeCtrl.clear();
    }
    if (nonce.isNotEmpty) {
      _nonceCtrl.text = nonce;
    } else {
      _nonceCtrl.clear();
    }
  }

  void _onAllClick() {
    _amountCtrl.text = availableBalance.toString();
    _amountCtrl.text = Fmt.parseShowBalance(availableBalance!,
        showLength: int.parse(availableDecimals ?? "0"));
  }

  @override
  Widget build(BuildContext context) {
    int nonceHolder = int.tryParse(
            store.assets!.mainTokenNetInfo.tokenAssestInfo?.inferredNonce ?? '0') ??
        0;
    return Observer(
      builder: (_) {
        AppLocalizations dic = AppLocalizations.of(context)!;
        final int decimals = int.parse(availableDecimals ?? "0");
        final fees = store.assets!.transferFees;
        double realBottom = MediaQuery.of(context).viewInsets.bottom;
        double nextBottom = realBottom > 0 ? realBottom - 120 : realBottom;
        nextBottom = nextBottom.isNegative ? 0 : nextBottom;
        String symbol = tokenSymbol;
        String pageTitle = dic.send + " " + symbol;
        String showBalance =
            store.assets!.nextToken.tokenBaseInfo?.showBalance != null
                ? Fmt.parseShowBalance(
                    store.assets!.nextToken.tokenBaseInfo!.showBalance!,
                    showLength: decimals)
                : "0.0";
        return Scaffold(
          appBar: AppBar(
            title: Text(pageTitle),
            shadowColor: Colors.transparent,
            centerTitle: true,
            actions: <Widget>[
              IconButton(
                icon: SvgPicture.asset('assets/images/assets/scanner.svg',
                    width: 20,
                    height: 20,
                    colorFilter:
                        ColorFilter.mode(Colors.black, BlendMode.srcIn)),
                onPressed: _onScan,
              )
            ],
          ),
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.white,
          body: SafeArea(
            maintainBottomViewPadding: true,
            child: Builder(
              builder: (BuildContext context) {
                return Column(
                  children: <Widget>[
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.fromLTRB(20, 22, 20, 0),
                        children: <Widget>[
                          Container(
                            child: Column(
                              children: [
                                InputItem(
                                  padding: const EdgeInsets.only(top: 0),
                                  label: dic.toAddress,
                                  placeholder: dic.address,
                                  initialValue: '',
                                  labelAffix: contactName != null
                                      ? Container(
                                          margin: EdgeInsets.only(
                                              left: 8, right: 8),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 4, vertical: 1),
                                          decoration: BoxDecoration(
                                              color: Colors.black
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(2)),
                                          child: Text(
                                            contactName!,
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black
                                                    .withValues(alpha: 0.5)),
                                          ),
                                        )
                                      : null,
                                  controller: _toAddressCtrl,
                                  focusNode: addressFocusNode,
                                  suffixIcon: AddressSelectionDropdown(
                                      addressList: addressList,
                                      onSelect: onSelect),
                                ),
                                InputItem(
                                    label: dic.amount,
                                    initialValue: '',
                                    placeholder: '0',
                                    controller: _amountCtrl,
                                    inputFormatters: [
                                      UI.decimalInputFormatter(decimals)
                                    ],
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            decimal: true),
                                    rightWidget: Text(
                                      showBalance + " " + symbol,
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0x80000000)),
                                    ),
                                    suffixIcon: GestureDetector(
                                      onTap: _onAllClick,
                                      behavior: HitTestBehavior.opaque,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            dic.allTransfer,
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Theme.of(context)
                                                    .primaryColor),
                                          )
                                        ],
                                      ),
                                    )),
                                InputItem(
                                  label: dic.memo,
                                  initialValue: '',
                                  controller: _memoCtrl,
                                ),
                              ],
                            ),
                          ),
                          NetworkFeeDisplay(
                            currentFee: currentFee ?? fees.medium,
                            transferFees: fees,
                            onAdvanceConfirm: _onAdvanceConfirm,
                            currentNonce: nonceHolder,
                            advanceFee: _feeCtrl.text,
                            advanceNonce: _nonceCtrl.text,
                            showFeeButtons: !store.settings!.isZekoNet,
                          )
                        ],
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(
                            top: 15, left: 15, right: 15, bottom: nextBottom)),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 38, vertical: 30),
                      child: NormalButton(
                        color: ColorsUtil.hexColor(0x6D5FFE),
                        text: dic.next,
                        submitting: submitting,
                        disabled: submitDisabled,
                        onPressed: _handleSubmit,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
