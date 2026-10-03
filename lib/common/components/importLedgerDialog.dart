import 'dart:async';

import 'package:auro_wallet/common/components/customStyledText.dart';
import 'package:auro_wallet/common/components/loadingCircle.dart';
import 'package:auro_wallet/common/consts/enums.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/ledgerMina/ledger_error.dart';
import 'package:auro_wallet/ledgerMina/ledger_error_message.dart';
import 'package:auro_wallet/ledgerMina/mina_ledger_application.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/ledger/ledger.dart';
import 'package:auro_wallet/store/wallet/wallet.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/utils/ledgerInit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ledger_flutter/ledger_flutter.dart';
import 'package:auro_wallet/utils/screenAwake.dart';

class ImportLedger extends StatefulWidget {
  ImportLedger(
      {this.generateAddress = false,
      this.accountIndex,
      this.accountName,
      this.password = "",
      this.initialLedgerFailure});

  final bool generateAddress;
  final int? accountIndex;
  final String? accountName;
  final String password;
  final LedgerFailureType? initialLedgerFailure;

  @override
  _ImportLedgerState createState() => new _ImportLedgerState();
}

enum _AddressRequestState { idle, pending, closed }

class _ImportLedgerState extends State<ImportLedger> {
  final store = globalAppStore;
  bool connected = false;
  LedgerFailureType? connectionFailure;
  _AddressRequestState addressRequest = _AddressRequestState.idle;
  Ledger? _addressLedger;
  LedgerDevice? _addressDevice;

  bool get _isActive => mounted &&
      ModalRoute.of(context)?.isCurrent != false;

  @override
  void initState() {
    super.initState();
    connectionFailure = widget.initialLedgerFailure;
  }

  Future<void> _closeAddressSession() async {
    if (addressRequest != _AddressRequestState.pending) return;
    addressRequest = _AddressRequestState.closed;
    final ledger = _addressLedger;
    final device = _addressDevice;
    if (ledger == null || device == null) return;
    await store.ledger!.disconnectSession(ledger, device);
  }

  void _closeDialog() {
    if (!_isActive) return;
    unawaited(_closeAddressSession());
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    unawaited(_closeAddressSession());
    super.dispose();
  }

  Future<void> onConnected(VoidCallback onSessionHandoff) async {
    if (!_isActive) return;
    final ledger = store.ledger!.ledgerInstance;
    final device = store.ledger!.ledgerDevice;
    if (ledger == null || device == null) return;
    bool isCurrent() => _isActive &&
        identical(store.ledger!.ledgerInstance, ledger) &&
        identical(store.ledger!.ledgerDevice, device);
    setState(() {
      connectionFailure = null;
      addressRequest = _AddressRequestState.idle;
    });
    try {
      await MinaLedgerApp(ledger).ensureMinaAppReadyWithRetry(
        device,
        isCurrent: isCurrent,
      );
    } catch (error) {
      // Transport cleanup can clear the failed device before this continuation.
      // Still show its error, but never update a replacement session's dialog.
      if (!_isActive ||
          !identical(store.ledger!.ledgerInstance, ledger) ||
          (store.ledger!.ledgerDevice != null &&
              !identical(store.ledger!.ledgerDevice, device))) return;
      final failure = classifyLedgerError(error);
      _onConnectionFailure(failure);
      if (failure == LedgerFailureType.other ||
          failure.isPairingFailure) {
        try {
          await ledger.disconnect(device);
        } catch (error, stackTrace) {
          ledgerErrorLog('Ledger stale-session disconnect', error,
              stackTrace: stackTrace);
        }
        if (!_isActive ||
            !identical(store.ledger!.ledgerInstance, ledger) ||
            (store.ledger!.ledgerDevice != null &&
                !identical(store.ledger!.ledgerDevice, device))) return;
        if (identical(store.ledger!.ledgerDevice, device)) {
          store.ledger!.setDevice(null);
        }
      }
      store.ledger!.setLedgerStatus(LedgerStatusTypes.unavailable);
      return;
    }
    if (!isCurrent()) return;
    store.ledger!.setLedgerStatus(LedgerStatusTypes.available);
    onSessionHandoff();
    setState(() {
      connected = true;
      addressRequest = widget.generateAddress
          ? _AddressRequestState.pending : _AddressRequestState.idle;
    });
    if (!widget.generateAddress) {
      Navigator.of(context).pop(true);
    } else {
      final accountIndex = widget.accountIndex;
      final accountName = widget.accountName;
      if (accountIndex == null || accountName == null) {
        addressRequest = _AddressRequestState.idle;
        UI.toast(AppLocalizations.of(context)!.buildFailed);
        Navigator.of(context).pop(false);
        return;
      }
      _addressLedger = ledger;
      _addressDevice = device;
      List<String> accounts = const [];
      Object? accountFailure;
      try {
        final minaApp = MinaLedgerApp(ledger, accountIndex: accountIndex);
        accounts = await minaApp.getAccounts(device);
      } catch (error, stackTrace) {
        ledgerErrorLog('Ledger address import GET_PUBLIC_KEY', error,
            stackTrace: stackTrace);
        accountFailure = error;
      }
      if (addressRequest == _AddressRequestState.closed) return;
      addressRequest = _AddressRequestState.idle;
      if (!_isActive ||
          !identical(store.ledger!.ledgerInstance, ledger) ||
          (store.ledger!.ledgerDevice != null &&
              !identical(store.ledger!.ledgerDevice, device))) return;
      if (accountFailure == null &&
          !identical(store.ledger!.ledgerDevice, device)) return;
      if (accountFailure != null || accounts.isEmpty) {
        final failure = accountFailure == null
            ? LedgerFailureType.other : classifyLedgerError(accountFailure);
        if (failure == LedgerFailureType.appNotOpen) {
          if (_isActive) {
            setState(() {
              connected = false;
              connectionFailure = failure;
            });
          }
          store.ledger!.setLedgerStatus(LedgerStatusTypes.unavailable);
          return;
        }
        if (_isActive) {
          AppLocalizations dic = AppLocalizations.of(context)!;
          final message = ledgerFailureMessage(dic, failure);
          UI.toast(message);
          Navigator.of(context).pop(false);
        }
        return;
      }
      var isSuccess = await webApi.account.createExternalWallet(
          accountName, accounts[0],
          context: context,
          source: WalletSource.outside,
          seedType: WalletStore.seedTypeLedger,
          hdIndex: accountIndex,
          password: widget.password);
      if (!_isActive) {
        return;
      }
      Navigator.of(context).pop(isSuccess == true);
    }
  }

