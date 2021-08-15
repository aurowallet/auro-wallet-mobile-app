import 'dart:convert';
import 'dart:math';

import 'package:auro_wallet/store/settings/types/contactData.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:auro_wallet/common/components/txConfirmDialog.dart';
import 'package:auro_wallet/common/components/feeSelector.dart';
import 'package:auro_wallet/common/components/formPanel.dart';
import 'package:auro_wallet/common/components/inputItem.dart';
import 'package:auro_wallet/common/components/normalButton.dart';
import 'package:auro_wallet/common/components/advancedTransferOptions.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/page/account/scanPage.dart';
import 'package:auro_wallet/page/assets/transactionDetail/transactionDetailPage.dart';
import 'package:auro_wallet/page/settings/contactListPage.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/assets/types/accountInfo.dart';
import 'package:auro_wallet/store/assets/types/transferData.dart';
import 'package:auro_wallet/store/settings/types/contactData.dart';
import 'package:auro_wallet/store/wallet/wallet.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mobx/mobx.dart';
import 'package:auro_wallet/store/assets/types/fees.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _amountCtrl = new TextEditingController();
  final TextEditingController _toAddressCtrl = new TextEditingController();
  final TextEditingController _memoCtrl = new TextEditingController();
  final TextEditingController _nonceCtrl = new TextEditingController();
  final TextEditingController _feeCtrl = new TextEditingController();
  late ReactionDisposer _monitorFeeDisposer;

  bool _submitDisabled = true;
  double? currentFee;
  String? _contactName;
  ContactData? _contactData;

  var _loading = Observable(true);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _monitorFeeDisposer = reaction((_) =>  store.assets!.transferFees, _onFeeLoaded);
      _amountCtrl.addListener(_monitorSummitStatus);
      _toAddressCtrl.addListener(_monitorSummitStatus);
      _toAddressCtrl.addListener(_onAddressChange);
      _feeCtrl.addListener(_onFeeInputChange);
      _loadData();
    });
  }


  @override
  void dispose() {
    _amountCtrl.dispose();
    _toAddressCtrl.dispose();
    _memoCtrl.dispose();
    _nonceCtrl.dispose();
    _feeCtrl.dispose();
    _monitorFeeDisposer();
    super.dispose();
  }

  void _onFeeInputChange() {
    setState((){
      if (_feeCtrl.text.isNotEmpty) {
        currentFee = double.parse(_feeCtrl.text);
      } else {
        currentFee = store.assets!.transferFees.medium;
      }
    });
  }

  void _onAddressChange() {
    if (_contactData!=null) {
      if (_toAddressCtrl.text == _contactData!.address) {
        setState(() {
          _contactName = _contactData!.name;
        });
      } else if (_contactName != null) {
        setState(() {
          _contactName = null;
        });
      }
    }
  }
  void _monitorSummitStatus() {
    if (_toAddressCtrl.text.isEmpty || _amountCtrl.text.isEmpty) {
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

  Future<void> _onScan() async {
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

  void _handleSubmit() async {
    _unFocus();
    if (_nonceCtrl.text.isEmpty) {
      if (_loading.value && currentFee == null) { // waiting nonce data from server and user does not choose fee
        EasyLoading.show(status: '');
        await asyncWhen((r) => _loading.value == false);
        EasyLoading.dismiss();
      }
    }
    if (await _validate()) {
      double amount = double.parse(_amountCtrl.text.trim());
      String toAddress = _toAddressCtrl.text.trim();
      String memo = _memoCtrl.text.trim();
      double fee;
      int inferredNonce;
      if (_nonceCtrl.text.isNotEmpty) {
        inferredNonce = int.parse(_nonceCtrl.text);
      } else {
        inferredNonce = store.assets!.accountsInfo[store.wallet!.currentAddress]!.inferredNonce;
      }
      fee = currentFee!;
      final Map<String, String> i18n = I18n.of(context).main;
      var txItems = [
        TxItem(label: i18n['amount']!, value: '${Fmt.priceCeil(amount)} ${COIN.coinSymbol}', type: TxItemTypes.amount),
        TxItem(label: i18n['toAddress']!, value: toAddress, type: TxItemTypes.address),
        TxItem(label: i18n['fromAddress']!, value: store.wallet!.currentAddress, type: TxItemTypes.address),
        TxItem(label: i18n['fee']!, value: '${fee.toString()} ${COIN.coinSymbol}', type: TxItemTypes.amount),
      ];
      if (memo.isNotEmpty) {
        txItems.insert(3, TxItem(label: i18n['memo2']!, value: memo, type: TxItemTypes.text));
      }
      bool isWatchMode = store.wallet!.currentWallet.walletType == WalletStore.seedTypeNone;
      UI.showTxConfirm(
          context: context,
          title: i18n['sendDetail']!,
          items: txItems,
          disabled: isWatchMode,
          buttonText: isWatchMode ? i18n['watchMode']: i18n['confirm'],
          onConfirm: () async {
             String? password = await UI.showPasswordDialog(
                context: context,
                wallet: store.wallet!.currentWallet,
            );
            if (password == null) {
              return;
            }
             EasyLoading.show();
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
              "toAddress": toAddress,
              "amount": amount,
              "fee": fee,
              "nonce": inferredNonce,
              "memo": memo,
            };

         /*   var data = TransferData()
              ..hash = "CkpYxs7Ky43F5giVbri4msoB4tGoVdTdp2sgxxTK1HH9TuCcJvUoF"
              ..paymentId = "29oBRYxP4TVPTfR9pdTJBfEDiE1KHGXiBzdTXmzA7KLeYrQRrCErxH4W69Xek2uDLuu9nFC7puaLBqkEmwq2vLBMKBWxaR5KGuY2GmrgjSKrqbHyrUzrNGHrRG166Kr61nme11FWFYywZsRgdmdTMKYoCoMx4evam2J3Q76patqgRZNj8BnaiEux6TSuZR65mQnzH7S9ZfsLL7vtbCwSjYG7wE6UrPccbHkY6vfkvYZz2LUSqARANvqLLnGKvu16nzbx1obok7PXjZbAbUYFGZCnm3KqriWmvZj25MYvB1gDytjvpqcg7YcSkfu6443ZUPRByLKTnTznLjePff5AmNsENDMmMLRUfzpockxW8SispsHWZ7R5pVnwnD8RBDGCckiVcPe8yzF"
              ..type = "PAYMENT"
              ..fee = "1000000"
              ..amount = "10000000"
              ..nonce = 45
              ..sender = "B62qoQSggXskw3YQjTCmi24Yh9HuuiXBSBKDKzgyxg1G7oe3ng2r4jo"
              ..receiver = "B62qoQSggXskw3YQjTCmi24Yh9HuuiXBSBKDKzgyxg1G7oe3ng2r4jo";*/

            TransferData? data = await webApi.account.signAndSendTx(txInfo, context: context);
            EasyLoading.dismiss();
             if (mounted) {
               if(data != null) {
                 await Navigator.pushReplacementNamed(context, TransactionDetailPage.route, arguments: data);
               } else {
                 Navigator.popUntil(context, ModalRoute.withName('/'));
               }
             }
             globalBalanceRefreshKey.currentState!.show();
          }
      );
      return;

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

  void _onFeeLoaded(Fees fees) {
    if (currentFee == null) {
      setState(() {
        currentFee = fees.medium;
      });
    }
  }

  Future<String?> _validateAddress () async {
    final Map<String, String> dic = I18n.of(context).main;
    String toAddress = _toAddressCtrl.text.trim();
    bool isValid = await webApi.account.isAddressValid(toAddress);
    if (!isValid) {
      return dic['sendAddressError']!;
    }
    return null;
  }
  void _unFocus() {
    FocusScope.of(context).requestFocus(new FocusNode());
  }
  String? _validateAmount () {
    final Map<String, String> dic = I18n.of(context).main;
    BigInt available = store.assets!.accountsInfo[store.wallet!.currentAddress]?.total ?? BigInt.from(0);
    final int decimals = COIN.decimals;
    double fee =  currentFee!;
    if (_amountCtrl.text.isEmpty) {
      return dic['amountError']!;
    }
    if (double.parse(_amountCtrl.text.trim()) >= available / BigInt.from(pow(10, decimals)) - fee) {
      return dic['balanceNotEnough']!;
    }
    return null;
  }
  void _onChooseFee (double fee) {
    _feeCtrl.text = '';
    setState(() {
      currentFee = fee;
    });
  }
  void _onChooseContact() async {
    var contact = await Navigator.of(context).pushNamed(ContactListPage.route, arguments: {
      "isToSelect": true
    });
    if (contact != null) {
      ContactData contactData = contact as ContactData;
      _toAddressCtrl.text = contactData.address;
      setState(() {
        _contactData = contactData;
        _contactName = contactData.name;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        var theme = Theme.of(context).textTheme;
        final Map<String, String> dic = I18n.of(context).main;
        final int decimals = COIN.decimals;
        BigInt available = store.assets!.accountsInfo[store.wallet!.currentAddress]?.total ?? BigInt.from(0);
        final fees = store.assets!.transferFees;
        return Scaffold(
          appBar: AppBar(
            title: Text(dic['send']!),
            shadowColor: Colors.transparent,
            centerTitle: true,
            actions: <Widget>[],
          ),
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Builder(
              builder: (BuildContext context) {
                return Column(
                  children: <Widget>[
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.fromLTRB(28, 10, 28, 30),
                        children: <Widget>[
                          FormPanel(
                            child: Column(
                              children: [
                                InputItem(
                                    padding: const EdgeInsets.only(top: 0),
                                    label: dic['toAddress']! +
                                        (_contactName != null ? '($_contactName)' : ''),
                                    initialValue: '',
                                    controller: _toAddressCtrl,
                                    suffixIcon: IconButton(
                                      icon: SvgPicture.asset(
                                          'assets/images/assets/scanner.svg',
                                          width: 20,
                                          height: 20
                                      ),
                                      onPressed: _onScan,
                                    ),
                                    rightWidget: GestureDetector(
                                      child: SvgPicture.asset(
                                          'assets/images/assets/contacts.svg',
                                          width: 20,
                                          height: 20
                                      ),
                                      onTap: _onChooseContact,
                                    )
                                ),
                                InputItem(
                                  label: dic['amount']!,
                                  initialValue: '',
                                  controller: _amountCtrl,
                                  inputFormatters: [
                                    UI.decimalInputFormatter(decimals)
                                  ],
                                  keyboardType: TextInputType.numberWithOptions(
                                      decimal: true),
                                  rightWidget: Text(
                                    '${dic['balance']!}:${Fmt.priceFloorBigInt(available, COIN.decimals, lengthMax: 6)}',
                                    textAlign: TextAlign.right,
                                    style: theme.headline6!.copyWith(
                                        color: ColorsUtil.hexColor(0xB1B3BD)
                                    ),
                                  ),
                                ),
                                InputItem(
                                  label: dic['memo']!,
                                  initialValue: '',
                                  controller: _memoCtrl,
                                ),
                              ],
                            ),
                          ),
                          FeeSelector(
                            fees: fees,
                            onChoose: _onChooseFee,
                            value: currentFee,
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
                      padding: EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                      child: NormalButton(
                        color: ColorsUtil.hexColor(0x6D5FFE),
                        text: dic['next']!,
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
