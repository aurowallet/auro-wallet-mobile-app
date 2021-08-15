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
import 'package:circular_check_box/circular_check_box.dart';


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
    Runes input = new Runes( data.name == null ? Fmt.address(data.address, pad: 8) : data.name!);
    return GestureDetector(
      onTap: onItemClick,
      child: FormPanel(
          padding: EdgeInsets.only(left: 20, top: 20, bottom: 20, right: 10),
          margin: EdgeInsets.only(top: 10),
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
                            String.fromCharCodes(input),
                            style: theme.headline5!.copyWith(
                                color: ColorsUtil.hexColor(0x010000D),
                                fontWeight: FontWeight.w600
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
                  Padding(padding: EdgeInsets.only(top:8),),
                  Text(
                      Fmt.address(data.address, pad: 10),
                      style: theme.headline6!.copyWith(
                          color: ColorsUtil.hexColor(0x999999),
                          fontWeight: FontWeight.normal,
                          height: 1.2
                      )
                  ),
                  Padding(padding: EdgeInsets.only(top:4),),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      new RichText(
                          text: TextSpan(
                              children: [
                                new TextSpan(
                                  text: '${i18n['validatorTotalStake']!}: ',
                                  style: theme.headline6!.copyWith(
                                      color: ColorsUtil.hexColor(0x666666),
                                      fontWeight: FontWeight.normal,
                                      height: 1.2
                                  ),
                                ),
                                new TextSpan(
                                  text: '${Fmt.balance(data.totalStake.toString(), COIN.decimals)}',
                                  style: theme.headline6!.copyWith(
                                      color: ColorsUtil.hexColor(0x333333),
                                      fontWeight: FontWeight.normal,
                                      height: 1.2
                                  ),
                                ),
                              ]
                          )
                      ),
                      new RichText(
                          text: TextSpan(
                              children: [
                                new TextSpan(
                                  text: '${i18n['delegations']!}: ',
                                  style: theme.headline6!.copyWith(
                                      color: ColorsUtil.hexColor(0x666666),
                                      fontWeight: FontWeight.normal,
                                      height: 1.2
                                  ),
                                ),
                                new TextSpan(
                                  text: '${data.delegations}',
                                  style: theme.headline6!.copyWith(
                                      color: ColorsUtil.hexColor(0x333333),
                                      fontWeight: FontWeight.normal,
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
              CircularCheckBox(
                value: checked,
                checkColor: Colors.white,
                activeColor: ColorsUtil.hexColor(0x59c49c),
                // inactiveColor: ColorsUtil.hexColor(0xCCCCCC),
                onChanged: _onClick,
              ),
            ],
          )
      )
    );
  }
}