  void _onConnectionFailure(LedgerFailureType failure) {
    if (!_isActive) return;
    store.ledger!.lastFailure = failure;
    store.ledger!.setLedgerStatus(LedgerStatusTypes.unavailable);
    if (failure == LedgerFailureType.rejected) {
      setState(() { connectionFailure = null; });
      UI.toast(AppLocalizations.of(context)!.ledgerReject);
      return;
    }
    setState(() {
      connectionFailure = failure;
    });
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    final showGenerateAddress = widget.generateAddress && connected;
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
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(dic.connectHardwareWallet,
                              style: TextStyle(
                                  color: Color(0xFF222222),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            child: SvgPicture.asset(
                                'assets/images/public/icon_nav_close.svg',
                                width: 24,
                                height: 24,
                                colorFilter: ColorFilter.mode(
                                    Colors.black, BlendMode.srcIn)),
                            onTap: _closeDialog,
                          )
                        ],
                      )),
                  Container(
                    height: 0.5,
                    color: Color(0xFF000000).withValues(alpha: 0.1),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 18).copyWith(top: 20),
                    child: showGenerateAddress
                        ? LedgerGetAddress()
                        : ConnectLedger(
                            onConnected: this.onConnected,
                            onConnectionFailure: _onConnectionFailure,
                            failure: connectionFailure,
                          ),
                  )
                ],
              ),
            ],
          ),
        ));
  }
}

class LedgerGetAddress extends StatefulWidget {
  LedgerGetAddress();

  @override
  _LedgerGetAddressState createState() => new _LedgerGetAddressState();
}

class _LedgerGetAddressState extends State<LedgerGetAddress> {
  @override
  void initState() {
    super.initState();
    ScreenAwake.acquire(ScreenAwakeKeys.ledgerGetAddress)
        .catchError((e) => debugPrint('ScreenAwake.acquire failed: $e'));
  }

  @override
  void dispose() {
    ScreenAwake.release(ScreenAwakeKeys.ledgerGetAddress)
        .catchError((e) => debugPrint('ScreenAwake.release failed: $e'));
    super.dispose();
  }

