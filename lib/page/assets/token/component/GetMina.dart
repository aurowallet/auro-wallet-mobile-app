import 'package:auro_wallet/common/consts/network.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/service/minaExchanges.dart';
import 'package:auro_wallet/page/assets/token/component/MinaExchangePicker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Keyed by account, network and node by the parent, matching the extension's
/// display lifetime. Once visible, keep the displayed providers until it resets.
class GetMina extends StatefulWidget {
  const GetMina({
    super.key,
    required this.config,
    required this.networkID,
    required this.address,
    required this.balance,
    required this.isLoading,
  });

  final MinaExchangesConfig? config;
  final String networkID;
  final String address;
  final String? balance;
  final bool isLoading;

  @override
  State<GetMina> createState() => _GetMinaState();
}

class _GetMinaState extends State<GetMina> {
  List<MinaExchange>? _displayed;
  @override
  Widget build(BuildContext context) {
    final exchanges = widget.config?.available ?? <MinaExchange>[];
    if (_displayed == null &&
        widget.networkID == networkIDMap.mainnet &&
        widget.address.isNotEmpty &&
        !widget.isLoading &&
        BigInt.tryParse(widget.balance ?? '') == BigInt.zero &&
        exchanges.isNotEmpty) {
      _displayed = List.unmodifiable(exchanges);
    }
    if (_displayed == null) return const SizedBox.shrink();
    return MinaExchangePicker(
      exchanges: _displayed!,
      builder: (context, open) => Material(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: open,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/images/assets/icon_buy.svg',
                  width: 16,
                  height: 16,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    AppLocalizations.of(context)!.getMina,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.25,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF594AF1),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
