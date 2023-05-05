import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/staking/staking.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:auro_wallet/store/staking/types/validatorData.dart';
import 'package:auro_wallet/common/components/formPanel.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:roundcheckbox/roundcheckbox.dart';

import '../delegatePage.dart';

class ValidatorItem extends StatelessWidget {
  ValidatorItem({required this.data});

  final ValidatorData data;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    final Map<String, String> i18n = I18n.of(context).main;
    final Map<String, String> stakingI18n = I18n.of(context).staking;
    return Container(
        margin: const EdgeInsets.only(top: 10),
        child: Material(
          color: Color(0xFFF9FAFC),
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(context, DelegatePage.route,
                  arguments: DelegateParams(
                      validatorData: data, manualAddValidator: false));
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: Colors.black.withOpacity(0.05), width: 0.5)),
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ItemLogo(
                      name: data.name,
                      logo: data.logo,
                    ),
                    Container(
                      width: 4,
                    ),
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                  data.name == null
                                      ? Fmt.address(data.address, pad: 10)
                                      : Fmt.stringSlice(data.name!, 16,
                                          withEllipsis: true,
                                          ellipsisCounted: true),
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500)),
                            ),
                            Text(
                                '${Fmt.balanceToInteger(data.totalStake.toString(), COIN.decimals)} ${COIN.coinSymbol}',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 5),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(Fmt.address(data.address, pad: 6),
                                style: TextStyle(
                                    color: Colors.black.withOpacity(0.5),
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    height: 1.2)),
                            Text(
                                '${stakingI18n['delegators']!.replaceAll('{count}', Fmt.balanceToInteger(data.delegations.toString(), 0))}',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black.withOpacity(0.5),
                                    fontWeight: FontWeight.w400,
                                    height: 1.2)),
                          ],
                        ),
                      ],
                    )),
                  ],
                )),
          ),
        ));
  }
}

class ItemLogo extends StatefulWidget {
  ItemLogo({this.name, required this.logo, this.radius = 15});

  final String? name;
  final String logo;
  final double? radius;

  @override
  ItemLogoState createState() => ItemLogoState();
}

class ItemLogoState extends State<ItemLogo> {
  bool loadError = false;

  onLoadError(exception, stackTrace) {
    setState(() {
      loadError = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final showText = widget.logo.isEmpty || loadError;
    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: Color(0x4D000000),
      onBackgroundImageError: !showText ? onLoadError : null,
      backgroundImage: !showText
          ? NetworkImage(
              widget.logo,
              // 'https://picsum.photos/250?image=10',
            )
          : null,
      child: showText
          ? Text(
              widget.name?.substring(0, 1).toUpperCase() ?? 'U',
              style: TextStyle(fontSize: 16, color: Colors.white),
            )
          : null,
    );
  }
}