  @override
  Widget build(context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    return Wrap(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                dic.ledgerAddressTip1,
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    height: 1.2,
                    fontWeight: FontWeight.w400),
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Text(
            "Get Address > Generate > Approve",
            style: TextStyle(
                fontSize: 14,
                color: Colors.black,
                height: 1.2,
                fontWeight: FontWeight.w700),
          ),
        ),
        CustomStyledText(
            text: dic.ledgerAddressTip3,
            style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                height: 1.2,
                fontWeight: FontWeight.w400)),
        Padding(
          padding: EdgeInsets.only(top: 26),
          child: Center(
            child: SvgPicture.asset('assets/images/ledger/ledger_mina.svg',
                width: 200,
                height: 43,
                colorFilter: ColorFilter.mode(
                    Theme.of(context).primaryColor, BlendMode.srcIn)),
          ),
        )
      ],
    );
  }
}

class ConnectLedger extends StatefulWidget {
  ConnectLedger({
    required this.onConnected,
    this.onConnectionFailure,
    this.failure,
  });

  final Future<void> Function(VoidCallback onSessionHandoff) onConnected;
  final void Function(LedgerFailureType failure)? onConnectionFailure;
  final LedgerFailureType? failure;

  bool get requiresUserAction => failure?.requiresConnectionAction ?? false;

  @override
  _ConnectLedgerState createState() => _ConnectLedgerState();
}

enum _LedgerScanFailure { notFound, unavailable }

class _ConnectLedgerState extends State<ConnectLedger> {
  final store = globalAppStore;
  bool searching = true;
  bool connecting = false;
  bool connectionHandedOff = false;
  LedgerDevice? ledgerDevice;
  Ledger? ledgerInstance;
  Timer? _reconnectTimer;
  Timer? _scanTimer;
  int _searchAttempt = 0;
  _LedgerScanFailure? _scanFailure;
  static const _scanTimeout = Duration(seconds: 15);
  int _connectAttempt = 0;
  static const int _maxConnectAttempts = 3;
  late final ScreenAwakeHandle _connectScreenAwakeHandle;

  bool get _isActive => mounted &&
      ModalRoute.of(context)?.isCurrent != false;

  bool get _hasActiveSession => ledgerDevice != null &&
      identical(store.ledger?.ledgerInstance, ledgerInstance) &&
      identical(store.ledger?.ledgerDevice, ledgerDevice);

