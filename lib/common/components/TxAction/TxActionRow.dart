import 'package:auro_wallet/common/components/TxAction/txActionDialog.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/assets/types/fees.dart';
import 'package:auro_wallet/store/assets/types/transferData.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';

class TxActionRow extends StatefulWidget {
  TxActionRow({required this.store, required this.data});

  final TransferData data;
  final AppStore store;

  @override
  _TxActionRowState createState() => _TxActionRowState();
}

class _TxActionRowState extends State<TxActionRow> {
  late ReactionDisposer _monitorFeeDisposer;
  double? currentFee;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _monitorFeeDisposer =
          reaction((_) => widget.store.assets!.transferFees, _onFeeLoaded);
    });
  }

  void _onFeeLoaded(Fees fees) {
    print('_onFeeLoaded');
    setState(() {
      currentFee = fees.speedup;
      print('set fee ctr');
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onOpenModal(bool isSpeedUp) async {
    final Map<String, String> i18n = I18n.of(context).main;
    var title = isSpeedUp ? i18n['speedUpTitle'] : i18n['cancelTransaction'];
    var modalType = isSpeedUp ? TxActionType.speedup : TxActionType.cancel;
    await UI.showTxAction(
        context: context,
        title: title!,
        txData: widget.data,
        buttonText: i18n['confirm'],
        modalType: modalType,
        onConfirm: () async {
          return false;
        });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        widget.data.showSpeedUp == true
            ? Row(
                children: [
                  GestureDetector(
                    child: Container(
                      height: 18,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Color(0xFF594AF1),
                          borderRadius: BorderRadius.circular(4)),
                      margin: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                      child: Padding(
                        padding: EdgeInsets.only(left: 4, right: 4),
                        child: Text(
                          textAlign: TextAlign.center,
                          I18n.of(context).main['speedUp']!,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFFFFFFFF)),
                          strutStyle: StrutStyle(
                            fontSize: 12,
                            leading: 0,
                            height: 1,
                            forceStrutHeight: true,
                          ),
                        ),
                      ),
                    ),
                    onTap: () => onOpenModal(true),
                  ),
                  Padding(padding: EdgeInsets.only(left: 6))
                ],
              )
            : Container(),
        GestureDetector(
          child: Container(
            height: 18,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                border: Border.all(
                  color: Color(0xFF594AF1),
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(4)),
            margin: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
            child: Padding(
              padding: EdgeInsets.only(left: 4, right: 4),
              child: Text(
                I18n.of(context).main['cancel']!,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF594AF1)),
                strutStyle: StrutStyle(
                  fontSize: 12,
                  leading: 0,
                  height: 1,
                  forceStrutHeight: true,
                ),
              ),
            ),
          ),
          onTap: () => onOpenModal(false),
        )
      ],
    );
  }
}
