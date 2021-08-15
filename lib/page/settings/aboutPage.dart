import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/common/components/browserLink.dart';
import 'package:auro_wallet/common/components/iconBrowserLink.dart';
import 'package:auro_wallet/common/components/normalButton.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/settings/settings.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class AboutPage extends StatefulWidget {
  AboutPage(this.store);

  final AppStore store;

  static final String route = '/profile/about';

  @override
  _AboutPage createState() => _AboutPage();
}

class _AboutPage extends State<AboutPage> {

  @override
  Widget build(BuildContext context) {
    final Map i18n = I18n.of(context).main;
    var theme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: AppBar(
        title: Text(i18n['about']!),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Observer(
          builder: (_) {
            AboutUsData? aboutus = widget.store.settings!.aboutus;
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Image.asset('assets/images/assets/2x/mina_round_logo@2x.png', width: 65, height: 65,),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                        i18n['walletName']!,
                        style: theme.headline3!.copyWith(color: ColorsUtil.hexColor(0x000000))
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text('$app_version', style: theme.headline5!.copyWith(color: ColorsUtil.hexColor(0x999999))),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 27, vertical: 20),
                  child: Text(i18n['walletAbout']!, style: theme.headline5!.copyWith(color: ColorsUtil.hexColor(0x000000), height: 1.3)),
                ),
                aboutus != null ? Padding(
                  padding: EdgeInsets.only(top: 70, left: 27, right: 27),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                          i18n['versionInfo']!,
                          style: theme.headline5!.copyWith(color: ColorsUtil.hexColor(0x999999))
                      ),
                      BrowserLink(aboutus.changelog, text: aboutus.gitReponame, showIcon: false,),
                    ],
                  ),
                ): Container(),
                aboutus != null ? Padding(
                  padding: EdgeInsets.only(top: 8, left: 27, right: 27),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                          i18n['followUs']!,
                          style: theme.headline5!.copyWith(color: ColorsUtil.hexColor(0x999999))
                      ),
                      Row(
                        children: [
                          aboutus.website != null ? IconBrowserLink(aboutus.website!.website, icon: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 9),
                            child: Image.asset('assets/images/setting/website.png', width: 16),
                          )) : Container(),
                          aboutus.twitter != null ? IconBrowserLink(aboutus.twitter!.website, icon: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 9),
                            child: Image.asset('assets/images/setting/twitter.png', width: 16),
                          )): Container(),
                          aboutus.telegram != null ? IconBrowserLink(aboutus.telegram!.website, icon: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 9),
                            child: Image.asset('assets/images/setting/telegram.png', width: 16),
                          )): Container(),
                          aboutus.wechat != null ? IconBrowserLink(aboutus.wechat!.website, icon: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 9),
                            child: Image.asset('assets/images/setting/wechat.png', width: 16),
                          )): Container(),
                        ],
                      ),
                    ],
                  ),
                ): Container(),
              ],
            );
          },
        ),
      ),
    );
  }
}
