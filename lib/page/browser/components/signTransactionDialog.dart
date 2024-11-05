import 'dart:async';
import 'dart:convert';

import 'package:auro_wallet/common/components/copyContainer.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/ledgerMina/mina_ledger_application.dart';
import 'package:auro_wallet/page/browser/components/browserBaseUI.dart';
import 'package:auro_wallet/page/browser/components/browserTab.dart';
import 'package:auro_wallet/page/browser/components/zkAppBottomButton.dart';
import 'package:auro_wallet/page/browser/components/zkAppWebsite.dart';
import 'package:auro_wallet/page/browser/components/zkRow.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/assets/types/transferData.dart';
import 'package:auro_wallet/store/browser/types/zkApp.dart';
import 'package:auro_wallet/store/ledger/ledger.dart';
import 'package:auro_wallet/store/wallet/wallet.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:auro_wallet/utils/zkUtils.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ledger_flutter/ledger_flutter.dart';

enum SignTxDialogType { Payment, Delegation, zkApp }

enum ZkAppValueEnum {
  recommed_site,
  recommed_default,
  recommed_custom,
}

class SignTransactionDialog extends StatefulWidget {
  SignTransactionDialog(
      {required this.signType,
      required this.to,
      required this.onConfirm,
      required this.url,
      required this.preNonce,
      this.zkNonce = "",
      this.amount,
      this.fee,
      this.memo,
      this.transaction,
      this.onCancel,
      this.iconUrl,
      this.feePayer,
      this.onlySign});

  final SignTxDialogType signType;
  final String to;
  final String? zkNonce;
  final String? amount;
  final String? fee;
  final String? memo;
  final Object? transaction;
  final Map<String, dynamic>? feePayer;
  final String url;
  final String? iconUrl;
  final int preNonce;
  final bool? onlySign;

  final Function(String, int) onConfirm;
  final Function()? onCancel;

  @override
  _SignTransactionDialogState createState() =>
      new _SignTransactionDialogState();
}

class _SignTransactionDialogState extends State<SignTransactionDialog> {
  final store = globalAppStore;

