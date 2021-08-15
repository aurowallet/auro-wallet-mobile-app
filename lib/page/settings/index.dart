import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:auro_wallet/common/components/formPanel.dart';
import 'package:auro_wallet/page/settings/aboutPage.dart';
import 'package:auro_wallet/page/settings/localesPage.dart';
import 'package:auro_wallet/page/settings/currenciesPage.dart';
import 'package:auro_wallet/page/settings/RemoteNodeListPage.dart';
import 'package:auro_wallet/page/account/termPage.dart';
import 'package:auro_wallet/store/wallet/types/accountData.dart';
import 'package:auro_wallet/store/wallet/types/walletData.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/wallet/types/walletData.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auro_wallet/page/settings/security/securityPage.dart';
import 'package:auro_wallet/page/settings/contactListPage.dart';
import 'package:url_launcher/url_launcher.dart';

class Profile extends StatelessWidget {
  Profile(this.store);

  final AppStore store;


  @override
  Widget build(BuildContext context) {
    final Map<String, String> i18n = I18n.of(context).main;
    var languageCode = store.settings!.localeCode.isNotEmpty ? store.settings!.localeCode : I18n.of(context).locale.languageCode.toLowerCase();
    var aboutUsData = store.settings!.aboutus;
    return Observer(builder: (_) {
      WalletData acc = store.wallet!.currentWallet;
      Color primaryColor = Theme.of(context).primaryColor;
      return Scaffold(
        appBar: AppBar(
          title: Text(i18n['setting']!, style: TextStyle(color: Colors.white, fontSize: 20),),
          centerTitle: true,
          elevation: 0.0,
          backgroundColor: primaryColor,
        ),
        backgroundColor: Colors.white,
        body: ListView(
          children: <Widget>[
            FormPanel(
              margin: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      width: 28,
                      child: SvgPicture.asset(
                          'assets/images/setting/security.svg',
                          width: 28,
                          height: 28
                      ),
                    ),
                    minLeadingWidth: 0,
                    title: Text(i18n['security']!),
                    trailing: Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () => Navigator.of(context).pushNamed(SecurityPage.route),
                  ),
                  ListTile(
                    leading: Container(
                      width: 28,
                      child: SvgPicture.asset(
                          'assets/images/setting/network.svg',
                          width: 28,
                          height: 28
                      ),
                    ),
                    minLeadingWidth: 0,
                    title: Text(i18n['network']!),
                    trailing: Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () => Navigator.of(context).pushNamed(RemoteNodeListPage.route),
                  ),
                  ListTile(
                    leading: Container(
                      width: 28,
                      child: SvgPicture.asset(
                          'assets/images/setting/locale.svg',
                          width: 28,
                          height: 28
                      ),
                    ),
                    minLeadingWidth: 0,
                    title: Text(i18n['language']!),
                    trailing: Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () => Navigator.of(context).pushNamed(LocalesPage.route),
                  ),
                  ListTile(
                    leading: Container(
                      width: 28,
                      child: SvgPicture.asset(
                          'assets/images/setting/usd.svg',
                          width: 28,
                          height: 28
                      ),
                    ),
                    minLeadingWidth: 0,
                    title: Text(i18n['currency']!),
                    trailing: Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () => Navigator.of(context).pushNamed(CurrenciesPage.route),
                  ),
                  ListTile(
                    leading: Container(
                      width: 28,
                      child: SvgPicture.asset(
                          'assets/images/setting/contact.svg',
                          width: 28,
                          height: 28
                      ),
                    ),
                    minLeadingWidth: 0,
                    title: Text(i18n['addressbook']!),
                    trailing: Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () => Navigator.of(context).pushNamed(ContactListPage.route),
                  ),
                ],
              ),
            ),
            FormPanel(
              margin: EdgeInsets.symmetric(horizontal: 30, vertical: 0),
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
              child: Column(
                  children: [
                    ListTile(
                      leading: Container(
                        width: 28,
                        child: SvgPicture.asset(
                            'assets/images/setting/aboutus.svg',
                            width: 28,
                            height: 28
                        ),
                      ),
                      minLeadingWidth: 0,
                      title: Text(i18n['about']!),
                      trailing: Icon(Icons.arrow_forward_ios, size: 18),
                      onTap: () => Navigator.of(context).pushNamed(AboutPage.route),
                    ),
                    ListTile(
                      leading: Container(
                        width: 28,
                        child: SvgPicture.asset(
                            'assets/images/public/terms.svg',
                            width: 28,
                            height: 28
                        ),
                      ),
                      minLeadingWidth: 0,
                      title: Text(i18n['userAgree']!),
                      trailing: Icon(Icons.arrow_forward_ios, size: 18),
                      onTap: ()  {
                        var termsUrl = '';
                        if (aboutUsData != null) {
                          switch(languageCode) {
                            case 'en':
                              termsUrl = aboutUsData.termsAndContionsEN;
                              break;
                            case 'zh':
                              termsUrl = aboutUsData.termsAndContionsZH;
                              break;
                          }
                        }
                        launch(termsUrl);
                      },
                    ),
                    ListTile(
                      leading: Container(
                        width: 28,
                        child: SvgPicture.asset(
                            'assets/images/public/privacy.svg',
                            width: 28,
                            height: 28
                        ),
                      ),
                      minLeadingWidth: 0,
                      title: Text(i18n['privacy']!),
                      trailing: Icon(Icons.arrow_forward_ios, size: 18),
                      onTap: ()  {
                        var termsUrl = '';
                        if (aboutUsData != null) {
                          switch(languageCode) {
                            case 'en':
                              termsUrl = aboutUsData.privacyPolicyEN;
                              break;
                            case 'zh':
                              termsUrl = aboutUsData.privacyPolicyZH;
                              break;
                          }
                        }
                        launch(termsUrl);
                      },
                    ),
                  ]),
            ),

          ],
        ),
      );
    });
  }
}
