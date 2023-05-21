import 'package:auro_wallet/common/components/customStyledText.dart';
import 'package:auro_wallet/common/components/loadingCircle.dart';
import 'package:auro_wallet/ledgerMina/mina_ledger_application.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ledger_flutter/ledger_flutter.dart';

class ImportLedger extends StatefulWidget {
  ImportLedger();

  @override
  _ImportLedgerState createState() => new _ImportLedgerState();
}

class _ImportLedgerState extends State<ImportLedger> {
  final store = globalAppStore;
  bool searching = true;
  bool connecting = false;
  LedgerDevice? ledgerDevice;
  Ledger? ledgerInstance;

  @override
  void initState() {
    super.initState();
    _scanDevice();
  }

  void _connect() async {
    setState(() {
      connecting = true;
    });
    await ledgerInstance!.disconnect(ledgerDevice!);
    await ledgerInstance!.connect(ledgerDevice!);
    setState(() {
      connecting = false;
    });
    store.ledger!.setDevice(ledgerDevice);
    store.ledger!.setLedger(ledgerInstance);
    Navigator.of(context).pop(true);
  }

  void _scanDevice() async {
    ledgerInstance = await _initLedger();
    ledgerInstance!.stopScanning();
    if (ledgerInstance!.devices.length > 0) {
      ledgerDevice = ledgerInstance!.devices[0];
      searching = false;
    } else {
      ledgerInstance!.scan().listen((device) async {
        setState(() {
          ledgerDevice = device;
          searching = false;
        });
      });
    }
  }

  Future<Ledger> _initLedger() async {
    final options = LedgerOptions(
      maxScanDuration: const Duration(milliseconds: 5000),
    );

    final ledger = Ledger(
      options: options,
      // onPermissionRequest: (status) async {
      //   // Location was granted, now request BLE
      //   Map<Permission, PermissionStatus> statuses = await [
      //     Permission.bluetoothScan,
      //     Permission.bluetoothConnect,
      //     Permission.bluetoothAdvertise,
      //   ].request();
      //
      //   if (status != BleStatus.ready) {
      //     return false;
      //   }
      //
      //   return statuses.values.where((status) => status.isDenied).isEmpty;
      // },
    );
    await ledger.close(ConnectionType.ble);
    return ledger;
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic = I18n.of(context).ledger;
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
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    child: Text(dic['connectLedger']!,
                        style: TextStyle(
                            color: Color(0xFF222222),
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                  ),
                  Container(
                    height: 0.5,
                    color: Color(0xFF000000).withOpacity(0.1),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 18).copyWith(top: 40),
                    child: Wrap(
                      children: [
                        LedgerTipItem(
                          num: '1',
                          text: dic['ledgerTip1']!,
                        ),
                        LedgerTipItem(
                          num: '2',
                          text: dic['ledgerTip2']!,
                        ),
                        LedgerTipItem(
                          num: '3',
                          text: dic['ledgerTip3']!,
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 49, left: 0, right: 0),
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                                minimumSize: Size(double.infinity, 40),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                // alignment: Alignment.centerLeft,
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                backgroundColor: Color(0xFFF9FAFC)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  (ledgerDevice == null
                                      ? "Searching..."
                                      : ledgerDevice!.name),
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 14),
                                ),
                                connecting || searching
                                    ? RotatingCircle(size: 20)
                                    : Container()
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
                    ),
                  )
                ],
              ),
              Positioned(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  child: SvgPicture.asset(
                    'assets/images/public/icon_nav_close.svg',
                    width: 24,
                    height: 24,
                    color: Colors.black,
                  ),
                  onTap: () => Navigator.pop(context),
                ),
                top: 8,
                right: 20,
              ),
            ],
          ),
        ));
  }
}

class LedgerTipItem extends StatelessWidget {
  LedgerTipItem({required this.num, required this.text});

  final String num;
  final String text;

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
              child: CustomStyledText(
                  text: text,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      height: 1.4,
                      fontWeight: FontWeight.w400))),
        ]));
  }
}
