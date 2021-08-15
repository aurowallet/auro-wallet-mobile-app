import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/common/components/normalButton.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:flutter/rendering.dart';
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
        child: BackgroundContainer(
            AssetImage("assets/images/assets/2x/top_header_bg@2x.png"),
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                iconTheme: IconThemeData(
                  color: Colors.white, //change your color here
                ),
                backgroundColor: Colors.transparent,
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
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(top: 32),
                            child: Image.asset(
                                'assets/images/public/2x/mina_text_logo@2x.png',
                                width: 63,
                                height: 57
                            ),
                          ),
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
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Powered by Bit Cat', style: TextStyle(color: ColorsUtil.hexColor(0xb9b9b9), fontSize: 14),),
                    )
                  ],
                ),
              ),
            )
        )
    );
  }
}