  bool isRiskAddress = false;
  bool showRawDataStatus = false;
  double lastFee = 0.0101;
  late String? lastMemo = "";
  late int inputNonce;
  ZkAppValueEnum feeType = ZkAppValueEnum.recommed_default;
  ZkAppValueEnum zkNonceType = ZkAppValueEnum.recommed_default;
  bool showFeeErrorTip = false;
  bool submitting = false;
  late String showToAddress = "";
  String sourceData = "";
  List<DataItem> rawData = [];
  bool isLedger = false;
  bool zkOnlySign = false;
  bool isManualNonce = false;
  bool showNonceRow = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        isLedger = store.wallet!.currentWallet.walletType ==
            WalletStore.seedTypeLedger;
      });
      checkParams();
    });
  }

  void checkParams() {
    String toAddress = widget.to.toLowerCase();
    bool isScam = toAddress.isNotEmpty &&
        store.assets!.scamAddressStr.indexOf(toAddress) != -1;
    bool isZkNonce = widget.zkNonce != null && widget.zkNonce!.isNotEmpty;
    ZkAppValueEnum nextZkNonceType = isZkNonce
        ? ZkAppValueEnum.recommed_site
        : ZkAppValueEnum.recommed_default;
    setState(() {
      isRiskAddress = isScam;
      inputNonce = isZkNonce
          ? int.parse(widget.zkNonce ?? widget.preNonce.toString())
          : widget.preNonce;
      zkNonceType = nextZkNonceType;
      showNonceRow = isZkNonce;
    });

    String toAddressTemp = widget.to;
    String? memoTemp = widget.memo;
    dynamic zkFee;
    Map<String, dynamic>? feePayer = widget.feePayer;
    String? transaction;
    if (widget.signType == SignTxDialogType.zkApp) {
      transaction = zkCommandFormat(widget.transaction);
      toAddressTemp =
          getContractAddress(transaction, store.wallet!.currentAddress);
      List<dynamic> zkFormatData =
          getZkInfo(transaction, store.wallet!.currentAddress);
      List<DataItem> dataItems = zkFormatData
          .map<DataItem>((item) => DataItem.fromJson(item))
          .toList();

      String zkBodyFee = getZkFee(transaction);
      if (zkBodyFee.isNotEmpty) {
        zkFee = zkBodyFee;
      } else {
        zkFee = feePayer?['fee'];
      }
      bool zkOnlySignTemp = widget.onlySign ?? false;
      setState(() {
        showToAddress = toAddressTemp;
        sourceData = transaction ?? "";
        rawData = dataItems;
        zkOnlySign = zkOnlySignTemp;
      });
    } else {
      setState(() {
        showToAddress = toAddressTemp;
      });
    }

    ZkAppValueEnum tempFeeType;
    dynamic webFee = zkFee ?? widget.fee;
    if (feePayer?['memo'] != null && feePayer?['memo'].isNotEmpty) {
      memoTemp = feePayer?['memo'];
    } else {
      memoTemp = widget.memo;
    }

    setState(() {
      lastMemo = memoTemp;
    });

    if (webFee != null && Fmt.isNumber(webFee)) {
      lastFee = double.parse(webFee.toString());
      tempFeeType = ZkAppValueEnum.recommed_site;
      showFeeErrorTip = lastFee >= store.assets!.transferFees.cap;
      setState(() {
        lastFee = lastFee;
        feeType = tempFeeType;
        showFeeErrorTip = showFeeErrorTip;
      });
    } else {
      double zkAdditionFee = 0;
      if (widget.signType == SignTxDialogType.zkApp && transaction != null) {
        int zkUpdateCount = getAccountUpdateCount(transaction);
        zkAdditionFee =
            store.assets!.transferFees.accountupdate * zkUpdateCount;
      }
      lastFee = store.assets!.transferFees.medium + zkAdditionFee;
      tempFeeType = ZkAppValueEnum.recommed_default;
      setState(() {
        lastFee = lastFee;
        feeType = tempFeeType;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  String? _validateAmount() {
    AppLocalizations dic = AppLocalizations.of(context)!;
    double? showBalance =
        store.assets!.mainTokenNetInfo.tokenBaseInfo?.showBalance;
    double availableBalanceStr =
        (showBalance != null ? showBalance : 0) as double;
    Decimal available = Decimal.parse(availableBalanceStr.toString());
    Decimal transferAmount =
        Decimal.parse(Fmt.parseNumber(widget.amount as String));
    Decimal transferFee = Decimal.parse(lastFee.toString());
    if (transferAmount > (available - transferFee)) {
      return dic.balanceNotEnough;
    }
    return null;
  }

  Future<bool> _validate() async {
    if (widget.signType == SignTxDialogType.Payment) {
      String? amountError = _validateAmount();
      if (amountError != null) {
        UI.toast(amountError);
        return false;
      }
    }
    return true;
  }

  Future<bool> _ledgerCheck() async {
    bool showLedgerDialog = false;
    if (store.ledger!.ledgerDevice == null) {
      showLedgerDialog = true;
    } else {
      try {
        final minaApp =
            MinaLedgerApp(store.ledger!.ledgerInstance!, accountIndex: 0);
        await Future.delayed(Duration(
            milliseconds: 400)); // avoid conflict with ledgerStatus Component
        await minaApp.getVersion(store.ledger!.ledgerDevice!);
        store.ledger!.setLedgerStatus(LedgerStatusTypes.available);
      } on LedgerException catch (e) {
        store.ledger!.setLedgerStatus(LedgerStatusTypes.unavailable);
        showLedgerDialog = true;
      }
    }
    if (showLedgerDialog) {
      print('connect ledger');
      bool? connected = await UI.showImportLedgerDialog(context: context);
      print('connected ledger');
      print(connected);
      // if (connected != true) {
      //   print('return');
      //   return false;
      // }
      // wait leger Status Version response
      await Future.delayed(const Duration(milliseconds: 500));
      return false;
    }
    return true;
  }

  Future<bool> onConfirm() async {
    AppLocalizations dic = AppLocalizations.of(context)!;
    if (isLedger && widget.signType == SignTxDialogType.zkApp) {
      UI.toast(dic.notSupportNow);
      return false;
    }
    print('onConfirm');
    bool exited = false;
    if (await _validate()) {
      if (isLedger && !await _ledgerCheck()) {
        return false;
      }
      setState(() {
        submitting = true;
      });

      String? privateKey;
      if (!isLedger) {
        String? password = await UI.showPasswordDialog(
            context: context,
            wallet: store.wallet!.currentWallet,
            inputPasswordRequired: false,
            isTransaction: true,
            store: store);
        if (password == null) {
          setState(() {
            submitting = false;
          });
          return false;
        }
        privateKey = await webApi.account.getPrivateKey(
            store.wallet!.currentWallet,
            store.wallet!.currentWallet.currentAccountIndex,
            password);
        if (privateKey == null) {
          setState(() {
            submitting = false;
          });
          UI.toast(dic.passwordError);
          return false;
        }
      }
      int nextNonce = inputNonce;
      if (!isManualNonce && zkNonceType != ZkAppValueEnum.recommed_site) {
        int tempNonce =
            await webApi.assets.fetchAccountNonce(store.wallet!.currentAddress);
        if (tempNonce != -1) {
          nextNonce = tempNonce;
        }
      }
      Map txInfo;
      bool isDelagetion = false;
      if (widget.signType == SignTxDialogType.zkApp) {
        txInfo = {
          "privateKey": privateKey,
          "fromAddress": store.wallet!.currentAddress,
          "fee": lastFee,
          "nonce": nextNonce,
          "memo": lastMemo != null ? lastMemo : "",
          "transaction": widget.transaction,
          "zkOnlySign": zkOnlySign
        };
      } else {
        txInfo = {
          "privateKey": privateKey,
          "accountIndex": store.wallet!.currentWallet.currentAccountIndex,
          "fromAddress": store.wallet!.currentAddress,
          "toAddress": widget.to,
          "fee": lastFee,
          "nonce": nextNonce,
          "memo": lastMemo != null ? lastMemo : "",
        };
        if (widget.signType == SignTxDialogType.Payment) {
          double amount = double.parse(Fmt.balance(
              widget.amount.toString(), COIN.decimals,
              maxLength: COIN.decimals));
          txInfo["amount"] = amount;
        } else if (widget.signType == SignTxDialogType.Delegation) {
          isDelagetion = true;
        }
      }
      dynamic data;
      if (isLedger) {
        print('start sign ledger');
        final tx = await webApi.account
            .ledgerSign(txInfo, context: context, isDelegation: isDelagetion);
        if (tx == null) {
          return false;
        }
        if (!exited) {
          data = await webApi.account
              .sendTxBody(tx, context: context, isDelegation: isDelagetion);
        }
      } else {
        if (widget.signType == SignTxDialogType.zkApp) {
          data = await webApi.account.signAndSendZkTx(txInfo, context: context);
        } else {
          if (isDelagetion) {
            data = await webApi.account
                .signAndSendDelegationTx(txInfo, context: context);
          } else {
            data = await webApi.account.signAndSendTx(txInfo, context: context);
          }
        }
      }
      if (data == null) {
        setState(() {
          submitting = false;
        });
        return false;
      }
      String hash = "";
      String signedData = "";
      if (data.runtimeType == TransferData) {
        hash = data.hash;
      } else {
        signedData = data["signedData"];
      }
      bool hashNotEmpty = hash.isNotEmpty;
      bool signedDataNotEmpty = signedData.isNotEmpty;
      if (hashNotEmpty || signedDataNotEmpty) {
        if (mounted && !exited) {
          String responseData = hashNotEmpty ? hash : signedData;
          int finalNonce = zkNonceType == ZkAppValueEnum.recommed_site
              ? inputNonce + 10 // +10 for force refresh nonce
              : nextNonce;
          await widget.onConfirm(
              responseData, finalNonce);
          setState(() {
            submitting = false;
          });
          globalBalanceRefreshKey.currentState?.show();
          return true;
        }
      } else {
        UI.toast("service error");
      }
      setState(() {
        submitting = false;
      });
      return false;
    }
    exited = true;
    return false;
  }

  void onCancel() {
    final onCancel = widget.onCancel;
    if (onCancel != null) {
      onCancel();
    }
  }

  Widget _buildAccountRow() {
    AppLocalizations dic = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            child: Text(
                Fmt.accountName(store.wallet!.currentWallet.currentAccount),
                style: TextStyle(
                    color: Colors.black.withOpacity(0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ),
          Container(
            margin: EdgeInsets.only(top: 4),
            child: Text('${Fmt.address(store.wallet!.currentAddress, pad: 6)}',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
          )
        ]),
        SvgPicture.asset(
          'assets/images/assets/right_arrow.svg',
          height: 14,
          color: Color(0xFF594AF1),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Container(
            child: Row(
              children: [
                Container(
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 6),
                    margin: EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Color(0xFF594AF1), width: 1)),
                    child: Text(widget.signType.name,
                        style: TextStyle(
                            color: Color(0xFF594AF1),
                            fontSize: 10,
                            fontWeight: FontWeight.w500))),
                Text(dic.toAddress,
                    style: TextStyle(
                        color: Colors.black.withOpacity(0.5),
                        fontSize: 12,
                        fontWeight: FontWeight.w500))
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 4),
            child: CopyContainer(
                text: widget.to,
                child: Text('${Fmt.address(showToAddress, pad: 6)}',
                    style: TextStyle(
                        color: isRiskAddress ? Color(0xFFD65A5A) : Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w500))),
          )
        ]),
      ],
    );
  }

  Widget _buildAmountRow() {
    AppLocalizations dic = AppLocalizations.of(context)!;
    return widget.amount != null && widget.amount!.isNotEmpty
        ? Container(
            margin: EdgeInsets.only(top: 20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                child: Text(dic.amount,
                    style: TextStyle(
                        color: Colors.black.withOpacity(0.5),
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
              ),
              Container(
                margin: EdgeInsets.only(top: 4),
                child: Text(widget.amount! + " " + COIN.coinSymbol,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
              )
            ]),
          )
        : Container();
  }

  void showAdvanceDialog() async {
    UI.showAdvance(
        context: context,
        fee: lastFee,
        nonce: inputNonce,
        onConfirm: (double fee, int nonce) {
          setState(() {
            lastFee = fee;
            inputNonce = nonce;
            isManualNonce = true;
            showFeeErrorTip = fee >= store.assets!.transferFees.cap;
            feeType = ZkAppValueEnum.recommed_custom;
            zkNonceType = ZkAppValueEnum.recommed_custom;
          });
        });
  }

  void resetZkNonce() async {
    setState(() {
      zkNonceType = ZkAppValueEnum.recommed_default;
      inputNonce = widget.preNonce;
    });
  }

  Widget _buildZkTip(ZkAppValueEnum nextType) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    Widget feeTip = Container();
    if (nextType != ZkAppValueEnum.recommed_custom) {
      bool isFeeDefault = nextType == ZkAppValueEnum.recommed_default;
      String feeContent = isFeeDefault ? dic.fee_default : dic.siteSuggested;
      Color feeTipBg = isFeeDefault
          ? Color(0xFF808080).withOpacity(0.1)
          : Color(0xFF0DB27C).withOpacity(0.1);
      Color feeContentColor =
          isFeeDefault ? Color(0xFF808080).withOpacity(0.5) : Color(0xFF0DB27C);
      feeTip = Container(
        padding: EdgeInsets.symmetric(horizontal: 4),
        margin: EdgeInsets.only(left: 4),
        decoration: BoxDecoration(
            color: feeTipBg,
            borderRadius: BorderRadius.all(Radius.circular(3))),
        child: Text(feeContent,
            style: TextStyle(
                color: feeContentColor,
                fontSize: 12,
                height: 1.25,
                fontWeight: FontWeight.w500)),
      );
    }
    return feeTip;
  }

  Widget _buildNonceRow() {
    if (!showNonceRow) {
      return Container();
    }
    AppLocalizations dic = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  child: Text('Nonce',
                      style: TextStyle(
                          color: Colors.black.withOpacity(0.5),
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                ),
                Container(
                  margin: EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Text(inputNonce.toString(),
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                      _buildZkTip(zkNonceType),
                    ],
                  ),
                )
              ]),
              zkNonceType == ZkAppValueEnum.recommed_site
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                          SizedBox(
                            height: 15,
                          ),
                          GestureDetector(
                              onTap: () => resetZkNonce(),
                              child: Container(
                                margin: EdgeInsets.only(top: 4),
                                child: Text(dic.reset,
                                    style: TextStyle(
                                        color: Color(0xFF594AF1),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500)),
                              ))
                        ])
                  : SizedBox(
                      width: 0,
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeeRow() {
    AppLocalizations dic = AppLocalizations.of(context)!;
    String showFee = (lastFee).toString();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  child: Text(dic.transactionFee,
                      style: TextStyle(
                          color: Colors.black.withOpacity(0.5),
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                ),
                Container(
                  margin: EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Text(showFee + " " + COIN.coinSymbol,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                      _buildZkTip(feeType),
                    ],
                  ),
                )
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                SizedBox(
                  height: 15,
                ),
                GestureDetector(
                    onTap: () => showAdvanceDialog(),
                    child: Container(
                      margin: EdgeInsets.only(top: 4),
                      child: Text(dic.advanceMode,
                          style: TextStyle(
                              color: Color(0xFF594AF1),
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                    ))
              ]),
            ],
          ),
        ),
        showFeeErrorTip
            ? Container(
                margin: EdgeInsets.only(top: 4),
                child: Text(dic.feeTooLarge,
                    style: TextStyle(
                        color: Color(0xFFE4B200),
                        fontSize: 12,
                        fontWeight: FontWeight.w400)),
              )
            : Container()
      ],
    );
  }

  Widget _buildMemoContent() {
    String memo = widget.memo ?? widget.feePayer?["memo"] ?? "";
    return Text(memo,
        style: TextStyle(
            color: Colors.black.withOpacity(0.8),
            fontSize: 14,
            fontWeight: FontWeight.w400));
  }

  Widget _buildZkTransactionContent() {
    if (showRawDataStatus) {
      return Text(prettyPrintJson(jsonDecode(sourceData)),
          style: TextStyle(
              color: Colors.black.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w400));
    } else {
      return TypeRowInfo(data: rawData, isZkData: true);
    }
  }

  void onClickRawData() {
    print('onClickRawData');
    setState(() {
      showRawDataStatus = !showRawDataStatus;
    });
  }

  Widget _buildTabRow() {
    AppLocalizations dic = AppLocalizations.of(context)!;
    List<String> tabTitleList = [];
    List<Widget> tabContengList = [];
    Widget? tabRightWidget;

    if (widget.transaction != null) {
      tabTitleList.add(dic.content);
      tabContengList
          .add(TabBorderContent(tabContent: _buildZkTransactionContent()));
      if (widget.signType == SignTxDialogType.zkApp) {
        String showContent =
            showRawDataStatus ? dic.rawData + "</>" : dic.showData;
        tabRightWidget = GestureDetector(
          child: Container(
            padding: EdgeInsets.only(bottom: 5, top: 5, left: 5),
            child: Text(
              showContent,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF808080)),
            ),
          ),
          onTap: onClickRawData,
        );
      }
    }
    if ((widget.memo != null && widget.memo!.isNotEmpty) ||
        (widget.feePayer?["memo"] != null &&
            widget.feePayer?["memo"]!.isNotEmpty)) {
      tabTitleList.add('Memo');
      tabContengList.add(TabBorderContent(tabContent: _buildMemoContent()));
    }
    if (tabTitleList.length == 0) {
      return Container();
    }
    return Container(
        height: 200,
        margin: EdgeInsets.only(top: 20),
        width: double.infinity,
        child: BrowserTab(
            tabTitles: tabTitleList,
            tabContents: tabContengList,
            tabRightWidget: tabRightWidget));
  }

  Widget _buildRiskTip() {
    AppLocalizations dic = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
          color: Color(0xFFD65A5A).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Color(0xFFD65A5A), width: 1)),
      child: Column(
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'assets/images/webview/icon_alert.svg',
                height: 30,
                width: 30,
              ),
              Text(dic.warning,
                  style: TextStyle(
                      color: Color(0xFFD65A5A),
                      fontSize: 14,
                      fontWeight: FontWeight.w500))
            ],
          ),
          Text(dic.warningTip,
              style: TextStyle(
                  color: Color(0xFFD65A5A),
                  fontSize: 12,
                  fontWeight: FontWeight.w400))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    double screenHeight = MediaQuery.of(context).size.height;
    double containerMaxHeight = screenHeight * 0.6;
    double minHeight = 200;
    if (containerMaxHeight <= minHeight) {
      containerMaxHeight = containerMaxHeight + 50;
    }
    return Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(12),
              topLeft: Radius.circular(12),
            )),
        padding: EdgeInsets.only(left: 0, top: 8, right: 0, bottom: 16),
        child: SafeArea(
          child: Stack(
            children: [
              Wrap(
                children: [
                  BrowserDialogTitleRow(
                      title: zkOnlySign ? dic.signatureRequest : dic.sendDetail,
                      showChainType: true,
                      showLedgerStatus: isLedger),
                  Container(
                      constraints: BoxConstraints(
                          minHeight: minHeight, maxHeight: containerMaxHeight),
                      child: SingleChildScrollView(
                          child: Padding(
                              padding:
                                  EdgeInsets.only(top: 20, left: 20, right: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  isRiskAddress ? _buildRiskTip() : Container(),
                                  ZkAppWebsite(
                                      icon: widget.iconUrl, url: widget.url),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  _buildAccountRow(),
                                  _buildAmountRow(),
                                  _buildNonceRow(),
                                  _buildFeeRow(),
                                  _buildTabRow()
                                ],
                              )))),
                  ZkAppBottomButton(
                      onConfirm: onConfirm,
                      onCancel: onCancel,
                      submitting: submitting)
                ],
              ),
            ],
          ),
        ));
  }
}
