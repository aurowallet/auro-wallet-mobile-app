import 'dart:math';
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
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
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

class _DelegatePageState extends State<DelegatePage> with SingleTickerProviderStateMixin {
  _DelegatePageState(this.store);

  final AppStore store;

  final TextEditingController _nonceCtrl = new TextEditingController();
  final TextEditingController _feeCtrl = new TextEditingController();
  final TextEditingController _memoCtrl = new TextEditingController();
  final TextEditingController _validatorCtrl = new TextEditingController();
  late ReactionDisposer _monitorFeeDisposer;
  bool _submitDisabled = false;
  var _loading = Observable(true);
  double? currentFee;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DelegateParams params = ModalRoute.of(context)!.settings.arguments as DelegateParams;
      _monitorFeeDisposer = reaction((_) =>  store.assets!.transferFees, _onFeeLoaded);
      _feeCtrl.addListener(_onFeeInputChange);
      if (params.manualAddValidator) {
        _validatorCtrl.addListener(_monitorSummitStatus);
        setState((){
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
    setState((){
      if (_feeCtrl.text.isNotEmpty) {
        currentFee = double.parse(Fmt.parseNumber(_feeCtrl.text));
      } else {
        currentFee = store.assets!.transferFees.medium;
      }
    });
  }


  void _monitorSummitStatus() {
    if (_validatorCtrl.text.isEmpty) {
      if (!_submitDisabled) {
        setState((){
          _submitDisabled = true;
        });
      }
    } else if(_submitDisabled) {
      setState((){
        _submitDisabled = false;
      });
    }
  }
  void _onFeeLoaded(Fees fees) {
    if (currentFee == null) {
      currentFee = fees.medium;
    }
  }

  Future<void> _loadData() async {
    await Future.wait([
      webApi.assets.fetchAccountInfo(),
      webApi.assets.queryTxFees(),
    ]);
    runInAction((){
      _loading.value = false;
    });
  }

  void _onChooseFee (double fee) {
    _feeCtrl.text = '';
    setState(() {
      currentFee = fee;
    });
  }

  String? _validateBalance () {
    final Map<String, String> dic = I18n.of(context).main;
    BigInt available = store.assets!.accountsInfo[store.wallet!.currentAddress]?.total ?? BigInt.from(0);
    final int decimals = COIN.decimals;
    double fee = currentFee!;
    if (available / BigInt.from(pow(10, decimals)) - fee <= 0) {
      return dic['balanceNotEnough']!;
    }
    return null;
  }
  Future<String?> _validateValidator () async {
    final Map<String, String> dic = I18n.of(context).main;
    DelegateParams params = ModalRoute.of(context)!.settings.arguments as DelegateParams;
    if (params.manualAddValidator) {
      if (_validatorCtrl.text.isEmpty) {
        return dic['inputNodeAddress']!;
      }
      bool isValid = await webApi.account.isAddressValid(_validatorCtrl.text.trim());
      if (!isValid) {
        return dic['sendAddressError']!;
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
    _unFocus();
    if (_nonceCtrl.text.isEmpty && currentFee == null) {
      if (_loading.value) { // waiting nonce data from server
        EasyLoading.show();
        await asyncWhen((r) => _loading.value == false);
        EasyLoading.dismiss();
      }
    }
    if (await _validate()) {
      final Map<String, String> i18n = I18n.of(context).main;
      String symbol = COIN.coinSymbol;
      int decimals = COIN.decimals;
      String memo = _memoCtrl.text.trim();
      double fee;
      int inferredNonce;
      if (_nonceCtrl.text.isNotEmpty) {
        inferredNonce = int.parse(_nonceCtrl.text);
      } else {
        inferredNonce = store.assets!.accountsInfo[store.wallet!.currentAddress]!.inferredNonce;
      }
      fee = currentFee!;
      DelegateParams params = ModalRoute.of(context)!.settings.arguments as DelegateParams;
      ValidatorData? validatorData = params.validatorData;
      String validatorAddress = params.manualAddValidator ? _validatorCtrl.text.trim() : validatorData!.address;
      List<TxItem> txItems = [];
      // if (!params.manualAddValidator) {
      //   txItems.add(TxItem(label: i18n['producerName']!, value: validatorData!.name ?? Fmt.address(validatorAddress, pad: 8)));
      // }
      txItems.addAll([
        TxItem(label: i18n['providerAddress']!, value: validatorAddress, type: TxItemTypes.address),
        TxItem(label: i18n['fromAddress']!, value: store.wallet!.currentAddress, type: TxItemTypes.address),
        TxItem(label: i18n['fee']!, value: '${fee.toString()} ${COIN.coinSymbol}', type: TxItemTypes.amount),
      ]);
      if (memo.isNotEmpty) {
        txItems.insert(3, TxItem(label: i18n['memo2']!, value: memo, type: TxItemTypes.text));
      }
      bool isWatchMode = store.wallet!.currentWallet.walletType == WalletStore.seedTypeNone;
      UI.showTxConfirm(
          context: context,
          title: i18n['delegationInfo']!,
          items: txItems,
          headLabel: !params.manualAddValidator ? i18n['producerName']! : null,
          headValue: !params.manualAddValidator ? Text(
            validatorData!.name ?? Fmt.address(validatorAddress, pad: 8),
            style: TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.w600
            ),
          ) : null,
          disabled: isWatchMode,
          buttonText: isWatchMode ? i18n['watchMode']: i18n['confirm'],
          onConfirm: () async {
            String? password = await UI.showPasswordDialog(context: context, wallet: store.wallet!.currentWallet);
            if (password == null) {
              return;
            }
            EasyLoading.show(status: '');
            String? privateKey = await webApi.account.getPrivateKey(
                store.wallet!.currentWallet,
                store.wallet!.currentWallet.currentAccountIndex,
                password);
            if (privateKey == null) {
              EasyLoading.dismiss();
              UI.toast(i18n['passwordError']!);
              return;
            }
            Map txInfo = {
              "privateKey": privateKey,
              "fromAddress": store.wallet!.currentAddress,
              "toAddress": validatorAddress,
              "fee": fee,
              "nonce": inferredNonce,
              "memo": memo,
            };

            TransferData? data = await webApi.account.signAndSendDelegationTx(txInfo, context: context);
            EasyLoading.dismiss();
            if (data != null) {
              await Navigator.pushReplacementNamed(context, TransactionDetailPage.route, arguments: data);
            } else {
              Navigator.popUntil(context, ModalRoute.withName('/'));
            }
            globalBalanceRefreshKey.currentState?.show();
          }
      );
      return;

    }

  }

  @override
  Widget build(BuildContext context) {

    return Observer(
      builder: (_) {
        final Map<String, String> i18n = I18n.of(context).main;
        final fees = store.assets!.transferFees;
        DelegateParams params = ModalRoute.of(context)!.settings.arguments as DelegateParams;
        ValidatorData? validatorData = params.validatorData;
        return Scaffold(
          appBar: AppBar(
            title: Text(i18n['staking']!),
            shadowColor: Colors.transparent,
            centerTitle: true,
          ),
          backgroundColor: Colors.white,
          body: SafeArea(
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
                                !params.manualAddValidator ?
                                ValidatorSelector(validatorData: validatorData!)
                                : InputItem(
                                  padding: const EdgeInsets.only(top: 0),
                                  label: i18n['stakingProviderName']!,
                                  controller: _validatorCtrl,
                                ),
                                InputItem(
                                  label: i18n['memo']!,
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
                            margin: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
                            decoration: BoxDecoration(
                                color: Color(0x1A000000)
                            ),
                          ),
                          AdvancedTransferOptions(
                            feeCtrl: _feeCtrl,
                            nonceCtrl: _nonceCtrl,
                            noncePlaceHolder: store.assets!.accountsInfo[store.wallet!.currentAddress]?.inferredNonce,
                            cap: fees.cap,
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 38, right: 38, top: 12, bottom: 30),
                      child: NormalButton(
                        color: ColorsUtil.hexColor(0x6D5FFE),
                        text: i18n['next']!,
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
    final Map<String, String> i18n = I18n.of(context).main;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          i18n['stakingProviderName']!,
          textAlign: TextAlign.left,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xD9000000)
          ),
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
                          color: Color(0xD9000000)
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 15, color: Colors.black,)
                  ]
              )
          ),
        )
      ],
    );
  }
}