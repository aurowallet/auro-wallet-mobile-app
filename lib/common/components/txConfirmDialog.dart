import 'package:auro_wallet/common/components/ledgerStatus.dart';
import 'package:auro_wallet/ledgerMina/mina_ledger_application.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/ledger/ledger.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:auro_wallet/common/components/normalButton.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ledger_flutter/ledger_flutter.dart';

enum TxItemTypes { address, amount, text, head }

class TxItem {
  TxItem({required this.label, required this.value, this.type});

  final String label;
  final String value;
  final TxItemTypes? type;
}

class TxConfirmDialog extends StatefulWidget {
  TxConfirmDialog({
    required this.items,
    required this.title,
    this.onConfirm,
    this.disabled = false,
    this.isLedger = false,
    this.buttonText,
    this.headerLabel,
    this.headerValue,
  });

  final List<TxItem> items;
  final String title;
  final String? headerLabel;
  final Widget? headerValue;
  final String? buttonText;
  final bool disabled;
  final bool isLedger;
  final Function()? onConfirm;

  final store = globalAppStore;

  @override
  _TxConfirmDialogState createState() => new _TxConfirmDialogState();
}

class _TxConfirmDialogState extends State<TxConfirmDialog> {
  bool submitting = false;

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
    final Map<String, String> dic = I18n
        .of(context)
        .ledger;
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
            dic['waitingLedger']!,
            style: TextStyle(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.only(top: 7),
        child: Text(
          dic['waitingLedgerSign']!,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.black.withOpacity(0.5),
              fontSize: 14,
              fontWeight: FontWeight.w600),
        ),
      ),
      Container(
        padding: EdgeInsets.only(top: 14, bottom: 60),
        child: Center(
          child: Text(
            dic['waitingNotClose']!,
            style: TextStyle(
                color: Color(0xFFE4B200).withOpacity(0.5),
                fontSize: 14,
                fontWeight: FontWeight.w600),
          ),
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

  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic = I18n
        .of(context)
        .main;
    final showLedgerConfirm = submitting && widget.isLedger;
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
                              widget.isLedger ? LedgerStatus() : Container(),
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
                  widget.headerLabel != null &&
                      widget.headerValue != null &&
                      !showLedgerConfirm
                      ? this
                      .renderHead(widget.headerLabel!, widget.headerValue!)
                      : Container(),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Wrap(
                      children: [
                        ...(showLedgerConfirm
                            ? this.renderLedgerConfirm()
                            : widget.items.map((e) {
                          return TxConfirmItem(
                            data: e,
                          );
                        }).toList()),
                        Padding(
                          padding:
                          EdgeInsets.only(top: 40, left: 18, right: 18),
                          child: NormalButton(
                            disabled: widget.disabled,
                            submitting: submitting,
                            text: widget.buttonText ?? dic['confirm']!,
                            onPressed: () async {
                              if (widget.isLedger && !await _ledgerCheck()) {
                                return;
                              }
                              setState(() {
                                submitting = true;
                              });
                              if (widget.onConfirm != null) {
                                widget.onConfirm!();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ));
  }
}

class TxConfirmItem extends StatelessWidget {
  TxConfirmItem({required this.data});

  final TxItem data;

  @override
  Widget build(BuildContext context) {
    Color valueColor;
    String text;
    var theme = Theme
        .of(context)
        .textTheme;
    switch (data.type) {
      case TxItemTypes.amount:
        text = data.value;
        // valueColor = Theme.of(context).primaryColor;
        break;
      case TxItemTypes.address:
        text = data.value;
        // valueColor = ColorsUtil.hexColor(0x333333);
        break;
      default:
        text = data.value;
        // valueColor = ColorsUtil.hexColor(0x333333);
        break;
    }
    return Padding(
        padding: EdgeInsets.only(top: 28),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            // width: 85,
            child: Text(
              data.label,
              style: TextStyle(
                  fontSize: 14,
                  color: Color(0x80000000),
                  height: 1.33,
                  fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            height: 4,
          ),
          Text(text,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  height: 1.33,
                  fontWeight: FontWeight.w500)),
        ]));
  }
}
