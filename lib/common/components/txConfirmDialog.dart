import 'package:auro_wallet/common/components/TimerManager.dart';
import 'package:auro_wallet/common/components/ledgerWaitingContent.dart';
import 'package:auro_wallet/common/components/ledgerStatusView.dart';
import 'package:auro_wallet/common/components/networkStatusView.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/ledgerMina/ledger_error.dart';
import 'package:auro_wallet/page/browser/components/zkAppBottomButton.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/utils/screenAwake.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart' show SvgPicture;

enum TxItemTypes { showTimer }

class TxItem {
  TxItem({required this.label, required this.value, this.showTimer = false});

  final String label;
  final String value;
  final bool showTimer;
}

class TxConfirmDialog extends StatefulWidget {
  TxConfirmDialog({
    required this.items,
    required this.title,
    this.onConfirm,
    this.disabled = false,
    this.isLedger = false,
    this.ledgerZkApp = false,
    this.buttonText,
    this.headerLabel,
    this.headerValue,
    this.timerManager,
  });

  final List<TxItem> items;
  final String title;
  final String? headerLabel;
  final Widget? headerValue;
  final String? buttonText;
  final bool disabled;
  final bool isLedger;
  final bool ledgerZkApp;
  final Future<dynamic> Function(bool Function() onLedgerInteraction)?
      onConfirm;
  final TimerManager? timerManager;

  final store = globalAppStore;

  @override
  _TxConfirmDialogState createState() => new _TxConfirmDialogState();
}

class _TxConfirmDialogState extends State<TxConfirmDialog> {
  bool submitting = false;
  bool checkingLedger = false;
  bool ledgerInteractionStarted = false;
  late final ScreenAwakeHandle _ledgerScreenAwakeHandle;

  Future<void> _setLedgerScreenAwake(bool active) async {
    if (!widget.isLedger) {
      return;
    }
    await _ledgerScreenAwakeHandle.setActive(active);
  }

  @override
  void initState() {
    super.initState();
    _ledgerScreenAwakeHandle = ScreenAwakeHandle(
      ScreenAwakeKeys.scoped('tx_confirm_ledger', this),
    );
  }

  @override
  void dispose() {
    _setLedgerScreenAwake(false)
        .catchError((e) => debugPrint('ScreenAwake release failed: $e'));
    super.dispose();
  }

  Widget renderHead(String headerLabel, Widget headerValue) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Center(
        child: Column(
          children: [
            Text(
              headerLabel,
              style: TextStyle(
                  color: const Color(0x80000000),
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ),
            headerValue
          ],
        ),
      ),
    );
  }

  bool _onLedgerInteraction() {
    if (!mounted || ModalRoute.of(context)?.isCurrent == false) return false;
    setState(() => ledgerInteractionStarted = true);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    final showLedgerConfirm =
        submitting && widget.isLedger && ledgerInteractionStarted;
    return Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(12),
              topLeft: Radius.circular(12),
            )),
        padding: EdgeInsets.only(left: 0, top: 8, right: 0, bottom: 16),
        child: SafeArea(
          child: Stack(
            children: [
              Wrap(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(showLedgerConfirm ? dic.waitingLedger : widget.title,
                            style: TextStyle(
                                color: Color(0xFF222222),
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                        showLedgerConfirm
                            ? GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => Navigator.pop(context),
                                child: SvgPicture.asset(
                                    'assets/images/public/icon_nav_close.svg',
                                    width: 24,
                                    height: 24,
                                    colorFilter: ColorFilter.mode(
                                        Colors.black, BlendMode.srcIn)),
                              )
                            : Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    widget.isLedger
                                        ? LedgerStatusView()
                                        : Container(),
                                    SizedBox(width: 4),
                                    NetworkStatusView()
                                  ],
                                ),
                              )
                      ],
                    ),
                  ),
                  Container(
                    height: 0.5,
                    color: Color(0xFF000000).withValues(alpha: 0.1),
                  ),
                  widget.headerLabel != null &&
                          widget.headerValue != null &&
                          !showLedgerConfirm
                      ? this
                          .renderHead(widget.headerLabel!, widget.headerValue!)
                      : Container(),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Wrap(
                      children: [
                        ...(showLedgerConfirm
                            ? [LedgerWaitingContent(zkApp: widget.ledgerZkApp)]
                            : widget.items.map((e) {
                                return TxConfirmItem(
                                    data: e, timerManager: widget.timerManager);
                              }).toList()),
                      ],
                    ),
                  ),
                  if (!showLedgerConfirm)
                    ZkAppBottomButton(
                      disabled: widget.disabled,
                      confirmBtnText: widget.buttonText ?? dic.confirm,
                      onConfirm: () async {
                        if (!mounted || submitting || checkingLedger) return;
                        if (widget.isLedger) {
                          setState(() {
                            checkingLedger = true;
                          });
                          try {
                            if (!await UI.ensureLedgerReady(
                                context: context,
                                ledgerStore: widget.store.ledger!,
                                stage:
                                    'Ledger transaction confirmation readiness'))
                              return;
                          } finally {
                            if (mounted) setState(() => checkingLedger = false);
                          }
                        }
                        if (!mounted) return;
                        setState(() {
                          submitting = true;
                        });
                        try {
                          await _setLedgerScreenAwake(true);
                          if (!mounted ||
                              ModalRoute.of(context)?.isCurrent == false)
                            return;
                          if (widget.onConfirm != null) {
                            await widget.onConfirm!(_onLedgerInteraction);
                          }
                        } catch (error, stackTrace) {
                          if (!widget.isLedger || !widget.ledgerZkApp) rethrow;
                          ledgerErrorLog(
                            'Ledger token transaction confirmation',
                            error,
                            stackTrace: stackTrace,
                          );
                          if (mounted) UI.toast(dic.buildFailed);
                        } finally {
                          if (mounted) {
                            setState(() {
                              submitting = false;
                              ledgerInteractionStarted = false;
                            });
                          }
                          await _setLedgerScreenAwake(false);
                        }
                      },
                      submitting: submitting || checkingLedger,
                    )
                ],
              ),
            ],
          ),
        ));
  }
}

class TxConfirmItem extends StatelessWidget {
  TxConfirmItem({required this.data, this.timerManager});

  final TxItem data;
  final TimerManager? timerManager;

  @override
  Widget build(BuildContext context) {
    String text = data.value;
    return Padding(
        padding: EdgeInsets.only(top: 28),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            // width: 85,
            child: Text(
              data.label,
              style: TextStyle(
                  fontSize: 14,
                  color: Color(0x80000000),
                  height: 1.33,
                  fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            height: 4,
          ),
          Row(
            children: [
              Flexible(
                  child: Text(text,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          height: 1.33,
                          fontWeight: FontWeight.w500))),
              (data.showTimer && timerManager != null)
                  ? CountdownTimer(timerManager: timerManager!)
                  : SizedBox(),
            ],
          )
        ]));
  }
}
