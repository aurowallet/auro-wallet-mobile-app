import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/staking/staking.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:auro_wallet/store/staking/types/validatorData.dart';
import 'package:auro_wallet/common/components/formPanel.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:roundcheckbox/roundcheckbox.dart';


class ValidatorItem extends StatelessWidget {
  ValidatorItem({required this.data,required this.checked,required this.toggle});
  final ValidatorData data;
  final bool checked;
  final void Function(String, bool) toggle;
  void _onClick(bool? isChecked) {
    toggle(data.address, isChecked!);
  }
  void onItemClick() {
    toggle(data.address, !checked);
  }
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    final Map<String, String> i18n = I18n.of(context).main;
    return GestureDetector(
      onTap: onItemClick,
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFF9FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: checked ? Theme.of(context).primaryColor : Colors.black.withOpacity(0.05)
          )
        ),
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                    Expanded(
                        child: Text(
                            data.name == null ? Fmt.address(data.address, pad: 8) : data.name!,
                            style: TextStyle(
                              fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.w500
                            )
                        ),
                    ),
                    // Text(
                    //     '${i18n['validatorStakeFee']!}:${data.fee.toStringAsFixed(2)}%',
                    //     style: theme.headline6!.copyWith(
                    //         color: ColorsUtil.hexColor(0x333333),
                    //         fontWeight: FontWeight.normal,
                    //         height: 1.2
                    //     )
                    // ),
                  ],),
                  Padding(padding: EdgeInsets.only(top:5),),
                  Text(
                      Fmt.address(data.address, pad: 10),
                      style: TextStyle(
                          color: Colors.black.withOpacity(0.5),
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          height: 1.2
                      )
                  ),
                  Padding(padding: EdgeInsets.only(top:4),),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      new RichText(
                          textScaleFactor: MediaQuery.of(context).textScaleFactor,
                          text: TextSpan(
                              children: [
                                new TextSpan(
                                  text: '${i18n['validatorTotalStake']!}: ',
                                  style: TextStyle(
                                      color: Colors.black.withOpacity(0.5),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      height: 1.2
                                  ),
                                ),
                                new TextSpan(
                                  text: '${Fmt.balance(data.totalStake.toString(), COIN.decimals)}',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      height: 1.2
                                  ),
                                ),
                              ]
                          )
                      ),
                      Container(
                        width: 12,
                      ),
                      new RichText(
                          textScaleFactor: MediaQuery.of(context).textScaleFactor,
                          text: TextSpan(
                              children: [
                                new TextSpan(
                                  text: '${i18n['delegations']!}: ',
                                  style: TextStyle(
                                      color: Colors.black.withOpacity(0.5),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      height: 1.2
                                  ),
                                ),
                                new TextSpan(
                                  text: '${data.delegations}',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      height: 1.2
                                  ),
                                ),
                              ]
                          )
                      ),
                    ],
                  )
                ],
              )),
              checked ? RoundCheckBox(
                size: 18,
                borderColor: ColorsUtil.hexColor(0xcccccc),
                isChecked: checked,
                uncheckedColor: Colors.white,
                checkedColor: Theme.of(context).primaryColor,
                checkedWidget: Icon(Icons.check, color: Colors.white, size: 12,),
                // inactiveColor: ColorsUtil.hexColor(0xCCCCCC),
                onTap: _onClick,
              ): Container(),
            ],
          )
      )
    );
  }
}