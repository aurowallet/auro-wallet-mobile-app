import 'package:auro_wallet/common/consts/settings.dart';
import 'package:decimal/decimal.dart';

/// Shared consensus-time conversions and staking estimates, without UI state.
abstract final class StakingMath {
  static const defaultSlotDurationMs = 90000;
  static const defaultEpochDays = 7.5;

  static double epochDays({
    required int slotsPerEpoch,
    required int slotDurationMs,
    required int epochDurationMs,
  }) {
    final duration = slotsPerEpoch > 0 && slotDurationMs > 0
        ? BigInt.from(slotsPerEpoch) * BigInt.from(slotDurationMs)
        : BigInt.from(epochDurationMs);
    if (duration <= BigInt.zero) return defaultEpochDays;
    // Round up to tenths of a day, as in extension, without a floating-point
    // intermediate that could cross an exact rounding boundary.
    final unit = BigInt.from(Duration.millisecondsPerDay ~/ 10);
    return ((duration + unit - BigInt.one) ~/ unit).toDouble() / 10;
  }

  static double slotMinutes(int? slotDurationMs) {
    final duration = BigInt.from(
      slotDurationMs != null && slotDurationMs > 0
          ? slotDurationMs
          : defaultSlotDurationMs,
    );
    final unit = BigInt.from(Duration.millisecondsPerMinute ~/ 10);
    return ((duration + unit ~/ BigInt.two) ~/ unit).toDouble() / 10;
  }

  static double epochProgress(int slot, int slotsPerEpoch) =>
      slotsPerEpoch > 0 ? slot.clamp(0, slotsPerEpoch) / slotsPerEpoch : 0;

  static ({BigInt days, int hours, int minutes})? epochTimeRemaining({
    required int slot,
    required int slotsPerEpoch,
    required int slotDurationMs,
  }) {
    if (slot < 0 || slotsPerEpoch <= 0 || slotDurationMs <= 0) return null;
    final slots = slotsPerEpoch - slot.clamp(0, slotsPerEpoch);
    // Keep products and division exact even for malformed, very large inputs.
    final minutes =
        BigInt.from(slots) *
        BigInt.from(slotDurationMs) ~/
        BigInt.from(Duration.millisecondsPerMinute);
    return (
      days: minutes ~/ BigInt.from(Duration.minutesPerDay),
      hours:
          (minutes ~/
                  BigInt.from(Duration.minutesPerHour) %
                  BigInt.from(Duration.hoursPerDay))
              .toInt(),
      minutes: (minutes % BigInt.from(Duration.minutesPerHour)).toInt(),
    );
  }

  /// APR is a percentage; positive estimates are truncated to four decimals.
  static String? estimateRewards({
    required num balance,
    required num apr,
    required num days,
  }) {
    if (!balance.isFinite ||
        !apr.isFinite ||
        !days.isFinite ||
        balance < 0 ||
        apr < 0 ||
        days < 0)
      return null;
    final product =
        Decimal.parse(balance.toString()) *
        Decimal.parse(apr.toString()) *
        Decimal.parse(days.toString());
    final scaled = (product.shift(4) / Decimal.fromInt(100 * DAYS_PER_YEAR))
        .floor();
    return Decimal.fromBigInt(scaled).shift(-4).toString();
  }
}