  @override
  void initState() {
    super.initState();
    _connectScreenAwakeHandle = ScreenAwakeHandle(
      ScreenAwakeKeys.scoped('ledger_connect', this),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isActive) return;
      if (store.ledger?.ledgerDevice == null) {
        _scanDevice();
      } else {
        setState(() {
          searching = false;
          ledgerDevice = store.ledger?.ledgerDevice;
          ledgerInstance = store.ledger?.ledgerInstance;
        });
        if (!widget.requiresUserAction) {
          unawaited(_checkExistingSession());
        }
      }
    });
  }

  @override
  void dispose() {
    _reconnectTimer?.cancel();
    _scanTimer?.cancel();
    _searchAttempt++;
    if (connecting &&
        !connectionHandedOff &&
        ledgerDevice != null &&
        ledgerInstance != null) {
      unawaited(store.ledger!.disconnectSession(ledgerInstance!, ledgerDevice!));
    }
    _connectScreenAwakeHandle.setActive(false)
        .catchError((e) => debugPrint('ScreenAwake release failed: $e'));
    unawaited(LedgerInit.stopScanLoop(ledger: ledgerInstance));
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ConnectLedger oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.requiresUserAction && !oldWidget.requiresUserAction) {
      _reconnectTimer?.cancel();
      _reconnectTimer = null;
      _connectAttempt = 0;
    }
  }

  Future<void> _checkExistingSession() async {
    if (!_isActive || connecting || !_hasActiveSession) return;
    setState(() {
      connecting = true;
      connectionHandedOff = false;
    });
    try {
      await _connectScreenAwakeHandle.setActive(true);
      await widget.onConnected(() {
        connectionHandedOff = true;
      });
    } finally {
      // A failed session is removed from the Store by its owner. Keep the
      // selected device here so its real name remains the manual retry target.
      if (_isActive && !connectionHandedOff) {
        setState(() {
          connecting = false;
        });
      }
      await _connectScreenAwakeHandle.setActive(false);
    }
  }

  void _connect() async {
    _reconnectTimer?.cancel();
    final ledger = ledgerInstance;
    final device = ledgerDevice;
    if (ledger == null || device == null) return;
    bool isCurrent() => _isActive &&
        identical(store.ledger?.ledgerInstance, ledger) &&
        (store.ledger?.ledgerDevice == null ||
            identical(store.ledger?.ledgerDevice, device));
    if (!isCurrent()) return;
    setState(() {
      connecting = true;
      connectionHandedOff = false;
    });
    _connectAttempt++;
    try {
      await _connectScreenAwakeHandle.setActive(true);
      await LedgerInit.stopScanLoop(ledger: ledger);
      await Future.delayed(const Duration(milliseconds: 500));
      if (!isCurrent()) return;
      await ledger.connect(device);
      if (!isCurrent()) {
        await store.ledger!.disconnectSession(ledger, device);
        return;
      }
      store.ledger!.setDevice(device);
      await widget.onConnected(() {
        connectionHandedOff = true;
      });
      _connectAttempt = 0;
      await _connectScreenAwakeHandle.setActive(false);
      if (!_isActive) return;
      setState(() {
        connecting = false;
      });
    } catch (e, stackTrace) {
      ledgerErrorLog('Ledger BLE connect', e, stackTrace: stackTrace);
      if (connectionHandedOff) {
        await _connectScreenAwakeHandle.setActive(false);
        return;
      }
      if (!isCurrent()) return;
      final ledgerFailure = classifyLedgerError(e);
      if (ledgerFailure != LedgerFailureType.other &&
          !ledgerFailure.isPairingFailure) {
        widget.onConnectionFailure?.call(ledgerFailure);
        _reconnectTimer?.cancel();
        _reconnectTimer = null;
        _connectAttempt = 0;
        await _connectScreenAwakeHandle.setActive(false);
        if (_isActive) {
          setState(() {
            connecting = false;
          });
        }
        return;
      }
      try {
        await ledger.disconnect(device);
      } catch (error, disconnectStackTrace) {
        ledgerErrorLog(
          'Ledger BLE connect cleanup',
          error,
          stackTrace: disconnectStackTrace,
        );
      }
      if (!isCurrent()) return;
      if (ledgerFailure.isPairingFailure) {
        store.ledger!.setDevice(null);
        await _connectScreenAwakeHandle.setActive(false);
        if (!_isActive) return;
        setState(() {
          connecting = false;
        });
        _connectAttempt = 0;
        widget.onConnectionFailure?.call(ledgerFailure);
      } else if (_connectAttempt < _maxConnectAttempts) {
        _reconnectTimer = Timer(const Duration(seconds: 1), () {
          if (_isActive) _connect();
        });
      } else {
        store.ledger!.setDevice(null);
        store.ledger!.setLedgerStatus(LedgerStatusTypes.unavailable);
        widget.onConnectionFailure?.call(LedgerFailureType.other);
        await _connectScreenAwakeHandle.setActive(false);
        if (!_isActive) return;
        setState(() {
          searching = false;
          connecting = false;
        });
        _connectAttempt = 0;
      }
    } finally {
      if (!isCurrent() && !connectionHandedOff) {
        await _connectScreenAwakeHandle.setActive(false);
        if (_isActive) setState(() { connecting = false; });
      }
    }
  }

  void _stopSearchWithError(int attempt, _LedgerScanFailure failure) {
    if (!_isActive || attempt != _searchAttempt || !searching) return;
    _scanTimer?.cancel();
    _searchAttempt++;
    setState(() {
      searching = false;
      _scanFailure = failure;
    });
    unawaited(LedgerInit.stopScanLoop(ledger: ledgerInstance).catchError(
      (Object error) => ledgerErrorLog('Ledger search cleanup', error),
    ));
  }

  void _scanDevice() async {
    if (!_isActive || (widget.requiresUserAction && ledgerDevice != null)) return;
    final attempt = ++_searchAttempt;
    _scanTimer?.cancel();
    setState(() {
      searching = true;
      _scanFailure = null;
    });
    _scanTimer = Timer(_scanTimeout, () {
      _stopSearchWithError(attempt, _LedgerScanFailure.notFound);
    });
    bool isCurrent() => _isActive && attempt == _searchAttempt;
    try {
      final ledger = await LedgerInit.init();
      if (!isCurrent()) return;
      ledgerInstance = ledger;
      // UI state can lose its device reference while the transport still owns
      // a ready session. Verify that session instead of requiring a new advert.
      final connected = ledger.devices;
      if (connected.length == 1 &&
          identical(store.ledger?.ledgerInstance, ledger) &&
          store.ledger?.ledgerDevice == null) {
        _scanTimer?.cancel();
        _searchAttempt++;
        final device = connected.single;
        store.ledger!.setDevice(device);
        setState(() {
          ledgerDevice = device;
          searching = false;
        });
        if (!widget.requiresUserAction) {
          unawaited(_checkExistingSession());
        }
        return;
      }
      await LedgerInit.scanLoop(
        ledger,
        onScanSuccess: (device) {
          if (!isCurrent()) return;
          _scanTimer?.cancel();
          _searchAttempt++;
          setState(() {
            ledgerDevice = device;
            searching = false;
            _scanFailure = null;
          });
        },
        onScanError: (_) =>
            _stopSearchWithError(attempt, _LedgerScanFailure.unavailable),
        onScanDone: () =>
            _stopSearchWithError(attempt, _LedgerScanFailure.unavailable),
      );
    } catch (error, stackTrace) {
      if (!isCurrent()) return;
      ledgerErrorLog('Ledger search startup', error, stackTrace: stackTrace);
      _stopSearchWithError(attempt, _LedgerScanFailure.unavailable);
    }
  }

  Widget renderError() {
    AppLocalizations dic = AppLocalizations.of(context)!;
    final errorStr = _scanFailure != null ||
            widget.failure == LedgerFailureType.other
        ? dic.ledgerConnectionError
        : ledgerFailureMessage(dic, widget.failure!);
    return Container(
      margin: EdgeInsets.only(top: 35),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Color(0xFFD65A5A).withValues(alpha: 0.1),
        border: Border.all(color: Color(0xFFD65A5A), width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      width: double.infinity,
      child: Text(
        errorStr,
        style: TextStyle(
            color: Color(0xFFD65A5A),
            fontSize: 14,
            fontWeight: FontWeight.w400),
      ),
    );
  }

  @override
  Widget build(context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    final isError = !connecting && (_scanFailure != null ||
        (widget.failure != null && widget.failure != LedgerFailureType.rejected));
    return Wrap(
      children: [
        LedgerTipItem(
            num: '1', text: dic.ledgerTip1),
        LedgerTipItem(
          num: '2',
          text: dic.ledgerTip2,
        ),
        LedgerTipItem(
          num: '3',
          text: dic.ledgerTip3,
        ),
        if (isError) renderError(),
        ValueListenableBuilder<LedgerDevice?>(
          valueListenable: store.ledger!.pairingDevice,
          builder: (context, pairingDevice, _) {
            if (!connecting || pairingDevice == null ||
                !identical(pairingDevice, ledgerDevice)) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(dic.loading,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF666666))),
            );
          },
        ),
        Padding(
          padding: EdgeInsets.only(top: isError ? 20 : 49, left: 0, right: 0),
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
                minimumSize: Size(double.infinity, 40),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                // alignment: Alignment.centerLeft,
                side: BorderSide(
                  color: Color.fromRGBO(0, 0, 0, 0.10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 10),
                backgroundColor: Color(0xFFF9FAFC)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ledgerDevice == null
                      ? (searching ? dic.ledgerSearching : dic.retry)
                      : ledgerDevice!.name,
                  style: TextStyle(color: Colors.black, fontSize: 14),
                ),
                connecting || (!isError && searching)
                    ? RotatingCircle(size: 20)
                    : Container()
              ],
            ),
            onPressed: () {
              if (ledgerDevice == null && !searching && !connecting) {
                _scanDevice();
              } else if (ledgerDevice != null && !connecting) {
                if (_hasActiveSession) {
                  _checkExistingSession();
                } else {
                  _connect();
                }
              }
              // _onClick('import');
            },
          ),
        ),
      ],
    );
  }
}

class LedgerTipItem extends StatelessWidget {
  LedgerTipItem({required this.num, required this.text, this.descText = ""});

  final String num;
  final String text;
  final String descText;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(bottom: 20),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Color(0xFF594AF1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                num,
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    height: 1.33,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Container(
            width: 8,
          ),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomStyledText(
                  text: text,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      height: 1.4,
                      fontWeight: FontWeight.w400)),
              descText != ""
                  ? (Container(
                      child: CustomStyledText(
                        text: descText,
                        style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFD65A5A),
                            height: 1.33,
                            fontWeight: FontWeight.w400),
                      ),
                    ))
                  : Container(),
            ],
          )),
        ]));
  }
}
