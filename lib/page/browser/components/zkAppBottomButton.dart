import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:flutter/material.dart';

class ZkAppBottomButton extends StatelessWidget {
  ZkAppBottomButton({this.onCancel, required this.onConfirm});

  final Function()? onCancel;
  final Function()? onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: 20,
      ),
      padding: EdgeInsets.only(top: 12, left: 20, right: 20, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
              child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              onCancel!();
              Navigator.of(context).pop();
            },
            child: Text("Cancel",
                style: TextStyle(
                    color: Color(0xFF594AF1),
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          )),
          SizedBox(width: 15),
          Expanded(
              child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 48),
              primary: ColorsUtil.hexColor(0x594AF1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              onConfirm!();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Confirm",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600))
              ],
            ),
          )),
        ],
      ),
    );
  }
}
