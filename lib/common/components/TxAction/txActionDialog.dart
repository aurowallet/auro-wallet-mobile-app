import 'package:auro_wallet/common/components/TxAction/txAdvanceDialog.dart';
import 'package:auro_wallet/common/components/customStyledText.dart';
import 'package:auro_wallet/common/components/ledgerStatus.dart';
import 'package:auro_wallet/common/components/normalButton.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/ledgerMina/mina_ledger_application.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/assets/types/transferData.dart';
import 'package:auro_wallet/store/ledger/ledger.dart';
import 'package:auro_wallet/store/wallet/wallet.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ledger_flutter/ledger_flutter.dart';
import 'package:decimal/decimal.dart';
import 'package:styled_text/styled_text.dart';

enum TxActionType { speedup, cancel }

class TxActionDialog extends StatefulWidget {
  TxActionDialog({
    required this.title,
    required this.txData,
    required this.buttonText,
    required this.modalType,
    this.onConfirm,
  });

  final String title;
  final TransferData txData;
  final String? buttonText;
  final TxActionType? modalType;
  final Function()? onConfirm;

  final store = globalAppStore;

  @override
  _TxActionDialogState createState() => new _TxActionDialogState();
}

class _TxActionDialogState extends State<TxActionDialog> {
  bool submitting = false;
  bool isLedger = false;
  double nextStateFee = 0;
  double preFee = 0;
  double speedUpFee = 0;
  @override
  void initState() {
    super.initState();
    double nextPlusFee = widget.modalType == TxActionType.cancel
        ? 0.0001
        : widget.store.assets!.transferFees.speedup;

    preFee = double.parse(widget.txData.fee as String);
    preFee = double.parse(Fmt.balance(
        widget.txData.fee.toString(), COIN.decimals,
        maxLength: COIN.decimals));

    speedUpFee = widget.store.assets!.transferFees.speedup;
    speedUpFee = speedUpFee.isNegative ? 0 : speedUpFee;

    nextStateFee = (Decimal.parse(nextPlusFee.toString()) +
            Decimal.parse(preFee.toString()))
        .toDouble();
    isLedger = widget.store.wallet!.currentWallet.walletType ==
        WalletStore.seedTypeLedger;
  }

