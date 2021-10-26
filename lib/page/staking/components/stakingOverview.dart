import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/staking/staking.dart';
import 'package:auro_wallet/store/staking/types/overviewData.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:percent_indicator/percent_indicator.dart';

class StakingOverview extends StatelessWidget {
  StakingOverview({required this.store});
  final AppStore store;
  List<String> _getTime() {
    OverviewData data = store.staking!.overviewData;
    if (data.slotsPerEpoch != 0) {
      double lastTime = (data.slotsPerEpoch - data.slot) * data.slotDuration / 1000;
      int days = (lastTime / 60 / 60 / 24).floor();
      double leave1 = (lastTime % (24 * 3600));
      int hours = (leave1 / (3600)).floor();
      double leave2 = leave1 % 3600;
      int minutes = (leave2 / 60).floor();
      return [days.toString().padLeft(2,'0'), hours.toString().padLeft(2,'0'), minutes.toString().padLeft(2,'0')];
    }
    return ['', '', ''];
  }
  @override
  Widget build(BuildContext context) {
    final Map<String, String> i18n = I18n.of(context).main;
    OverviewData data = store.staking!.overviewData;
    List<String> time = _getTime();
    var theme = Theme.of(context).textTheme;
    TextStyle labelStyle = theme.headline5!.copyWith(color: ColorsUtil.hexColor(0x333333));
    TextStyle valueStyle = theme.headline5!.copyWith(color: ColorsUtil.hexColor(0x737be4), fontWeight: FontWeight.bold, );
    return Container(
        margin: EdgeInsets.only(top: 10, left: 28, right: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(i18n['epochInfo']!, style: theme.headline4!.copyWith(color: ColorsUtil.hexColor(0x020028), fontWeight: FontWeight.w600), ),
            Container(
              padding: EdgeInsets.only(left: 20, right: 20, top: 29, bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: 60,
                            child: Text(
                              'Epoch',
                              style: labelStyle,
                            ),
                          ),
                          Text(data.epoch.toString(), style: valueStyle,),
                        ],
                      ),
                      Padding(padding: EdgeInsets.only(top: 14)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: 60,
                            child: Text('Slot', style: labelStyle,),
                          ),
                          Text(data.slot.toString(), style: valueStyle),
                          Text(' / ${data.slotsPerEpoch.toString()}', style: valueStyle.copyWith(color: ColorsUtil.hexColor(0xb1b3be))),
                        ],
                      ),
                      Padding(padding: EdgeInsets.only(top: 14)),
                      Text(i18n['epochEndTime']!, style: labelStyle,),
                      Padding(padding: EdgeInsets.only(top: 14)),
                      Row(
                        children: [
                          TimeInfo(time: time[0] + 'd'),
                          Text(' : '),
                          TimeInfo(time: time[1] + 'h'),
                          Text(' : '),
                          TimeInfo(time: time[2] + 'm'),
                        ],
                      ),
                    ],
                  ),
                  PercentageCircle(percentage: data.slotsPerEpoch != 0 ? (data.slot / data.slotsPerEpoch) : 0,)
                ],
              ),
            )
          ],
        )
    );
  }
}

class TimeInfo extends StatelessWidget {
  TimeInfo({required this.time});
  final String time;
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    return Container(
        decoration: BoxDecoration(
          border: Border.all(
              color: ColorsUtil.hexColor(0x979797),
              width: 1
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        constraints: BoxConstraints(
          minWidth: 40,
        ),
        padding: EdgeInsets.symmetric(vertical: 1),
        child: Text(
            time,
            textAlign: TextAlign.center,
            style: theme.headline6
        )
    );
  }
}

class PercentageCircle extends StatelessWidget {
  PercentageCircle({required this.percentage});
  final double percentage;
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    return Container(
      child: new CircularPercentIndicator(
        radius: 100.0,
        lineWidth: 10.0,
        percent: percentage,
        circularStrokeCap: CircularStrokeCap.round,
        center: new Text((percentage * 100).toStringAsFixed(0) + '%', style: theme.headline5!.copyWith(color: ColorsUtil.hexColor(0x1e1f20), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.grey,
        maskFilter: MaskFilter.blur(BlurStyle.solid, 3),
        linearGradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [ColorsUtil.hexColor(0x9B4EDE), ColorsUtil.hexColor(0x737BE4)],
        ),
      )
    );
  }
}