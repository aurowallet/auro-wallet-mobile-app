import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/staking/components/stakingOverview.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/staking/staking.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/utils/stakingMath.dart';
import 'package:auro_wallet/store/staking/types/overviewData.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'default slot is 90 seconds and node-provided 180 seconds is retained',
    () {
      for (final value in [null, 0, -1, 90000]) {
        expect(StakingMath.slotMinutes(value), 1.5);
      }
      expect(StakingMath.slotMinutes(180000), 3);
      expect(StakingMath.slotMinutes(92999), 1.5);
      expect(StakingMath.slotMinutes(93000), 1.6);
    },
  );

  test('exact epoch boundaries never round up by an extra tenth', () {
    for (var tenths = 1; tenths <= 1000; tenths++) {
      final duration = (Duration.millisecondsPerDay ~/ 10) * tenths;
      expect(
        StakingMath.epochDays(
          slotsPerEpoch: 0,
          slotDurationMs: 0,
          epochDurationMs: duration,
        ),
        tenths / 10,
      );
      expect(
        StakingMath.epochDays(
          slotsPerEpoch: 0,
          slotDurationMs: 0,
          epochDurationMs: duration + 1,
        ),
        (tenths + 1) / 10,
      );
    }
  });

  test(
    'countdown uses actual slots and truncates only the seconds remainder',
    () {
      final time = StakingMath.epochTimeRemaining(
        slot: 0,
        slotsPerEpoch: 7140,
        slotDurationMs: 90000,
      )!;
      expect(time.days, BigInt.from(7));
      expect(time.hours, 10);
      expect(time.minutes, 30);
      expect(
        StakingMath.epochTimeRemaining(
          slot: 0,
          slotsPerEpoch: 1,
          slotDurationMs: 59999,
        )!.minutes,
        0,
      );
      expect(
        StakingMath.epochTimeRemaining(
          slot: 0,
          slotsPerEpoch: 1,
          slotDurationMs: 60000,
        )!.minutes,
        1,
      );
    },
  );

  test('unknown and out-of-range consensus data do not divide by zero', () {
    expect(OverviewData().epochTimeRemaining, isNull);
    expect(OverviewData().epochProgress, 0);
    expect(StakingMath.epochProgress(5, 0), 0);
    expect(StakingMath.epochProgress(-1, 7140), 0);
    expect(StakingMath.epochProgress(8000, 7140), 1);
    expect(
      StakingMath.epochTimeRemaining(
        slot: -1,
        slotsPerEpoch: 7140,
        slotDurationMs: 90000,
      ),
      isNull,
    );
    final end = StakingMath.epochTimeRemaining(
      slot: 8000,
      slotsPerEpoch: 7140,
      slotDurationMs: 90000,
    )!;
    expect(end, (days: BigInt.zero, hours: 0, minutes: 0));
  });

  test('extreme countdown inputs retain exact days and bounded remainders', () {
    const max = 0x7fffffffffffffff;
    final time = StakingMath.epochTimeRemaining(
      slot: 0,
      slotsPerEpoch: max,
      slotDurationMs: max,
    )!;
    expect(time.days, greaterThan(BigInt.from(max)));
    expect(time.hours, inInclusiveRange(0, 23));
    expect(time.minutes, inInclusiveRange(0, 59));
    final displayedMinutes =
        time.days * BigInt.from(1440) +
        BigInt.from(time.hours * 60 + time.minutes);
    final remainder =
        BigInt.from(max) * BigInt.from(max) -
        displayedMinutes * BigInt.from(60000);
    expect(remainder >= BigInt.zero && remainder < BigInt.from(60000), isTrue);
  });

  test(
    'estimates use the same APR formula and truncate recurring fractions',
    () {
      expect(
        StakingMath.estimateRewards(balance: 1000, apr: 5, days: 7.5),
        '1.0273',
      );
      expect(
        StakingMath.estimateRewards(balance: 1000, apr: 5, days: 90),
        '12.3287',
      );
      expect(
        StakingMath.estimateRewards(balance: 1000, apr: 5, days: 180),
        '24.6575',
      );
      expect(
        StakingMath.estimateRewards(balance: 10, apr: 1, days: 1),
        '0.0002',
      );
      expect(
        StakingMath.estimateRewards(balance: 365, apr: 1, days: 1),
        '0.01',
      );
      expect(StakingMath.estimateRewards(balance: 0, apr: 5, days: 7.5), '0');
    },
  );

  test(
    'invalid estimates stay unknown and large finite products do not overflow',
    () {
      for (final invalid in [
        double.nan,
        double.infinity,
        double.negativeInfinity,
        -1,
      ]) {
        expect(
          StakingMath.estimateRewards(balance: invalid, apr: 5, days: 7.5),
          isNull,
        );
        expect(
          StakingMath.estimateRewards(balance: 1, apr: invalid, days: 7.5),
          isNull,
        );
        expect(
          StakingMath.estimateRewards(balance: 1, apr: 5, days: invalid),
          isNull,
        );
      }
      final value = StakingMath.estimateRewards(
        balance: 1e200,
        apr: 1e200,
        days: 365,
      )!;
      expect(value, '1${List.filled(398, '0').join()}');
    },
  );

  testWidgets(
    'overview failure replaces the old countdown with unknown labels',
    (tester) async {
      final store = AppStore();
      store.staking = StakingStore(store);
      store.staking!.setOverviewInfo({
        'epoch': 12,
        'slot': 0,
        'slotsPerEpoch': 7140,
        'slotDuration': 90000,
      }, shouldCache: false);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: StakingOverview(store: store)),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('07d'), findsOneWidget);
      expect(find.text('10h'), findsOneWidget);
      expect(find.text('30m'), findsOneWidget);
      store.staking!.clearOverviewData();
      await tester.pumpAndSettle();
      expect(find.text('07d'), findsNothing);
      expect(find.text('--d'), findsOneWidget);
      expect(find.text('--h'), findsOneWidget);
      expect(find.text('--m'), findsOneWidget);
      expect(find.text(' / --'), findsOneWidget);
      expect(
        tester
            .widget<PercentageCircle>(find.byType(PercentageCircle))
            .percentage,
        0,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