  Widget renderHead(String headerLabel, Widget headerValue) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Center(
        child: Column(
          children: [
            Text(
              headerLabel,
              style: TextStyle(
                  color: const Color(0x80000000),
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ),
            headerValue
          ],
        ),
      ),
    );
  }

  List<Widget> renderLedgerConfirm() {
    AppLocalizations dic = AppLocalizations.of(context)!;
    return [
      Container(
        padding: EdgeInsets.only(top: 35),
        child: Center(
          child: SvgPicture.asset(
            'assets/images/public/pending_tip.svg',
            width: 58,
          ),
        ),
      ),
      Container(
        padding: EdgeInsets.only(top: 29),
        child: Center(
          child: Text(
            dic.waitingLedger,
            style: TextStyle(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.only(top: 7),
        child: Text(
          dic.waitingLedgerSign,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.black.withOpacity(0.5),
              fontSize: 14,
              fontWeight: FontWeight.w400),
        ),
      ),
      Container(
        padding: EdgeInsets.only(top: 14, bottom: 60),
        child: Center(
          child: CustomStyledText(
              text: dic.ledgerAddressTip3,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  height: 1.2,
                  fontWeight: FontWeight.w400)),
        ),
      )
    ];
  }

  Future<bool> _ledgerCheck() async {
    bool showLedgerDialog = false;
    if (widget.store.ledger!.ledgerDevice == null) {
      showLedgerDialog = true;
    } else {
      try {
        final minaApp = MinaLedgerApp(widget.store.ledger!.ledgerInstance!,
            accountIndex: 0);
        await Future.delayed(Duration(
            milliseconds: 400)); // avoid conflict with ledgerStatus Component
        await minaApp.getVersion(widget.store.ledger!.ledgerDevice!);
        widget.store.ledger!.setLedgerStatus(LedgerStatusTypes.available);
      } on LedgerException catch (e) {
        widget.store.ledger!.setLedgerStatus(LedgerStatusTypes.unavailable);
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

  void showAdvanceDialog() async {
    String? nextFee = await showDialog<String>(
      context: context,
      builder: (_) {
        return TxAdvanceDialog(
          currentNonce: widget.txData.nonce!,
          nextStateFee: nextStateFee,
        );
      },
    );
    if (nextFee!.isNotEmpty) {
      nextStateFee = double.parse(nextFee);
    }
  }

  Future<bool> onClickNextStep() async {
    bool exited = false;
    bool isDelagetion = false;
    AppLocalizations dic = AppLocalizations.of(context)!;
    String? privateKey;
    if (!isLedger) {
      String? password = await UI.showPasswordDialog(
          context: context,
          wallet: widget.store.wallet!.currentWallet,
          inputPasswordRequired: false);
      if (password == null) {
        return false;
      }
      privateKey = await webApi.account.getPrivateKey(
          widget.store.wallet!.currentWallet,
          widget.store.wallet!.currentWallet.currentAccountIndex,
          password);
      if (privateKey == null) {
        UI.toast(dic.passwordError);
        return false;
      }
    }
    Map<String, dynamic> txInfo = {};
    if (widget.modalType == TxActionType.cancel) {
      txInfo = {
        "privateKey": privateKey,
        "accountIndex": widget.store.wallet!.currentWallet.currentAccountIndex,
        "fromAddress": widget.store.wallet!.currentAddress,
        "toAddress": widget.store.wallet!.currentAddress,
        "amount": 0.0,
        "fee": nextStateFee,
        "nonce": widget.txData.nonce,
        "memo": ""
      };
    } else {
      String txType = widget.txData.type.toLowerCase();
      String? memo = widget.txData.memo;

      txInfo = {
        "privateKey": privateKey,
        "accountIndex": widget.store.wallet!.currentWallet.currentAccountIndex,
        "fromAddress": widget.store.wallet!.currentAddress,
        "toAddress": widget.txData.receiver,
        "fee": nextStateFee,
        "nonce": widget.txData.nonce,
        "memo": memo!.isNotEmpty ? memo : "",
      };
      if (txType == 'payment') {
        double amount = double.parse(Fmt.balance(
            widget.txData.amount.toString(), COIN.decimals,
            maxLength: COIN.decimals));
        txInfo["amount"] = amount;
      } else {
        isDelagetion = true;
      }
    }
    TransferData? data;
    if (isLedger) {
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
      if (isDelagetion) {
        data = await webApi.account
            .signAndSendDelegationTx(txInfo, context: context);
      } else {
        data = await webApi.account.signAndSendTx(txInfo, context: context);
      }
    }
    if (mounted && !exited) {
      globalBalanceRefreshKey.currentState!.show();
      return true;
    }
    exited = true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    final showLedgerConfirm = submitting && isLedger;
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
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(widget.title,
                            style: TextStyle(
                                color: Color(0xFF222222),
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              isLedger ? LedgerStatus() : Container(),
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                child: SvgPicture.asset(
                                  'assets/images/public/icon_nav_close.svg',
                                  width: 24,
                                  height: 24,
                                  color: Colors.black,
                                ),
                                onTap: () => Navigator.pop(context),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    height: 0.5,
                    color: Color(0xFF000000).withOpacity(0.1),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Wrap(
                      children: showLedgerConfirm
                          ? this.renderLedgerConfirm()
                          : [
                              Padding(
                                  padding: EdgeInsets.only(top: 20, bottom: 20),
                                  child: TxActionTip(type: widget.modalType!)),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                      fit: FlexFit.tight,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            dic.currentFee,
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF808080),
                                                fontWeight: FontWeight.w500),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(top: 4),
                                            child: Text(
                                              preFee.toString() +
                                                  ' ' +
                                                  COIN.coinSymbol,
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          )
                                        ],
                                      )),
                                  SvgPicture.asset(
                                      'assets/images/assets/right_arrow.svg',
                                      width: 8,
                                      color: Color(0xFF594AF1)),
                                  Flexible(
                                      fit: FlexFit.tight,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(dic.currentFee,
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF808080),
                                                  fontWeight: FontWeight.w500)),
                                          Padding(
                                            padding: EdgeInsets.only(top: 4),
                                            child: Text(
                                              nextStateFee.toString() +
                                                  ' ' +
                                                  COIN.coinSymbol,
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ],
                                      ))
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 30),
                                    child: GestureDetector(
                                        onTap: () => showAdvanceDialog(),
                                        child: Text(
                                          dic.advanceMode,
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF594AF1),
                                              fontWeight: FontWeight.w500),
                                        )),
                                  ),
                                ],
                              ),
                            ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20, left: 18, right: 18),
                    child: NormalButton(
                      submitting: submitting,
                      text: widget.buttonText ?? dic.confirm,
                      onPressed: () async {
                        if (isLedger && !await _ledgerCheck()) {
                          return;
                        }
                        setState(() {
                          submitting = true;
                        });
                        await onClickNextStep();
                        submitting = false;
                        if (widget.onConfirm != null) {
                          widget.onConfirm!();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}

class TxActionTip extends StatelessWidget {
  TxActionTip({required this.type});

  final TxActionType type;

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    if (type == TxActionType.cancel) {
      return Text(
        dic.transactionCancelTip,
        style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF808080)),
      );
    } else {
      return new StyledText(
          text: dic.speedUpTip,
          style: TextStyle(
              color: Color(0xFF808080),
              fontSize: 14,
              fontWeight: FontWeight.w400),
          tags: {
            'light': StyledTextTag(
              style: TextStyle(
                  color: Color(0xFF000000).withOpacity(0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            )
          });
    }
  }
}
