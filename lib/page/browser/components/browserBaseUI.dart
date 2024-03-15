import 'package:flutter/material.dart';

class BrowserDialogTitleRow extends StatelessWidget {
  BrowserDialogTitleRow({required this.title, this.chainId});

  final String title;
  final String? chainId;

  @override
  Widget build(BuildContext context) {
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
                    : Container()
              ],
            ),
          ),
          Container(
            height: 0.5,
            color: Color(0xFF000000).withOpacity(0.1),
          ),
        ],
      ),
    );
  }
}
