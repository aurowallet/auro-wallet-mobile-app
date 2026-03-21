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
    final shouldShowWarning = transferFees.isFeeExceedsCapValue(currentFee);

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
                  color: Color(0xD9000000),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                Fmt.parseShowBalance(currentFee, showLength: COIN.decimals) + " " + COIN.coinSymbol,
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0x80000000),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          if (shouldShowWarning)
            Padding(
              padding: EdgeInsets.only(top: 4),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  dic.feeTooLarge,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFFE8B30E),
                  ),
                ),
              ),
            ),
          Container(
            height: 0.5,
            margin: EdgeInsets.only(top: 10),
            decoration: BoxDecoration(color: Color(0x1A000000)),
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
