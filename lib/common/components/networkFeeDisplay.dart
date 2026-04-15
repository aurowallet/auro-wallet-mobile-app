import 'package:auro_wallet/common/components/advanceFeeModal.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/store/assets/types/fees.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:flutter/material.dart';

class NetworkFeeDisplay extends StatelessWidget {
  NetworkFeeDisplay({
    required this.currentFee,
    required this.transferFees,
    required this.onAdvanceConfirm,
    this.currentNonce,
    this.advanceFee,
    this.advanceNonce,
    this.showFeeButtons = true,
    this.showAdvanceButton = true,
  });

  final double currentFee;
  final Fees transferFees;
  final Function(String fee, String nonce) onAdvanceConfirm;
  final int? currentNonce;
  final String? advanceFee;
  final String? advanceNonce;
  final bool showFeeButtons;
  final bool showAdvanceButton;

  void _onClickAdvance(BuildContext context) {
    showAdvanceFeeModal(
      context: context,
      currentFee: currentFee,
      transferFees: transferFees,
      onConfirm: onAdvanceConfirm,
      currentNonce: currentNonce,
      advanceFee: advanceFee,
      advanceNonce: advanceNonce,
      showFeeButtons: showFeeButtons,
    );
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dic.networkFee,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                Fmt.parseShowBalance(currentFee, showLength: COIN.decimals) + " " + COIN.coinSymbol,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          Container(
            height: 0.5,
            margin: EdgeInsets.only(top: 10),
            decoration: BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0.10)),
          ),
          if (showAdvanceButton)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _onClickAdvance(context),
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: EdgeInsets.only(
                      left: 10, right: 10, top: 10, bottom: 10),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: Theme.of(context).primaryColor,
                ),
                child: Text(
                  dic.advanceMode,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
