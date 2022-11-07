import 'package:flutter/material.dart';
import 'package:auro_wallet/common/components/browserLink.dart';
import 'package:auro_wallet/common/components/iconBrowserLink.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/store/settings/settings.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    final Map i18nSettings = I18n.of(context).settings;
    var theme = Theme.of(context).textTheme;
    var languageCode = widget.store.settings!.localeCode.isNotEmpty ? widget.store.settings!.localeCode : I18n.of(context).locale.languageCode.toLowerCase();
    var aboutUsData = widget.store.settings!.aboutus;
    var termsUrl = '';
    var privacyUrl = '';
    if (aboutUsData != null) {
      switch(languageCode) {
        case 'en':
          termsUrl = aboutUsData.termsAndContionsEN;
          privacyUrl = aboutUsData.privacyPolicyEN;
          break;
        case 'zh':
          termsUrl = aboutUsData.termsAndContionsZH;
          privacyUrl = aboutUsData.privacyPolicyZH;
          break;
      }
    }
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: AppBar(
        title: Text(i18n['about']!),
        centerTitle: true,
      ),
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: Observer(
          builder: (_) {
            AboutUsData? aboutus = widget.store.settings!.aboutus;
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 55, bottom: 10),
                  child: Image.asset('assets/images/setting/setting_logo.png', width: 72, height: 72,),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                        i18n['walletName']!,
                        style: TextStyle(fontSize:18, fontWeight: FontWeight.w500, color: Colors.black)
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Text('$app_version', style: TextStyle(fontSize:14, fontWeight: FontWeight.w400, color: Colors.black.withOpacity(0.5))),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10, right: 30, left: 30),
                  child: Text(i18n['walletAbout']!, style: TextStyle(fontSize:14, fontWeight: FontWeight.w400, color: ColorsUtil.hexColor(0x000000), height: 1.3)),
                ),
                Container(
                  margin: EdgeInsets.only(top: 52),
                  child: BrowserLink(termsUrl, text: i18n['userAgree']!, showIcon: false,),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10),
                  child: BrowserLink(privacyUrl, text: i18n['privacy']!, showIcon: false,),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10),
                  child: BrowserLink(privacyUrl, text: i18nSettings['github']!, showIcon: false,),
                ),
                Container(
                  padding: EdgeInsets.only(top: 40, bottom: 23),
                  child: Text(
                      i18n['followUs']!,
                      style: TextStyle(
                          fontSize: 12,
                          color: Color(0x80000000)
                      )
                  ),
                ),
                aboutus != null ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      children: [
                        aboutus.website != null ? SocialItem(
                          name: 'Website',
                          link: aboutus.website!.website,
                          icon: 'assets/images/setting/website.svg',
                        ) : Container(),
                        SizedBox(width: 20,),
                        aboutus.website != null ? SocialItem(
                          name: 'Twitter',
                          link: aboutus.twitter!.website,
                          icon: 'assets/images/setting/twitter.svg',
                        ) : Container(),
                        SizedBox(width: 20,),
                        aboutus.website != null ? SocialItem(
                          name: 'Telegram',
                          link: aboutus.telegram!.website,
                          image: Image.asset('assets/images/setting/telegram.png', width: 24, height: 24,),
                        ) : Container(),
                      ],
                    ),
                  ],
                ): Container(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class SocialItem extends StatelessWidget {
  SocialItem({required this.name, required this.link, this.icon, this.image});
  final String name;
  final String? icon;
  final String link;
  final Widget? image;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Color(0x1AC4C4C4),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Color(0x1A000000),
              width: 1
            )
          ),
          child: IconBrowserLink(link, icon: image ?? (icon != null ? SvgPicture.asset(icon!): Container())),
        ),
        SizedBox(height: 4),
        Text(
          name,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0x80000000),
            height: 1.4
          ),
        )
      ],
    );
  }
}