import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/staking/staking.dart';
import 'package:auro_wallet/store/staking/types/overviewData.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:percent_indicator/percent_indicator.dart';

class StakingOverview extends StatelessWidget {
  StakingOverview({required this.store});

  final AppStore store;

  List<String> _getTime() {
    OverviewData data = store.staking!.overviewData;
    if (data.slotsPerEpoch != 0) {
      double lastTime =
          (data.slotsPerEpoch - data.slot) * data.slotDuration / 1000;
      int days = (lastTime / 60 / 60 / 24).floor();
      double leave1 = (lastTime % (24 * 3600));
      int hours = (leave1 / (3600)).floor();
      double leave2 = leave1 % 3600;
      int minutes = (leave2 / 60).floor();
      return [
        days.toString().padLeft(2, '0'),
        hours.toString().padLeft(2, '0'),
        minutes.toString().padLeft(2, '0')
      ];
    }
    return ['', '', ''];
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> i18n = I18n.of(context).main;
    OverviewData data = store.staking!.overviewData;
    List<String> time = _getTime();
    var theme = Theme.of(context).textTheme;
    TextStyle labelStyle = TextStyle(
        fontSize: 12,
        color: Colors.black.withOpacity(0.5),
        fontWeight: FontWeight.w500);
    TextStyle valueStyle = TextStyle(
      fontSize: 18,
      color: Theme.of(context).primaryColor,
      fontWeight: FontWeight.w500,
    );
    return Container(
        margin: EdgeInsets.only(top: 10, left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  'assets/images/stake/icon_epoch.svg',
                  width: 16,
                  color: Colors.black,
                ),
                Container(
                  width: 8,
                ),
                Text(
                  i18n['epochInfo']!,
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w600),
                )
              ],
            ),
            Container(
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                  color: Color(0xFFF9FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Colors.black.withOpacity(0.05), width: 0.5)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Epoch',
                        style: labelStyle,
                      ),
                      Text(
                        data.epoch.toString(),
                        style: valueStyle,
                      ),
                      Padding(padding: EdgeInsets.only(top: 10)),
                      Container(
                        width: 60,
                        child: Text(
                          'Slot',
                          style: labelStyle,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(data.slot.toString(), style: valueStyle),
                          Text(' / ${data.slotsPerEpoch.toString()}',
                              style: valueStyle.copyWith(
                                  color: ColorsUtil.hexColor(0xb1b3be))),
                        ],
                      ),
                      Padding(padding: EdgeInsets.only(top: 10)),
                      Text(
                        i18n['epochEndTime']!,
                        style: labelStyle,
                      ),
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
                  PercentageCircle(
                    percentage: data.slotsPerEpoch != 0
                        ? (data.slot / data.slotsPerEpoch)
                        : 0,
                  )
                ],
              ),
            )
          ],
        ));
  }
}

class TimeInfo extends StatelessWidget {
  TimeInfo({required this.time});

  final String time;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    return Container(
        padding: EdgeInsets.zero,
        child: Text(time,
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)));
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
      radius: 108.0,
      lineWidth: 8.0,
      percent: percentage,
      circularStrokeCap: CircularStrokeCap.round,
      center: Row(
        textBaseline: TextBaseline.alphabetic,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text((percentage * 100).toStringAsFixed(0),
              style: TextStyle(
                  fontSize: 30,
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                  height: 1)),
          Text('%',
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                  height: 1)),
        ],
      ),
      backgroundColor: Color(0x1A000000),
      // maskFilter: MaskFilter.blur(BlurStyle.solid, 3),
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFF7870), Color(0xFF594AF1)],
      ),
    ));
  }
}
