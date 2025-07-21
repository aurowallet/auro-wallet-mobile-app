import 'dart:async';

import 'package:auro_wallet/common/components/customStyledText.dart';
import 'package:auro_wallet/common/components/loadingCircle.dart';
import 'package:auro_wallet/common/consts/enums.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
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

class ImportLedger extends StatefulWidget {
  ImportLedger(
      {this.generateAddress = false,
      this.accountIndex,
      this.accountName,
      this.password = ""});

  final bool generateAddress;
  final int? accountIndex;
  final String? accountName;
  final String password;

  @override
  _ImportLedgerState createState() => new _ImportLedgerState();
}

class _ImportLedgerState extends State<ImportLedger> {
  final store = globalAppStore;
  bool connected = false;
  bool locked = false;
  bool minaNotOpened = false;

  @override
  void initState() {
    super.initState();
  }

  void onConnected() async {
    print('onConnected');
    final minaApp =
        MinaLedgerApp(store.ledger!.ledgerInstance!, accountIndex: 0);
    try {
      await minaApp.getVersion(store.ledger!.ledgerDevice!);
    } on LedgerException catch (e) {
      print(e.errorCode);
      print(e.message);
      switch (e.errorCode) {
        case 25873:
          setState(() {
            locked = false;
            minaNotOpened = true;
          });
          break;
        case 21781:
          setState(() {
            minaNotOpened = false;
            locked = true;
          });
          break;
      }
      print('returned');
      await store.ledger!.ledgerInstance!
          .disconnect(store.ledger!.ledgerDevice!);
      store.ledger!.setDevice(null);
      store.ledger!.setLedgerStatus(LedgerStatusTypes.unavailable);
      return;
    } on Exception catch (e) {
      setState(() {
        minaNotOpened = false;
        locked = true;
      });
      await store.ledger!.ledgerInstance!
          .disconnect(store.ledger!.ledgerDevice!);
      store.ledger!.setDevice(null);
      store.ledger!.setLedgerStatus(LedgerStatusTypes.unavailable);
      print('get version faield11');
      print(e);
      return;
    }
    store.ledger!.setLedgerStatus(LedgerStatusTypes.available);
    setState(() {
      connected = true;
    });
    if (!widget.generateAddress) {
      Navigator.of(context).pop(true);
    } else {
      final accountIndex = widget.accountIndex;
      final accountName = widget.accountName;
      if (accountIndex == null || widget.accountName == null) {
        return;
      }
      List<String>? accounts;
      try {
        final minaApp = MinaLedgerApp(store.ledger!.ledgerInstance!,
            accountIndex: accountIndex);
        print(minaApp);
        accounts = await minaApp.getAccounts(store.ledger!.ledgerDevice!);
      } on LedgerException catch (e) {
        print(e.errorCode);
        print(e.message);
        if (mounted) {
          AppLocalizations dic = AppLocalizations.of(context)!;
          UI.toast(dic.ledgerReject);
          Navigator.of(context).pop(false);
        }
        return;
      }
      if (accounts.length == 0) {
        return;
      }
      print('accounts');
      print(accounts[0]);
      var isSuccess = await webApi.account.createExternalWallet(
          accountName!, accounts[0],
          context: context,
          source: WalletSource.outside,
          seedType: WalletStore.seedTypeLedger,
          hdIndex: accountIndex,
          password: widget.password);
      if (isSuccess == true) {
        Navigator.of(context).pop(true);
      } else {
        Navigator.of(context).pop(false);
      }
    }
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
                            onTap: () => Navigator.pop(context),
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
                            locked: locked,
                            minaNotOpened: minaNotOpened,
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
  Widget build(context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    return Wrap(
      children: [
        Text(
          dic.ledgerAddressTip1,
          style: TextStyle(
              fontSize: 14,
              color: Colors.black,
              height: 1.2,
              fontWeight: FontWeight.w400),
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
    this.locked = false,
    this.minaNotOpened = false,
  });

  final void Function() onConnected;
  final bool locked;
  final bool minaNotOpened;

  @override
  _ConnectLedgerState createState() => _ConnectLedgerState();
}

class _ConnectLedgerState extends State<ConnectLedger> {
  final store = globalAppStore;
  bool searching = true;
  bool connecting = false;
  bool unactive = false;
  LedgerDevice? ledgerDevice;
  Ledger? ledgerInstance;
  StreamSubscription<LedgerDevice>? cancelScan;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (store.ledger?.ledgerDevice == null) {
        _scanDevice();
      } else {
        setState(() {
          searching = false;
          ledgerDevice = store.ledger?.ledgerDevice;
          ledgerInstance = store.ledger?.ledgerInstance;
        });
        widget.onConnected();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    LedgerInit.cancelScan?.cancel();
    LedgerInit.offScanListener();
  }

  void _connect() async {
    print('start connect');
    setState(() {
      connecting = true;
    });
    bool finishConnecting = false;
    Future.delayed(Duration(seconds: 6), () {
      if (mounted) {
        if (!finishConnecting) {
          print('reconnect');
          this._connect();
        }
      }
    });
    try {
      // await ledgerInstance!.stopScanning();
      // await ledgerInstance!.dispose();
      await ledgerInstance!.connect(ledgerDevice!);
      print('finish connect');
      setState(() {
        unactive = false;
        connecting = false;
      });
      finishConnecting = true;
    } on LedgerException catch (e) {
      await ledgerInstance!.disconnect(ledgerDevice!);
      store.ledger!.setDevice(null);
      print('connect error');
      print(e);
      setState(() {
        unactive = true;
        connecting = false;
      });
      finishConnecting = true;
      return;
    }
    store.ledger!.setDevice(ledgerDevice);
    widget.onConnected();
  }

  onScanSuccess(LedgerDevice device) async {
    print('scaned a device' + DateTime.now().toUtc().toString());
    setState(() {
      ledgerDevice = device;
      searching = false;
    });
  }

  Future<void> scan(Ledger ledger) async {
    print('start scan in import ledger dialog');
    if (!mounted) {
      return;
    }
    // await LedgerInit.dispose();
    LedgerInit.scanLoop(ledger, onScanSuccess: onScanSuccess);
    // await ledger.stopScanning();
  }

  void _scanDevice() async {
    ledgerInstance = await _initLedger();
    print('start scan' + DateTime.now().toUtc().toString());
    await this.scan(ledgerInstance!);
    // ledgerInstance!.statusStateChanges.listen((event) {
    //   print('statusStateChanges');
    //   print(event.name);
    //   print(ledgerInstance!.devices.length);
    // });
    // ledgerInstance!.deviceStateChanges.listen((event) {
    //   print('deviceStateChanges');
    //   print(event.connectionState);
    //   print(ledgerInstance!.devices.length);
    // });
  }

  Future<Ledger> _initLedger() async {
    final ledger = await LedgerInit.init();
    return ledger;
  }

  Widget renderError() {
    late String errorStr;
    AppLocalizations dic = AppLocalizations.of(context)!;
    if (unactive || widget.locked) {
      errorStr = dic.unlockLedger;
    }
    if (widget.minaNotOpened) {
      errorStr = dic.openMinaApp;
    }
    return Container(
      margin: EdgeInsets.only(top: 35),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Color(0xFFD65A5A).withValues(alpha: 0.1),
        border: Border.all(color: Color(0xFFD65A5A), width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
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
    bool isError = widget.locked || widget.minaNotOpened;
    return Wrap(
      children: [
        LedgerTipItem(
            num: '1', text: dic.ledgerTip1, descText: dic.ledgerSupport),
        LedgerTipItem(
          num: '2',
          text: dic.ledgerTip2,
        ),
        LedgerTipItem(
          num: '3',
          text: dic.ledgerTip3,
        ),
        isError ? this.renderError() : Container(),
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
                  (ledgerDevice == null
                      ? dic.ledgerSearching
                      : ledgerDevice!.name),
                  style: TextStyle(color: Colors.black, fontSize: 14),
                ),
                connecting || searching ? RotatingCircle(size: 20) : Container()
              ],
            ),
            onPressed: () {
              if (ledgerDevice != null) {
                _connect();
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
