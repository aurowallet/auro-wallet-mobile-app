import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class BrowserDialogTitleRow extends StatelessWidget {
  BrowserDialogTitleRow(
      {required this.title,
      this.chainId,
      this.showCloseIcon,
      this.ledgerWidget});

  final String title;
  final String? chainId;
  final bool? showCloseIcon;
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
                chainId != null
                    ? Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.black.withOpacity(0.1),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                  color: Color(0xFF594AF1),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(3))),
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            Text(chainId!,
                                style: TextStyle(
                                    height: 1.25,
                                    color: Color(0xFF808080),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500))
                          ],
                        ),
                      )
                    : Container(),
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
