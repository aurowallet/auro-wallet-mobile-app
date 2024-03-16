import 'package:flutter/material.dart';

class AccountSelectDialog extends StatefulWidget {
  AccountSelectDialog({
    this.onConfirm,
    this.onCancel,
  });

  final Function()? onConfirm;
  final Function()? onCancel;

  @override
  _AccountSelectDialogState createState() => new _AccountSelectDialogState();
}

class _AccountSelectDialogState extends State<AccountSelectDialog> {
  @override
  void initState() {
    super.initState();
  }

  void onConfirm() {
    print('onConfirm');
  }

  void onCancel() {}

  Widget renderDrapbar() {
    return Container(
      // color: Colors.amber.withOpacity(0.3),
      height: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double containerMaxHeight = screenHeight * 0.6;
    return Container(
        height: containerMaxHeight,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(12),
              topLeft: Radius.circular(12),
            )),
        child: SafeArea(
          child: Column(
            children: [
              renderDrapbar(),
              Flexible(
                child: ListView.builder(
                  itemCount: 2,
                  itemBuilder: (context, index) =>
                      Container(child: Text("Test")), // use real WalletItem
                ),
              )
            ],
          ),
        ));
    // return Container(
    //     height: 300,
    //     decoration: BoxDecoration(
    //         color: Colors.white,
    //         borderRadius: BorderRadius.only(
    //           topRight: Radius.circular(12),
    //           topLeft: Radius.circular(12),
    //         )),
    //     child: SafeArea(
    //         child: SingleChildScrollView(
    //       child: Column(
    //         children: [
    //           renderDrapbar(),
    //           ...List.generate(
    //               4, (index) => WalletItem()), // Generate your items
    //         ],
    //       ),
    //     )));
  }
}
