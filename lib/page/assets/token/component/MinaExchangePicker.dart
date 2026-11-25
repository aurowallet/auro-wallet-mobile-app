import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/service/minaExchanges.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Shares the exchange sheet between the home entry and the token Buy action.
/// The owner keys this widget by account and node to close stale sheets.
class MinaExchangePicker extends StatefulWidget {
  const MinaExchangePicker({
    super.key,
    required this.exchanges,
    required this.builder,
  });

  final List<MinaExchange> exchanges;
  final Widget Function(BuildContext context, VoidCallback open) builder;

  @override
  State<MinaExchangePicker> createState() => _MinaExchangePickerState();
}

class _MinaExchangePickerState extends State<MinaExchangePicker> {
  late final _exchanges = ValueNotifier(widget.exchanges);

  @override
  void didUpdateWidget(covariant MinaExchangePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The modal is in another route; update it after the owner's build ends.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _exchanges.value = widget.exchanges;
    });
  }

  ModalRoute<void>? _sheet;
  bool _isOpening = false;

  @override
  void dispose() {
    final sheet = _sheet;
    // A native bottom sheet lives outside this widget's subtree.
    if (sheet != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (sheet.isActive) sheet.navigator?.removeRoute(sheet);
      });
    }
    _exchanges.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    if (_isOpening || widget.exchanges.isEmpty) return;
    _isOpening = true;

    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        showDragHandle: false,
        backgroundColor: Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
        builder: (context) {
          _sheet = ModalRoute.of<void>(context);
          final dic = AppLocalizations.of(context)!;
          return SafeArea(
            top: false,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.7,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 20, right: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            dic.getMinaFrom,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xCC000000),
                            ),
                          ),
                        ),
                        IconButton(
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                          onPressed: () => Navigator.pop(context),
                          tooltip: MaterialLocalizations.of(
                            context,
                          ).closeButtonTooltip,
                          icon: SvgPicture.asset(
                            'assets/images/public/icon_nav_close.svg',
                            width: 24,
                            height: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    height: 0.5,
                    thickness: 0.5,
                    color: Color(0x1A000000),
                  ),
                  Flexible(
                    child: ValueListenableBuilder<List<MinaExchange>>(
                      valueListenable: _exchanges,
                      builder: (context, exchanges, _) => ListView.separated(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: exchanges.length,
                        separatorBuilder: (_, __) => const Divider(
                          height: 0.5,
                          thickness: 0.5,
                          color: Color(0x1A000000),
                        ),
                        itemBuilder: (context, index) {
                          final exchange = exchanges[index];
                          final description = exchange.descriptionFor(
                            Localizations.localeOf(context).toLanguageTag(),
                          );
                          return InkWell(
                            onTap: () => UI.launchURL(exchange.url),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              child: Row(
                                children: [
                                  _ExchangeIcon(exchange: exchange),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          exchange.name,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black,
                                          ),
                                        ),
                                        if (description.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            description,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF808080),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  SvgPicture.asset(
                                    'assets/images/assets/icon_link.svg',
                                    width: 16,
                                    height: 16,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } finally {
      _sheet = null;
      _isOpening = false;
    }
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _open);
}

class _ExchangeIcon extends StatelessWidget {
  const _ExchangeIcon({required this.exchange});
  final MinaExchange exchange;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      color: const Color(0xFFEDEFF2),
      child: Text(
        exchange.name.characters.take(1).toString(),
        style: const TextStyle(fontSize: 14, color: Color(0xFF808080)),
      ),
    );
    final isSvg = Uri.parse(
      exchange.iconUrl,
    ).path.toLowerCase().endsWith('.svg');
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: isSvg
          ? SvgPicture.network(
              exchange.iconUrl,
              width: 30,
              height: 30,
              placeholderBuilder: (_) => placeholder,
              errorBuilder: (_, __, ___) => placeholder,
            )
          : Image.network(
              exchange.iconUrl,
              width: 30,
              height: 30,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => placeholder,
            ),
    );
  }
}
