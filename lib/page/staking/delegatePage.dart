import 'dart:math';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/assets/token/TokenDetail.dart';
import 'package:auro_wallet/store/assets/types/tokenPendingTx.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:auro_wallet/common/components/txConfirmDialog.dart';
import 'package:auro_wallet/common/components/feeSelector.dart';
import 'package:auro_wallet/common/components/formPanel.dart';
import 'package:auro_wallet/common/components/inputItem.dart';
import 'package:auro_wallet/common/components/normalButton.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/page/assets/transactionDetail/transactionDetailPage.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/staking/types/validatorData.dart';
import 'package:auro_wallet/store/assets/types/transferData.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:auro_wallet/store/wallet/wallet.dart';
import 'package:auro_wallet/common/components/advancedTransferOptions.dart';
import 'package:mobx/mobx.dart';
import 'package:auro_wallet/store/assets/types/fees.dart';

class DelegateParams {
  DelegateParams({this.manualAddValidator = false, this.validatorData});

  bool manualAddValidator;
  ValidatorData? validatorData;
}

class DelegatePage extends StatefulWidget {
  static final String route = '/staking/delegate';

  DelegatePage(this.store);

  final AppStore store;

  @override
  _DelegatePageState createState() => _DelegatePageState(store);
}

class _DelegatePageState extends State<DelegatePage>
    with SingleTickerProviderStateMixin {
  _DelegatePageState(this.store);

  final AppStore store;

  final TextEditingController _nonceCtrl = new TextEditingController();
  final TextEditingController _feeCtrl = new TextEditingController();
  final TextEditingController _memoCtrl = new TextEditingController();
  final TextEditingController _validatorCtrl = new TextEditingController();
  late ReactionDisposer _monitorFeeDisposer;
  bool _submitDisabled = false;
  bool submitting = false;
  var _loading = Observable(true);
  bool inputDirty = false;
  double? currentFee;

  @override
  void initState() {
    super.initState();
    _onFeeLoaded(store.assets!.transferFees);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DelegateParams params =
          ModalRoute.of(context)!.settings.arguments as DelegateParams;
      _monitorFeeDisposer =
          reaction((_) => store.assets!.transferFees, _onFeeLoaded);
      _feeCtrl.addListener(_onFeeInputChange);
      if (params.manualAddValidator) {
        _validatorCtrl.addListener(_monitorSummitStatus);
        setState(() {
          _submitDisabled = true;
        });
      }
      _loadData();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _memoCtrl.dispose();
    _nonceCtrl.dispose();
    _feeCtrl.dispose();
    _validatorCtrl.dispose();
    _monitorFeeDisposer();
  }

  void _onFeeInputChange() {
    setState(() {
      inputDirty = true;
      if (_feeCtrl.text.isNotEmpty) {
        currentFee = double.parse(Fmt.parseNumber(_feeCtrl.text));
      } else {
        currentFee = null;
      }
    });
  }

  void _monitorSummitStatus() {
    if (_validatorCtrl.text.isEmpty) {
      if (!_submitDisabled) {
        setState(() {
          _submitDisabled = true;
        });
      }
    } else if (_submitDisabled) {
      setState(() {
        _submitDisabled = false;
      });
    }
  }

  void _onFeeLoaded(Fees fees) {
    if (inputDirty) {
      return;
    }
    print('_onFeeLoaded');
    if (currentFee == null) {
      currentFee = fees.medium;
      _feeCtrl.text = currentFee.toString();
      print('set fee ctr');
    }
  }

  Future<void> _loadData() async {
    await Future.wait([
      webApi.assets.fetchAllTokenAssets(),
      webApi.assets.queryTxFees(),
      webApi.assets.fetchPendingTokenList(
          widget.store.wallet!.currentAddress,
          widget.store.assets!.mainTokenNetInfo.tokenAssestInfo
                  ?.inferredNonce ??
              "0")
    ]);
    runInAction(() {
      _loading.value = false;
    });
  }

  void _onChooseFee(double fee) {
    _feeCtrl.text = fee.toString();
    setState(() {
      currentFee = fee;
    });
  }

  String? _validateBalance() {
    AppLocalizations dic = AppLocalizations.of(context)!;
    double? showBalance =
        store.assets!.mainTokenNetInfo.tokenBaseInfo?.showBalance;
    double availableBalanceStr =
        (showBalance != null ? showBalance : 0) as double;
    BigInt available =
        BigInt.from(pow(10, COIN.decimals) * availableBalanceStr);
    final int decimals = COIN.decimals;
    double fee = _feeCtrl.text.isNotEmpty
        ? double.parse(Fmt.parseNumber(_feeCtrl.text))
        : currentFee!;
    if (available / BigInt.from(pow(10, decimals)) - fee <= 0) {
      return dic.balanceNotEnough;
    }
    return null;
  }

  Future<String?> _validateValidator() async {
    AppLocalizations dic = AppLocalizations.of(context)!;
    DelegateParams params =
        ModalRoute.of(context)!.settings.arguments as DelegateParams;
    if (params.manualAddValidator) {
      if (_validatorCtrl.text.isEmpty) {
        return dic.inputNodeAddress;
      }
      bool isValid =
          await webApi.account.isAddressValid(_validatorCtrl.text.trim());
      if (!isValid) {
        return dic.sendAddressError;
      }
      return null;
    }
    return null;
  }

  Future<bool> _validate() async {
    String? amountError = _validateBalance();
    if (amountError != null) {
      UI.toast(amountError);
      return false;
    }
    String? addressError = await _validateValidator();
    if (addressError != null) {
      UI.toast(addressError);
      return false;
    }
    return true;
  }

  void _unFocus() {
    FocusScope.of(context).requestFocus(new FocusNode());
  }

  void _handleSubmit() async {
    List<TokenPendingTx>? tempTxList = widget
        .store.assets!.tokenPendingTxList[widget.store.wallet!.currentAddress];

    if (tempTxList != null && tempTxList.length > 0) {
      bool? isAgree =
          await UI.showTokenTxDialog(context: context, txList: tempTxList);
      if (isAgree == null || !isAgree) {
        return;
      }
    }
    _unFocus();
    if (_nonceCtrl.text.isEmpty && currentFee == null) {
      if (_loading.value) {
        // waiting nonce data from server
        setState(() {
          submitting = true;
        });
        await asyncWhen((r) => _loading.value == false);
        setState(() {
          submitting = false;
        });
      }
    }
    if (await _validate()) {
      AppLocalizations dic = AppLocalizations.of(context)!;
      String symbol = COIN.coinSymbol;
      int decimals = COIN.decimals;
      String memo = _memoCtrl.text.trim();
      double fee;
      bool shouldShowNonce = false;
      int inferredNonce;
      if (_nonceCtrl.text.isNotEmpty) {
        shouldShowNonce = true;
        inferredNonce = int.parse(_nonceCtrl.text);
      } else {
        inferredNonce = int.parse(
            store.assets!.mainTokenNetInfo.tokenAssestInfo?.inferredNonce ??
                "0");
      }
      fee = _feeCtrl.text.isNotEmpty
          ? double.parse(Fmt.parseNumber(_feeCtrl.text))
          : currentFee!;
      DelegateParams params =
          ModalRoute.of(context)!.settings.arguments as DelegateParams;
      ValidatorData? validatorData = params.validatorData;
      String validatorAddress = params.manualAddValidator
          ? _validatorCtrl.text.trim()
          : validatorData!.address;
      List<TxItem> txItems = [];
      // if (!params.manualAddValidator) {
      //   txItems.add(TxItem(label: dic.producerName, value: validatorData!.name ?? Fmt.address(validatorAddress, pad: 8)));
      // }
      txItems.addAll([
        TxItem(
            label: dic.providerAddress,
            value: validatorAddress,
            type: TxItemTypes.address),
        TxItem(
            label: dic.fromAddress,
            value: store.wallet!.currentAddress,
            type: TxItemTypes.address),
        TxItem(
            label: dic.fee,
            value: '${fee.toString()} ${COIN.coinSymbol}',
            type: TxItemTypes.amount),
      ]);
      if (shouldShowNonce) {
        txItems.add(TxItem(
            label: "Nonce ", value: '$inferredNonce', type: TxItemTypes.text));
      }
      if (memo.isNotEmpty) {
        txItems
            .add(TxItem(label: dic.memo2, value: memo, type: TxItemTypes.text));
      }
      bool isWatchMode =
          store.wallet!.currentWallet.walletType == WalletStore.seedTypeNone;
      String validateName;
      bool isLedger =
          store.wallet!.currentWallet.walletType == WalletStore.seedTypeLedger;
      if (params.manualAddValidator) {
        validateName = Fmt.address(validatorAddress, pad: 10);
      } else {
        validateName =
            validatorData!.name ?? Fmt.address(validatorAddress, pad: 10);
      }
      bool exited = false;
      await UI.showTxConfirm(
          context: context,
          title: dic.sendDetail,
          items: txItems,
          isLedger: isLedger,
          headLabel: dic.producerName,
          headValue: Text(
            validateName,
            style: TextStyle(
                fontSize: 20, color: Colors.black, fontWeight: FontWeight.w600),
          ),
          disabled: isWatchMode,
          buttonText: isWatchMode ? dic.watchMode : dic.confirm,
          onConfirm: () async {
            String? privateKey;
            if (!isLedger) {
              String? password = await UI.showPasswordDialog(
                  context: context,
                  wallet: store.wallet!.currentWallet,
                  inputPasswordRequired: false,
                  isTransaction: true,
                  store: store);
              if (password == null) {
                return false;
              }
              privateKey = await webApi.account.getPrivateKey(
                  store.wallet!.currentWallet,
                  store.wallet!.currentWallet.currentAccountIndex,
                  password);
              if (privateKey == null) {
                UI.toast(dic.passwordError);
                return false;
              }
            }
            Map txInfo = {
              "privateKey": privateKey,
              "accountIndex": store.wallet!.currentWallet.currentAccountIndex,
              "fromAddress": store.wallet!.currentAddress,
              "toAddress": validatorAddress,
              "fee": fee,
              "nonce": inferredNonce,
              "memo": memo,
            };
            TransferData? data;
            if (isLedger) {
              // data = await webApi.account
              //     .ledgerSign(txInfo, context: context, isDelegation: true);
              print('stake: start sign ledger');
              final tx = await webApi.account
                  .ledgerSign(txInfo, context: context, isDelegation: true);
              if (tx == null) {
                return false;
              }
              if (!exited) {
                data = await webApi.account
                    .sendTxBody(tx, context: context, isDelegation: true);
              }
            } else {
              data = await webApi.account
                  .signAndSendDelegationTx(txInfo, context: context);
            }
            if (data == null) {
              return false;
            }
            if (mounted) {
              // if (data != null) {
              //   await Navigator.pushReplacementNamed(context, TransactionDetailPage.route, arguments: data);
              // } else {
              //   Navigator.popUntil(context, ModalRoute.withName('/'));
              // }
              // Navigator.popAndPushNamed(context, ModalRoute.withName('/'));
              bool isRouteInStack = false;
              Navigator.popUntil(context, (route) {
                if (route.settings.name == TokenDetailPage.route) {
                  isRouteInStack = true;
                  return true;
                }
                return false;
              });
              if (isRouteInStack) {
                Navigator.popUntil(
                    context, ModalRoute.withName(TokenDetailPage.route));
              } else {
                await Navigator.of(context).pushNamedAndRemoveUntil(
                    '/', (Route<dynamic> route) => false);
              }
              globalBalanceRefreshKey.currentState?.show();
              return true;
            }
            return false;
          });
      exited = true;
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        AppLocalizations dic = AppLocalizations.of(context)!;
        final fees = store.assets!.transferFees;
        DelegateParams params =
            ModalRoute.of(context)!.settings.arguments as DelegateParams;
        ValidatorData? validatorData = params.validatorData;

        double realBottom = MediaQuery.of(context).viewInsets.bottom;
        double nextBottom = realBottom > 0 ? realBottom - 102 : realBottom;
        nextBottom = nextBottom.isNegative ? 0 : nextBottom;
        return Scaffold(
          appBar: AppBar(
            title: Text(dic.staking),
            shadowColor: Colors.transparent,
            centerTitle: true,
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
                        padding: EdgeInsets.fromLTRB(20, 28, 20, 0),
                        children: <Widget>[
                          Container(
                            child: Column(
                              children: [
                                !params.manualAddValidator
                                    ? ValidatorSelector(
                                        validatorData: validatorData!)
                                    : InputItem(
                                        padding: const EdgeInsets.only(top: 0),
                                        label: dic.stakingProviderName,
                                        controller: _validatorCtrl,
                                      ),
                                InputItem(
                                  label: dic.memo,
                                  initialValue: '',
                                  controller: _memoCtrl,
                                ),
                              ],
                            ),
                          ),
                          FeeSelector(
                            fees: fees,
                            value: currentFee,
                            onChoose: _onChooseFee,
                          ),
                          Container(
                            height: 0.5,
                            margin: EdgeInsets.symmetric(
                                horizontal: 0, vertical: 10),
                            decoration: BoxDecoration(color: Color(0x1A000000)),
                          ),
                          AdvancedTransferOptions(
                            feeCtrl: _feeCtrl,
                            nonceCtrl: _nonceCtrl,
                            noncePlaceHolder: int.parse(store
                                    .assets!
                                    .mainTokenNetInfo
                                    .tokenAssestInfo
                                    ?.inferredNonce ??
                                "0"),
                            cap: fees.cap,
                          )
                        ],
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(
                            top: 15, left: 15, right: 15, bottom: nextBottom)),
                    Container(
                      padding: EdgeInsets.only(
                          left: 38, right: 38, top: 12, bottom: 30),
                      child: NormalButton(
                        color: ColorsUtil.hexColor(0x6D5FFE),
                        text: dic.next,
                        disabled: _submitDisabled,
                        onPressed: _handleSubmit,
                      ),
                    )
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

class ValidatorSelector extends StatelessWidget {
  ValidatorSelector({required this.validatorData});

  final ValidatorData validatorData;

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dic.stakingProviderName,
          textAlign: TextAlign.left,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xD9000000)),
        ),
        GestureDetector(
          onTap: () async {
            Navigator.pop(context);
          },
          behavior: HitTestBehavior.opaque,
          child: Container(
              height: 50,
              margin: EdgeInsets.only(top: 6),
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                // color:  ColorsUtil.hexColor(0xF6F7F8),
                border: Border.all(color: Color(0x1A000000), width: 0.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      validatorData.name ?? Fmt.address(validatorData.address),
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Color(0xD9000000)),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 15,
                      color: Colors.black,
                    )
                  ])),
        )
      ],
    );
  }
}
