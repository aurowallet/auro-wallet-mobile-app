import 'package:auro_wallet/store/staking/types/overviewData.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('epoch rounding matches extension and prefers slots times duration', () {
    final data = OverviewData.fromJson({
      'slotsPerEpoch': 7140, 'slotDuration': 90000, 'epochDuration': 1,
    });
    expect(data.epochDays, 7.5);
    expect(data.epochDaysText, '7.5');
    data.slotDuration = 180000;
    expect(data.epochDays, 14.9);
    expect(data.epochDaysText, '14.9');
  });

  test('whole days and rounding boundaries do not gain another tenth', () {
    final data = OverviewData()..epochDuration = Duration.millisecondsPerDay * 7;
    expect(data.epochDaysText, '7');
    data.epochDuration += 1;
    expect(data.epochDays, 7.1);
    data.epochDuration = Duration.millisecondsPerDay ~/ 10;
    expect(data.epochDays, 0.1);
  });

  for (final value in [null, 0, -1, 'invalid', 'NaN', double.nan,
    'Infinity', double.infinity, double.negativeInfinity, '1e9999']) {
    test('invalid configuration $value safely falls back to 7.5 days', () {
      final data = OverviewData.fromJson({
        'slotsPerEpoch': value, 'slotDuration': value, 'epochDuration': value,
      });
      expect(data.epochDays, 7.5);
      expect(data.epochDaysText, '7.5');
      expect(data.hasEpochInfo, isFalse);
    });
  }

  test('invalid derived duration falls back to configured epoch duration', () {
    final data = OverviewData.fromJson({
      'slotsPerEpoch': '7140', 'slotDuration': 0,
      'epochDuration': '${Duration.millisecondsPerDay * 8}',
    });
    expect(data.epochDays, 8);
    expect(data.epochDaysText, '8');
  });

  test('large positive inputs do not wrap or clamp to a signed integer', () {
    final data = OverviewData()
      ..slotsPerEpoch = 0x7fffffffffffffff
      ..slotDuration = 0x7fffffffffffffff;
    final expected = (data.slotsPerEpoch.toDouble() * data.slotDuration /
        Duration.millisecondsPerDay * 10).ceilToDouble() / 10;
    expect(data.epochDays.isFinite, isTrue);
    expect(data.epochDays, expected);
    expect(data.epochDays, greaterThan(1e20));
    expect(double.parse(data.epochDaysText), data.epochDays);
  });

  test('missing epoch and invalid slot do not create a valid overview', () {
    final data = OverviewData.fromJson({
      'slotsPerEpoch': 7140, 'slotDuration': 90000,
    });
    expect(data.hasEpochInfo, isFalse);
    data.epoch = 1;
    data.slot = -1;
    expect(data.hasEpochInfo, isFalse);
    data.slot = 10000;
    expect(data.boundedSlot, 7140);
  });
}
