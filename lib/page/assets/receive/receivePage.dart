import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:auro_wallet/common/components/normalButton.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:auro_wallet/common/components/backgroundContainer.dart';
import 'package:auro_wallet/common/components/formPanel.dart';
import 'dart:ui' as ui;
import 'package:share/share.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';


class ReceivePage extends StatelessWidget {
  ReceivePage(this.store);

  static final String route = '/assets/receive';
  final AppStore store;
  GlobalKey _globalKey = new GlobalKey();

  void _onShare() async {
    RenderRepaintBoundary? boundary = _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    var pngBytes = byteData!.buffer.asUint8List();
    Directory tempDir = await getTemporaryDirectory();
    String storagePath = tempDir.path;
    var path = '$storagePath/${store.wallet!.currentAddress}.png';
    File file =File(path);
    if (!file.existsSync()) {
      file.createSync();
    }
    file.writeAsBytesSync(pngBytes);
    Share.shareFiles([path], text: store.wallet!.currentAddress);
  }
  @override
  Widget build(BuildContext context) {
    String codeAddress = store.wallet!.currentAddress;
    Color themeColor = Theme.of(context).primaryColor;
    var i18n = I18n.of(context).main;
    var theme = Theme.of(context).textTheme;
    return  RepaintBoundary(
        key: _globalKey,
        child: Scaffold(
          backgroundColor: Color(0xFF594AF1),
          appBar: AppBar(
            iconTheme: IconThemeData(
              color: Colors.white, //change your color here
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(i18n['receiveTitle']!, style: TextStyle(color: Colors.white),),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(Icons.share),
                onPressed: _onShare,
              )
            ],
          ),
          body: SafeArea(
            child: Stack(
              children: [
                Positioned(child: Image.asset(
                    'assets/images/receive/dot2.png',
                    width: 303,
                    height: 595
                ), left: 0, top: -50,),
                Positioned(child: Image.asset(
                    'assets/images/receive/dot1.png',
                    width: 251,
                    height: 340
                ), right: 0, bottom: 0,),
                Column(
                  children: [
                    Expanded(
                      child: ListView(
                        children: <Widget>[
                          FormPanel(
                            margin: EdgeInsets.only(top: 64, left: 28, right: 28, bottom: 20),
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(0),
                                  child: Text(
                                    i18n['addressQrTip']!,
                                    style: theme.headline6!.copyWith(
                                        color: ColorsUtil.hexColor(0x999999)
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(),
                                  margin: EdgeInsets.only(top: 10),
                                  child: QrImage(
                                    data: codeAddress,
                                    size: 200,
                                    embeddedImage: AssetImage('assets/images/assets/2x/mina_round_logo@2x.png'),
                                    embeddedImageStyle: QrEmbeddedImageStyle(size: Size(40, 40)),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(left: 16, right: 16, top: 15),
                                  child: Text(
                                    store.wallet!.currentAddress,
                                    textAlign: TextAlign.center,
                                    style: theme.headline6!.copyWith(
                                        color: ColorsUtil.hexColor(0x404040),
                                        height: 1.3
                                    ),
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width / 2,
                                  padding: EdgeInsets.only(top: 40, bottom: 10),
                                  child: NormalButton(
                                    text: i18n['copyAddress']!,
                                    onPressed: () => UI.copyAndNotify(
                                        context, store.wallet!.currentAddress),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 33),
                            child: Image.asset('assets/images/assets/card_logo.png', width: 119, height: 107,),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('aurowallet.com', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),),
                    )
                  ],
                ),
              ],
            ),
          ),
        )
    );
  }
}
