import 'package:auro_wallet/common/components/networkStatusView.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class BrowserDialogTitleRow extends StatelessWidget {
  BrowserDialogTitleRow(
      {required this.title,
      this.showChainType = false,
      this.showCloseIcon,
      this.ledgerWidget});

  final String title;
  final bool? showCloseIcon;
  final bool showChainType;
  final Widget? ledgerWidget;

  @override
  Widget build(BuildContext context) {
    List<Widget> closeWidget = [];
    List<Widget> ledgerRow = [];
    if (ledgerWidget != null) {
      ledgerRow.add(ledgerWidget!);
    }
    if (showCloseIcon == true) {
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
                color: Colors.black,
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
                showChainType ? NetworkStatusView() : Container(),
                ...closeWidget,
              ],
            ),
          ),
          ledgerRow.length > 0
              ? Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [...ledgerRow]))
              : Container(),
          Container(
            height: 0.5,
            color: Color(0xFF000000).withOpacity(0.1),
          ),
        ],
      ),
    );
  }
}
