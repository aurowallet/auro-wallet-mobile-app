import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/store/assets/types/fees.dart';
import 'package:flutter/material.dart';

class FeeButtonGroup extends StatelessWidget {
  const FeeButtonGroup({
    Key? key,
    required this.fees,
    required this.currentFeeText,
    required this.fallbackFee,
    required this.onSelectFee,
  }) : super(key: key);

  final Fees fees;
  final String currentFeeText;
  final double fallbackFee;
  final ValueChanged<double> onSelectFee;

  String? _getSelectedFeeKey() {
    final currentValue =
        currentFeeText.isNotEmpty ? currentFeeText : fallbackFee.toString();
    final parsed = double.tryParse(currentValue);
    if (parsed == null) return null;
    if (parsed == fees.slow) return 'slow';
    if (parsed == fees.medium) return 'medium';
    if (parsed == fees.fast) return 'fast';
    return null;
  }

  Widget _buildFeeButton(String label, double fee, String key, Color bgColor,
      Color selectedBorderColor, String? selectedKey) {
    final isSelected = selectedKey == key;
    return GestureDetector(
      onTap: () => onSelectFee(fee),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? selectedBorderColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    final selectedKey = _getSelectedFeeKey();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildFeeButton(
          dic.fee_slow,
          fees.slow,
          'slow',
          Colors.black.withValues(alpha: 0.3),
          Color(0xFF808080),
          selectedKey,
        ),
        SizedBox(width: 6),
        _buildFeeButton(
          dic.fee_default,
          fees.medium,
          'medium',
          Color(0xFF0DB27C),
          Color(0xFF008056),
          selectedKey,
        ),
        SizedBox(width: 6),
        _buildFeeButton(
          dic.fee_fast,
          fees.fast,
          'fast',
          Color(0xFFD65A5A),
          Color(0xFF963E3E),
          selectedKey,
        ),
      ],
    );
  }
}
