import 'package:auro_wallet/common/components/ledgerStatusView.dart';
import 'package:auro_wallet/common/components/networkStatusView.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class BrowserDialogTitleRow extends StatelessWidget {
  BrowserDialogTitleRow(
      {required this.title,
      this.showChainType = false,
      this.showCloseIcon = false,
      this.showLedgerStatus = false,
      this.chainId,
      });

  final String title;
  final bool showCloseIcon;
  final bool showChainType;
  final bool showLedgerStatus;
  final String? chainId;

  @override
  Widget build(BuildContext context) {
    List<Widget> closeWidget = [];
    if (showCloseIcon) {
      closeWidget.add(Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: SvgPicture.asset(
                'assets/images/public/icon_nav_close.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn)
              ),
              onTap: () => Navigator.pop(context),
            )
          ],
        ),
      ));
    }
    return Container(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(title,
                    style: TextStyle(
                        color: Color(0xFF222222),
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    showLedgerStatus ? LedgerStatusView() : Container(),
                    SizedBox(width: 4),
                    showChainType ? NetworkStatusView(chainId:chainId) : Container(),
                  ],
                ),
                ...closeWidget,
              ],
            ),
          ),
          Container(
            height: 0.5,
            color: Color(0xFF000000).withValues(alpha: 0.1),
          ),
        ],
      ),
    );
  }
}
