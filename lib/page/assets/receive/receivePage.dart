import 'package:auro_wallet/common/components/customStyledText.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:dotted_line/dotted_line.dart';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';

class ReceivePage extends StatelessWidget {
  ReceivePage(this.store);

  static final String route = '/assets/receive';
  final AppStore store;
  final GlobalKey _globalKey = GlobalKey();

  void _onShare() async {
    RenderRepaintBoundary? boundary =
        _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    var pngBytes = byteData!.buffer.asUint8List();
    Directory tempDir = await getTemporaryDirectory();
    String storagePath = tempDir.path;
    var path = '$storagePath/${store.wallet!.currentAddress}.png';
    File file = File(path);
    if (!file.existsSync()) {
      file.createSync();
    }
    file.writeAsBytesSync(pngBytes);
    final result = await Share.shareXFiles([XFile(path)], text: store.wallet!.currentAddress);
    if (result.status == ShareResultStatus.success) {
        print('Sharing success!');
    }
  }

  @override
  Widget build(BuildContext context) {

    String tokenSymbol = COIN.coinSymbol;
    dynamic args = ModalRoute.of(context)!.settings.arguments;
    if (args != null &&
        args['isFromRoute'] == true &&
        args['tokenSymbol'] != null) {
      tokenSymbol = args['tokenSymbol'];
    }
    String currentAddress = store.wallet!.currentAddress;
    String firstPart = currentAddress.substring(0, currentAddress.length - 6);
    String lastPart = currentAddress.substring(currentAddress.length - 6);

    String codeAddress = store.wallet!.currentAddress;
    AppLocalizations dic = AppLocalizations.of(context)!;
    var theme = Theme.of(context).textTheme;
    var textButtonStyle = TextButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        foregroundColor: Theme.of(context).primaryColor,
        textStyle: TextStyle(color: Colors.black));
    return RepaintBoundary(
        key: _globalKey,
        child: Scaffold(
          backgroundColor: Color(0xFF594AF1),
          appBar: AppBar(
            leading: null,
            title: null,
            toolbarHeight: 0,
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            actions: null,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.dark,
            ),
          ),
          body: SafeArea(
            maintainBottomViewPadding: true,
            child: Stack(
              children: [
                Positioned(
                  child: Image.asset('assets/images/receive/dot2.png',
                      width: 303, height: 595),
                  left: 0,
                  top: -20,
                ),
                Positioned(
                  child: Image.asset('assets/images/receive/dot1.png',
                      width: 251, height: 340),
                  right: 0,
                  bottom: 0,
                ),
                Column(
                  children: [
                    AppBar(
                      iconTheme: IconThemeData(
                        color: Colors.white, //change your color here
                      ),
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      title: Text(
                        dic.receive,
                        style: TextStyle(color: Colors.white),
                      ),
                      centerTitle: true,
                    ),
                    Expanded(
                      child: ListView(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(
                                top: 10, left: 20, right: 20, bottom: 0),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                  top: 0,
                                  bottom: 0,
                                ),
                                Positioned(
                                  top: 51,
                                  left: 9,
                                  right: 9,
                                  child: Container(
                                    height: 18,
                                    color: Colors.white,
                                    alignment: Alignment.center,
                                    child: DottedLine(
                                      dashColor: Color(0x1A000000),
                                      dashLength: 3,
                                      dashGapLength: 3,
                                    ),
                                  ),
                                ),
                                Container(
                                  // color: Colors.white,
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        padding: EdgeInsets.all(0),
                                        height: 60,
                                        alignment: Alignment.center,
                                        child: Text(
                                          dic.scantopay,
                                          style: theme.headlineSmall!.copyWith(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              height: 1,
                                              color: Colors.black),
                                        ),
                                      ),
                                      Container(
                                          padding: EdgeInsets.only(
                                              top: 30, bottom: 10),
                                          alignment: Alignment.center,
                                          child: CustomStyledText(
                                            text: dic.addressQrTip(tokenSymbol),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: Color(0x80000000),
                                            ),
                                          )),
                                      Container(
                                        decoration: BoxDecoration(),
                                        margin: EdgeInsets.only(top: 22),
                                        child: QrImageView(
                                          data: codeAddress,
                                          padding: EdgeInsets.zero,
                                          size: 150,
                                          embeddedImage: AssetImage(
                                              'assets/images/setting/setting_logo.png'),
                                          embeddedImageStyle:
                                              QrEmbeddedImageStyle(
                                                  size: Size(36, 36)),
                                        ),
                                      ),
                                      Container(
                                          padding: EdgeInsets.only(
                                              left: 40, right: 40, top: 22),
                                          child: RichText(
                                            text: TextSpan(
                                              text: firstPart,
                                              style: theme.headlineSmall!.copyWith(
                                                color: Colors.black,
                                                height: 1.3,
                                                fontSize: 14,
                                              ),
                                              children: <InlineSpan>[
                                                WidgetSpan(
                                                  alignment:
                                                      PlaceholderAlignment
                                                          .baseline,
                                                  baseline:
                                                      TextBaseline.alphabetic,
                                                  child: Text(
                                                    lastPart,
                                                    style: theme.headlineSmall!
                                                        .copyWith(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      height: 1.3,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )),
                                      Container(
                                        margin: EdgeInsets.only(top: 30),
                                        height: 1,
                                        color: Colors.black.withValues(alpha: 0.05),
                                      ),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                                child: SizedBox(
                                              height: 48,
                                              child: TextButton(
                                                style: textButtonStyle,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    SvgPicture.asset(
                                                      'assets/images/receive/icon_share.svg',
                                                    ),
                                                    SizedBox(
                                                      width: 13,
                                                    ),
                                                    Text(dic.share,
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600))
                                                  ],
                                                ),
                                                onPressed: _onShare,
                                              ),
                                            )),
                                            Container(
                                              width: 0.5,
                                              height: 48,
                                              color:
                                                  Colors.black.withValues(alpha: 0.1),
                                            ),
                                            Expanded(
                                              child: SizedBox(
                                                height: 48,
                                                child: TextButton(
                                                  style: textButtonStyle,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      SvgPicture.asset(
                                                        'assets/images/receive/icon_copy.svg',
                                                      ),
                                                      SizedBox(
                                                        width: 13,
                                                      ),
                                                      Text(dic.copy,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600))
                                                    ],
                                                  ),
                                                  onPressed: () {
                                                    UI.copyAndNotify(
                                                        context,
                                                        store.wallet!
                                                            .currentAddress);
                                                  },
                                                ),
                                              ),
                                            )
                                          ]),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 33),
                            child: SvgPicture.asset(
                              'assets/images/assets/icon_mina.svg',
                              width: 119,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'aurowallet.com',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5), fontSize: 14),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}

class InvertedCircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return new Path()
      ..addOval(new Rect.fromCircle(center: new Offset(0, 69), radius: 9))
      ..addOval(
          new Rect.fromCircle(center: new Offset(size.width, 69), radius: 9))
      ..addRect(new Rect.fromLTWH(0.0, 0, size.width, size.height))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
