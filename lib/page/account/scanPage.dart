import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:auro_wallet/common/components/backgroundContainer.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_code_tools/qr_code_tools.dart';
import 'dart:io'; // For Platform.isX
import 'dart:async'; // For Platform.isX
import 'package:rxdart/rxdart.dart';
import 'package:image_picker/image_picker.dart';



class ScanPage extends StatefulWidget {
  const ScanPage();
  static final String route = '/account/scan';
  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? _controller;
  StreamSubscription? _subscription;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      _controller?.pauseCamera();
    } else if (Platform.isIOS) {
      _controller?.resumeCamera();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    _controller = controller;
    _listen();
  }
  void _listen () {
     _subscription  = _controller?.scannedDataStream.listen((scanData) {
      _onScan(scanData.code);
    });
  }

  Future<bool> canOpenCamera() async {
    var status = await PermissionHandler().checkPermissionStatus(PermissionGroup.camera);
    if (status != PermissionStatus.granted) {
      var future = await PermissionHandler()
          .requestPermissions([PermissionGroup.camera]);
      for (final item in future.entries) {
        if (item.value != PermissionStatus.granted) {
          return false;
        }
      }
    }
    return true;
  }

  void _getQrByGallery() {
    final ImagePicker _picker = ImagePicker();
    Stream<XFile?>.fromFuture(
        _picker.pickImage(source: ImageSource.gallery))
        .flatMap((XFile? file) {
          if (file != null) {
            return Stream<String>.fromFuture(
              QrCodeToolsPlugin.decodeFrom(file.path),
            );
          }
          return Stream<String>.value('');
    }).listen((String data) {
      if (data.isNotEmpty) {
        _onScan(data);
      }
    }).onError((dynamic error, dynamic stackTrace) {
    });
  }
  Future _onScan(String? txt) async {
    if (txt == null) {
      return;
    }
    _subscription?.cancel();
    final Map<String, String> dic = I18n.of(context).main;
    String address = '';
    String chainType = '';
    final String data = txt.trim();
    List<String> ls = data.split(':');
    if (ls.length > 0) {
      if (ls.length > 1) {
        if (ls[0].toLowerCase() != 'mina' || !Fmt.isAddress(ls[1])) {
          UI.toast(dic['notValidAddress']!);
        } else {
          chainType = ls[0];
          address = ls[1];
        }
      } else {
        if (!Fmt.isAddress(ls[0])) {
          UI.toast(dic['notValidAddress']!);
        } else {
          address = ls[0];
        }
      }
    }
    if (address.length > 0) {
      print('address detected in Qr');
      Navigator.of(context).pop(QRCodeAddressResult(address: address, chainType: chainType));
    } else {
      _listen();
    }
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: null,
      body: BackgroundContainer(
        AssetImage(
          'assets/images/public/scan_bg.png',
        ),
        FutureBuilder<bool>(
          future: canOpenCamera(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.hasData && snapshot.data == true) {
              return Stack(
                children: [
                  Column(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: QRView(
                          key: _qrKey,
                          onQRViewCreated: _onQRViewCreated,
                          overlay: QrScannerOverlayShape(
                            borderColor: Colors.white,
                            overlayColor : const Color.fromRGBO(0, 0, 0, 80),
                          ),
                        ),
                      ),
                      // Expanded(
                      //   flex: 1,
                      //   child: Center(
                      //     child: (_result != null)
                      //         ? Text(
                      //         'Barcode Type: ${_result?.format}   Data: ${_result?.code}')
                      //         : Text('Scan a code'),
                      //   ),
                      // )
                    ],
                  ),
                  AppBar(
                    title: Text(I18n.of(context).main['scan']!, style: TextStyle(color: Colors.white),),
                    centerTitle: true,
                    backgroundColor: Colors.transparent,
                    iconTheme: IconThemeData(
                      color: Colors.white, //change your color here
                    ),
                  ),
                  Positioned(
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(0, 0, 0, 80),
                          borderRadius:  BorderRadius.circular(40),
                        ),
                        child: IconButton(
                          color: Colors.white,
                          icon: Icon(Icons.photo_album, color: Colors.white,),
                          onPressed: _getQrByGallery,
                        ),
                      ),
                    right: 20,
                    bottom: 40,
                  )
                ],
              );
            } else {
              return Container();
            }
          },
        ),
        fit: BoxFit.cover,
      )
    );
  }
}

class QRCodeAddressResult {
  QRCodeAddressResult({required this.chainType,required this.address});
  final String chainType;
  final String address;
}
