import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/common/components/backgroundContainer.dart';
import 'dart:async'; // For Platform.isX
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanPage extends StatefulWidget {
  const ScanPage();
  static final String route = '/account/scan';
  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> with WidgetsBindingObserver {
  StateSetter? stateSetter;
  IconData lightIcon = Icons.flash_on;

  final MobileScannerController controller = MobileScannerController();
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(controller.start());
  }

  @override
  void reassemble() {
    super.reassemble();
    controller.pause();
    super.reassemble();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _getQrByGallery() async {
    final ImagePicker _picker = ImagePicker();
    try {
      // Pick the image from gallery
      final XFile? file = await _picker.pickImage(source: ImageSource.gallery);

      if (file != null) {
        // Decode the QR code from the image
        final BarcodeCapture? barcodeCapture =
            await controller.analyzeImage(file.path);
        final String qrData = barcodeCapture?.barcodes.first.displayValue ?? "";

        if (qrData.isNotEmpty) {
          _onScan(qrData);
        }
      }
    } catch (e, stackTrace) {
      // Handle any errors that occur during the process
      print('Error picking or processing image: $e');
      print(stackTrace);
    }
  }

  Future _onScan(String? txt) async {
    if (txt == null) {
      return;
    }
    AppLocalizations dic = AppLocalizations.of(context)!;
    String address = '';
    String chainType = '';
    final String data = txt.trim();
    List<String> ls = data.split(':');
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
      Navigator.of(context)
          .pop(QRCodeAddressResult(address: address, chainType: chainType));
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
                onDetect: _handleBarcode,
                scanWindow: Rect.fromCenter(
                  center: MediaQuery.of(context)
                      .size
                      .center(Offset.zero),
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
                left: 60,
                bottom: 60,
                child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    stateSetter = setState;
                    return MaterialButton(
                        child: Icon(
                          lightIcon,
                          size: 40,
                          color: Theme.of(context).primaryColor,
                        ),
                        onPressed: () {
                          controller.toggleTorch();
                          if (lightIcon == Icons.flash_on) {
                            lightIcon = Icons.flash_off;
                          } else {
                            lightIcon = Icons.flash_on;
                          }
                          stateSetter!(() {});
                        });
                  },
                ),
              ),
              Positioned(
                right: 60,
                bottom: 60,
                child: MaterialButton(
                    child: Icon(
                      Icons.image,
                      size: 40,
                      color: Theme.of(context).primaryColor,
                    ),
                    onPressed: _getQrByGallery),
              )
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
