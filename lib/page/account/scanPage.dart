import 'dart:async'; // For Platform.isX

import 'package:auro_wallet/common/components/backgroundContainer.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/assets/transfer/transferPage.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanPage extends StatefulWidget {
  const ScanPage();
  static final String route = '/account/scan';
  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> with WidgetsBindingObserver {
  final AppStore store = globalAppStore;
  StateSetter? stateSetter;
  bool isFlashLight = false;

  final MobileScannerController controller = MobileScannerController(
    autoStart: false,
  );
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(controller.start());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!controller.value.hasCameraPermission) {
      return;
    }

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;
      case AppLifecycleState.resumed:
        unawaited(controller.start());
      case AppLifecycleState.inactive:
        unawaited(controller.stop());
    }
  }

  @override
  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    await controller.dispose();
  }

  QRCodeAddressResult? _processQRCodeData(String data, AppLocalizations dic) {
    List<String> ls = data.split(':');
    String address = '';
    String chainType = '';

    if (ls.length > 0) {
      if (ls.length > 1) {
        if (ls[0].toLowerCase() != 'mina' || !Fmt.isAddress(ls[1])) {
          UI.toast(dic.notValidAddress);
        } else {
          chainType = ls[0];
          address = ls[1];
        }
      } else {
        if (!Fmt.isAddress(ls[0])) {
          UI.toast(dic.notValidAddress);
        } else {
          address = ls[0];
        }
      }
    }

    if (address.length > 0) {
      print('address detected in Qr');
      return QRCodeAddressResult(address: address, chainType: chainType);
    }
    return null;
  }

  Future _onScan(String? txt) async {
    final params =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    bool isScanWc = params?['isScanWc'] ?? false;

    if (txt == null) {
      return;
    }
    AppLocalizations dic = AppLocalizations.of(context)!;
    String address = '';
    String chainType = '';
    final String data = txt.trim();

    if (isScanWc && data.length > 0) {
      if (data.startsWith("wc:")) {
        Navigator.of(context)
            .pop(QRCodeAddressResult(address: data, chainType: chainType));
        return;
      } else {
        QRCodeAddressResult? res = _processQRCodeData(data, dic);
        if (res != null) {
          await store.assets!.setNextToken(store.assets!.mainTokenNetInfo);
          Navigator.of(context).pushReplacementNamed(TransferPage.route,
              arguments: {"isFromModal": true, "address": res.address});
          return;
        }
      }
    } else {
      QRCodeAddressResult? res = _processQRCodeData(data, dic);
      if (res != null) {
        Navigator.of(context)
            .pop(QRCodeAddressResult(address: address, chainType: chainType));
      }
    }
  }

  void _handleBarcode(BarcodeCapture barcodes) {
    if (mounted) {
      if (barcodes.barcodes.isNotEmpty) {
        final firstBarcode = barcodes.barcodes.first;
        if (firstBarcode.displayValue != null) {
          controller.stop();
          _onScan(firstBarcode.displayValue);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;
    final scanWindowHeight = 260.0;
    final scanWindowTop = (screenHeight - scanWindowHeight) / 2;
    final textTop = scanWindowTop + scanWindowHeight + 50.0;
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: null,
        body: BackgroundContainer(
          AssetImage(
            'assets/images/public/scan_bg.png',
          ),
          Stack(
            children: [
              MobileScanner(
                key: qrKey,
                controller: controller,
                onDetect: _handleBarcode,
                scanWindow: Rect.fromCenter(
                  center: MediaQuery.of(context).size.center(Offset.zero),
                  width: 260,
                  height: 260,
                ),
              ),
              QRScannerOverlay(overlayColour: Color.fromRGBO(0, 0, 0, 0.4)),
              AppBar(
                title: Text(
                  dic.scan,
                  style: TextStyle(color: Colors.white),
                ),
                centerTitle: true,
                backgroundColor: Colors.transparent,
                iconTheme: IconThemeData(
                  color: Colors.white,
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: textTop,
                child: Center(
                  child: Container(
                    width: 260,
                    child: Text(
                      dic.scanTip,
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 100,
                child: Center(
                  child: StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return MaterialButton(
                          child: SvgPicture.asset(
                            "assets/images/public/icon_flashlight.svg",
                            width: 40,
                            height: 40,
                            colorFilter: ColorFilter.mode(
                              isFlashLight
                                  ? Theme.of(context).primaryColor
                                  : Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                          onPressed: () {
                            controller.toggleTorch();
                            setState(() {
                              isFlashLight = !isFlashLight;
                            });
                          });
                    },
                  ),
                ),
              ),
            ],
          ),
          fit: BoxFit.cover,
        ));
  }
}

class QRCodeAddressResult {
  QRCodeAddressResult({required this.chainType, required this.address});
  final String chainType;
  final String address;
}

class QRScannerOverlay extends StatelessWidget {
  const QRScannerOverlay({Key? key, required this.overlayColour})
      : super(key: key);

  final Color overlayColour;

  @override
  Widget build(BuildContext context) {
    double scanArea = 260.0;
    return Stack(children: [
      ColorFiltered(
        colorFilter: ColorFilter.mode(
            overlayColour, BlendMode.srcOut), // This one will create the magic
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                  color: Color(0xFF594AF1),
                  backgroundBlendMode: BlendMode
                      .dstOut), // This one will handle background + difference out
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                height: scanArea,
                width: scanArea,
                decoration: BoxDecoration(
                  color: Color(0xFF594AF1),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
      Align(
        alignment: Alignment.center,
        child: CustomPaint(
          foregroundPainter: BorderPainter(),
          child: SizedBox(
            width: scanArea + 25,
            height: scanArea + 25,
          ),
        ),
      ),
    ]);
  }
}

class BorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const width = 4.0;
    const radius = 20.0;
    const tRadius = 3 * radius;
    final rect = Rect.fromLTWH(
      width,
      width,
      size.width - 2 * width,
      size.height - 2 * width,
    );
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(radius));
    const clippingRect0 = Rect.fromLTWH(
      0,
      0,
      tRadius,
      tRadius,
    );
    final clippingRect1 = Rect.fromLTWH(
      size.width - tRadius,
      0,
      tRadius,
      tRadius,
    );
    final clippingRect2 = Rect.fromLTWH(
      0,
      size.height - tRadius,
      tRadius,
      tRadius,
    );
    final clippingRect3 = Rect.fromLTWH(
      size.width - tRadius,
      size.height - tRadius,
      tRadius,
      tRadius,
    );

    final path = Path()
      ..addRect(clippingRect0)
      ..addRect(clippingRect1)
      ..addRect(clippingRect2)
      ..addRect(clippingRect3);

    canvas.clipPath(path);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Color(0xFF594AF1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = width,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
